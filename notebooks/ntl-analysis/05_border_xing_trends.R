

daily_df   <- readRDS(file.path(ntl_bm_dir, "FinalData", "aggregated", "border_xing_daily.Rds"))
monthly_df <- readRDS(file.path(ntl_bm_dir, "FinalData", "aggregated", "border_xing_monthly.Rds"))

daily_df %>%
  dplyr::filter(date >= ymd("2023-01-01")) %>%
  ggplot() +
  geom_vline(xintercept = ymd("2023-02-06"),
             color = "red") +
  geom_col(aes(x = date,
               y = viirs_bm_mean)) +
  facet_wrap(~crossing,
             scales = "free_y") +
  labs(x = NULL,
       y = "NTL",
       title = "Daily NTL: 2023") +
  theme_classic() +
  theme(strip.background = element_blank(),
        strip.text = element_text(face = "bold"))

ggsave(filename = file.path(figures_dir, "border_xing_ntl_daily_2023.png"),
       height = 8, width = 12)

daily_df %>%
  ggplot() +
  geom_col(aes(x = date,
               y = viirs_bm_mean)) +
  facet_wrap(~crossing,
             scales = "free_y") +
  labs(x = NULL,
       y = "NTL",
       title = "Daily NTL: 2022 - Present") +
  theme_classic() +
  theme(strip.background = element_blank(),
        strip.text = element_text(face = "bold"))

ggsave(filename = file.path(figures_dir, "border_xing_ntl_daily.png"),
       height = 8, width = 12)

monthly_df %>%
  dplyr::filter(date >= ymd("2022-01-01")) %>%
  ggplot() +
  geom_col(aes(x = date,
               y = viirs_bm_mean)) +
  facet_wrap(~crossing,
             scales = "free_y") +
  labs(x = NULL,
       y = "NTL",
       title = "Monthly NTL: 2022 - Present (Jan 2023)") +
  theme_classic() +
  theme(strip.background = element_blank(),
        strip.text = element_text(face = "bold"))

ggsave(filename = file.path(figures_dir, "border_xing_ntl_monthly_recent.png"),
       height = 8, width = 12)

monthly_df %>%
  ggplot() +
  geom_col(aes(x = date,
               y = viirs_bm_mean)) +
  facet_wrap(~crossing,
             scales = "free_y") +
  labs(x = NULL,
       y = "NTL",
       title = "Monthly NTL: 2012 - Present") +
  theme_classic() +
  theme(strip.background = element_blank(),
        strip.text = element_text(face = "bold"))

ggsave(filename = file.path(figures_dir, "border_xing_ntl_monthly.png"),
       height = 8, width = 12)
