

for(adm_i in 0:4){
  for(time_type in c("monthly", "annual", "daily")){
    
    ## Load/append
    ntl_df <- file.path(ntl_bm_dir, "aggregated_individual_files",
                        paste0("adm", adm_i),
                        time_type) %>%
      list.files(pattern = "*.Rds",
                 full.names = T) %>%
      map_df(readRDS)
    
    ## Cleanup
    ntl_df$viirs_bm_mean[ntl_df$viirs_bm_sum == 0]           <- 0
    ntl_df$viirs_bm_gf_mean[ntl_df$viirs_bm_gf_sum == 0]     <- 0
    ntl_df$viirs_bm_nogf_mean[ntl_df$viirs_bm_nogf_sum == 0] <- 0
    
    ## Export
    name_root <- paste0("adm", adm_i, "_", time_type)
    
    saveRDS(ntl_df,   file.path(ntl_bm_dir, "aggregated", paste0(name_root, ".Rds")))
    write_csv(ntl_df, file.path(ntl_bm_dir, "aggregated", paste0(name_root, ".csv")))
    write_dta(ntl_df, file.path(ntl_bm_dir, "aggregated", paste0(name_root, ".dta")))
    
  }
}