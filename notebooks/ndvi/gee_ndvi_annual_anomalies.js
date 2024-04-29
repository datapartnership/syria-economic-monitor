// Set variables for country boundaries and crop mask layer
var gaul = ee.FeatureCollection("FAO/GAUL_SIMPLIFIED_500m/2015/level0");
var aoi = gaul.filterMetadata('ADM0_NAME', 'equals', 'Syrian Arab Republic');
var crop_mask = ee.Image("USGS/GFSAD1000_V1").gt(0).clip(aoi);

Map.centerObject(aoi, 7);
// Map.addLayer(aoi, {}, 'Syria');
// map.addLayer(crop_mask, {palette: ["ffffff", "028500"], bands: ['landcover']}, 'Crop Extent');

// Set variables for NDVI Datasets
var terra = ee.ImageCollection('MODIS/006/MOD13Q1').select('NDVI');
var aqua = ee.ImageCollection('MODIS/006/MYD13Q1').select('NDVI');
var modis = terra.merge(aqua);

// Set referece period (2000 to 2020, or 2021)
// We produced maps for both
// Filter data for day of year between 290th (October 17) and 180th (June 28)
// This period matches with the crop calendar as reported in ASAP (Anomaly hot Spots of Agricultural Production)

var modis_ref_2020 = modis.filter(ee.Filter.calendarRange(2020, 2020, 'year'))
        .filter(ee.Filter.calendarRange(290, 180, 'day_of_year'));

var modis_ref_2021 = modis.filter(ee.Filter.calendarRange(2021, 2021, 'year'))
        .filter(ee.Filter.calendarRange(290, 180, 'day_of_year'));

var modis_2022 = modis.filter(ee.Filter.calendarRange(2022, 2022, 'year'))
        .filter(ee.Filter.calendarRange(290, 180, 'day_of_year'));

var PrepareModis = function(image) {
  return image.clip(aoi).multiply(0.0001).mask(crop_mask)
  .set('date', image.date().format("YYYY_MM_dd"))
  .set('source', 'modis');
};

var modis_ref_2020_mean = modis_ref_2020.map(PrepareModis).mean();
var modis_ref_2021_mean = modis_ref_2021.map(PrepareModis).mean();
var modis_2022_mean = modis_2022.map(PrepareModis).mean();
var anom_2020 = modis_2022_mean.subtract(modis_ref_2020_mean); //.unmask(-999) Use unmask if exporting
var anom_2021 = modis_2022_mean.subtract(modis_ref_2021_mean); //.unmask(-999) Use unmask if exporting

var palettes = require('users/gena/packages:palettes');
var pal_div = palettes.colorbrewer.RdYlGn[9];
var pal_greens = palettes.colorbrewer.Greens[9];

var vis = {min: -0.25, max: 0.25, palette: pal_div};

Map.addLayer(anom_2021, {min: -0.25, max: 0.25, palette: pal_div}, "Change in NDVI, 2022 (diff. from 2021)");
Map.addLayer(anom_2020, {min: -0.25, max: 0.25, palette: pal_div}, "Change in NDVI, 2022 (diff. from 2020)");

// Map.addLayer(modis_ref_clipped, {min: 0, max: 1, palette: pal_greens}, "Reference Mean NDVI");

// Export.image.toDrive({
//   image: anom,
//   description: 'NDVI_2022_diff_2021',
//   maxPixels:10e9,
//   scale: 250,
//   region: aoi
// });
