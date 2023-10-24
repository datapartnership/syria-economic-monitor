# Clean Turkey Nighttime Lights Data

for(ADM in 1:2){
  
  # Load data --------------------------------------------------------------------
  ntl_a1 <- read_csv(file.path(ntl_bm_dir, "FinalData", "aggregated", "tur_temp", paste0("tur_admin_daily",ADM,"_VNP46A1.csv")))
  ntl_a2 <- read_csv(file.path(ntl_bm_dir, "FinalData", "aggregated", "tur_temp", paste0("tur_admin_daily",ADM,"_VNP46A2.csv")))
  
  #ntl_a1 <- ntl_a1 %>% dplyr::filter(date >= ymd("2022-11-01"))
  #ntl_a2 <- ntl_a2 %>% dplyr::filter(date >= ymd("2022-11-01"))
  
  gadm_sp <- getData('GADM', country='TUR', level=ADM)
  
  eq <- readOGR(dsn = file.path(data_dir, "USGS Earthquake Location", "RawData", "mi.shp"))
  eq$mi <- as.numeric(eq$PARAMVALUE)
  
  ### Variable to merge
  gadm_sp$gadm_uid <- gadm_sp[[paste0("GID_", ADM)]]
  ntl_a1$gadm_uid  <- ntl_a1[[paste0("GID_", ADM)]]
  ntl_a2$gadm_uid  <- ntl_a2[[paste0("GID_", ADM)]]
  
  ### Clean NTL
  ntl_a1 <- ntl_a1 %>% 
    rename_at(vars(contains("viirs_bm_")) , ~ paste0(., "_raw")) %>%
    dplyr::select(gadm_uid, date, contains("viirs_bm_"))
  
  ntl_a2 <- ntl_a2 %>% 
    rename_at(vars(contains("viirs_bm_")) , ~ paste0(., "_corrected")) %>%
    dplyr::select(gadm_uid, date, contains("viirs_bm_"))
  
  # Spatial merge EQ and GADM ----------------------------------------------------
  gadm_sp$eq_mi <- lapply(1:nrow(gadm_sp), function(i){
    print(paste(i, "/", nrow(gadm_sp)))
    inter_tf <- gIntersects(gadm_sp[i,], eq, byid = T) %>% as.vector()
    return(max(eq$mi[inter_tf]))
  }) %>% 
    unlist() %>%
    as.vector()
  
  gadm_sp$eq_mi[gadm_sp$eq_mi %in% -Inf] <- NA
  
  # Merge ------------------------------------------------------------------------
  data_df <- ntl_a1 %>%
    full_join(ntl_a2, by = c("gadm_uid", "date")) %>%
    left_join(gadm_sp@data, by = "gadm_uid") 
  
  # Export -----------------------------------------------------------------------
  write_csv(data_df, file.path(ntl_bm_dir, "FinalData", "aggregated", 
                               paste0("tur_admin",ADM,"_eq_intensity.csv")))
}

# data_df %>%
#   dplyr::filter(date >= ymd("2023-02-01")) %>%
#   group_by(date, eq_mi) %>%
#   dplyr::summarise(viirs = mean(viirs_bm_mean_corrected, na.rm = T)) %>%
#   ggplot() +
#   geom_col(aes(x = date, y = viirs)) +
#   facet_wrap(~as.factor(eq_mi))
# 
# ntl_a2 %>%
#   group_by(date) %>%
#   dplyr::summarise(viirs_bm_mean = mean(viirs_bm_mean))
