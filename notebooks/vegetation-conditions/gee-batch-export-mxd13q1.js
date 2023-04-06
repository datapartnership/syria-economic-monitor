/*
 * MODIS Vegetation Indices (MOD13Q1 & MYD13Q1)
 *
 * Set of script to:
 * - Combine the two 16-day composites into a synthethic 8-day composite 
 *   containing data from both Aqua and Terra 
 * - Applying QC Bitmask
 * - Clipped for Ukraine and batch export the collection to Google Drive
 * 
 * Contact: Benny Istanto. Climate Geographer - GOST/DECAT/DECDG, The World Bank
 * If you found a mistake, send me an email to bistanto@worldbank.org
 * 
 * Changelog:
 * 2022-03-10 first draft
 *
 * ------------------------------------------------------------------------------
 */

/* 
 * BOUNDARY
 */
 
// Bounding box Ukraine
// var bbox_ukr = ee.Geometry.Rectangle(21.7, 43.7, 40.7, 52.4);
// var bnd_ukr = ee.FeatureCollection("users/bennyistanto/datasets/shp/bnd/ukr_bnd_adm0_geoboundaries");
// var ukr = bnd_ukr.geometry();
var bnd_syr = ee.FeatureCollection("users/bennyistanto/datasets/shp/bnd/syr_bnd_adm0");
var syr = bnd_syr.geometry();
// var bnd_mmr = ee.FeatureCollection("users/bennyistanto/datasets/shp/bnd/mmr_bnd_adm0");
// var mmr = bnd_mmr.geometry();

// Center of the map
// Map.setCenter(31.434, 48.996, 6); // Ukraine
Map.setCenter(38.555, 35.001, 7); // Syria
// Map.setCenter(96.431, 21.288, 6); // Myanmar

/*
 * QC BITMASK FUNCTIONs
 */
 
 //---
/*
 * Bitmask for SummaryQA
 *  Bits 0-1: VI quality (MODLAND QA Bits)
 *    0: Good data, use with confidence
 *    1: Marginal data, useful but look at detailed QA for more information
 *    2: Pixel covered with snow/ice
 *    3: Pixel is cloudy
 * 
 * Bitmask for DetailedQA
 *  Bits 0-1: VI quality (MODLAND QA Bits)
 *    0: VI produced with good quality
 *    1: VI produced, but check other QA
 *    2: Pixel produced, but most probably cloudy
 *    3: Pixel not produced due to other reasons than clouds
 *  Bits 2-5: VI usefulness
 *    0: Highest quality
 *    1: Lower quality
 *    2: Decreasing quality
 *    4: Decreasing quality
 *    8: Decreasing quality
 *    9: Decreasing quality
 *    10: Decreasing quality
 *    12: Lowest quality
 *    13: Quality so low that it is not useful
 *    14: L1B data faulty
 *    15: Not useful for any other reason/not processed
 *  Bits 6-7: Aerosol Quantity
 *    0: Climatology
 *    1: Low
 *    2: Intermediate
 *    3: High
 *  Bit 8: Adjacent cloud detected
 *    0: No
 *    1: Yes
 *  Bit 9: Atmosphere BRDF correction
 *    0: No
 *    1: Yes
 *  Bit 10: Mixed Clouds
 *    0: No
 *    1: Yes
 *  Bits 11-13: Land/water mask
 *    0: Shallow ocean
 *    1: Land (nothing else but land)
 *    2: Ocean coastlines and lake shorelines
 *    3: Shallow inland water
 *    4: Ephemeral water
 *    5: Deep inland water
 *    6: Moderate or continental ocean
 *    7: Deep ocean
 *  Bit 14: Possible snow/ice
 *    0: No
 *    1: Yes
 *  Bit 15: Possible shadow
 *    0: No
 *    1: Yes
*/

// How to get good quality image
// Using bitwiseExtract function from Daniel Wiell
// Reference: https://gis.stackexchange.com/a/349401
// Example: A mask with "Good data, use with confidence" would be bitwiseExtract(image, 0, 1).eq(0)

/*
 * Utility to extract bitmask values. 
 * Look up the bit-ranges in the catalog. 
 * 
 * value - ee.Number of ee.Image to extract from.
 * fromBit - int or ee.Number with the first bit.
 * toBit - int or ee.Number with the last bit (inclusive). 
 *         Defaults to fromBit.
 */
function bitwiseExtract(value, fromBit, toBit) {
  if (toBit === undefined)
    toBit = fromBit;
  var maskSize = ee.Number(1).add(toBit).subtract(fromBit);
  var mask = ee.Number(1).leftShift(maskSize).subtract(1);
  return value.rightShift(fromBit).bitwiseAnd(mask);
}

// Applying the SummaryQA  and DetailedQA
var modisQA_mask = function(image) {
  var sqa = image.select('SummaryQA');
  var dqa = image.select('DetailedQA');
  var viQualityFlagsS = bitwiseExtract(sqa, 0, 1); 
  var viQualityFlagsD = bitwiseExtract(dqa, 0, 1);
  // var viUsefulnessFlagsD = bitwiseExtract(dqa, 2, 5);
  var viSnowIceFlagsD = bitwiseExtract(dqa, 14);
  var viShadowFlagsD = bitwiseExtract(dqa, 15);
  var mask = viQualityFlagsS.eq(0) // Good data, use with confidence
    .and(viQualityFlagsD.eq(0)) // VI produced with good quality
    // .or(viUsefulnessFlagsD.eq(0)) // Highest quality
    .and(viQualityFlagsS.eq(1)) // Marginal data, useful but look at detailed QA for more information
    .and(viQualityFlagsD.eq(1)) // VI produced, but check other QA
    .and(viSnowIceFlagsD).eq(0); // No snow/ice
    // .and(viShadowFlagsD).eq(0); // No shadow
  return image.updateMask(mask);
};

/*
 * DATE AND DATA
 */
 
// 8-days MODIS EVI/NDVI Dataset Availability:
// Terra - https://developers.google.com/earth-engine/datasets/catalog/MODIS_006_MOD13Q1?hl=en
// Aqua - https://developers.google.com/earth-engine/datasets/catalog/MODIS_006_MYD13Q1?hl=en

// Import MODIS
var MOD13 = ee.ImageCollection('MODIS/061/MOD13Q1'); // Terra
var MYD13 = ee.ImageCollection('MODIS/061/MYD13Q1'); // Aqua
// I will use MXD as code for combined Terra and Aqua

// Start and End date available
var start_period = ee.Date('2023-01-01'); // First MOD/MYD 13Q1 data 24 Feb 2000, 4 Jul 2002
var end_period = ee.Date('2023-12-31'); // Last MOD/MYD 13Q1 data 18 Feb 2022, 10 Feb 2022

/*
 * INITIAL PROCESS
 */

// Bring in MODIS data. Select EVI/NDVI and pre-processed Quality Control Band
// MODIS VI Terra
var mod13q1 = MOD13.select(['EVI','SummaryQA','DetailedQA'])
  .filterDate(start_period, end_period);
// MODIS VI Aqua
var myd13q1 = MYD13.select(['EVI','SummaryQA','DetailedQA'])
  .filterDate(start_period, end_period);

// Removed bad pixel
// Mask the less than Good images from the collection of images
// MODIS VI Terra only with good pixel
var mod13q1_QC = mod13q1.map(modisQA_mask);
// MODIS VI Terra only with good pixel
var myd13q1_QC = myd13q1.map(modisQA_mask);

// MODIS EVI/NDVI cleaned
var mxd13q1_cleaned = mod13q1_QC.select('EVI').merge(myd13q1_QC.select('EVI'));
// Sorted time
var mxd13q1_cleaned_sorted = mxd13q1_cleaned.sort("system:time_start");
print(mxd13q1_cleaned_sorted);

// Symbology
var viVis = {
  min: 0.0,
  max: 8000.0,
  palette: [
    'FFFFFF', 'CE7E45', 'DF923D', 'F1B555', 'FCD163', '99B718', '74A901',
    '66A000', '529400', '3E8601', '207401', '056201', '004C00', '023B01',
    '012E01', '011D01', '011301'
  ],
};

// Test the output as expected or not
// Add last image to map display

Map.addLayer(mxd13q1_cleaned_sorted.select('EVI').first().clip(syr), viVis, 'VI');

/*
 * DOWNLOADS 
 */

// // Test for 1 image
// Export.image.toDrive({
//   image: mxd13q1_4326.select('EVI').first().clip(ukr).unmask(-32768, false).toInt16(),
//   description: 'mmr_phy_mxd13q1_evi_test',
//   scale: 250,
//   maxPixels: 1e13,
//   region: ukr
// });      

// Batch export
mxd13q1_cleaned_sorted
  .aggregate_array('system:index')
  .evaluate(function (indexes){
    indexes.forEach(function (index) {
      var image = mxd13q1_cleaned_sorted
        .filterMetadata('system:index', 'equals', index)
        .first();
      var filename = 'syr_phy_mxd13q1_evi_' + index.replace(/_(\d{4})_(\d{2})_(\d{2})$/, '_$1$2$3');
      Export.image.toDrive({
        image: image.select('EVI').clip(syr).unmask(-32768, false).toInt16(),
        description: filename,
        folder:'syr_mxd13q1_evi',
        scale: 250,
        maxPixels: 1e13,
        region: syr,
        crs: 'EPSG:4326'
      });      
    });
});

// End of script

/*
 * Exporting image without clicking RUN button
 * 
 * 1. Run your Google Earth Engine code;
 * 2. Wait until all the tasks are listed (the Run buttons are shown);
 * 3. Click two computer keys fn and f12 at the same time and bring up console;
 *    or find it via: menubar Develop > Show JavaScript Console (Safari),
 *    and menubar View > Developer > JavaScript Console (Chrome)
 * 4. Copy and paste (line 267-276 below) into the console, press Enter;
 * 5. Wait until the code sends messages to the server to run all the tasks (you wait and relax);
 * 6. Wait until GEE shows the dialogue window asking you to click "Run"; 
 *    then Copy and paste (line 278-289 below), press Enter
 *    Notes: 
 *    Please bear in mind, the time execution is depend on the image size you will export. 
 *    Example, 1 year data for Ukraine on MODIS VI takes a minute to popup a window "Task: Initiate image export".
 * 7. Keep your computer open until all the tasks (Runs) are done 
 *    (you probably need to set your computer to never sleep).
 */

/**
 * Copyright (c) 2017 Dongdong Kong. All rights reserved.
 * This work is licensed under the terms of the MIT license.  
 * For a copy, see <https://opensource.org/licenses/MIT>.
 *
 * Batch execute GEE Export task
 *
 * First of all, You need to generate export tasks. And run button was shown.
 *   
 * Then press F12 get into console, then paste those scripts in it, and press 
 * enter. All the task will be start automatically. 
 * (Firefox and Chrome are supported. Other Browsers I didn't test.)
 * 
 * @Author: 
 *  Dongdong Kong, 28 Aug' 2017, Sun Yat-sen University
 *  yzq.yang, 17 Sep' 2021
 */

/*
function runTaskList(){
    // var tasklist = document.getElementsByClassName('task local type-EXPORT_IMAGE awaiting-user-config');
    // for (var i = 0; i < tasklist.length; i++)
    //         tasklist[i].getElementsByClassName('run-button')[0].click();
    $$('.run-button' ,$$('ee-task-pane')[0].shadowRoot).forEach(function(e) {
         e.click();
    })
}

runTaskList();

function confirmAll() {
    // var ok = document.getElementsByClassName('goog-buttonset-default goog-buttonset-action');
    // for (var i = 0; i < ok.length; i++)
    //     ok[i].click();
    $$('ee-table-config-dialog, ee-image-config-dialog').forEach(function(e) {
         var eeDialog = $$('ee-dialog', e.shadowRoot)[0]
         var paperDialog = $$('paper-dialog', eeDialog.shadowRoot)[0]
         $$('.ok-button', paperDialog)[0].click()
    })
}

confirmAll();
*/