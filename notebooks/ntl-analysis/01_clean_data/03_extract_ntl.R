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
}



# Load/prep gas flaring data ---------------------------------------------------
#### Gas Flaring
gf_df <- readRDS(file.path(gas_flare_dir, "FinalData", "gas_flare_locations.Rds"))

gf_sf <- st_as_sf(gf_df,
                  coords = c("longitude", "latitude"),
                  crs = 4326)

gf_sf <- gf_sf %>% st_buffer(dist = 5000)

# Extract data -----------------------------------------------------------------
adm_i <- "border_crossings_1km"
time_type <- "daily"

for(adm_i in rev(c("adm0",
                   "adm1",
                   "adm2",
                   "adm3",
                   "adm4",
                   "border_crossings_1km"))){
  for(time_type in c("annual", "monthly", "daily")){
    
    # Load data --------------------------------------------------------------------
    if(adm_i == "border_crossings_1km"){
      gadm_sf <- read_sf(file.path(data_dir, "Border Crossings", 
                                   "TUR_SYR_bordercrossings_1kmbuffer.geojson"))
    }
    
    if(adm_i == "adm0"){
      gadm_sf <- read_sf(file.path(unocha_dir, "syr_pplp_adm4_unocha_20210113", 
                                   "syr_admbnda_adm0_uncs_unocha_20201217.json"))
      gadm_sf$date <- NULL
    }
    
    if(adm_i == "adm1"){
      gadm_sf <- read_sf(file.path(unocha_dir, "syr_pplp_adm4_unocha_20210113", 
                                   "syr_admbnda_adm1_uncs_unocha_20201217.json")) 
      gadm_sf$date <- NULL
    }
    
    if(adm_i == "adm2"){
      gadm_sf <- read_sf(file.path(unocha_dir, "syr_pplp_adm4_unocha_20210113", 
                                   "syr_admbnda_adm2_uncs_unocha_20201217.json")) 
      gadm_sf$date <- NULL
    }
    
    if(adm_i == "adm3"){
      gadm_sf <- read_sf(file.path(unocha_dir, "syr_pplp_adm4_unocha_20210113",
                                   "syr_admbnda_adm3_uncs_unocha_20201217.json")) 
      gadm_sf$date <- NULL
    }
    
    # Point file, so create circles with 0.5km radius
    if(adm_i == "adm4"){
      gadm_sf <- read_sf(file.path(unocha_dir, "syr_pplp_adm4_unocha_20210113", 
                                   "syr_pplp_adm4_unocha_20210113.json")) 
      gadm_sf$date <- NULL
      
      gadm_sf <- gadm_sf %>% st_buffer(dist = 500)
      
      gadm_sf <- gadm_sf %>%
        group_by(ADM0_EN, ADM1_EN, ADM2_EN, ADM3_EN, ADM4_EN) %>%
        dplyr::summarise(geometry = geometry %>% st_union()) %>%
        ungroup()
      
    }
    
    
    # Extract VIIRS - Black Marble -------------------------------------------------
    bm_files <- list.files(file.path(ntl_bm_dir, "rasters", time_type))
    
    for(file_i in bm_files){
      
      if(time_type == "annual"){
        date_i <- file_i %>%
          str_replace_all("VNP46A4_NearNadir_Composite_Snow_Free_qflag_t", "") %>%
          str_replace_all(".tif", "")
        
        date_clean_i <- date_i %>% as.numeric()
      }
      
      if(time_type == "monthly"){
        date_i <- file_i %>%
          str_replace_all("VNP46A3_NearNadir_Composite_Snow_Free_qflag_t", "") %>%
          str_replace_all(".tif", "")
        
        date_clean_i <- date_i %>%
          str_replace_all("_", "-") %>%
          paste0("-01") %>%
          ymd()
      }
      
      if(time_type == "daily"){
        date_i <- file_i %>%
          str_replace_all("VNP46A2_Gap_Filled_DNB_BRDF-Corrected_NTL_qflag_t", "") %>%
          str_replace_all(".tif", "")
        
        date_clean_i <- date_i %>%
          str_replace_all("_", "-") %>%
          ymd()
      }
      
      dir.create(file.path(ntl_bm_dir, "aggregated_individual_files", paste0(adm_i)))
      dir.create(file.path(ntl_bm_dir, "aggregated_individual_files", paste0(adm_i), time_type))
      
      OUT_FILE <- file.path(ntl_bm_dir, "aggregated_individual_files",
                            paste0(adm_i),
                            time_type,
                            paste0(date_i, ".Rds"))
      
      if(!file.exists(OUT_FILE)){
        
        print(file_i)
        
        r <- raster(file.path(ntl_bm_dir, "rasters", time_type, file_i))
        
        r_gf   <- r %>% mask(gf_sf)
        r_nogf <- r %>% mask(gf_sf, inverse = TRUE)
        
        gadm_ntl_sf <- gadm_sf
        
        gadm_ntl_sf$viirs_bm_mean <- exact_extract(r, gadm_ntl_sf, 'mean')
        gadm_ntl_sf$viirs_bm_sum <- exact_extract(r, gadm_ntl_sf, 'sum')
        gadm_ntl_sf$viirs_bm_median <- exact_extract(r, gadm_ntl_sf, 'median')
        
        gadm_ntl_sf$viirs_bm_gf_mean <- exact_extract(r_gf, gadm_ntl_sf, 'mean')
        gadm_ntl_sf$viirs_bm_gf_sum  <- exact_extract(r_gf, gadm_ntl_sf, 'sum')
        
        gadm_ntl_sf$viirs_bm_nogf_mean <- exact_extract(r_nogf, gadm_ntl_sf, 'mean')
        gadm_ntl_sf$viirs_bm_nogf_sum  <- exact_extract(r_nogf, gadm_ntl_sf, 'sum')
        
        gadm_ntl_sf$date <- date_clean_i
        
        
        #### Merge NTL with GADM data
        gadm_ntl_df <- gadm_ntl_sf %>%
          st_drop_geometry()
        
        # Export -----------------------------------------------------------------------
        saveRDS(gadm_ntl_df, OUT_FILE)
      }
      
    }
  }
}

