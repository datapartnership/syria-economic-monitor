# Append Syria NTL Aggregations into One Dataset

adm_i <- 3
product_id <- "VNP46A2"
for(adm_i in c(3,4)){
  for(product_id in c("VNP46A2")){
    list.files(file.path(ntl_bm_dir, "FinalData", "aggregated", "syr_temp", "daily_files"),
               full.names = T) %>%
      str_subset(paste0("syr_admin", adm_i, "_")) %>%
      str_subset(product_id) %>%
      map_df(readRDS) %>%
      write_csv(file.path(ntl_bm_dir, "FinalData", "aggregated",
                          "syr_temp",
                          paste0("syr_admin_daily",
                                 adm_i, "_", product_id, ".csv")))
  }
}



