# Orbital Insight: Clean Data

# Load data --------------------------------------------------------------------
oi_df <- st_read(file.path(oi_dir, "RawData", "WorldBank_Master_Objects_Standard.geojson"))
oi_df$geometry <- NULL

oi_df$object[oi_df$algo_version %in% "truck_detector_skysat_ds_v2.0.0"] <- "truck"

oi_df <- oi_df %>%
  mutate(aoi_name = case_when(
    aoi_name == "Area 9 Small" ~ "Al Aridah",
    aoi_name == "Area 13 Small" ~ "Al Abbudiyah",
    aoi_name == "Area 14 Small" ~ "Matraba"
  ))

# Clean data -------------------------------------------------------------------
oi_df <- oi_df %>%
  dplyr::mutate(measurement_ts = measurement_ts %>% ymd_hms()) %>%
  dplyr::mutate(date = measurement_ts %>% as.Date()) %>%
  dplyr::mutate(hour = measurement_ts %>% hour())

saveRDS(oi_df, file.path(oi_dir, "FinalData", "oi.Rds"))

oi_date_df <- oi_df %>%
  mutate(date = date %>% floor_date(unit = "month")) %>%
  group_by(date, object, aoi_name) %>%
  dplyr::summarise(value = max(measured_count)) %>%
  ungroup()

oi_hour_df <- oi_df %>%
  group_by(hour, object, aoi_name) %>%
  dplyr::summarise(value = max(measured_count)) %>%
  ungroup()

# Figures ----------------------------------------------------------------------
# oi_hour_df %>%
#   dplyr::filter(object == "truck") %>%
#   ggplot(aes(x = hour,
#              y = value)) +
#   geom_col(width = 0.5) +
#   facet_wrap(~aoi_name)

max_v <- max(oi_date_df$value)

p_car <- oi_date_df %>%
  dplyr::filter(object == "car") %>%
  ggplot(aes(x = date,
             y = value)) +
  geom_col(width = 50, fill = "dodgerblue3") +
  labs(x = NULL,
       y = NULL,
       title = "A. Number of Cars") +
  facet_wrap(~aoi_name) +
  theme_classic() +
  theme(strip.text = element_text(face = "bold"),
        strip.background = element_blank(),
        plot.title = element_text(face = "bold")) +
  ylim(0, max_v)

ggsave(p_car, filename = file.path(figures_dir, "oi_cars.png"),
       height = 2.75, width = 7)

p_truck <- oi_date_df %>%
  dplyr::filter(object == "truck") %>%
  ggplot(aes(x = date,
             y = value)) +
  geom_col(width = 50, fill = "dodgerblue3") +
  labs(x = NULL,
       y = NULL,
       title = "B. Number of Trucks") +
  facet_wrap(~aoi_name) +
  theme_classic() +
  theme(strip.text = element_text(face = "bold"),
        strip.background = element_blank(),
        plot.title = element_text(face = "bold")) +
  ylim(0, max_v)

ggsave(p_truck, filename = file.path(figures_dir, "oi_trucks.png"),
       height = 2.75, width = 7)

p <- ggarrange(p_car,
               p_truck,
               ncol = 1)

ggsave(p, filename = file.path(figures_dir, "oi_cars_trucks.png"),
       height = 2.75*2, width = 7)


