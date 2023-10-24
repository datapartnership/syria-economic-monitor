# Monthly Trends

syr_df <- readRDS(file.path(ntl_bm_dir, "FinalData", "aggregated",
                            paste0("syr", "_admin_adm",
                                   3, "_", "monthly", ".Rds"))) %>%
  mutate(country = "Syria",
         adm = ADM3_EN %>% tolower() %>% tools::toTitleCase())

tur_df <- readRDS(file.path(ntl_bm_dir, "FinalData", "aggregated",
                            paste0("tur", "_admin_adm",
                                   2, "_", "monthly", ".Rds"))) %>%
  mutate(country = "Turkey",
         adm = adm2_en %>% tolower() %>% tools::toTitleCase())

df <- bind_rows(
  syr_df,
  tur_df
) %>%
  mutate(adm_c = paste0(adm, "\n", country)) %>%
  dplyr::filter(date >= ymd("2021-01-01"))


df %>%
  dplyr::filter(country == "Syria") %>%
  group_by(date, eq_intensity_str) %>%
  dplyr::summarise(viirs_bm_mean = mean(viirs_bm_mean)) %>%
  ggplot() +
  geom_vline(xintercept = ymd("2023-02-01"), color = "red") + 
  geom_line(aes(x = date,
               y = viirs_bm_mean),
            linewidth = 0.75) +
  facet_wrap(~eq_intensity_str,
             scales = "free_y") +
  labs(x = NULL,
       y = NULL,
       title = "Syria") +
  theme_classic2() +
  theme(strip.background = element_blank(),
        strip.text = element_text(face = "bold"),
        plot.title = element_text(hjust = 0.5, face = "bold"))

ggsave(filename = file.path(figures_dir, "syr_eqintensity_monthly.png"),
       height = 4, width = 10)

df %>%
  dplyr::filter(country == "Turkey") %>%
  group_by(date, eq_intensity_str) %>%
  dplyr::summarise(viirs_bm_mean = mean(viirs_bm_mean)) %>%
  ggplot() +
  geom_vline(xintercept = ymd("2023-02-01"), color = "red") + 
  geom_line(aes(x = date,
               y = viirs_bm_mean),
            linewidth = 0.75) +
  facet_wrap(~eq_intensity_str,
             scales = "free_y") +
  labs(x = NULL,
       y = NULL,
       title = "Turkey") +
  theme_classic2() +
  theme(strip.background = element_blank(),
        strip.text = element_text(face = "bold"),
        plot.title = element_text(hjust = 0.5, face = "bold"))

ggsave(filename = file.path(figures_dir, "tur_eqintensity_monthly.png"),
       height = 4, width = 10)




