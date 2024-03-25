# Trends in Governorate NTL

# Files for ADM 3 and 4, and for the two types of daily data (1 = less processed;
# 2 = more processed)

DELETE_FILES <- F

if(DELETE_FILES){
  f_to_rm <- file.path(ntl_bm_dir, "FinalData", "aggregated", "tur_temp", "daily_files") %>%
    list.files(full.names = T,
               pattern = "*.Rds")

  for(f_i in f_to_rm){
    file.remove(f_i)
  }
}

for(adm_i in rev(c(1,2))){
  for(product_id in c("VNP46A2")){

    # Load/prep gas flaring data ---------------------------------------------------
    #### Gas Flaring
    gf_df <- readRDS(file.path(gas_flare_dir, "FinalData", "gas_flare_locations.Rds"))

    coordinates(gf_df) <- ~longitude+latitude
    crs(gf_df) <- CRS("+init=epsg:4326")

    gf_sf <- gf_df %>% st_as_sf() %>% st_buffer(dist = 5000)
    gf_sp <- gf_sf %>% as("Spatial")

    ## Non GS Locations
    gadm_0_sp <- getData('GADM', country='TUR', level=0)
    gadm_0_sp$date <- NULL

    gadm_no_gf_sp <- gDifference(gadm_0_sp, gf_sp, byid=F)
    gadm_no_gf_sp$id <- 1

    # Load data --------------------------------------------------------------------
    gadm_sp <- getData('GADM', country='TUR', level=adm_i)

    gadm_df <- gadm_sp@data %>%
      dplyr::mutate(uid = 1:n())

    gadm_id_df <- gadm_df %>%
      dplyr::select(uid)

    # Extract VIIRS - Black Marble -------------------------------------------------
    daily_files <- list.files(file.path(ntl_bm_dir, "FinalData", paste0(product_id, "_rasters")))

    for(file_i in daily_files){

      OUT_FILE <- file.path(ntl_bm_dir, "FinalData", "aggregated",
                            "tur_temp", "daily_files",
                            paste0("tur_admin",
                                   adm_i, "_",
                                   file_i %>% str_replace_all(".tif", ".Rds")))

      if(!file.exists(OUT_FILE)){

        print(file_i)

        r <- raster(file.path(ntl_bm_dir, "FinalData", paste0(product_id, "_rasters"), file_i))

        r_gf   <- r %>% crop(gf_sp) %>% mask(gf_sp)
        r_nogf <- r %>% crop(gadm_no_gf_sp) %>% mask(gadm_no_gf_sp)

        gadm_sf <- gadm_sp %>% st_as_sf()

        gadm_id_df$viirs_bm_mean <- exact_extract(r, gadm_sf, 'mean')
        gadm_id_df$viirs_bm_sum <- exact_extract(r, gadm_sf, 'sum')

        gadm_id_df$viirs_bm_gf_mean <- exact_extract(r_gf, gadm_sf, 'mean')
        gadm_id_df$viirs_bm_gf_sum  <- exact_extract(r_gf, gadm_sf, 'sum')

        gadm_id_df$viirs_bm_nogf_mean <- exact_extract(r_nogf, gadm_sf, 'mean')
        gadm_id_df$viirs_bm_nogf_sum  <- exact_extract(r_nogf, gadm_sf, 'sum')

        # Add date info
        year_i <- file_i %>% substring(12,15) %>% as.numeric()
        day_i  <- file_i %>% substring(17,19) %>% as.numeric()
        gadm_id_df$year <- year_i
        gadm_id_df$day  <- day_i
        gadm_id_df$date <- as.Date(day_i, origin = paste0(year_i-1, "-12-31")) # 1 = Jan 1 of next year

        #### Merge NTL with GADM data
        data_df <- gadm_id_df %>%
          left_join(gadm_df, by = c("uid"))

        data_df$viirs_bm_mean[data_df$viirs_bm_sum == 0]           <- 0
        data_df$viirs_bm_gf_mean[data_df$viirs_bm_gf_sum == 0]     <- 0
        data_df$viirs_bm_nogf_mean[data_df$viirs_bm_nogf_sum == 0] <- 0

        # Export -----------------------------------------------------------------------
        saveRDS(data_df, OUT_FILE)
      }


    }
  }
}
