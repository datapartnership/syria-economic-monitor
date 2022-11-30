# Extract NTL to GADM

adm_i <- 1

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

#### Gas Flaring
gf_df <- readRDS(file.path(gas_flare_dir, "FinalData", "gas_flare_locations.Rds"))

coordinates(gf_df) <- ~longitude+latitude
crs(gf_df) <- CRS("+init=epsg:4326")

gf_sf <- gf_df %>% st_as_sf() %>% st_buffer(dist = 5000)
gf_sp <- gf_sf %>% as("Spatial")

## Non GS Locations
gadm_0_sp <- readRDS(file.path(gadm_dir, "RawData", paste0("gadm36_SYR_",0,"_sp.rds")))

#gadm_0_sp <- gSimplify(gadm_0_sp, tol = 1)
gadm_no_gf_sp <- gDifference(gadm_0_sp, gf_sp, byid=F)
gadm_no_gf_sp$id <- 1

# Load data --------------------------------------------------------------------
for(adm_i in 0:2){
  ## GADM
  gadm_sp <- readRDS(file.path(gadm_dir, "RawData", paste0("gadm36_SYR_",adm_i,"_sp.rds")))
  
  gadm_df <- gadm_sp@data %>%
    dplyr::select(paste0("NAME_", 0:adm_i), paste0("GID_", 0:adm_i)) %>%
    dplyr::mutate(uid = 1:n())
  
  gadm_id_df <- gadm_df %>%
    dplyr::select(uid)
  
  # Extract VIIRS ----------------------------------------------------------------
  r <- raster(file.path(ntl_viirs_dir, "RawData", 
                        "syr_viirs_raw_monthly_start_201204_avg_rad.tif"))
  
  n_bands <- nbands(r)
  
  viirs_df <- map_df(1:n_bands, function(i){
    print(i)
    
    r <- raster(file.path(ntl_viirs_dir, "RawData", 
                          "syr_viirs_raw_monthly_start_201204_avg_rad.tif"), i)
    
    r_gf   <- r %>% crop(gf_sp) %>% mask(gf_sp)
    r_nogf <- r %>% crop(gadm_no_gf_sp) %>% mask(gadm_no_gf_sp)
    
    gadm_id_df$viirs_mean <- exact_extract(r, gadm_sp, 'mean')
    gadm_id_df$viirs_sum  <- exact_extract(r, gadm_sp, 'sum')
    
    gadm_id_df$viirs_gf_mean <- exact_extract(r_gf, gadm_sp, 'mean')
    gadm_id_df$viirs_gf_sum  <- exact_extract(r_gf, gadm_sp, 'sum')
    
    gadm_id_df$viirs_nogf_mean <- exact_extract(r_nogf, gadm_sp, 'mean')
    gadm_id_df$viirs_nogf_sum  <- exact_extract(r_nogf, gadm_sp, 'sum')
    
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
    
    r_gf   <- r %>% crop(gf_sp) %>% mask(gf_sp)
    r_nogf <- r %>% crop(gadm_no_gf_sp) %>% mask(gadm_no_gf_sp)
    
    gadm_id_df$viirs_c_mean <- exact_extract(r, gadm_sp, 'mean')
    gadm_id_df$viirs_c_sum <- exact_extract(r, gadm_sp, 'sum')
    
    gadm_id_df$viirs_c_gf_mean <- exact_extract(r_gf, gadm_sp, 'mean')
    gadm_id_df$viirs_c_gf_sum  <- exact_extract(r_gf, gadm_sp, 'sum')
    
    gadm_id_df$viirs_c_nogf_mean <- exact_extract(r_nogf, gadm_sp, 'mean')
    gadm_id_df$viirs_c_nogf_sum  <- exact_extract(r_nogf, gadm_sp, 'sum')
    
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
    
    r <- raster(file.path(ntl_bm_dir, "FinalData", "monthly_rasters",
                          paste0("bm_vnp46A3_",ym_i_df$year,"_",ym_i_df$month %>% pad2(),
                                 ".tif")))
    
    r_gf   <- r %>% crop(gf_sp) %>% mask(gf_sp)
    r_nogf <- r %>% crop(gadm_no_gf_sp) %>% mask(gadm_no_gf_sp)
    
    gadm_id_df$viirs_bm_mean <- exact_extract(r, gadm_sp, 'mean')
    gadm_id_df$viirs_bm_sum <- exact_extract(r, gadm_sp, 'sum')
    
    gadm_id_df$viirs_bm_gf_mean <- exact_extract(r_gf, gadm_sp, 'mean')
    gadm_id_df$viirs_bm_gf_sum  <- exact_extract(r_gf, gadm_sp, 'sum')
    
    gadm_id_df$viirs_bm_nogf_mean <- exact_extract(r_nogf, gadm_sp, 'mean')
    gadm_id_df$viirs_bm_nogf_sum  <- exact_extract(r_nogf, gadm_sp, 'sum')
    
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
  
  saveRDS(data_df, file.path(gadm_dir, "FinalData", paste0("gadm_", adm_i, "_ntl.Rds")))
}

