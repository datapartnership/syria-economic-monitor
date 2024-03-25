# Trends in Governorate NTL

for(time_type in c("daily", "monthly")){
  # ADM3 -------------------------------------------------------------------------
  ntl3_v1_df <- readRDS(file.path(ntl_bm_dir, "FinalData", "aggregated", "syr_temp",
                                   paste0("syr_admin_adm3_",time_type,".Rds")))

  ntl3_v1_df <- ntl3_v1_df %>%
    dplyr::rename(ADM3_CODE = ADM3_PCODE) %>%
    dplyr::select(ADM3_CODE, date, contains("viirs_bm_"))

  eq3_df <- read_xlsx(file.path(eq_intensity_dir, "RawData", "Intensity_ADM3.xlsx"))

  ntl_eq_3_df <- ntl3_v1_df %>%
    left_join(eq3_df, by = "ADM3_CODE") %>%
    dplyr::mutate(date = date %>% ymd())

  write_csv(ntl_eq_3_df, file.path(ntl_bm_dir, "FinalData", "aggregated",
                                   paste0("syr_admin",3,"_eq_intensity_",time_type,".csv")))

  # ADM4 -------------------------------------------------------------------------
  ntl4_v1_df <- read_csv(file.path(ntl_bm_dir, "FinalData", "aggregated", "syr_temp",
                                   paste0("syr_admin_adm4_",time_type,".csv")))

  ntl4_v1_df <- ntl4_v1_df %>%
    dplyr::select(ADM4_PCODE, "date", contains("viirs_bm_"))

  eq4_df <- read_xlsx(file.path(eq_intensity_dir, "RawData", "IntensityAoC_ADM4.xlsx"))

  ntl_eq_4_df <- ntl4_v1_df %>%
    left_join(eq4_df, by = "ADM4_PCODE") %>%
    dplyr::mutate(date = date %>% ymd())

  write_csv(ntl_eq_4_df, file.path(ntl_bm_dir, "FinalData", "aggregated",
                                   paste0("syr_admin",4,"_eq_intensity_",time_type,".csv")))
}
