# Download Black Marble Data

# Setup ------------------------------------------------------------------------
#### Bearer token from NASA
# To get token, see: https://github.com/ramarty/download_blackmarble
bearer <- "BEARER-TOKEN-HERE"
bearer <- read_csv("~/Desktop/bearer_bm.csv") %>% pull(token)

##### Region of Interest

## Polygon around Syria and Turkey
syr_sp <- getData('GADM', country='SYR', level=0)
tur_sp <- getData('GADM', country='TUR', level=0)

# Combine Syria and Turkey into one polygon
roi_sp <- rbind(syr_sp, tur_sp)
roi_sp$id <- 1
roi_sp <- raster::aggregate(roi_sp, by = "id")
roi_sf <- roi_sp %>% st_as_sf()
