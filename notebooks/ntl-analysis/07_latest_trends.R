# Latest Trends

# Load data --------------------------------------------------------------------
product_id <- "VNP46A2"
adm_i <- 3

ntl_df <- read_csv(file.path(ntl_bm_dir, "FinalData", "aggregated",
                             "syr_temp",
                             paste0("syr_admin_daily",
                                    adm_i, "_", product_id, ".csv")))

eq3_df <- read_xlsx(file.path(eq_intensity_dir, "RawData", "Intensity_ADM3.xlsx"))
eq3_df <- eq3_df %>%
  dplyr::rename(ADM3_PCODE = ADM3_CODE)

ntl_eq_3_df <- ntl_df %>%
  left_join(eq3_df, by = "ADM3_PCODE") %>%
  dplyr::mutate(date = date %>% ymd())

# Moving averages --------------------------------------------------------------
ntl_eq_3_df <- ntl_eq_3_df %>%
  dplyr::arrange(desc(ADM3_PCODE)) %>% 
  dplyr::group_by(ADM3_PCODE) %>% 
  dplyr::mutate(viirs_bm_mean_7 = zoo::rollmean(viirs_bm_mean, k = 7, fill = NA),
                viirs_bm_median_7 = zoo::rollmean(viirs_bm_median, k = 7, fill = NA)) %>% 
  dplyr::ungroup()

# Trends -----------------------------------------------------------------------
ntl_eq_3_df %>%
  dplyr::filter(intensity %in% c("Very Strong", "Strong"),
                date >= ymd("2022-12-01")) %>%
  
  ggplot() +
  geom_line(aes(x = date, y = viirs_bm_median)) +
  geom_vline(xintercept = ymd("2023-02-06"), color = "red") +
  facet_wrap(~ADM3_NAME, scales = "free_y") +
  labs(x = NULL, y = "NTL")






