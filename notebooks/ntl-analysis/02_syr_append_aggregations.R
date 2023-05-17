# Append Syria NTL Aggregations into One Dataset

adm_i <- 3
product_id <- "VNP46A3"
for(adm_i in c(3,4)){
  for(product_id in c("VNP46A2", "VNP46A3")){
    
    if(product_id == "VNP46A2") time_name <- "daily"
    if(product_id == "VNP46A3") time_name <- "monthly"
    
    list.files(file.path(ntl_bm_dir, "FinalData", "aggregated", "syr_temp", product_id),
               full.names = T) %>%
      str_subset(paste0("syr_admin", adm_i, "_")) %>%
      str_subset(product_id) %>%
      map_df(readRDS) %>%
      write_csv(file.path(ntl_bm_dir, "FinalData", "aggregated",
                          "syr_temp",
                          paste0("syr_admin_adm",
                                 adm_i, "_", time_name, ".csv")))
  }
}



