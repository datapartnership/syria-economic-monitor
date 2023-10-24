# Trends in Governorate NTL

# Files for ADM 3 and 4, and for the two types of daily data (1 = less processed;
# 2 = more processed)

# Prep border crossings --------------------------------------------------------
bc_df <- read_csv(file.path(bc_dir, "TUR_SYR_bordercrossings.csv"))
bc_df <- bc_df %>%
  clean_names()

bc_df$geometry <- NULL

coordinates(bc_df) <- ~longitude+latitude
crs(bc_df) <- CRS("+init=epsg:4326")

bc_sf <- bc_df %>% st_as_sf()
bc_sf <- st_buffer(bc_sf, dist = 1000)

# Monthly ----------------------------------------------------------------------
monthly_files <- list.files(file.path(ntl_bm_dir, "FinalData", paste0("monthly", "_rasters")))

ntl_monthly_df <- map_df(monthly_files, function(file_i){
  print(file_i)
  
  r <- rast(file.path(ntl_bm_dir, "FinalData", paste0("monthly", "_rasters"), file_i))
  
  bc_df <- bc_sf
  bc_df$geometry <- NULL
  bc_df$viirs_bm_mean <- exact_extract(r, bc_sf, 'mean')
  bc_df$viirs_bm_sum <- exact_extract(r, bc_sf, 'sum')
  bc_df$viirs_bm_median <- exact_extract(r, bc_sf, 'median')
  
  # Add date info
  bc_df$date <- file_i %>% 
    str_replace_all("VNP46A3_t", "") %>% 
    str_replace_all(".tif", "") %>%
    str_replace_all("_", "-") %>% 
    paste0("-01") %>% 
    ymd()
  
  #### Merge NTL with GADM data 
  bc_df$viirs_bm_mean[bc_df$viirs_bm_sum == 0]           <- 0
  
  return(bc_df)
})

write_csv(ntl_monthly_df, file.path(ntl_bm_dir, "FinalData", "aggregated", "border_xing_monthly.csv"))
saveRDS(ntl_monthly_df,   file.path(ntl_bm_dir, "FinalData", "aggregated", "border_xing_monthly.Rds"))

# for(file_i in rev(monthly_files)){
#   
#   OUT_FILE <- file.path(ntl_bm_dir, "FinalData", "aggregated", "border_xing_temp",
#                         "monthly_files", 
#                         paste0("syr_border_xing_", 
#                                file_i %>% str_replace_all(".tif", ".Rds")))
#   
#   if(!file.exists(OUT_FILE)){
#     
#     print(file_i)
#     
#     r <- rast(file.path(ntl_bm_dir, "FinalData", paste0("monthly", "_rasters"), file_i))
#     
#     bc_df <- bc_sf
#     bc_df$geometry <- NULL
#     bc_df$viirs_bm_mean <- exact_extract(r, bc_sf, 'mean')
#     bc_df$viirs_bm_sum <- exact_extract(r, bc_sf, 'sum')
#     bc_df$viirs_bm_median <- exact_extract(r, bc_sf, 'median')
#     
#     # Add date info
#     bc_df$date <- file_i %>% 
#       str_replace_all("VNP46A3_t", "") %>% 
#       str_replace_all(".tif", "") %>%
#       str_replace_all("_", "-") %>% 
#       paste0("-01") %>% 
#       ymd()
# 
#     #### Merge NTL with GADM data 
#     bc_df$viirs_bm_mean[bc_df$viirs_bm_sum == 0]           <- 0
#     
#     # Export -----------------------------------------------------------------------
#     saveRDS(bc_df, OUT_FILE)
#   }
# }

# Daily ------------------------------------------------------------------------
daily_files <- list.files(file.path(ntl_bm_dir, "FinalData", paste0("daily", "_rasters")))

ntl_daily_df <- map_df(daily_files, function(file_i){
  print(file_i)
  
  r <- rast(file.path(ntl_bm_dir, "FinalData", paste0("daily", "_rasters"), file_i))
  
  bc_df <- bc_sf
  bc_df$geometry <- NULL
  bc_df$viirs_bm_mean <- exact_extract(r, bc_sf, 'mean')
  bc_df$viirs_bm_sum <- exact_extract(r, bc_sf, 'sum')
  
  # Add date info
  bc_df$date <- file_i %>% 
    str_replace_all("VNP46A2_t", "") %>% 
    str_replace_all(".tif", "") %>%
    str_replace_all("_", "-") %>% 
    ymd()
  
  #### Merge NTL with GADM data 
  bc_df$viirs_bm_mean[bc_df$viirs_bm_sum == 0]           <- 0
  
  return(bc_df)
})

write_csv(ntl_daily_df, file.path(ntl_bm_dir, "FinalData", "aggregated", "border_xing_daily.csv"))
saveRDS(ntl_daily_df,   file.path(ntl_bm_dir, "FinalData", "aggregated", "border_xing_daily.Rds"))

# for(file_i in rev(daily_files)){
#   
#   OUT_FILE <- file.path(ntl_bm_dir, "FinalData", "aggregated", "border_xing_temp",
#                         "daily_files", 
#                         paste0("syr_border_xing_", 
#                                file_i %>% str_replace_all(".tif", ".Rds")))
#   
#   if(!file.exists(OUT_FILE)){
#     
#     print(file_i)
#     
#     r <- rast(file.path(ntl_bm_dir, "FinalData", paste0("daily", "_rasters"), file_i))
#     
#     bc_df <- bc_sf
#     bc_df$geometry <- NULL
#     bc_df$viirs_bm_mean <- exact_extract(r, bc_sf, 'mean')
#     bc_df$viirs_bm_sum <- exact_extract(r, bc_sf, 'sum')
# 
#     # Add date info
#     bc_df$date <- file_i %>% 
#       str_replace_all("VNP46A2_t", "") %>% 
#       str_replace_all(".tif", "") %>%
#       str_replace_all("_", "-") %>% 
#       ymd()
#     
#     #### Merge NTL with GADM data 
#     bc_df$viirs_bm_mean[bc_df$viirs_bm_sum == 0]           <- 0
#     
#     # Export -----------------------------------------------------------------------
#     saveRDS(bc_df, OUT_FILE)
#   }
# }
# 
