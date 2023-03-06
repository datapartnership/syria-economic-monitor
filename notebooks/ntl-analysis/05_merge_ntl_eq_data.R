# Trends in Governorate NTL

# ADM3 -------------------------------------------------------------------------
ntl3_v1_df <- read_csv(file.path(ntl_bm_dir, "FinalData", "aggregated", "syr_temp", "syr_admin_daily3_VNP46A1.csv"))
ntl3_v2_df <- read_csv(file.path(ntl_bm_dir, "FinalData", "aggregated", "syr_temp", "syr_admin_daily3_VNP46A2.csv"))

ntl3_v1_df <- ntl3_v1_df %>% 
  rename_at(vars(contains("viirs_bm_")) , ~ paste0(., "_raw")) %>%
  dplyr::rename(ADM3_CODE = ADM3_PCODE) %>%
  dplyr::select(ADM3_CODE, date, contains("viirs_bm_"))

ntl3_v2_df <- ntl3_v2_df %>% 
  rename_at(vars(contains("viirs_bm_")) , ~ paste0(., "_corrected")) %>%
  dplyr::rename(ADM3_CODE = ADM3_PCODE) %>%
  dplyr::select(ADM3_CODE, date, contains("viirs_bm_"))

eq3_df <- read_xlsx(file.path(eq_intensity_dir, "RawData", "Intensity_ADM3.xlsx"))

ntl_eq_3_df <- ntl3_v1_df %>%
  full_join(ntl3_v2_df, by = c("ADM3_CODE", "date")) %>%
  left_join(eq3_df, by = "ADM3_CODE") %>%
  dplyr::mutate(date = date %>% ymd())

#ntl_eq_3_df <- ntl_eq_3_df %>%
#  dplyr::filter(date >= ymd("2022-09-01"))

write_csv(ntl_eq_3_df, file.path(ntl_bm_dir, "FinalData", "aggregated", paste0("syr_admin",3,"_eq_intensity.csv")))

# ADM4 -------------------------------------------------------------------------
ntl4_v1_df <- read_csv(file.path(ntl_bm_dir, "FinalData", "aggregated", "syr_temp", "syr_admin_daily4_VNP46A1.csv"))
ntl4_v2_df <- read_csv(file.path(ntl_bm_dir, "FinalData", "aggregated", "syr_temp", "syr_admin_daily4_VNP46A2.csv"))

ntl4_v1_df <- ntl4_v1_df %>% 
  rename_at(vars(contains("viirs_bm_")) , ~ paste0(., "_raw")) %>%
  dplyr::select(ADM4_PCODE, "date", contains("viirs_bm_"))

ntl4_v2_df <- ntl4_v2_df %>% 
  rename_at(vars(contains("viirs_bm_")) , ~ paste0(., "_corrected")) %>%
  dplyr::select(ADM4_PCODE, "date", contains("viirs_bm_"))

eq4_df <- read_xlsx(file.path(eq_intensity_dir, "RawData", "IntensityAoC_ADM4.xlsx"))

ntl_eq_4_df <- ntl4_v1_df %>%
  full_join(ntl4_v2_df, by = c("ADM4_PCODE", "date")) %>%
  left_join(eq4_df, by = "ADM4_PCODE") %>%
  dplyr::mutate(date = date %>% ymd())

#ntl_eq_4_df <- ntl_eq_4_df %>%
#  dplyr::filter(date >= ymd("2022-09-01"))

write_csv(ntl_eq_4_df, file.path(ntl_bm_dir, "FinalData", "aggregated", paste0("syr_admin",4,"_eq_intensity.csv")))


# # ADM4 -------------------------------------------------------------------------
# ntl4_v1_df <- read_csv(file.path(ntl_bm_dir, "FinalData", "aggregated", "syr_admin_daily4_VNP46A1.csv"))
# ntl4_v2_df <- read_csv(file.path(ntl_bm_dir, "FinalData", "aggregated", "syr_admin_daily4_VNP46A2.csv"))
# 
# #ntl4_df <- read_csv(file.path(ntl_bm_dir, "FinalData", "aggregated", paste0("syr_admin",4,".csv")))
# eq4_df <- read_xlsx(file.path(eq_intensity_dir, "RawData", "IntensityAoC_ADM4.xlsx"))
# 
# ntl4_df <- ntl4_df %>%
#   dplyr::rename(ADM4_PCODE = ADM4_PCODE)
# 
# ntl_eq_4_df <- ntl4_df %>%
#   left_join(eq4_df, by = "ADM4_PCODE")
# 
# write_csv(ntl_eq_4_df, file.path(ntl_bm_dir, "FinalData", "aggregated", paste0("syr_admin",4,"_eq_intensity.csv")))

# ntl_eq_3_df$viirs_bm_mean
# 
# ntl_eq_3_df %>%
#   dplyr::filter(date >= ymd("2023-01-15")) %>%
#   group_by(date, intensity) %>%
#   dplyr::summarise(viirs = mean(viirs_bm_nogf_mean_corrected, na.rm=T)) %>%
#   ungroup() %>%
#   ggplot(aes(x = date, y = viirs)) +
#   geom_col() +
#   facet_wrap(~intensity,
#              scales = "free_y")
