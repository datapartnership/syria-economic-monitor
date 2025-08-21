# Download Black Marble Data

# Setup ------------------------------------------------------------------------
#### Bearer token from NASA
# To get token, see: https://github.com/ramarty/download_blackmarble
bearer <- "BEARER-TOKEN-HERE"
bearer <- read_csv("~/Dropbox/bearer_bm.csv") %>% pull(token)

##### Region of Interest

## Polygon around Syria and Turkey
roi_sf <- read_sf(file.path(data_dir, "boundaries", "syr_admin0.shp")) %>%
  st_as_sf()

# Download annual data --------------------------------------------------------
bm_raster(roi_sf = roi_sf,
          product_id = "VNP46A4",
          date = 2012:2024,
          bearer = bearer,
          output_location_type = "file",
          file_dir = file.path(data_dir,
                               "NTL BlackMarble",
                               "FinalData",
                               "annual_rasters"))

bm_raster(roi_sf = roi_sf,
          product_id = "VNP46A3",
          date = seq.Date(from = ymd("2012-01-01"), to = Sys.Date(), by = "month") %>% rev(),
          bearer = bearer,
          output_location_type = "file",
          file_dir = file.path(data_dir,
                               "NTL BlackMarble",
                               "FinalData",
                               "monthly_rasters"))

bm_raster(roi_sf = roi_sf,
          product_id = "VNP46A2",
          date = seq.Date(from = ymd("2023-06-01"), to = Sys.Date(), by = "day") %>% rev(),
          bearer = bearer,
          output_location_type = "file",
          file_dir = file.path(data_dir,
                               "NTL BlackMarble",
                               "FinalData",
                               "daily_rasters"))
