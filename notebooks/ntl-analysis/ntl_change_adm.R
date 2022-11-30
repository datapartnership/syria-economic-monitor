# Change in NTL

# Load data --------------------------------------------------------------------
gadm_sp <- readRDS(file.path(gadm_dir, "RawData", "gadm36_SYR_2_sp.rds"))

ntl_df <- readRDS(file.path(gadm_dir, "FinalData", paste0("gadm_", 2, "_ntl.Rds")))
ntl_df$year %>% table()

# Prep data --------------------------------------------------------------------
ntl_df <- ntl_df %>%
  group_by(GID_2, year) %>%
  dplyr::summarise(across(c(viirs_bm_gf_sum,
                             viirs_bm_nogf_sum,
                             viirs_bm_sum), sum)) %>%
  ungroup() %>%
  dplyr::filter(year %in% c(2019, 2021)) %>%
  pivot_wider(id_cols = c(GID_2),
              names_from = year,
              values_from = c(viirs_bm_nogf_sum,
                              viirs_bm_gf_sum,
                              viirs_bm_sum))

ntl_df <- ntl_df %>%
  mutate(viirs_bm_nogf_sum_diff = log(viirs_bm_nogf_sum_2021) - log(viirs_bm_nogf_sum_2019))

gadm_sf <- merge(gadm_sp, ntl_df, by = "GID_2") %>% st_as_sf()

# Map --------------------------------------------------------------------------
p <- ggplot() +
  geom_sf(data = gadm_sf,
          aes(fill = viirs_bm_nogf_sum_diff)) +
  theme_void() +
  scale_fill_gradient2(low = "blue",
                       mid = "white",
                       high = "red",
                       midpoint = 0) +
  labs(title = "NTL Difference: 2021 - 2019",
       fill = "Growth\nRate") +
  coord_sf() +
  theme(plot.title = element_text(face = "bold", hjust = 0.5),
        legend.position = "right")

ggsave(p,
       filename = file.path(out_ntl_dir, "figures", "ntl_change.png"),
       height = 5, width = 6)










