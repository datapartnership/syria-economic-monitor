"""
Air Pollution Visualization Functions

This module provides interactive visualization functions for air pollution data
using Altair for creating interactive line plots.
"""

import pandas as pd
import altair as alt
from typing import List, Optional, Union


def create_interactive_lineplot(
    dataframe: pd.DataFrame,
    x_column: str = "start_date",
    y_column: str = "mean",
    category_column: str = "NAME_EN",
    categories: Optional[Union[str, List[str]]] = None,
    title: str = "Air Pollution Levels Over Time",
    subtitle: Optional[str] = None,
    width: int = 800,
    height: int = 400,
    color_scheme: str = "category20",
) -> alt.Chart:
    """
    Create an interactive line plot for air pollution data using Altair.

    Parameters:
    -----------
    dataframe : pd.DataFrame
        The input dataframe containing air pollution data
    x_column : str, default "start_date"
        Column name for x-axis (typically date/time)
    y_column : str, default "mean"
        Column name for y-axis (pollution values)
    category_column : str, default "NAME_EN"
        Column name for categories to create multiple lines
    categories : str, list of str, or None, default None
        Specific categories to plot. If None, plots all categories.
        If string, plots only that category. If list, plots specified categories.
    title : str, default "Air Pollution Levels Over Time"
        Chart title
    subtitle : str or None, default None
        Chart subtitle
    width : int, default 800
        Chart width in pixels
    height : int, default 400
        Chart height in pixels
    color_scheme : str, default "category20"
        Altair color scheme for lines

    Returns:
    --------
    alt.Chart
        Interactive Altair chart object

    Examples:
    ---------
    # Plot all categories
    chart = create_interactive_lineplot(monthly_no2_national)

    # Plot specific category
    chart = create_interactive_lineplot(
        monthly_no2_adm1,
        categories="Damascus",
        category_column="ADM1_EN"
    )

    # Plot multiple specific categories
    chart = create_interactive_lineplot(
        monthly_no2_adm1,
        categories=["Damascus", "Aleppo", "Homs"],
        category_column="ADM1_EN"
    )
    """

    # Make a copy to avoid modifying the original dataframe
    df = dataframe.copy()

    # Convert date column to datetime if it's not already
    if x_column in df.columns:
        df[x_column] = pd.to_datetime(df[x_column])

    # Filter by categories if specified
    if categories is not None:
        if isinstance(categories, str):
            categories = [categories]
        df = df[df[category_column].isin(categories)]

    # Create selection for interactive legend (click to hide/show lines)
    # Using Altair v5 syntax with proper legend binding
    legend_selection = alt.selection_point(fields=[category_column], bind="legend")

    # Create the base chart with zoom/pan functionality
    base = alt.Chart(df).add_selection(
        alt.selection_interval(bind="scales"), legend_selection
    )

    # Create the line chart
    line_chart = (
        base.mark_line(strokeWidth=2, point=True)
        .encode(
            x=alt.X(f"{x_column}:T", title="Date", axis=alt.Axis(format="%Y-%m")),
            y=alt.Y(f"{y_column}:Q", title="NO2 Levels", scale=alt.Scale(zero=False)),
            color=alt.Color(
                f"{category_column}:N",
                title="Region (Click to hide/show)",
                scale=alt.Scale(scheme=color_scheme),
                legend=alt.Legend(
                    title="Region (Click to hide/show)",
                    titleFontSize=12,
                    labelFontSize=10,
                ),
            ),
            opacity=alt.condition(legend_selection, alt.value(1.0), alt.value(0.2)),
            strokeWidth=alt.condition(legend_selection, alt.value(3), alt.value(1)),
            tooltip=[
                alt.Tooltip(f"{x_column}:T", title="Date"),
                alt.Tooltip(f"{y_column}:Q", title="NO2 Level"),
                alt.Tooltip(f"{category_column}:N", title="Region"),
            ],
        )
        .properties(
            width=width,
            height=height,
            title=alt.TitleParams(
                text=title,
                subtitle=subtitle
                if subtitle
                else "Source: Google Earth Engine via Copernicus Satellite Imagery",
                fontSize=16,
                anchor="start",
            ),
        )
        .interactive()
    )

    return line_chart


def create_multi_admin_lineplot(
    adm0_data: Optional[pd.DataFrame] = None,
    adm1_data: Optional[pd.DataFrame] = None,
    adm2_data: Optional[pd.DataFrame] = None,
    adm3_data: Optional[pd.DataFrame] = None,
    admin_level: str = "adm1",
    categories: Optional[Union[str, List[str]]] = None,
    title: str = "Air Pollution Levels by Administrative Region",
    **kwargs,
) -> alt.Chart:
    """
    Create an interactive line plot for different administrative levels.

    Parameters:
    -----------
    adm0_data, adm1_data, adm2_data, adm3_data : pd.DataFrame or None
        DataFrames for different administrative levels
    admin_level : str, default "adm1"
        Which administrative level to plot ("adm0", "adm1", "adm2", "adm3")
    categories : str, list of str, or None
        Specific categories to plot
    title : str
        Chart title
    **kwargs
        Additional arguments passed to create_interactive_lineplot

    Returns:
    --------
    alt.Chart
        Interactive Altair chart object
    """

    # Map admin levels to data and column names
    admin_mapping = {
        "adm0": {"data": adm0_data, "category_column": "NAME_EN", "y_column": "mean"},
        "adm1": {
            "data": adm1_data,
            "category_column": "NAME_EN",  # For admin1, NAME_EN contains the admin1 names
            "y_column": "mean",
        },
        "adm2": {
            "data": adm2_data,
            "category_column": "NAME_EN",  # For admin2, NAME_EN contains the admin2 names
            "y_column": "mean",
        },
        "adm3": {
            "data": adm3_data,
            "category_column": "NAME_EN",  # For admin3, NAME_EN contains the admin3 names
            "y_column": "mean",
        },
    }

    if admin_level not in admin_mapping:
        raise ValueError(f"admin_level must be one of {list(admin_mapping.keys())}")

    config = admin_mapping[admin_level]
    data = config["data"]

    if data is None:
        raise ValueError(f"No data provided for {admin_level}")

    # Set default parameters based on admin level
    default_params = {
        "category_column": config["category_column"],
        "y_column": config["y_column"],
        "title": title,
        "categories": categories,
    }

    # Update with any user-provided parameters
    default_params.update(kwargs)

    return create_interactive_lineplot(data, **default_params)


def load_airpollution_data(data_path: str = "../../data/airpollution/") -> dict:
    """
    Load all air pollution datasets.

    Parameters:
    -----------
    data_path : str, default "../../data/airpollution/"
        Path to the air pollution data directory

    Returns:
    --------
    dict
        Dictionary containing all loaded datasets
    """
    try:
        datasets = {}

        # Load national (admin0) data
        datasets["adm0"] = pd.read_csv(
            f"{data_path}syr_admin0_no2_monthly_combined.csv"
        )

        # Load admin1 data
        datasets["adm1"] = pd.read_csv(
            f"{data_path}admin1/syria_adm1_no2_monthly_combined.csv"
        )

        # Load admin2 data
        datasets["adm2"] = pd.read_csv(
            f"{data_path}admin2/syr_admin2_no2_monthly_combined.csv"
        )

        # Load admin3 data
        datasets["adm3"] = pd.read_csv(
            f"{data_path}admin3/syr_admin3_no2_monthly_combined.csv"
        )

        # Convert date columns to datetime
        for key, df in datasets.items():
            if "start_date" in df.columns:
                df["start_date"] = pd.to_datetime(df["start_date"])

        return datasets

    except FileNotFoundError as e:
        print(f"Error loading data: {e}")
        return {}


# Example usage and convenience functions
def quick_national_plot(data_path: str = "../../data/airpollution/") -> alt.Chart:
    """Quick plot of national-level air pollution data."""
    datasets = load_airpollution_data(data_path)
    if "adm0" in datasets:
        return create_interactive_lineplot(
            datasets["adm0"],
            title="National Air Pollution Levels in Syria",
            subtitle="NO2 concentrations from Copernicus Satellite Imagery",
        )
    else:
        raise ValueError("Could not load national data")


def quick_admin1_plot(
    categories: Optional[Union[str, List[str]]] = None,
    data_path: str = "../../data/airpollution/",
) -> alt.Chart:
    """Quick plot of admin1-level air pollution data."""
    datasets = load_airpollution_data(data_path)
    if "adm1" in datasets:
        return create_multi_admin_lineplot(
            adm1_data=datasets["adm1"],
            admin_level="adm1",
            categories=categories,
            title="Provincial Air Pollution Levels in Syria",
        )
    else:
        raise ValueError("Could not load admin1 data")


if __name__ == "__main__":
    # Example usage
    print("Loading air pollution data...")
    datasets = load_airpollution_data()

    if datasets:
        print("Available datasets:", list(datasets.keys()))

        # Create a sample plot
        chart = quick_national_plot()
        print("Created national-level chart")

        # Save as HTML for viewing
        chart.save("air_pollution_national.html")
        print("Saved chart as 'air_pollution_national.html'")
    else:
        print("No datasets loaded successfully")


def create_temporal_maps(
    dataframe: pd.DataFrame,
    boundaries_gdf: pd.DataFrame,
    join_column: str = "NAME_EN",
    pollution_column: str = "mean",
    date_column: str = "start_date",
    temporal_grouping: str = "year",
    title: str = None,  # Allow custom title input
    title_prefix: str = "Air Pollution Levels",
    width: int = 400,
    height: int = 300,
    color_scheme: str = "blues",
) -> alt.Chart:
    """
    Create temporal maps showing pollution changes over time using Altair.

    Parameters:
    -----------
    dataframe : pd.DataFrame
        Air pollution data with temporal information
    boundaries_gdf : gpd.GeoDataFrame
        Geographic boundaries for mapping
    join_column : str, default "NAME_EN"
        Column name to join pollution data with boundaries
    pollution_column : str, default "mean"
        Column containing pollution values
    date_column : str, default "start_date"
        Column containing date information
    temporal_grouping : str, default "year"
        How to group time periods ("year", "month", "quarter")
    title : str or None, default None
        Custom title for the chart. If None, uses title_prefix with temporal grouping.
    title_prefix : str, default "Air Pollution Levels"
        Prefix for map titles (used when title is None)
    width : int, default 400
        Width of each map
    height : int, default 300
        Height of each map
    color_scheme : str, default "blues"
        Color scheme for the maps

    Returns:
    --------
    alt.Chart
        Altair chart with temporal maps
    """

    # Make copies to avoid modifying original data
    df = dataframe.copy()
    gdf = boundaries_gdf.copy()

    # Ensure date column is datetime
    df[date_column] = pd.to_datetime(df[date_column])

    # Create temporal grouping
    if temporal_grouping == "year":
        df["time_period"] = df[date_column].dt.year
    elif temporal_grouping == "month":
        df["time_period"] = df[date_column].dt.to_period("M").astype(str)
    elif temporal_grouping == "quarter":
        df["time_period"] = df[date_column].dt.to_period("Q").astype(str)
    else:
        raise ValueError("temporal_grouping must be 'year', 'month', or 'quarter'")

    # Aggregate data by time period and region
    agg_data = (
        df.groupby(["time_period", join_column])[pollution_column].mean().reset_index()
    )

    # Calculate global min/max for consistent color scale
    global_min = agg_data[pollution_column].min()
    global_max = agg_data[pollution_column].max()

    # Use custom title if provided, otherwise use title_prefix with temporal grouping
    chart_title = (
        title
        if title is not None
        else f"{title_prefix} - {temporal_grouping.title()} View"
    )

    # Create the choropleth map using the same pattern as vegetation analytics
    base_map = (
        alt.Chart(agg_data, title=chart_title)
        .mark_geoshape(stroke="white", strokeWidth=0.5)
        .encode(
            shape="geo:G",
            color=alt.Color(
                f"{pollution_column}:Q",
                scale=alt.Scale(
                    scheme=color_scheme,
                    domain=[
                        global_min,
                        global_max,
                    ],  # Fixed domain for consistent coloring
                ),
                title="NO2 Level",
                legend=alt.Legend(
                    orient="right",
                    titleFontSize=12,
                    labelFontSize=10,
                    gradientLength=200,
                ),
            ),
            tooltip=[
                alt.Tooltip(f"{join_column}:N", title="Region"),
                alt.Tooltip(f"{pollution_column}:Q", title="NO2 Level", format=".3f"),
                alt.Tooltip("time_period:O", title="Time Period"),
            ],
            facet=alt.Facet("time_period:O", columns=3, title=None),
        )
        .transform_lookup(
            lookup=join_column,
            from_=alt.LookupData(data=gdf, key=join_column),
            as_="geo",
        )
        .properties(width=width, height=height)
        .resolve_scale(
            color="shared"  # Share color scale across all facets
        )
    )

    return base_map


def create_yearly_maps(
    dataframe: pd.DataFrame,
    boundaries_gdf: pd.DataFrame,
    join_column: str = "NAME_EN",
    pollution_column: str = "mean",
    **kwargs,
) -> alt.Chart:
    """
    Create maps showing yearly changes in pollution levels.

    Parameters:
    -----------
    dataframe : pd.DataFrame
        Air pollution data
    boundaries_gdf : gpd.GeoDataFrame
        Geographic boundaries
    join_column : str, default "NAME_EN"
        Column to join data with boundaries
    pollution_column : str, default "mean"
        Pollution value column
    **kwargs
        Additional arguments passed to create_temporal_maps

    Returns:
    --------
    alt.Chart
        Yearly temporal maps
    """
    return create_temporal_maps(
        dataframe=dataframe,
        boundaries_gdf=boundaries_gdf,
        join_column=join_column,
        pollution_column=pollution_column,
        temporal_grouping="year",
        title_prefix="Annual Air Pollution Levels",
        **kwargs,
    )


def create_monthly_maps(
    dataframe: pd.DataFrame,
    boundaries_gdf: pd.DataFrame,
    join_column: str = "NAME_EN",
    pollution_column: str = "mean",
    year_filter: Optional[int] = None,
    width: int = 300,
    height: int = 250,
    **kwargs,
) -> alt.Chart:
    """
    Create maps showing monthly changes in pollution levels.

    Parameters:
    -----------
    dataframe : pd.DataFrame
        Air pollution data
    boundaries_gdf : gpd.GeoDataFrame
        Geographic boundaries
    join_column : str, default "NAME_EN"
        Column to join data with boundaries
    pollution_column : str, default "mean"
        Pollution value column
    year_filter : int or None, default None
        Filter to specific year (e.g., 2023). If None, shows all months.
    width : int, default 300
        Width of each map
    height : int, default 250
        Height of each map
    **kwargs
        Additional arguments passed to create_temporal_maps

    Returns:
    --------
    alt.Chart
        Monthly temporal maps
    """

    # Filter by year if specified
    if year_filter is not None:
        df_filtered = dataframe.copy()
        df_filtered["start_date"] = pd.to_datetime(df_filtered["start_date"])
        df_filtered = df_filtered[df_filtered["start_date"].dt.year == year_filter]
        title_suffix = f" ({year_filter})"
    else:
        df_filtered = dataframe
        title_suffix = ""

    return create_temporal_maps(
        dataframe=df_filtered,
        boundaries_gdf=boundaries_gdf,
        join_column=join_column,
        pollution_column=pollution_column,
        temporal_grouping="month",
        title_prefix=f"Monthly Air Pollution Levels{title_suffix}",
        width=width,
        height=height,
        **kwargs,
    )


def create_animated_map(
    dataframe: pd.DataFrame,
    boundaries_gdf: pd.DataFrame,
    join_column: str = "NAME_EN",
    pollution_column: str = "mean",
    date_column: str = "start_date",
    temporal_grouping: str = "year",
    width: int = 600,
    height: int = 400,
    color_scheme: str = "blues",
) -> alt.Chart:
    """
    Create a temporal overview map showing pollution changes over time.

    Parameters:
    -----------
    dataframe : pd.DataFrame
        Air pollution data
    boundaries_gdf : gpd.GeoDataFrame
        Geographic boundaries
    join_column : str, default "NAME_EN"
        Column to join data with boundaries
    pollution_column : str, default "mean"
        Pollution value column
    date_column : str, default "start_date"
        Date column for temporal grouping
    temporal_grouping : str, default "year"
        Time grouping ("year", "month", "quarter")
    width : int, default 600
        Map width
    height : int, default 400
        Map height
    color_scheme : str, default "blues"
        Color scheme

    Returns:
    --------
    alt.Chart
        Temporal map chart (faceted by time period)
    """

    # Create a temporal overview using smaller faceted maps
    return create_temporal_maps(
        dataframe=dataframe,
        boundaries_gdf=boundaries_gdf,
        join_column=join_column,
        pollution_column=pollution_column,
        date_column=date_column,
        temporal_grouping=temporal_grouping,
        title_prefix="Temporal Changes in Air Pollution",
        width=width // 3,  # Smaller since it's faceted
        height=height // 3,
        color_scheme=color_scheme,
    )
