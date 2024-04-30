# Append Syria NTL Aggregations into One Dataset

adm_i <- 2
product_id <- "VNP46A1"

for(adm_i in c(1:2)){
  for(product_id in c("VNP46A1", "VNP46A2")){

    list.files(file.path(ntl_bm_dir, "FinalData", "aggregated", "tur_temp", "daily_files"),
               full.names = T) %>%
      str_subset(paste0("tur_admin", adm_i, "_")) %>%
      str_subset(product_id) %>%
      map_df(readRDS) %>%
      write_csv(file.path(ntl_bm_dir, "FinalData", "aggregated",
                          "tur_temp",
                          paste0("tur_admin_daily",
                                 adm_i, "_", product_id, ".csv")))

  }
}
