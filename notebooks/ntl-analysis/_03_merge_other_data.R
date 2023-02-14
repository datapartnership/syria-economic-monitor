# Trends in Governorate NTL

# ADM3 -------------------------------------------------------------------------
ntl3_df <- read_csv(file.path(ntl_bm_dir, "FinalData", "aggregated", paste0("syr_admin",3,".csv")))
eq3_df <- read_xlsx(file.path(eq_intensity_dir, "RawData", "Intensity_ADM3.xlsx"))

ntl3_df <- ntl3_df %>%
  dplyr::rename(ADM3_CODE = ADM3_PCODE)

ntl_eq_3_df <- ntl3_df %>%
  left_join(eq3_df, by = "ADM3_CODE")

write_csv(ntl_eq_3_df, file.path(ntl_bm_dir, "FinalData", "aggregated", paste0("syr_admin",3,"_eq_intensity.csv")))

# ADM4 -------------------------------------------------------------------------
ntl4_df <- read_csv(file.path(ntl_bm_dir, "FinalData", "aggregated", paste0("syr_admin",4,".csv")))
eq4_df <- read_xlsx(file.path(eq_intensity_dir, "RawData", "IntensityAoC_ADM4.xlsx"))

ntl4_df <- ntl4_df %>%
  dplyr::rename(ADM4_PCODE = ADM4_PCODE)

ntl_eq_4_df <- ntl4_df %>%
  left_join(eq4_df, by = "ADM4_PCODE")

write_csv(ntl_eq_4_df, file.path(ntl_bm_dir, "FinalData", "aggregated", paste0("syr_admin",4,"_eq_intensity.csv")))

# ntl_eq_3_df$viirs_bm_mean
# 
# ntl_eq_3_df %>%
#   group_by(year_month, intensity) %>%
#   dplyr::summarise(viirs_bm_mean = mean(viirs_bm_mean)) %>%
#   ungroup() %>%
#   ggplot(aes(x = year_month, y = viirs_bm_mean)) +
#   geom_line() +
#   facet_wrap(~intensity)
