df <- read_csv(file.path(ntl_bm_dir, "FinalData", "aggregated",
                    "syr_temp",
                    paste0("syr_admin_daily",
                           3, "_", "VNP46A2", ".csv")))

df <- df %>%
  dplyr::filter(date >= ymd("2023-01-01"))

eq <- read_csv("~/Desktop/syria_eq.csv")
eq <- eq %>%
  group_by(ADM3_EN) %>%
  dplyr::summarise(max_intensity_feb06 = max(max_intensity_feb06)) %>%
  ungroup()

df <- df %>%
  left_join(eq, by = "ADM3_EN")

p <- df %>%
  dplyr::filter(max_intensity_feb06 >= 7) %>%
  ggplot() +
  geom_vline(xintercept = ymd("2023-02-06"),
             color = "red") +
  geom_col(aes(x = date, y = viirs_bm_mean)) +
  facet_wrap(~ADM3_EN,
             scales = "free_y") +
  theme_classic() +
  theme(strip.background = element_blank(),
        strip.text = element_text(face = "bold")) +
  labs(x = NULL,
       y = "NTL")

ggsave(p, filename = file.path(figures_dir, "adm3_trends_eq.png"),
       height = 4, width = 8)

p <- df %>%
  dplyr::filter(max_intensity_feb06 == 6) %>%
  ggplot() +
  geom_vline(xintercept = ymd("2023-02-06"),
             color = "red") +
  geom_col(aes(x = date, y = viirs_bm_mean)) +
  facet_wrap(~ADM3_EN,
             scales = "free_y") +
  theme_classic() +
  theme(strip.background = element_blank(),
        strip.text = element_text(face = "bold")) +
  labs(x = NULL,
       y = "NTL")

ggsave(p, filename = file.path(figures_dir, "adm3_trends_eq_6.png"),
       height = 4, width = 8)

