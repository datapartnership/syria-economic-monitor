
res_i <- 5
hex_df <- readRDS(file.path(hex_dir, "FinalData", paste0("hex_", res_i, "_ntl.Rds")))
hex_sf <- readRDS(file.path(hex_dir, "RawData", paste0("hex_", res_i, ".Rds")))

hex_sum_df <- hex_df %>%
  dplyr::filter(year %in% c(2013, 2021)) %>%
  group_by(uid, year) %>%
  dplyr::summarise(viirs_bm_mean = mean(viirs_bm_mean)) %>%
  ungroup() %>%
  arrange(year) %>%
  #dplyr::mutate(viirs_bm_mean = log(viirs_bm_mean)) %>%
  group_by(uid) %>%
  dplyr::mutate(viirs_diff = (viirs_bm_mean[year == 2021] - viirs_bm_mean[year == 2013]) ) %>%
  dplyr::mutate(viirs_diff_ln = ( log(viirs_bm_mean[year == 2021]+1) - log(viirs_bm_mean[year == 2013]+1) ) ) %>%
  #dplyr::mutate(viirs_diff = (viirs_bm_mean[year == 2021] - viirs_bm_mean[year == 2013]) / viirs_bm_mean[year == 2013] ) %>%
  dplyr::filter(year == 2021)

data_sf <- merge(hex_sf, hex_sum_df, by = "uid")


ggplot() +
  geom_sf(data = data_sf,
          aes(fill = viirs_diff_ln)) +
  scale_fill_gradient2() +
  coord_sf() +
  theme_void()

bins <- seq(from=-3.5, to=3.5,by=0.7)
bins
pal <- colorBin("RdYlGn", domain = data_sf$viirs_diff_ln, bins = bins)

leaflet() %>%
  addTiles() %>%
  addPolygons(data = data_sf,
              fillColor = ~pal(viirs_diff_ln),
              fillOpacity = 0.8,
              opacity = 0) %>%
  addLegend(pal = pal, values = bins,
            title = "NTL Change")

data_sf$viirs_diff_ln %>% summary()
