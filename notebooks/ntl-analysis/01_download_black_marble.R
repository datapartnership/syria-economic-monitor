# Download Black Marble Data

BEARER <- "BEARER-TOKEN-HERE" # Bearer token from NASA

# Load data --------------------------------------------------------------------
# Load black marble grid and country polygons

## Black marble grid
grid_sf <- read_sf("https://raw.githubusercontent.com/ramarty/download_blackmarble/main/data/blackmarbletiles.geojson")

## Polygon around Syria and Turkey
syr_sp <- getData('GADM', country='SYR', level=0) 
tur_sp <- getData('GADM', country='TUR', level=0) 

## Region of Interest
# Combine Syria and Turkey into one polygon
rio_sp <- rbind(syr_sp, tur_sp)
rio_sp$id <- 1
rio_sp <- raster::aggregate(rio_sp, by = "id")
rio_sf <- rio_sp %>% st_as_sf()

# Grab tiles for Syria ---------------------------------------------------------
# Remove grid along edges, which causes st_intersects to fail
grid_sf <- grid_sf[!(grid_sf$TileID %>% str_detect("h00")),]
grid_sf <- grid_sf[!(grid_sf$TileID %>% str_detect("v00")),]

inter <- st_intersects(grid_sf, rio_sf, sparse = F) %>% as.vector()
grid_use_sf <- grid_sf[inter,]

# Download monthly -------------------------------------------------------------

## Create dataframe of all tiles
monthly_files_df <- read.csv("https://raw.githubusercontent.com/ramarty/download_blackmarble/main/data/VNP46A3.csv")

## Grab tiles in Syria
tile_ids_rx <- grid_use_sf$TileID %>% paste(collapse = "|")
monthly_files_use_df <- monthly_files_df[monthly_files_df$name %>% str_detect(tile_ids_rx),]

## Create year_month variable
monthly_files_use_df <- monthly_files_use_df %>%
  mutate(year_month = paste0(year, "-", month, "-01") %>%
           ymd() %>%
           substring(1,7) %>%
           str_replace_all("-", "_"))

for(year_month_i in unique(monthly_files_use_df$year_month)){
  
  OUT_FILE <- file.path(data_dir, 
                        "NTL BlackMarble",
                        "FinalData",
                        "VNP46A3_rasters",
                        paste0("bm_VNP46A3_",year_month_i,".tif"))
  
  if(!file.exists(OUT_FILE)){
    
    df_i <- monthly_files_use_df[monthly_files_use_df$year_month %in% year_month_i,]
    
    r_list <- lapply(df_i$name, function(name_i){
      download_raster(name_i, BEARER)
    })
    
    ## Mosaic rasters together
    names(r_list)    <- NULL
    r_list$fun       <- max
    
    r <- do.call(raster::mosaic, r_list) 
    
    writeRaster(r, OUT_FILE)
  }
}

# Download daily ---------------------------------------------------------------
# req <- GET("api.github.com/repos/ramarty/download_blackmarble/contents/data/VNP46A2")
# 
# daily_files <- lapply(content(req), function(i){
#   i$name
# }) %>% 
#   unlist()

year <- 2023
day <- 37

for(year in 2022:2023){
  for(day in rev(1:366)){
    
    print(paste(year, day))
    
    OUT_FILE <- file.path(data_dir, 
                          "NTL BlackMarble",
                          "FinalData",
                          "VNP46A2_rasters",
                          paste0("bm_VNP46A2_",year,"_",pad3(day),".tif"))
    
    if(!file.exists(OUT_FILE)){
      
      out <- tryCatch(
        {
          
          ## Create dataframe of all tiles
          day_files_df_i <- read.csv(paste0("https://raw.githubusercontent.com/ramarty/download_blackmarble/main/data/VNP46A2/",year,"/VNP46A2_", year, "_", pad3(day), ".csv"))
          
          ## Grab tiles in Syria
          tile_ids_rx <- grid_use_sf$TileID %>% paste(collapse = "|")
          day_files_df_i <- day_files_df_i[day_files_df_i$name %>% str_detect(tile_ids_rx),]
          
          r_list <- lapply(day_files_df_i$name, function(name_i){
            download_raster(name_i, BEARER)
          })
          
          ## Mosaic rasters together
          names(r_list)    <- NULL
          r_list$fun       <- max
          
          r <- do.call(raster::mosaic, r_list) 
          
          writeRaster(r, OUT_FILE)
          
        },
        error=function(cond) {
          print("Error! Skipping.")
        }
      )
      
      
    }
    
  }
}





# 
library(raster)

r <- raster("~/Desktop/bm_vnp46A3_2014_290.tif")
ra <- raster::aggregate(r, fact = 4)
ra[] <- log(ra[] + 1)

pal <- colorNumeric(c("#0C2C84", "#41B6C4", "#FFFFCC"), unique(ra[]),
                    na.color = "transparent")

leaflet() %>% addTiles() %>%
  addRasterImage(ra, colors = pal, opacity = 0.8) %>%
  addLegend(pal = pal, values = unique(ra[]),
            title = "Surface temp")
