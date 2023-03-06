# Trends in Governorate NTL

# Files for ADM 3 and 4, and for the two types of daily data (1 = less processed;
# 2 = more processed)

DELETE_FILES <- F

if(DELETE_FILES){
  f_to_rm <- file.path(ntl_bm_dir, "FinalData", "aggregated", "border_xing_temp", "daily_files") %>%
    list.files(full.names = T,
               pattern = "*.Rds")
  
  for(f_i in f_to_rm){
    file.remove(f_i)
  }
}

# Prep border crossings --------------------------------------------------------
bc_df <- read_csv(file.path(bc_dir, "TUR_SYR_bordercrossings.csv"))
bc_df <- bc_df %>%
  clean_names()

bc_df$geometry <- NULL

coordinates(bc_df) <- ~longitude+latitude
crs(bc_df) <- CRS("+init=epsg:4326")

bc_sf <- bc_df %>% st_as_sf()
bc_sf <- st_buffer(bc_sf, dist = 1000)

# Daily ------------------------------------------------------------------------
daily_files <- list.files(file.path(ntl_bm_dir, "FinalData", paste0("VNP46A2", "_rasters")))

for(file_i in rev(daily_files)){
  
  OUT_FILE <- file.path(ntl_bm_dir, "FinalData", "aggregated", "border_xing_temp",
                        "daily_files", 
                        paste0("syr_border_xing_", 
                               file_i %>% str_replace_all(".tif", ".Rds")))
  
  if(!file.exists(OUT_FILE)){
    
    print(file_i)
    
    r <- raster(file.path(ntl_bm_dir, "FinalData", paste0("VNP46A2", "_rasters"), file_i))
    
    bc_df <- bc_sf
    bc_df$geometry <- NULL
    bc_df$viirs_bm_mean <- exact_extract(r, bc_sf, 'mean')
    bc_df$viirs_bm_sum <- exact_extract(r, bc_sf, 'sum')
    
    
    # Add date info
    year_i <- file_i %>% substring(12,15) %>% as.numeric()
    day_i  <- file_i %>% substring(17,19) %>% as.numeric()
    bc_df$year <- year_i
    bc_df$day  <- day_i
    bc_df$date <- as.Date(day_i, origin = paste0(year_i-1, "-12-31")) # 1 = Jan 1 of next year
    
    #### Merge NTL with GADM data 
    bc_df$viirs_bm_mean[bc_df$viirs_bm_sum == 0]           <- 0
    
    # Export -----------------------------------------------------------------------
    saveRDS(bc_df, OUT_FILE)
  }
}

# Monthyl ----------------------------------------------------------------------
monthly_files <- list.files(file.path(ntl_bm_dir, "FinalData", paste0("VNP46A3", "_rasters")))

for(file_i in rev(monthly_files)){
  
  OUT_FILE <- file.path(ntl_bm_dir, "FinalData", "aggregated", "border_xing_temp",
                        "monthly_files", 
                        paste0("syr_border_xing_", 
                               file_i %>% str_replace_all(".tif", ".Rds")))
  
  if(!file.exists(OUT_FILE)){
    
    print(file_i)
    
    r <- raster(file.path(ntl_bm_dir, "FinalData", paste0("VNP46A3", "_rasters"), file_i))
    
    bc_df <- bc_sf
    bc_df$geometry <- NULL
    bc_df$viirs_bm_mean <- exact_extract(r, bc_sf, 'mean')
    bc_df$viirs_bm_sum <- exact_extract(r, bc_sf, 'sum')
    
    
    # Add date info
    year_i <- file_i %>% substring(12,15) %>% as.numeric()
    month_i  <- file_i %>% substring(17,18) %>% as.numeric()
    bc_df$date <- paste0(year_i, "_", month_i, "-01") %>% ymd()

    #### Merge NTL with GADM data 
    bc_df$viirs_bm_mean[bc_df$viirs_bm_sum == 0]           <- 0
    
    # Export -----------------------------------------------------------------------
    saveRDS(bc_df, OUT_FILE)
  }
}



