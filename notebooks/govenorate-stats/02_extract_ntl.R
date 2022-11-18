# Extract NTL

# Functions --------------------------------------------------------------------
viirs_date <- function(i, year_start, month_start){
  
  year <- year_start
  month <- month_start
  
  if(i > 1){
    
    i <- i - 1
    
    for(i in 1:i){
      month <- month + 1
      
      if(month == 13){
        year <- year + 1
        month <- 1
      }
    }
    
  }
  
  return(list(year = year,
              month = month))
}

pad2 <- function(x){
  if(nchar(x) == 1) x <- paste0("0", x)
  return(x)
}

# Load data --------------------------------------------------------------------
gadm_sp <- readRDS(file.path(gov_stats_dir, "FinalData", "individual_files", "adm_blank.Rds"))

gadm_id_df <- gadm_sp@data %>%
  dplyr::select(uid)

# Extract VIIRS ----------------------------------------------------------------
r <- raster(file.path(ntl_viirs_dir, "RawData", 
                      "syr_viirs_raw_monthly_start_201204_avg_rad.tif"))

n_bands <- nbands(r)

viirs_df <- map_df(1:n_bands, function(i){
  print(i)
  
  r <- raster(file.path(ntl_viirs_dir, "RawData", 
                        "syr_viirs_raw_monthly_start_201204_avg_rad.tif"), i)
  
  gadm_id_df$viirs_mean <- exact_extract(r, gadm_sp, 'mean')
  
  date_i <- viirs_date(i, 2012, 4)
  
  gadm_id_df$year <- date_i$year
  gadm_id_df$month <- date_i$month
  
  return(gadm_id_df)
})

# Extract VIIRS - Corrected ----------------------------------------------------
r <- raster(file.path(ntl_viirs_c_dir, "RawData", 
                      "syr_viirs_corrected_monthly_start_201401_avg_rad.tif"))

n_bands <- nbands(r)

viirs_c_df <- map_df(1:n_bands, function(i){
  print(i)
  
  r <- raster(file.path(ntl_viirs_c_dir, "RawData", 
                        "syr_viirs_corrected_monthly_start_201401_avg_rad.tif"), i)
  
  gadm_id_df$viirs_c_mean <- exact_extract(r, gadm_sp, 'mean')
  
  date_i <- viirs_date(i, 2014, 1)
  
  gadm_id_df$year <- date_i$year
  gadm_id_df$month <- date_i$month
  
  return(gadm_id_df)
})

# Extract VIIRS - Black Marble -------------------------------------------------
ym_df <- cross_df(list(year = 2012:2022,
                       month = 1:12))

ym_df <- ym_df[!((ym_df$year %in% 2022) & (ym_df$month %in% 9:12)),]

viirs_bm_df <- map_df(1:nrow(ym_df), function(i){
  print(i)
  
  ym_i_df <- ym_df[i,]
  
  ym_i_df$year
  
  r <- raster(file.path(ntl_bm_dir, "FinalData", "monthly_rasters",
                        paste0("bm_vnp46A3_",ym_i_df$year,"_",ym_i_df$month %>% pad2(),
                               ".tif")))
  
  gadm_id_df$viirs_bm_mean <- exact_extract(r, gadm_sp, 'mean')
  
  gadm_id_df$year <- ym_i_df$year
  gadm_id_df$month <- ym_i_df$month
  
  return(gadm_id_df)
})

# Merge ------------------------------------------------------------------------
data_df <- viirs_bm_df %>%
  full_join(viirs_c_df, by = c("uid", "month", "year")) %>%
  full_join(viirs_df, by = c("uid", "month", "year")) %>%
  left_join(gadm_df, by = c("uid"))

# Export -----------------------------------------------------------------------
data_df <- data_df %>%
  dplyr::mutate(year_month = paste0(year, "-", month, "-01") %>% ymd())

saveRDS(data_df, file.path(gadm_dir, "FinalData", "ntl.Rds"))



