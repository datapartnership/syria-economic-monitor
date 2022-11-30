# Extract DMSP

# Load data --------------------------------------------------------------------
#### Gas Flaring
gf_df <- readRDS(file.path(gas_flare_dir, "FinalData", "gas_flare_locations.Rds"))

coordinates(gf_df) <- ~longitude+latitude
crs(gf_df) <- CRS("+init=epsg:4326")

for(buffer in c(20000)){
  
  gf_sf <- gf_df %>% st_as_sf() %>% st_buffer(dist = buffer)
  gf_sp <- gf_sf %>% as("Spatial")
  gf_sp$id <- 1
  gf_sp <- raster::aggregate(gf_sp, by = "id")
  
  ## Non GS Locations
  # gadm_0_sp <- readRDS(file.path(gadm_dir, "RawData", paste0("gadm36_SYR_",0,"_sp.rds")))
  # 
  # gadm_no_gf_sp <- gDifference(gadm_0_sp, gf_sp, byid=F)
  # gadm_no_gf_sp$id <- 1
  
  # Extract NTL ------------------------------------------------------------------
  ntl_df <- map_df(1992:2022, function(year){
    print(year)
    
    df_out <- data.frame(year = year)
    
    if(year < 2022){
      
      #if(year <= 2013) r <- raster(file.path(dmsp_harmon_dir, "RawData", paste0("Harmonized_DN_NTL_",year,"_calDMSP.tif"))) %>% crop(gf_sp)
      #if(year > 2013) r <- raster(file.path(dmsp_harmon_dir, "RawData", paste0("Harmonized_DN_NTL_",year,"_simVIIRS.tif"))) %>% crop(gf_sp)
      
      #df_out$dmsp_harmon_mean <- exact_extract(r, gf_sp, 'mean')
      #df_out$dmsp_harmon_sum  <- exact_extract(r, gf_sp, 'sum')
      
      if(year <= 2013){
        r_dmps <- raster(file.path(dmsp_dir, "RawData", paste0("syr_dmspols_",year,".tif"))) %>% crop(gf_sp)
        
        df_out$dmsp_mean <- exact_extract(r_dmps, gf_sp, 'mean')
        #df_out$dmsp_sum  <- exact_extract(r_dmps, gf_sp, 'sum')
      }
    }
    
    if(year >= 2012){
      r_paths <- file.path("~/Desktop/monthly_rasters") %>%
        list.files(pattern = paste0("bm_vnp46A3_", year),
                   full.names = T)
      
      r_stack <- stack(r_paths)
      
      r_mean <- calc(r_stack, fun = mean)
      r_mean <- r_mean %>% crop(gf_sp) %>% mask(gf_sp)
      
      df_out$viirs_mean <- exact_extract(r_mean, gf_sp, 'mean')
      #df_out$viirs_sum  <- exact_extract(r_mean, gf_sp, 'sum')
    }
    
    return(df_out)
  })
  
  # Standardize ------------------------------------------------------------------
  ntl_df_over <- ntl_df %>%
    dplyr::filter(year %in% 2012:2013)
  
  r_min <- ntl_df_over$viirs_mean %>% min()
  r_max <- ntl_df_over$viirs_mean %>% max()
  
  t_min <- ntl_df_over$dmsp_mean %>% min()
  t_max <- ntl_df_over$dmsp_mean %>% max()
  
  ntl_df <- ntl_df %>%
    mutate(viirs_scale = ((viirs_mean - r_min)/(r_max - r_min))*(t_max - t_min) + t_min)
  
  ntl_df$ntl_scale <- ntl_df$dmsp_mean
  ntl_df$ntl_scale[is.na(ntl_df$ntl_scale)] <- ntl_df$viirs_scale[is.na(ntl_df$ntl_scale)]
  
  ggplot() +
    geom_col(data = ntl_df, aes(x = year, y = dmsp_mean)) +
    geom_line(data = ntl_df, aes(x = year, y = viirs_scale), color = "orange")
  
  write_csv(ntl_df, paste0("~/Desktop/dmsp_gasflare_",buffer,"m.csv"))
  
}

buffer = 20000
ntl_df <- read_csv(paste0("~/Desktop/dmsp_viirs_gasflare.csv"))

ggplot() +
  geom_col(data = ntl_df, aes(x = year, y = dmsp_mean)) +
  geom_line(data = ntl_df, aes(x = year, y = viirs_scale), color = "orange")

dmsp_df %>%
  #dplyr::filter(year <= 2013) %>%
  ggplot() +
  geom_line(aes(x = year,
                y = dmsp_mean))
