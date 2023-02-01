# Download Black Marble Data

BEARER <- "BEARER-TOKEN-HERE" # Bearer token from NASA

# Load data --------------------------------------------------------------------
# Load black marble grid and Syria polygon

grid_sf <- read_sf("https://raw.githubusercontent.com/ramarty/download_blackmarble/main/data/blackmarbletiles.geojson")
syr_sf <- getData('GADM', country='SYR', level=0) %>% st_as_sf()

# Grab tiles for Syria ---------------------------------------------------------
# Remove grid along edges, which causes st_intersects to fail
grid_sf <- grid_sf[!(grid_sf$TileID %>% str_detect("h00")),]
grid_sf <- grid_sf[!(grid_sf$TileID %>% str_detect("v00")),]

inter <- st_intersects(grid_sf, syr_sf, sparse = F) %>% as.vector()
grid_use_sf <- grid_sf[inter,]

# Dataframe of files to download -----------------------------------------------

## Create dataframe of all tiles
monthly_files_df <- read.csv("https://raw.githubusercontent.com/ramarty/download_blackmarble/main/data/monthly_datasets.csv")

## Grab tiles in Syria
tile_ids_rx <- grid_use_sf$TileID %>% paste(collapse = "|")
monthly_files_use_df <- monthly_files_df[monthly_files_df$name %>% str_detect(tile_ids_rx),]

## Create year_month variable
monthly_files_use_df <- monthly_files_use_df %>%
  mutate(month_day_start = month_day_start %>% pad3(),
         month = month_day_start %>% month_start_day_to_month(),
         year_month = paste0(year, "_", month))

# Download data ----------------------------------------------------------------
for(year_month_i in unique(monthly_files_use_df$year_month)){
  
  OUT_FILE <- file.path(data_dir, paste0("bm_vnp46A3_",year_month_i,".tif"))
  
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