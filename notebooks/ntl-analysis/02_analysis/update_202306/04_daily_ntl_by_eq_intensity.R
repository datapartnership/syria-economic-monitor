# Daily NTL by Intensity

# Load data --------------------------------------------------------------------
ntl_df <- read_csv(file.path(ntl_bm_dir, "FinalData", "aggregated", "syr_temp",
                             "syr_admin_adm3_daily.csv"))

eq3_df <- read_xlsx(file.path(eq_intensity_dir, "RawData", "Intensity_ADM3.xlsx"))
eq3_df <- eq3_df %>%
  dplyr::select(ADM3_CODE, POPULATION, intensity) %>%
  dplyr::rename(ADM3_PCODE = ADM3_CODE)

ntl_df <- ntl_df %>%
  left_join(eq3_df, by = "ADM3_PCODE")

# Calculate moving average within groups
ntl_df <- ntl_df %>%
  arrange(date) %>%
  group_by(ADM3_PCODE) %>%
  mutate(viirs_bm_mean_ma7 = rollmean(viirs_bm_mean,
                                      k = 7, align = "right", fill = NA),
         viirs_bm_gf_mean_ma7 = rollmean(viirs_bm_gf_mean,
                                         k = 7, align = "right", fill = NA)) %>%
  ungroup()

# SELECT =======================================================================
ntl_df %>%
  dplyr::filter(date >= ymd("2022-11-01")) %>%
  dplyr::filter(intensity == "Very Strong") %>%
  ggplot(aes(x = date)) +
  geom_col(aes(y = viirs_bm_mean), fill = "gray70") +
  geom_line(aes(y = viirs_bm_mean_ma7), color = "black") +
  geom_vline(xintercept = ymd("2023-02-06"), color = "red") +
  facet_wrap(~ADM3_EN, scales = "free_y") +
  labs(x = NULL,
       y = NULL,
       title = "Earthquake Intensity: Very Strong") +
  theme_classic2() +
  theme(strip.text = element_text(face = "bold"),
        strip.background = element_blank(),
        plot.title = element_text(face = "bold", hjust = 0.5))

# ALL LIGHTS ===================================================================

# Figures: Individual ADM ------------------------------------------------------
ntl_df %>%
  dplyr::filter(date >= ymd("2022-11-01")) %>%
  dplyr::filter(intensity == "Very Strong") %>%
  ggplot(aes(x = date)) +
  geom_col(aes(y = viirs_bm_mean), fill = "gray70") +
  geom_line(aes(y = viirs_bm_mean_ma7), color = "black") +
  geom_vline(xintercept = ymd("2023-02-06"), color = "red") +
  facet_wrap(~ADM3_EN, scales = "free_y") +
  labs(x = NULL,
       y = NULL,
       title = "Earthquake Intensity: Very Strong") +
  theme_classic2() +
  theme(strip.text = element_text(face = "bold"),
        strip.background = element_blank(),
        plot.title = element_text(face = "bold", hjust = 0.5))

ggsave(filename = file.path(figures_dir, "ntl_eq_very_strong.png"),
       height = 4, width = 6)

ntl_df %>%
  dplyr::filter(date >= ymd("2022-11-01")) %>%
  dplyr::filter(intensity == "Strong") %>%
  ggplot(aes(x = date)) +
  geom_col(aes(y = viirs_bm_mean), fill = "gray70") +
  geom_line(aes(y = viirs_bm_mean_ma7), color = "black") +
  geom_vline(xintercept = ymd("2023-02-06"), color = "red") +
  facet_wrap(~ADM3_EN, scales = "free_y") +
  labs(x = NULL,
       y = NULL,
       title = "Earthquake Intensity: Strong") +
  theme_classic2() +
  theme(strip.text = element_text(face = "bold"),
        strip.background = element_blank(),
        plot.title = element_text(face = "bold", hjust = 0.5))

ggsave(filename = file.path(figures_dir, "ntl_eq_strong.png"),
       height = 5, width = 8)

# Figures: Average -------------------------------------------------------------
ntl_df %>%
  dplyr::filter(date >= ymd("2022-11-01")) %>%
  group_by(date, intensity) %>%
  summarise(viirs_bm_mean_ma7 = mean(viirs_bm_mean_ma7),
            viirs_bm_mean = mean(viirs_bm_mean)) %>%
  ungroup() %>%

  mutate(intensity = factor(intensity, levels = rev(c("Weak",
                                                      "Light",
                                                      "Moderate",
                                                      "Strong",
                                                      "Very Strong")))) %>%

  ggplot(aes(x = date)) +
  geom_col(aes(y = viirs_bm_mean), fill = "gray70") +
  geom_line(aes(y = viirs_bm_mean_ma7), color = "black") +
  geom_vline(xintercept = ymd("2023-02-06"), color = "red") +
  facet_wrap(~intensity, scales = "free_y") +
  labs(x = NULL,
       y = NULL,
       title = "Average Trends in NTL by Earthquake Intensity") +
  theme_classic2() +
  theme(strip.text = element_text(face = "bold"),
        strip.background = element_blank(),
        plot.title = element_text(face = "bold", hjust = 0.5))

ggsave(filename = file.path(figures_dir, "ntl_eq_avg.png"),
       height = 4, width = 6)

# GAS FLARING LIGHTS ===========================================================

# Figures: Individual ADM ------------------------------------------------------
ntl_df %>%
  filter(!is.na(viirs_bm_gf_mean)) %>%
  dplyr::filter(date >= ymd("2022-11-01")) %>%
  dplyr::filter(intensity == "Very Strong") %>%
  ggplot(aes(x = date)) +
  geom_col(aes(y = viirs_bm_gf_mean), fill = "gray70") +
  geom_line(aes(y = viirs_bm_gf_mean_ma7), color = "black") +
  geom_vline(xintercept = ymd("2023-02-06"), color = "red") +
  facet_wrap(~ADM3_EN, scales = "free_y") +
  labs(x = NULL,
       y = NULL,
       title = "Earthquake Intensity: Very Strong") +
  theme_classic2() +
  theme(strip.text = element_text(face = "bold"),
        strip.background = element_blank(),
        plot.title = element_text(face = "bold", hjust = 0.5))

ggsave(filename = file.path(figures_dir, "ntl_gf_eq_very_strong.png"),
       height = 4, width = 6)

ntl_df %>%
  dplyr::filter(!is.na(viirs_bm_gf_mean)) %>%
  dplyr::filter(date >= ymd("2022-11-01")) %>%
  dplyr::filter(intensity == "Strong") %>%
  mutate(ADM3_EN = ADM3_EN %>% as.character()) %>%
  ggplot(aes(x = date)) +
  geom_col(aes(y = viirs_bm_gf_mean), fill = "gray70") +
  geom_line(aes(y = viirs_bm_gf_mean_ma7), color = "black") +
  geom_vline(xintercept = ymd("2023-02-06"), color = "red") +
  facet_wrap(~ADM3_EN, scales = "free_y") +
  labs(x = NULL,
       y = NULL,
       title = "Earthquake Intensity: Strong") +
  theme_classic2() +
  theme(strip.text = element_text(face = "bold"),
        strip.background = element_blank(),
        plot.title = element_text(face = "bold", hjust = 0.5))

ggsave(filename = file.path(figures_dir, "ntl_gf_eq_strong.png"),
       height = 5, width = 8)

# Figures: Average -------------------------------------------------------------
ntl_df %>%
  dplyr::filter(date >= ymd("2022-11-01")) %>%
  group_by(date, intensity) %>%
  summarise(viirs_bm_gf_mean_ma7 = mean(viirs_bm_gf_mean_ma7),
            viirs_bm_gf_mean = mean(viirs_bm_gf_mean)) %>%
  ungroup() %>%

  mutate(intensity = factor(intensity, levels = rev(c("Weak",
                                                      "Light",
                                                      "Moderate",
                                                      "Strong",
                                                      "Very Strong")))) %>%
  filter(!is.na(viirs_bm_gf_mean)) %>%

  ggplot(aes(x = date)) +
  geom_col(aes(y = viirs_bm_gf_mean), fill = "gray70") +
  geom_line(aes(y = viirs_bm_gf_mean_ma7), color = "black") +
  geom_vline(xintercept = ymd("2023-02-06"), color = "red") +
  facet_wrap(~intensity, scales = "free_y") +
  labs(x = NULL,
       y = NULL,
       title = "Average Trends in NTL by Earthquake Intensity") +
  theme_classic2() +
  theme(strip.text = element_text(face = "bold"),
        strip.background = element_blank(),
        plot.title = element_text(face = "bold", hjust = 0.5))

ggsave(filename = file.path(figures_dir, "ntl_gf_eq_avg.png"),
       height = 4, width = 6)
