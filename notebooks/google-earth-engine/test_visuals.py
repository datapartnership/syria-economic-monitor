# Example usage of airpollution_visuals.py
import sys

sys.path.append(".")

from airpollution_visuals import load_airpollution_data, quick_national_plot

# Test the visualization functions
if __name__ == "__main__":
    print("Testing air pollution visualization functions...")

    # Test loading data
    try:
        datasets = load_airpollution_data()
        print(f"Successfully loaded {len(datasets)} datasets")

        for key, df in datasets.items():
            print(f"{key}: {df.shape[0]} rows, {df.shape[1]} columns")
            if not df.empty:
                print(
                    f"  Date range: {df['start_date'].min()} to {df['start_date'].max()}"
                )
                print(
                    f"  Categories: {df['NAME_EN'].unique()[:5]}..."
                )  # Show first 5 categories

    except Exception as e:
        print(f"Error testing data loading: {e}")

    # Test creating a chart
    try:
        chart = quick_national_plot()
        print("Successfully created national chart")
        chart.save("test_air_pollution.html")
        print("Saved test chart as 'test_air_pollution.html'")
    except Exception as e:
        print(f"Error creating chart: {e}")
