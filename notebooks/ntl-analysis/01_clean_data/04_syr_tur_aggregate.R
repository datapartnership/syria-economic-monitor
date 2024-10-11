# Trends in Governorate NTL

# Files for ADM 3 and 4, and for the two types of daily data (1 = less processed;
# 2 = more processed)

DELETE_FILES <- F

if(DELETE_FILES){
  f_to_rm <- file.path(ntl_bm_dir, "FinalData", "aggregated", "syr_temp", "daily") %>%
    list.files(full.names = T,
               pattern = "*.Rds")
  
  for(f_i in f_to_rm){
    file.remove(f_i)
  }
  
  f_to_rm <- file.path(ntl_bm_dir, "FinalData", "aggregated", "tur_temp", "daily") %>%
    list.files(full.names = T,
               pattern = "*.Rds")
  
  for(f_i in f_to_rm){
    file.remove(f_i)
  }
  
  f_to_rm <- file.path(ntl_bm_dir, "FinalData", "aggregated", "syr_temp", "monthly") %>%
    list.files(full.names = T,
               pattern = "*.Rds")
  
  for(f_i in f_to_rm){
    file.remove(f_i)
  }
  
  f_to_rm <- file.path(ntl_bm_dir, "FinalData", "aggregated", "tur_temp", "monthly") %>%
    list.files(full.names = T,
               pattern = "*.Rds")
  
  for(f_i in f_to_rm){
    file.remove(f_i)
  }
  
  f_to_rm <- file.path(ntl_bm_dir, "FinalData", "aggregated", "syr_temp", "annual") %>%
    list.files(full.names = T,
               pattern = "*.Rds")
  
  for(f_i in f_to_rm){
    file.remove(f_i)
  }
  
  f_to_rm <- file.path(ntl_bm_dir, "FinalData", "aggregated", "tur_temp", "annual") %>%
    list.files(full.names = T,
               pattern = "*.Rds")
  
  for(f_i in f_to_rm){
    file.remove(f_i)
  }
}



# Extract data -----------------------------------------------------------------
adm_i <- 2
product_id <- "annual"
country_code <- "syr"

for(adm_i in 0:4){ # 0:4
  for(product_id in c("annual" , "monthly", "daily")){ # annual", "monthly", "daily"
    for(country_code in c("tur", "syr")){ # c("tur", "syr")
      
      if( (country_code == "tur") & (adm_i %in% c(3,4)) ){
        next
      }
      
      # Load/prep gas flaring data ---------------------------------------------------
      ## Non GS Locations
      if(country_code == "syr"){
        gadm_0_sp <- read_sf(file.path(unocha_dir, "RawData", "syr_admbnda_adm0_uncs_unocha_20201217.json")) 
        gadm_0_sp$date <- NULL
      }
      
      if(country_code == "tur"){
        gadm_0_sp <- read_sf(file.path(data_dir, "turkey_administrativelevels0_1_2", "tur_polbnda_adm0.shp"))
        gadm_0_sp$date <- NULL
      }
      
      #### Gas Flaring
      gf_df <- readRDS(file.path(gas_flare_dir, "FinalData", "gas_flare_locations.Rds"))
      
      gf_sf <- st_as_sf(gf_df, coords = c("longitude", "latitude"), crs = 4326)
      gf_sf <- gf_sf %>% st_intersection(gadm_0_sp)
      
      gf_sf <- gf_sf %>% st_buffer(dist = 5000)
      
      #### Non-GF locations
      gf_combine_sf <- gf_sf %>%
        mutate(id = 1) %>%
        group_by(id) %>%
        summarise(geometry = geometry %>%
                    st_union() %>%
                    st_make_valid())
      
      gf_combine_sf <- gf_combine_sf[2,]
      
      gadm_no_gf_sp <- st_difference(gadm_0_sp, gf_combine_sf)
      gadm_no_gf_sp$id <- 1
      
      # Load data --------------------------------------------------------------------
      if(country_code == "syr"){
        
        if(adm_i == 0){
          gadm_sp <- read_sf(file.path(unocha_dir, "RawData", "syr_admbnda_adm0_uncs_unocha_20201217.json")) 
          gadm_sp$date <- NULL
        }
        
        if(adm_i == 1){
          gadm_sp <- read_sf(file.path(unocha_dir, "RawData", "syr_admbnda_adm1_uncs_unocha_20201217.json")) 
          gadm_sp$date <- NULL
        }
        
        if(adm_i == 2){
          gadm_sp <- read_sf(file.path(unocha_dir, "RawData", "syr_admbnda_adm2_uncs_unocha_20201217.json")) 
          gadm_sp$date <- NULL
        }
        
        if(adm_i == 3){
          gadm_sp <- read_sf(file.path(unocha_dir, "RawData", "syr_admbnda_adm3_uncs_unocha_20201217.json")) 
          gadm_sp$date <- NULL
        }
        
        # Point file, so create circles with 0.5km radius
        if(adm_i == 4){
          gadm_sp <- read_sf(file.path(unocha_dir, "RawData", "syr_pplp_adm4_unocha_20210113.json")) 
          gadm_sp$date <- NULL
          
          gadm_sp <- geo.buffer(gadm_sp, r = 0.5*1000)
          
          gadm_sp <- gadm_sp %>%
            group_by(ADM0_EN, ADM1_EN, ADM2_EN, ADM3_EN, ADM4_EN) %>%
            summarise(geometry = geometry %>% st_union) %>%
            ungroup()
          
        }
      }
      
      if(country_code == "tur"){
        
        if(adm_i == 0){
          gadm_sp <- read_sf(file.path(data_dir, "turkey_administrativelevels0_1_2", "tur_polbnda_adm0.shp")) 
        }
        
        if(adm_i == 1){
          gadm_sp <- read_sf(file.path(data_dir, "turkey_administrativelevels0_1_2", "tur_polbnda_adm1.shp")) 
        }
        
        if(adm_i == 2){
          gadm_sp <- read_sf(file.path(data_dir, "turkey_administrativelevels0_1_2", "tur_polbna_adm2.shp")) 
        }

        
      }
      
      gadm_df <- gadm_sp %>%
        dplyr::mutate(uid = 1:n())
      
      gadm_id_df <- gadm_df %>%
        dplyr::select(uid)
      
      # Extract VIIRS - Black Marble -------------------------------------------------
      daily_files <- list.files(file.path(ntl_bm_dir, "FinalData", paste0(product_id, "_rasters")))
      
      for(file_i in rev(daily_files)){
        
        OUT_FILE <- file.path(ntl_bm_dir, "FinalData", "aggregated", 
                              paste0(country_code,"_temp"), product_id,
                              paste0("admin", 
                                     adm_i, "_", 
                                     file_i %>% str_replace_all(".tif", ".Rds")))
        
        dir.create(file.path(ntl_bm_dir, "FinalData", "aggregated", 
                             paste0(country_code,"_temp")))
        
        dir.create(file.path(ntl_bm_dir, "FinalData", "aggregated", 
                             paste0(country_code,"_temp"), product_id))
        
        if(!file.exists(OUT_FILE)){
          
          print(file_i)
          
          r <- raster(file.path(ntl_bm_dir, "FinalData", paste0(product_id, "_rasters"), file_i))
          
          r_gf   <- r %>% crop(gf_sf) %>% mask(gf_sf)
          r_nogf <- r %>% crop(gadm_no_gf_sp) %>% mask(gadm_no_gf_sp)
          
          gadm_sf <- gadm_sp
          
          gadm_id_df$viirs_bm_mean <- exact_extract(r, gadm_sf, 'mean')
          gadm_id_df$viirs_bm_sum <- exact_extract(r, gadm_sf, 'sum')
          gadm_id_df$viirs_bm_median <- exact_extract(r, gadm_sf, 'median')
          
          gadm_id_df$viirs_bm_gf_mean <- exact_extract(r_gf, gadm_sf, 'mean')
          gadm_id_df$viirs_bm_gf_sum  <- exact_extract(r_gf, gadm_sf, 'sum')
          
          gadm_id_df$viirs_bm_nogf_mean <- exact_extract(r_nogf, gadm_sf, 'mean')
          gadm_id_df$viirs_bm_nogf_sum  <- exact_extract(r_nogf, gadm_sf, 'sum')
          
          # Add date info
          if(product_id == "daily"){
            gadm_id_df$date <- file_i %>% 
              str_replace_all(".*qflag_t", "") %>% 
              str_replace_all(".tif", "") %>%
              ymd()
          }
          
          if(product_id == "monthly"){
            gadm_id_df$date <- file_i %>% 
              str_replace_all(".*qflag_t", "") %>% 
              str_replace_all(".tif", "") %>%
              paste0("-01") %>%
              ymd()
          }
          
          if(product_id == "annual"){
            gadm_id_df$date <- file_i %>%
              str_replace_all(".*qflag_t", "") %>% 
              str_replace_all(".tif", "") %>%
              as.numeric()
          }
          
          #### Merge NTL with GADM data 
          gadm_data_df <- gadm_df %>%
            st_drop_geometry()
          
          data_df <- gadm_id_df %>%
            left_join(gadm_data_df, by = c("uid"))
          
          data_df$viirs_bm_mean[data_df$viirs_bm_sum == 0]           <- 0
          data_df$viirs_bm_gf_mean[data_df$viirs_bm_gf_sum == 0]     <- 0
          data_df$viirs_bm_nogf_mean[data_df$viirs_bm_nogf_sum == 0] <- 0
          
          # Export -----------------------------------------------------------------------
          saveRDS(data_df, OUT_FILE)
        }
        
      }
    }
  }
}
