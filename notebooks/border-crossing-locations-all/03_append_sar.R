# Append SAR Data

sar_df <- file.path(s1_sar_dir, "FinalData", "individual_files") %>% 
  list.files(pattern = "*sar_",
             full.names = T) %>%
  map_df(readRDS)

saveRDS(sar_df, file.path(s1_sar_dir, "FinalData", "sar.Rds"))
