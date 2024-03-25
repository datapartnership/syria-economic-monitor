# Border Crossing Trends

df <- readRDS(file.path(ntl_bm_dir, "FinalData", "aggregated", "border_xing_monthly.Rds"))

df %>%
  dplyr::filter(date >= ymd("2021-01-01")) %>%
  ggplot() +
  geom_vline(xintercept = ymd("2023-02-01"), color = "red") +
  geom_line(aes(x = date,
                y = viirs_bm_mean),
            linewidth = 0.75) +
  facet_wrap(~crossing,
             scales = "free_y") +
  labs(x = NULL,
       y = NULL,
       title = "Border Crossings") +
  theme_classic2() +
  theme(strip.background = element_blank(),
        strip.text = element_text(face = "bold"),
        plot.title = element_text(hjust = 0.5, face = "bold"))

ggsave(filename = file.path(figures_dir, "border_xing_monthly.png"),
       height = 5, width = 8)
