# Gas Flaring Trends

ntl_df <- readRDS(file.path(gadm_dir, "FinalData", paste0("gadm_", 0, "_ntl.Rds")))

ntl_df %>%
  ggplot() +
  geom_col(aes(x = year_month,
               y = viirs_bm_gf_mean),
           fill = "dodgerblue4") +
  labs(x = NULL,
       y = "Average Luminosity") +
  theme_minimal() +
  theme(panel.grid = element_blank()) 

ggsave(filename = file.path(figures_dir, "ntl_gas_flares.png"),
       height = 3,
       width = 5)


ntl_export_df <- ntl_df %>%
  dplyr::select(year_month, viirs_bm_gf_mean) %>%
  dplyr::rename(ntl = viirs_bm_gf_mean)

write.csv(ntl_export_df, "~/Desktop/ntl_gasflare_locations.csv", row.names = F)


