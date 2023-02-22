# Download Black Marble Data

# Setup ------------------------------------------------------------------------
#### Bearer token from NASA
# To get token, see: https://github.com/ramarty/download_blackmarble
BEARER <- "BEARER-TOKEN-HERE" 

##### Region of Interest

## Polygon around Syria and Turkey
syr_sp <- getData('GADM', country='SYR', level=0) 
tur_sp <- getData('GADM', country='TUR', level=0) 

# Combine Syria and Turkey into one polygon
roi_sp <- rbind(syr_sp, tur_sp)
roi_sp$id <- 1
roi_sp <- raster::aggregate(roi_sp, by = "id")
roi_sf <- roi_sp %>% st_as_sf()

# Download monthly data --------------------------------------------------------
# Downloads a raster for each month. If raster already created, skips calling 
# function.

for(year in 2022:2012){
  for(month in 1:12){
    OUT_FILE <- file.path(data_dir, 
                          "NTL BlackMarble",
                          "FinalData",
                          "VNP46A3_rasters",
                          paste0("bm_VNP46A3_",year,"_",pad2(month),".tif"))
    
    if(!file.exists(OUT_FILE)){
      r <- bm_raster(roi_sf = roi_sf,
                     product_id = "VNP46A3",
                     year = year,
                     month = month,
                     bearer = BEARER)
      
      writeRaster(r, OUT_FILE)
    }
  }
}

# Download daily data --------------------------------------------------------
# * Downloads a raster for each daily If raster already created, skips calling 
#   function.
# * Some days do not have data, which will cause an error. Use trycatch to skip
# * Both VNP46A1 and VNP46A2 are daily data. VNP46A2 has more corrections, but
#   VNP46A1 has more recent data. We download both.

for(year in 2023){
  for(day in 1:366){
    for(product_id in c("VNP46A1", "VNP46A2")){
      
      OUT_FILE <- file.path(data_dir, 
                            "NTL BlackMarble",
                            "FinalData",
                            paste0(product_id, "_rasters"),
                            paste0("bm_",product_id,"_",year,"_",pad3(day),".tif"))
      
      if(!file.exists(OUT_FILE)){
        
        out <- tryCatch(
          {
            
            r <- bm_raster(roi_sf = roi_sf,
                           product_id = product_id,
                           year = year,
                           day = day,
                           bearer = BEARER)
            
            writeRaster(r, OUT_FILE)
          },
          error=function(cond) {
            print("Error! Skipping.")
          }
        )
        
      }
    }
  }
}

