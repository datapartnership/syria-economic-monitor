

for(adm_i in c("adm0",
               "adm1",
               "adm2",
               "adm3",
               "adm4",
               "border_crossings_1km")){
  for(time_type in c("monthly", "annual", "daily")){
    print(paste(adm_i, time_type))
    
    ## Load/append
    ntl_df <- file.path(ntl_bm_dir, "aggregated_individual_files",
                        paste0(adm_i),
                        time_type) %>%
      list.files(pattern = "*.Rds",
                 full.names = T) %>%
      map_df(readRDS)
    
    ## Cleanup
    ntl_df$viirs_bm_mean[ntl_df$viirs_bm_sum == 0]           <- 0
    ntl_df$viirs_bm_gf_mean[ntl_df$viirs_bm_gf_sum == 0]     <- 0
    ntl_df$viirs_bm_nogf_mean[ntl_df$viirs_bm_nogf_sum == 0] <- 0
    
    ## Export
    name_root <- paste0(adm_i, "_", time_type)
    
    ntl_df <- ntl_df %>%
      clean_names()
    
    saveRDS(ntl_df,   file.path(ntl_bm_dir, "aggregated", paste0(name_root, ".Rds")))
    write_csv(ntl_df, file.path(ntl_bm_dir, "aggregated", paste0(name_root, ".csv")))
    write_dta(ntl_df, file.path(ntl_bm_dir, "aggregated", paste0(name_root, ".dta")))
    
  }
}