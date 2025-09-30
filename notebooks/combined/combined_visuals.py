"""
Combined Visualizations for Syria Economic Monitor

This module provides visualization functions for displaying relationships
between GDP and various economic/environmental indicators includin    plt.tight_layout()
    plt.subplots_adjust(top=0.88, wspace=0.4)
    
    return fig2 levels, nighttime lights (NTL), and Enhanced Vegetation Index (EVI).
"""

import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import numpy as np
import altair as alt
from typing import Tuple, Dict
import altair as alt


def normalize_data(data: pd.Series) -> pd.Series:
    """Normalize data to 0-1 scale for comparison plotting."""
    return (data - data.min()) / (data.max() - data.min())


def create_three_part_gdp_line_charts(
    gdp_data: pd.DataFrame,
    no2_data: pd.DataFrame,
    ntl_data: pd.DataFrame, 
    evi_data: pd.DataFrame,
    year_column: str = 'year_int',
    gdp_column: str = 'GDP per capita (constant SYP)',
    no2_column: str = 'mean_no2',
    ntl_column: str = 'viirs_bm_mean',
    evi_column: str = 'EVI',
    chart_width: int = 400,
    chart_height: int = 300
) -> alt.Chart:
    """
    Create three interactive line charts showing GDP trends alongside NO2, NTL, and EVI using Altair.
    Uses dual axes without normalization, arranged as 2 charts in top row, 1 in bottom row.
    
    Parameters:
    -----------
    gdp_data : pd.DataFrame
        DataFrame containing GDP data with year and GDP columns
    no2_data : pd.DataFrame
        DataFrame containing NO2 pollution data
    ntl_data : pd.DataFrame
        DataFrame containing nighttime lights data
    evi_data : pd.DataFrame
        DataFrame containing Enhanced Vegetation Index data
    year_column : str, default 'year_int'
        Name of the year column in all datasets
    gdp_column : str, default 'GDP per capita (constant SYP)'
        Name of the GDP column
    no2_column : str, default 'mean_no2'
        Name of the NO2 column
    ntl_column : str, default 'viirs_bm_mean'
        Name of the NTL column
    evi_column : str, default 'EVI'
        Name of the EVI column
    chart_width : int, default 400
        Width of each chart
    chart_height : int, default 300
        Height of each chart
        
    Returns:
    --------
    alt.Chart
        Combined Altair chart with three panels in 2x2 layout
    """
    
    # Merge datasets with GDP
    gdp_no2 = pd.merge(gdp_data, no2_data, on=year_column, how='inner')
    gdp_ntl = pd.merge(gdp_data, ntl_data, on=year_column, how='inner')
    gdp_evi = pd.merge(gdp_data, evi_data, on=year_column, how='inner')
    
    # Calculate R-squared values for linear relationships
    def calculate_r_squared(x, y):
        """Calculate R-squared between two variables, handling missing values"""
        mask = ~(np.isnan(x) | np.isnan(y))
        x_clean = x[mask]
        y_clean = y[mask]
        
        if len(x_clean) < 2:
            return 0.0
        
        correlation = np.corrcoef(x_clean, y_clean)[0, 1]
        return correlation ** 2 if not np.isnan(correlation) else 0.0
    
    # Calculate R-squared for each relationship (only for GDP, not population)
    r2_no2 = 0.0
    r2_ntl = 0.0
    r2_evi = 0.0
    
    if 'GDP' in gdp_column or 'gdp' in gdp_column.lower():
        if not gdp_no2.empty:
            r2_no2 = calculate_r_squared(gdp_no2[gdp_column].values, gdp_no2[no2_column].values)
        if not gdp_ntl.empty:
            r2_ntl = calculate_r_squared(gdp_ntl[gdp_column].values, gdp_ntl[ntl_column].values)
        if not gdp_evi.empty:
            r2_evi = calculate_r_squared(gdp_evi[gdp_column].values, gdp_evi[evi_column].values)
    
    # Define color scheme
    colors = ['#2E8B57', '#DC143C', '#FF8C00', '#4169E1']
    
    def create_dual_axis_chart(merged_df, indicator_col, indicator_name, title, gdp_color, indicator_color):
        if merged_df.empty:
            # Create empty chart with message
            return alt.Chart(pd.DataFrame({'x': [0], 'y': [0], 'text': ['No overlapping data']})).mark_text(
                fontSize=16,
                color='gray'
            ).encode(
                x=alt.X('x:Q', scale=alt.Scale(domain=[0, 1]), axis=None),
                y=alt.Y('y:Q', scale=alt.Scale(domain=[0, 1]), axis=None),
                text='text:N'
            ).properties(
                width=chart_width,
                height=chart_height,
                title=alt.TitleParams(text=title, fontSize=14, anchor='start')
            )
        
        # Determine the y-axis title based on the column name
        if 'GDP' in gdp_column or 'gdp' in gdp_column.lower():
            y_axis_title = 'GDP (LCU)'
            variable_name = 'GDP (LCU)'
        elif 'pop' in gdp_column.lower() or 'population' in gdp_column.lower():
            y_axis_title = 'Population'
            variable_name = 'Population'
        else:
            y_axis_title = gdp_column.replace('_', ' ').title()
            variable_name = y_axis_title
        
        # Create selection for legend interaction
        legend_selection = alt.selection_point(fields=['variable'], bind='legend')
        
        # GDP line (left axis)
        gdp_line = alt.Chart(merged_df).mark_line(
            color=gdp_color,
            strokeWidth=3,
            point=alt.OverlayMarkDef(size=80, filled=True)
        ).encode(
            x=alt.X(f'{year_column}:O', title='Year', axis=alt.Axis(labelAngle=45)),
            y=alt.Y(f'{gdp_column}:Q', 
                   title=y_axis_title,
                   scale=alt.Scale(zero=False)),
            tooltip=[f'{year_column}:O', f'{gdp_column}:Q', f'{indicator_col}:Q']
        ).add_params(legend_selection).transform_calculate(
            variable=f"'{variable_name}'"
        )
        
        # Indicator line (right axis) - we'll use a transform to scale it to fit
        indicator_line = alt.Chart(merged_df).mark_line(
            color=indicator_color,
            strokeWidth=3,
            strokeDash=[5, 5],
            point=alt.OverlayMarkDef(size=80, filled=True)
        ).encode(
            x=alt.X(f'{year_column}:O'),
            y=alt.Y(f'{indicator_col}:Q',
                   title=indicator_name,
                   scale=alt.Scale(zero=False)),
            tooltip=[f'{year_column}:O', f'{gdp_column}:Q', f'{indicator_col}:Q']
        ).add_params(legend_selection).transform_calculate(
            variable=f"'{indicator_name}'"
        )
        
        # Combine the two lines
        combined = alt.layer(gdp_line, indicator_line).resolve_scale(
            y='independent'
        ).properties(
            width=chart_width,
            height=chart_height,
            title=alt.TitleParams(text=title, fontSize=14, anchor='start')
        )
        
        return combined
    
    # Determine the main indicator name for titles
    if 'GDP' in gdp_column or 'gdp' in gdp_column.lower():
        main_indicator = 'GDP'
        # Add R-squared values to titles for GDP charts
        title1 = f'{main_indicator} vs Air Pollution (NO2) - R² = {r2_no2:.3f}'
        title2 = f'{main_indicator} vs Economic Activity (NTL) - R² = {r2_ntl:.3f}'
        title3 = f'{main_indicator} vs Agricultural Activity (EVI) - R² = {r2_evi:.3f}'
    elif 'pop' in gdp_column.lower() or 'population' in gdp_column.lower():
        main_indicator = 'Population'
        # No R-squared for population charts
        title1 = f'{main_indicator} vs Air Pollution (NO2)'
        title2 = f'{main_indicator} vs Economic Activity (NTL)'
        title3 = f'{main_indicator} vs Agricultural Activity (EVI)'
    else:
        main_indicator = gdp_column.replace('_', ' ').title()
        # No R-squared for other indicators
        title1 = f'{main_indicator} vs Air Pollution (NO2)'
        title2 = f'{main_indicator} vs Economic Activity (NTL)'
        title3 = f'{main_indicator} vs Agricultural Activity (EVI)'
    
    # Create individual charts with dynamic titles including R-squared values
    chart1 = create_dual_axis_chart(gdp_no2, no2_column, 'NO2 Levels', title1, colors[0], colors[1])
    chart2 = create_dual_axis_chart(gdp_ntl, ntl_column, 'Nighttime Lights', title2, colors[0], colors[2])
    chart3 = create_dual_axis_chart(gdp_evi, evi_column, 'Vegetation Index', title3, colors[0], colors[3])
    
    # Arrange charts: 2 in top row, 1 in bottom row
    top_row = alt.hconcat(chart1, chart2)
    bottom_row = alt.hconcat(chart3, alt.Chart().mark_text().encode().properties(width=chart_width, height=chart_height))
    
    combined_chart = alt.vconcat(
        top_row, bottom_row
    ).resolve_scale(
        color='independent',
        y='independent'
    ).properties(
        title=alt.TitleParams(
            text=f'{main_indicator} Trends vs Economic/Environmental Indicators in Syria (Dual Axes)',
            fontSize=16,
            anchor='start',
            offset=20
        )
    )
    
    return combined_chart


def create_three_part_gdp_comparison(
    gdp_data: pd.DataFrame,
    no2_data: pd.DataFrame,
    ntl_data: pd.DataFrame, 
    evi_data: pd.DataFrame,
    year_column: str = 'year',
    gdp_column: str = 'GDP per capita (constant SYP)',
    no2_column: str = 'mean_no2',
    ntl_column: str = 'viirs_bm_mean',
    evi_column: str = 'EVI',
    figsize: Tuple[int, int] = (15, 12),
    style: str = 'whitegrid'
) -> plt.Figure:
    """
    Create a three-part bar plot showing GDP trends alongside NO2, NTL, and EVI.
    
    Parameters:
    -----------
    gdp_data : pd.DataFrame
        DataFrame containing GDP data with year and GDP columns
    no2_data : pd.DataFrame
        DataFrame containing NO2 pollution data
    ntl_data : pd.DataFrame
        DataFrame containing nighttime lights data
    evi_data : pd.DataFrame
        DataFrame containing Enhanced Vegetation Index data
    year_column : str, default 'year'
        Name of the year column in all datasets
    gdp_column : str, default 'GDP per capita (constant SYP)'
        Name of the GDP column
    no2_column : str, default 'mean_no2'
        Name of the NO2 column
    ntl_column : str, default 'viirs_bm_mean'
        Name of the NTL column
    evi_column : str, default 'EVI'
        Name of the EVI column
    figsize : tuple, default (15, 12)
        Figure size (width, height)
    style : str, default 'whitegrid'
        Seaborn style
        
    Returns:
    --------
    plt.Figure
        Matplotlib figure object
    """
    
    # Set style
    sns.set_style(style)
    plt.rcParams['font.size'] = 10
    
    # Create figure with subplots arranged horizontally
    fig, (ax1, ax2, ax3) = plt.subplots(1, 3, figsize=figsize)
    fig.suptitle('GDP Trends vs Economic/Environmental Indicators in Syria', 
                 fontsize=16, fontweight='bold', y=0.95)
    
    # Colors for consistency
    gdp_color = '#2E86AB'  # Blue
    indicator_colors = ['#A23B72', '#F18F01', '#C73E1D']  # Pink, Orange, Red
    
    # Prepare data - ensure year columns are datetime
    for df in [gdp_data, no2_data, ntl_data, evi_data]:
        if year_column in df.columns:
            if not pd.api.types.is_datetime64_any_dtype(df[year_column]):
                df[year_column] = pd.to_datetime(df[year_column])
    
    # Plot 1: GDP vs NO2
    
    # Merge GDP and NO2 data
    gdp_no2 = pd.merge(gdp_data, no2_data, on=year_column, how='inner')
    
    # Create twin axis
    ax1_twin = ax1.twinx()
    
    # Plot bars
    years = gdp_no2[year_column].dt.year
    width = 0.35
    x_pos = np.arange(len(years))
    
    bars1 = ax1.bar(x_pos - width/2, gdp_no2[gdp_column], width, 
                    label='GDP (LCU)', color=gdp_color, alpha=0.8)
    bars2 = ax1_twin.bar(x_pos + width/2, gdp_no2[no2_column], width,
                        label='NO2 Levels', color=indicator_colors[0], alpha=0.8)
    
    ax1.set_ylabel('GDP (Local Currency Units)', color=gdp_color, fontweight='bold')
    ax1_twin.set_ylabel('NO2 Levels (molecules/cm²)', color=indicator_colors[0], fontweight='bold')
    ax1.set_title('GDP vs Air Pollution (NO2 Levels)', fontsize=14, fontweight='bold', pad=20)
    
    # Format axes
    ax1.tick_params(axis='y', labelcolor=gdp_color)
    ax1_twin.tick_params(axis='y', labelcolor=indicator_colors[0])
    ax1.set_xticks(x_pos)
    ax1.set_xticklabels(years, rotation=45)
    
    # Add grid
    ax1.grid(True, alpha=0.3)
    
    # Plot 2: GDP vs NTL
    
    # Merge GDP and NTL data
    gdp_ntl = pd.merge(gdp_data, ntl_data, on=year_column, how='inner')
    
    # Create twin axis
    ax2_twin = ax2.twinx()
    
    # Plot bars
    years2 = gdp_ntl[year_column].dt.year
    x_pos2 = np.arange(len(years2))
    
    bars3 = ax2.bar(x_pos2 - width/2, gdp_ntl[gdp_column], width,
                    label='GDP (LCU)', color=gdp_color, alpha=0.8)
    bars4 = ax2_twin.bar(x_pos2 + width/2, gdp_ntl[ntl_column], width,
                        label='Nighttime Lights', color=indicator_colors[1], alpha=0.8)
    
    ax2.set_ylabel('GDP (Local Currency Units)', color=gdp_color, fontweight='bold')
    ax2_twin.set_ylabel('Nighttime Lights Intensity', color=indicator_colors[1], fontweight='bold')
    ax2.set_title('GDP vs Economic Activity (Nighttime Lights)', fontsize=14, fontweight='bold', pad=20)
    
    # Format axes
    ax2.tick_params(axis='y', labelcolor=gdp_color)
    ax2_twin.tick_params(axis='y', labelcolor=indicator_colors[1])
    ax2.set_xticks(x_pos2)
    ax2.set_xticklabels(years2, rotation=45)
    
    # Add grid
    ax2.grid(True, alpha=0.3)
    
    # Plot 3: GDP vs EVI
    
    # Merge GDP and EVI data
    gdp_evi = pd.merge(gdp_data, evi_data, on=year_column, how='inner')
    
    # Create twin axis
    ax3_twin = ax3.twinx()
    
    # Plot bars
    years3 = gdp_evi[year_column].dt.year
    x_pos3 = np.arange(len(years3))
    
    bars5 = ax3.bar(x_pos3 - width/2, gdp_evi[gdp_column], width,
                    label='GDP (LCU)', color=gdp_color, alpha=0.8)
    bars6 = ax3_twin.bar(x_pos3 + width/2, gdp_evi[evi_column], width,
                        label='Vegetation Index', color=indicator_colors[2], alpha=0.8)
    
    ax3.set_ylabel('GDP (Local Currency Units)', color=gdp_color, fontweight='bold')
    ax3_twin.set_ylabel('Enhanced Vegetation Index (EVI)', color=indicator_colors[2], fontweight='bold')
    ax3.set_title('GDP vs Agricultural Activity (Enhanced Vegetation Index)', fontsize=14, fontweight='bold', pad=20)
    ax3.set_xlabel('Year', fontsize=12, fontweight='bold')
    
    # Format axes
    ax3.tick_params(axis='y', labelcolor=gdp_color)
    ax3_twin.tick_params(axis='y', labelcolor=indicator_colors[2])
    ax3.set_xticks(x_pos3)
    ax3.set_xticklabels(years3, rotation=45)
    
    # Add grid
    ax3.grid(True, alpha=0.3)
    
    # Add legends
    lines1, labels1 = ax1.get_legend_handles_labels()
    lines2, labels2 = ax1_twin.get_legend_handles_labels()
    ax1.legend(lines1 + lines2, labels1 + labels2, loc='upper left', frameon=True, fancybox=True, shadow=True)
    
    lines3, labels3 = ax2.get_legend_handles_labels()
    lines4, labels4 = ax2_twin.get_legend_handles_labels()
    ax2.legend(lines3 + lines4, labels3 + labels4, loc='upper left', frameon=True, fancybox=True, shadow=True)
    
    lines5, labels5 = ax3.get_legend_handles_labels()
    lines6, labels6 = ax3_twin.get_legend_handles_labels()
    ax3.legend(lines5 + lines6, labels5 + labels6, loc='upper left', frameon=True, fancybox=True, shadow=True)
    
    # Adjust layout
    plt.tight_layout()
    plt.subplots_adjust(top=0.92)
    
    return fig


def create_normalized_comparison_chart(
    gdp_data: pd.DataFrame,
    no2_data: pd.DataFrame,
    ntl_data: pd.DataFrame,
    evi_data: pd.DataFrame,
    year_column: str = 'year',
    gdp_column: str = 'GDP',
    no2_column: str = 'mean_no2',
    ntl_column: str = 'sum',
    evi_column: str = 'EVI',
    figsize: Tuple[int, int] = (12, 8)
) -> plt.Figure:
    """
    Create a normalized line chart showing all indicators on the same scale.
    
    Parameters:
    -----------
    gdp_data : pd.DataFrame
        DataFrame containing GDP data
    no2_data : pd.DataFrame
        DataFrame containing NO2 data
    ntl_data : pd.DataFrame
        DataFrame containing NTL data
    evi_data : pd.DataFrame
        DataFrame containing EVI data
    year_column : str
        Name of the year column
    gdp_column : str
        Name of the GDP column
    no2_column : str
        Name of the NO2 column
    ntl_column : str
        Name of the NTL column
    evi_column : str
        Name of the EVI column
    figsize : tuple
        Figure size
        
    Returns:
    --------
    plt.Figure
        Matplotlib figure object
    """
    
    # Merge all data
    merged_data = gdp_data[[year_column, gdp_column]].copy()
    
    if not no2_data.empty:
        merged_data = pd.merge(merged_data, no2_data[[year_column, no2_column]], 
                              on=year_column, how='outer')
    
    if not ntl_data.empty:
        merged_data = pd.merge(merged_data, ntl_data[[year_column, ntl_column]], 
                              on=year_column, how='outer')
    
    if not evi_data.empty:
        merged_data = pd.merge(merged_data, evi_data[[year_column, evi_column]], 
                              on=year_column, how='outer')
    
    # Sort by year
    merged_data = merged_data.sort_values(year_column)
    
    # Normalize all indicators
    indicators = {}
    if gdp_column in merged_data.columns:
        indicators['GDP (Normalized)'] = normalize_data(merged_data[gdp_column].dropna())
    if no2_column in merged_data.columns:
        indicators['NO2 (Normalized)'] = normalize_data(merged_data[no2_column].dropna())
    if ntl_column in merged_data.columns:
        indicators['NTL (Normalized)'] = normalize_data(merged_data[ntl_column].dropna())
    if evi_column in merged_data.columns:
        indicators['EVI (Normalized)'] = normalize_data(merged_data[evi_column].dropna())
    
    # Create plot
    fig, ax = plt.subplots(figsize=figsize)
    
    colors = ['#2E86AB', '#A23B72', '#F18F01', '#C73E1D']
    
    for i, (name, data) in enumerate(indicators.items()):
        years = merged_data[year_column].dt.year[:len(data)]
        ax.plot(years, data, marker='o', linewidth=2, label=name, 
                color=colors[i % len(colors)], markersize=6)
    
    ax.set_xlabel('Year', fontsize=12, fontweight='bold')
    ax.set_ylabel('Normalized Values (0-1 Scale)', fontsize=12, fontweight='bold')
    ax.set_title('Normalized Comparison of GDP and Economic Indicators in Syria', 
                 fontsize=14, fontweight='bold')
    
    ax.legend(loc='best', frameon=True, fancybox=True, shadow=True)
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    
    return fig


def create_correlation_heatmap(
    gdp_data: pd.DataFrame,
    no2_data: pd.DataFrame,
    ntl_data: pd.DataFrame,
    evi_data: pd.DataFrame,
    year_column: str = 'year',
    gdp_column: str = 'GDP',
    no2_column: str = 'mean_no2',
    ntl_column: str = 'sum',
    evi_column: str = 'EVI',
    figsize: Tuple[int, int] = (8, 6)
) -> plt.Figure:
    """
    Create a correlation heatmap between all indicators.
    
    Parameters:
    -----------
    gdp_data : pd.DataFrame
        DataFrame containing GDP data
    no2_data : pd.DataFrame
        DataFrame containing NO2 data
    ntl_data : pd.DataFrame
        DataFrame containing NTL data
    evi_data : pd.DataFrame
        DataFrame containing EVI data
    year_column : str
        Name of the year column
    gdp_column : str
        Name of the GDP column
    no2_column : str
        Name of the NO2 column
    ntl_column : str
        Name of the NTL column
    evi_column : str
        Name of the EVI column
    figsize : tuple
        Figure size
        
    Returns:
    --------
    plt.Figure
        Matplotlib figure object
    """
    
    # Merge all data
    merged_data = gdp_data[[year_column, gdp_column]].copy()
    
    if not no2_data.empty:
        merged_data = pd.merge(merged_data, no2_data[[year_column, no2_column]], 
                              on=year_column, how='inner')
    
    if not ntl_data.empty:
        merged_data = pd.merge(merged_data, ntl_data[[year_column, ntl_column]], 
                              on=year_column, how='inner')
    
    if not evi_data.empty:
        merged_data = pd.merge(merged_data, evi_data[[year_column, evi_column]], 
                              on=year_column, how='inner')
    
    # Calculate correlations
    correlation_data = merged_data.select_dtypes(include=[np.number]).corr()
    
    # Create heatmap
    fig, ax = plt.subplots(figsize=figsize)
    
    sns.heatmap(correlation_data, 
                annot=True, 
                cmap='RdBu_r', 
                center=0, 
                square=True,
                fmt='.3f',
                cbar_kws={'label': 'Correlation Coefficient'},
                ax=ax)
    
    ax.set_title('Correlation Matrix: GDP and Economic Indicators', 
                 fontsize=14, fontweight='bold')
    
    plt.tight_layout()
    
    return fig


# Example usage function
def quick_gdp_analysis(
    gdp_data: pd.DataFrame,
    no2_data: pd.DataFrame,
    ntl_data: pd.DataFrame,
    evi_data: pd.DataFrame
) -> Dict[str, plt.Figure]:
    """
    Quick analysis generating all three types of plots.
    
    Returns:
    --------
    dict
        Dictionary containing all generated figures
    """
    
    figures = {}
    
    # Three-part comparison
    figures['three_part'] = create_three_part_gdp_comparison(
        gdp_data, no2_data, ntl_data, evi_data
    )
    
    # Normalized comparison
    figures['normalized'] = create_normalized_comparison_chart(
        gdp_data, no2_data, ntl_data, evi_data
    )
    
    # Correlation heatmap
    figures['correlation'] = create_correlation_heatmap(
        gdp_data, no2_data, ntl_data, evi_data
    )
    
    return figures


if __name__ == "__main__":
    print("Combined visualizations module for Syria Economic Monitor")
    print("Available functions:")
    print("- create_three_part_gdp_comparison()")
    print("- create_normalized_comparison_chart()")
    print("- create_correlation_heatmap()")
    print("- quick_gdp_analysis()")