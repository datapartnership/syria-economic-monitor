"""
CHIRPS Rainfall Data Extraction using Google Earth Engine

This module provides functions to extract CHIRPS rainfall data for Myanmar 
using Google Earth Engine.
"""

import ee
import pandas as pd
import geopandas as gpd
from pathlib import Path
import logging

# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


class CHIRPSRainfallExtractor:
    """Extract CHIRPS rainfall data using Google Earth Engine for Myanmar."""
    
    def __init__(self, output_dir="../data/rainfall", boundaries_dir="../data/boundaries"):
        """
        Initialize the CHIRPS rainfall data extractor.
        
        Parameters:
        -----------
        output_dir : str
            Directory to save extracted data
        boundaries_dir : str
            Directory containing Myanmar administrative boundaries
        """
        self.output_dir = Path(output_dir)
        self.output_dir.mkdir(parents=True, exist_ok=True)
        self.boundaries_dir = Path(boundaries_dir)
        
        # Myanmar bounding box
        self.myanmar_bbox = {
            'lon_min': 92.2,
            'lon_max': 101.2,
            'lat_min': 9.5,
            'lat_max': 28.5
        }
        
        # Create Myanmar geometry for GEE
        self.myanmar_geom = ee.Geometry.Rectangle([
            self.myanmar_bbox['lon_min'],
            self.myanmar_bbox['lat_min'],
            self.myanmar_bbox['lon_max'],
            self.myanmar_bbox['lat_max']
        ])
        
        logger.info(f"Initialized CHIRPSRainfallExtractor with output_dir: {self.output_dir}")
        logger.info(f"Using Myanmar boundaries from: {self.boundaries_dir}")
    
    def authenticate_gee(self):
        """
        Authenticate and initialize Google Earth Engine.
        """
        try:
            ee.Initialize()
            logger.info("Google Earth Engine already initialized")
        except Exception:
            logger.info("Authenticating Google Earth Engine...")
            ee.Authenticate()
            ee.Initialize()
            logger.info("Google Earth Engine authenticated and initialized")
    
    def load_myanmar_boundaries(self, admin_level=1):
        """
        Load Myanmar administrative boundaries from shapefile.
        
        Parameters:
        -----------
        admin_level : int
            Administrative level (0, 1, 2, 3, 4, or 5)
        
        Returns:
        --------
        geopandas.GeoDataFrame
            GeoDataFrame with Myanmar administrative boundaries
        """
        shapefile_name = f"mmr_polbnda_adm{admin_level}_250k_mimu_20240215.shp"
        shapefile_path = self.boundaries_dir / shapefile_name
        
        if not shapefile_path.exists():
            raise FileNotFoundError(f"Shapefile not found: {shapefile_path}")
        
        logger.info(f"Loading Myanmar ADM{admin_level} boundaries from {shapefile_path}")
        gdf = gpd.read_file(shapefile_path)
        
        # Ensure CRS is WGS84
        if gdf.crs is None:
            gdf = gdf.set_crs('EPSG:4326')
        elif gdf.crs != 'EPSG:4326':
            gdf = gdf.to_crs('EPSG:4326')
        
        logger.info(f"Loaded {len(gdf)} administrative regions")
        return gdf
    
    def get_rainfall_data(self, start_date, end_date, temporal_resolution="monthly"):
        """
        Extract CHIRPS rainfall data for Myanmar.
        
        Parameters:
        -----------
        start_date : str
            Start date (format: 'YYYY-MM-DD')
        end_date : str
            End date (format: 'YYYY-MM-DD')
        temporal_resolution : str
            Temporal resolution: "daily" or "monthly"
        
        Returns:
        --------
        pandas.DataFrame
            DataFrame with columns: date, mean_rainfall_mm
        """
        logger.info(f"Extracting CHIRPS rainfall from {start_date} to {end_date}")
        logger.info(f"Temporal resolution: {temporal_resolution}")
        
        # Load CHIRPS dataset
        chirps = ee.ImageCollection('UCSB-CHG/CHIRPS/DAILY').filterDate(start_date, end_date).filterBounds(self.myanmar_geom)
        
        if temporal_resolution == "monthly":
            # Aggregate to monthly
            def monthly_sum(date):
                date = ee.Date(date)
                monthly = chirps.filterDate(date, date.advance(1, 'month')).sum()
                return monthly.set('system:time_start', date.millis())
            
            # Get monthly dates
            months = ee.List.sequence(0, ee.Date(end_date).difference(ee.Date(start_date), 'month').subtract(1))
            start = ee.Date(start_date)
            monthly_dates = months.map(lambda m: start.advance(m, 'month'))
            
            chirps = ee.ImageCollection.fromImages(monthly_dates.map(monthly_sum))
        
        # Extract time series for Myanmar
        def extract_rainfall(image):
            # Calculate mean rainfall over Myanmar
            stats = image.reduceRegion(
                reducer=ee.Reducer.mean(),
                geometry=self.myanmar_geom,
                scale=5000,  # 5km resolution
                maxPixels=1e9
            )
            
            return ee.Feature(None, {
                'date': image.date().format('YYYY-MM-dd'),
                'rainfall_mm': stats.get('precipitation')
            })
        
        # Map over collection
        features = chirps.map(extract_rainfall)
        
        # Get data as list
        logger.info("Fetching data from Google Earth Engine...")
        data = features.getInfo()
        
        # Convert to DataFrame
        records = []
        for feature in data['features']:
            props = feature['properties']
            if props['rainfall_mm'] is not None:
                records.append({
                    'date': pd.to_datetime(props['date']),
                    'mean_rainfall_mm': props['rainfall_mm']
                })
        
        df = pd.DataFrame(records)
        df = df.sort_values('date').reset_index(drop=True)
        
        logger.info(f"Extracted {len(df)} rainfall records")
        return df
    
    def get_rainfall_by_region(self, start_date, end_date, regions_gdf, admin_column='ADM1_EN', temporal_resolution="monthly"):
        """
        Extract CHIRPS rainfall by administrative regions.
        
        Parameters:
        -----------
        start_date : str
            Start date (format: 'YYYY-MM-DD')
        end_date : str
            End date (format: 'YYYY-MM-DD')
        regions_gdf : geopandas.GeoDataFrame
            GeoDataFrame containing administrative regions
        admin_column : str
            Column name containing region names
        temporal_resolution : str
            Temporal resolution: "daily" or "monthly"
        
        Returns:
        --------
        pandas.DataFrame
            DataFrame with columns: region, date, rainfall_mm
        """
        logger.info(f"Extracting CHIRPS rainfall by region using column: {admin_column}")
        
        # Ensure CRS is WGS84
        if regions_gdf.crs is None:
            regions_gdf = regions_gdf.set_crs('EPSG:4326')
        elif regions_gdf.crs != 'EPSG:4326':
            regions_gdf = regions_gdf.to_crs('EPSG:4326')
        
        # Load CHIRPS dataset
        chirps = ee.ImageCollection('UCSB-CHG/CHIRPS/DAILY').filterDate(start_date, end_date).filterBounds(self.myanmar_geom)
        
        if temporal_resolution == "monthly":
            # Aggregate to monthly
            def monthly_sum(date):
                date = ee.Date(date)
                monthly = chirps.filterDate(date, date.advance(1, 'month')).sum()
                return monthly.set('system:time_start', date.millis())
            
            # Get monthly dates
            months = ee.List.sequence(0, ee.Date(end_date).difference(ee.Date(start_date), 'month').subtract(1))
            start = ee.Date(start_date)
            monthly_dates = months.map(lambda m: start.advance(m, 'month'))
            
            chirps = ee.ImageCollection.fromImages(monthly_dates.map(monthly_sum))
        
        # Extract for each region
        all_results = []
        
        for idx, region in regions_gdf.iterrows():
            region_name = region[admin_column]
            logger.info(f"Processing region: {region_name}")
            
            # Convert geometry to GEE format
            geom_json = region.geometry.__geo_interface__
            ee_geom = ee.Geometry(geom_json)
            
            # Extract rainfall for this region
            def extract_regional_rainfall(image):
                stats = image.reduceRegion(
                    reducer=ee.Reducer.mean(),
                    geometry=ee_geom,
                    scale=5000,
                    maxPixels=1e9
                )
                
                return ee.Feature(None, {
                    'date': image.date().format('YYYY-MM-dd'),
                    'rainfall_mm': stats.get('precipitation'),
                    'region': region_name
                })
            
            features = chirps.map(extract_regional_rainfall)
            data = features.getInfo()
            
            # Add to results
            for feature in data['features']:
                props = feature['properties']
                if props['rainfall_mm'] is not None:
                    all_results.append({
                        'region': props['region'],
                        'date': pd.to_datetime(props['date']),
                        'rainfall_mm': props['rainfall_mm']
                    })
        
        df = pd.DataFrame(all_results)
        df = df.sort_values(['region', 'date']).reset_index(drop=True)
        
        logger.info(f"Extracted {len(df)} region-date rainfall records")
        return df
    
    def save_to_csv(self, df, filename):
        """
        Save DataFrame to CSV file.
        
        Parameters:
        -----------
        df : pandas.DataFrame
            DataFrame to save
        filename : str
            Output filename
        
        Returns:
        --------
        str
            Path to saved file
        """
        output_path = self.output_dir / filename
        df.to_csv(output_path, index=False)
        logger.info(f"Saved data to {output_path}")
        return str(output_path)
