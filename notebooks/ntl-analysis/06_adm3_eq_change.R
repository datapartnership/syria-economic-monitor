
## Load data
ntl_df <- read_csv(file.path(ntl_bm_dir, "FinalData", "aggregated",
                             "syr_temp",
                             paste0("syr_admin_daily",
                                    3, "_", "VNP46A2", ".csv")))

adm3_sf <- read_sf(dsn = file.path(unocha_dir, "RawData", 
                                   "syr_admbnda_adm3_uncs_unocha_20201217.json")) 

## Clean data
ntl_df <- ntl_df %>%
  dplyr::filter(date >= ymd("2023-02-06") - 14,
                date <= ymd("2023-02-06") + 14) %>%
  dplyr::mutate(post_eq = ifelse(date >= ymd("2023-02-06"), "after", "before")) %>%
  group_by(post_eq, ADM3_EN) %>%
  dplyr::summarise(viirs_bm_mean = mean(viirs_bm_mean)) %>%
  pivot_wider(id_cols = ADM3_EN,
              names_from = post_eq,
              values_from = viirs_bm_mean) %>%
  dplyr::mutate(pc = (after - before)/before*100)

adm3_sf <- adm3_sf %>%
  left_join(ntl_df, by = "ADM3_EN")

## Map
p <- ggplot() +
  geom_sf(data = adm3_sf,
          aes(fill = pc),
          color = "black") +
  labs(fill = "Percent\nChange") +
  theme_void() +
  scale_fill_distiller(palette = "Spectral")

ggsave(p, filename = file.path(figures_dir, "syria_eq_pc_2weeks_map.png"),
       height = 8, width = 8)

## Histogram
p <- ggplot() +
  geom_histogram(data = adm3_sf,
                 aes(x = pc)) +
  geom_vline(xintercept = 0,
             color = "red") +
  theme_minimal() +
  labs(x = "Percent Change",
       y = "N") 

ggsave(p, filename = file.path(figures_dir, "syria_eq_pc_2weeks_hist.png"),
       height = 3.5, width = 2.5)
