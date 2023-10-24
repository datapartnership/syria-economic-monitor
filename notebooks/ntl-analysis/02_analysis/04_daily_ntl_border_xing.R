# Daily NTL by Intensity

# Load data --------------------------------------------------------------------
ntl_df <- readRDS(file.path(ntl_bm_dir, "FinalData", "aggregated", "border_xing_daily.Rds"))

ntl_df <- ntl_df %>%
  distinct(date, crossing, .keep_all = T)

# Calculate moving average within groups
ntl_df <- ntl_df %>%
  dplyr::filter(!is.na(date)) %>%
  ungroup() %>%
  arrange(date) %>%
  group_by(crossing) %>%
  mutate(viirs_bm_mean_ma7 = rollmean(viirs_bm_mean,
                                      k = 7, align = "right", fill = NA)) %>%
  ungroup()

# Figures: Individual ADM ------------------------------------------------------
ntl_df %>%
  dplyr::filter(date >= ymd("2022-11-01"),
                date <= ymd("2023-10-15")) %>%
  dplyr::filter(crossing %in% c("Bab al Hawa",
                                "Ar Ra'-ee",
                                "Bab al-Salam")) %>%
  ggplot(aes(x = date)) +
  geom_col(aes(y = viirs_bm_mean), fill = "gray70") +
  geom_line(aes(y = viirs_bm_mean_ma7), color = "black") +
  geom_vline(xintercept = ymd("2023-02-06"), color = "red") +
  facet_wrap(~crossing, scales = "free_y", ncol = 1) +
  labs(x = NULL,
       y = NULL,
       title = "Daily NTL Along Border Crossings") +
  theme_classic2() +
  theme(strip.text = element_text(face = "bold"),
        strip.background = element_blank(),
        plot.title = element_text(face = "bold", hjust = 0.5))

ggsave(filename = file.path(figures_dir, "ntl_border_xing_more_severe.png"),
       height = 4.5, width = 3.7)

ntl_df %>%
  dplyr::filter(date >= ymd("2022-11-01"),
                date <= ymd("2023-04-15")) %>%
  dplyr::filter(crossing %in% c("Tall Al Abyad",
                                "Bab al Kasab",
                                "Ras al Ain")) %>%
  ggplot(aes(x = date)) +
  geom_col(aes(y = viirs_bm_mean), fill = "gray70") +
  geom_line(aes(y = viirs_bm_mean_ma7), color = "black") +
  geom_vline(xintercept = ymd("2023-02-06"), color = "red") +
  facet_wrap(~crossing, scales = "free_y", ncol = 1) +
  labs(x = NULL,
       y = NULL,
       title = "Daily NTL Along Border Crossings") +
  theme_classic2() +
  theme(strip.text = element_text(face = "bold"),
        strip.background = element_blank(),
        plot.title = element_text(face = "bold", hjust = 0.5))

ggsave(filename = file.path(figures_dir, "ntl_border_xing_less_severe.png"),
       height = 4.5, width = 3.7)

# Figures: Individual ADM ------------------------------------------------------
ntl_df %>%
  dplyr::filter(date >= ymd("2022-11-01")) %>%
  ggplot(aes(x = date)) +
  geom_col(aes(y = viirs_bm_mean), fill = "gray70") +
  geom_line(aes(y = viirs_bm_mean_ma7), color = "black") +
  geom_vline(xintercept = ymd("2023-02-06"), color = "red") +
  facet_wrap(~crossing, scales = "free_y") +
  labs(x = NULL,
       y = NULL,
       title = "Daily NTL Along Border Crossings") +
  theme_classic2() +
  theme(strip.text = element_text(face = "bold"),
        strip.background = element_blank(),
        plot.title = element_text(face = "bold", hjust = 0.5))

ggsave(filename = file.path(figures_dir, "ntl_border_xing.png"),
       height = 5, width = 10)
