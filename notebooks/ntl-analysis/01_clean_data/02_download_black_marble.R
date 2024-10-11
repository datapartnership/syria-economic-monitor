# Download Black Marble Data

# Setup ------------------------------------------------------------------------
#### Bearer token from NASA
# To get token, see: https://github.com/ramarty/download_blackmarble
bearer <- "BEARER-TOKEN-HERE" 
bearer <- read_csv("~/Desktop/bearer_bm.csv") %>% pull(token)

##### Region of Interest

## Polygon around Syria and Turkey
syr_sp <- gadm(country = "SYR", level=1, path = tempdir()) |> st_as_sf()
tur_sp <- gadm(country = "TUR", level=1, path = tempdir()) |> st_as_sf()

# Combine Syria and Turkey into one polygon
roi_sp <- rbind(syr_sp, tur_sp)
roi_sp$id <- 1
roi_sf <- roi_sp %>% st_as_sf() #%>% st_combine()

# Download annual data --------------------------------------------------------
dir.create(file.path(data_dir, 
                     "NTL BlackMarble",
                     "FinalData",
                     "annual_rasters"))
bm_raster(roi_sf = roi_sf,
          product_id = "VNP46A4",
          date = 2012:2023,
          bearer = bearer,
          output_location_type = "file",
          file_dir = file.path(data_dir, 
                               "NTL BlackMarble",
                               "FinalData",
                               "annual_rasters"))

dir.create(file.path(data_dir, 
                     "NTL BlackMarble",
                     "FinalData",
                     "monthly_rasters"))
bm_raster(roi_sf = roi_sf,
          product_id = "VNP46A3",
          date = seq.Date(from = ymd("2012-01-01"), to = Sys.Date(), by = "month") %>% rev(),
          bearer = bearer,
          output_location_type = "file",
          file_dir = file.path(data_dir, 
                               "NTL BlackMarble",
                               "FinalData",
                               "monthly_rasters"))

dir.create(file.path(data_dir, 
                     "NTL BlackMarble",
                     "FinalData",
                     "daily_rasters"))
bm_raster(roi_sf = roi_sf,
          product_id = "VNP46A2",
          date = seq.Date(from = ymd("2022-01-01"), to = Sys.Date(), by = "day") %>% rev(),
          bearer = bearer,
          variable = "Gap_Filled_DNB_BRDF-Corrected_NTL",
          quality = NULL,
          output_location_type = "file",
          file_dir = file.path(data_dir, 
                               "NTL BlackMarble",
                               "FinalData",
                               "daily_rasters"))


