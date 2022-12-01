# Compare Traffic Data

# Load data --------------------------------------------------------------------
ol_df <- readRDS(file.path(outlogic_dir, "FinalData", "outlogic_bc_counts.Rds"))
sn_df <- readRDS(file.path(spaceknow_dir, "FinalData", "spaceknow.Rds"))
oi_df <- readRDS(file.path(oi_dir, "FinalData", "oi.Rds"))

# Cleanup ----------------------------------------------------------------------
ol_df <- ol_df %>%
  dplyr::filter(aoi %in% c("Al-Abboudiyeh", "Al-Arida", "Matraba")) %>%
  dplyr::mutate(aoi = case_when(
    aoi %in% "Al-Abboudiyeh" ~ "Al Abbudiyah",
    aoi %in% "Al-Arida" ~ "Al Aridah",
    aoi %in% "Matraba" ~ "Matraba"
  ))

ol_df <- ol_df %>%
  complete(date = seq(from = ymd("2021-01-01"),
                      to = ymd("2022-10-15"),
                      by = 1),
           aoi,
           fill = list(device_count = 0))

sn_df <- sn_df %>%
  dplyr::mutate(name = case_when(
    name %in% "Al-Dabbouseh" ~ "Al Abbudiyah",
    name %in% "Tartous" ~ "Al Aridah",
    name %in% "Matraba" ~ "Matraba"
  ),
  date = date %>% as.Date()) %>%
  mutate(name_orbit = paste(name, orbit)) %>%
  dplyr::filter(name_orbit %in% c("Al Abbudiyah desc21",
                                  "Matraba orbit1",
                                  "Al Aridah desc21")) %>%
  
  ungroup() %>%
  group_by(name) %>%
  mutate(bp_perc33 = quantile(border_point, 0.33)) %>%
  ungroup() %>%
  
  mutate(border_point_adj = border_point - bp_perc33)

sn_df$border_point_adj[sn_df$border_point_adj < 0] <- 0

sn_df$border_point_adj[sn_df$name %in% "Matraba"] <- sn_df$border_point[sn_df$name %in% "Matraba"] 

# Figures ---------------------------------------------------------------------
#### Orbital Insight
p <- oi_df %>%
  
  mutate(date = date %>% floor_date(unit = "month")) %>%
  group_by(date, object, aoi_name) %>%
  dplyr::summarise(value = max(measured_count)) %>%
  ungroup() %>%
  
  mutate(object = object %>% tools::toTitleCase() %>% factor(levels = c("Truck", "Car"))) %>%
  
  ggplot() +
  geom_col(aes(x = date, y = value, fill = object),
           width = 30) +
  facet_wrap(~aoi_name) +
  theme_minimal() +
  theme(strip.text = element_text(face = "bold"),
        plot.title = element_text(face = "bold")) +
  labs(x = NULL,
       y = "N Vehicles",
       title = "Number of Cars and Trucks",
       fill = NULL) +
  scale_fill_manual(values = c("dodgerblue4", "darkorange"))

ggsave(p, filename = file.path(figures_dir, "orbital_insight_border_trends.png"),
       height = 3, width = 7)


#### Outlogic
ol_df$device_count %>% table()
summary(ol_df$device_count)

p <- ol_df %>%
  
  mutate(date = date %>% floor_date(unit = "months")) %>%
  group_by(date, aoi) %>%
  dplyr::summarise(device_count = device_count %>% mean) %>%
  
  ggplot() +
  geom_col(aes(x = date, y = device_count),
           fill = "dodgerblue4") +
  facet_wrap(~aoi,
             ncol = 3) +
  labs(x = NULL,
       y = "N Devices",
       title = "Number of Unique Devices at Border Crossing",
       subtitle = "Daily Values, Averaged Monthly") +
  
  theme_minimal() +
  theme(strip.text = element_text(face = "bold"),
        plot.title = element_text(face = "bold"))

ggsave(p, filename = file.path(figures_dir, "outlogic_border_trends.png"),
       height = 3, width = 7)

p <- ol_df %>%
  
  ggplot() +
  geom_col(aes(x = date, y = device_count),
           fill = "dodgerblue4") +
  facet_wrap(~aoi,
             ncol = 3) +
  labs(x = NULL,
       y = "N Devices",
       title = "Number of Unique Devices at Border Crossing",
       subtitle = "Daily Values") +
  
  theme_minimal() +
  theme(strip.text = element_text(face = "bold"),
        plot.title = element_text(face = "bold"))

ggsave(p, filename = file.path(figures_dir, "outlogic_border_trends_daily.png"),
       height = 3, width = 7)

#### Outlogic
p <- ol_df %>%
  
  mutate(date = date %>% floor_date(unit = "months")) %>%
  group_by(date, aoi) %>%
  dplyr::summarise(device_count = device_count %>% max) %>%
  
  ggplot() +
  geom_col(aes(x = date, y = device_count),
           fill = "dodgerblue4") +
  facet_wrap(~aoi,
             ncol = 3) +
  labs(x = NULL,
       y = "N Devices",
       title = "Number of Unique Devices at Border Crossing",
       subtitle = "Daily Values, Max Value per Month") +
  
  theme_minimal() +
  theme(strip.text = element_text(face = "bold"),
        plot.title = element_text(face = "bold"))

ggsave(p, filename = file.path(figures_dir, "outlogic_border_trends_max.png"),
       height = 3, width = 7)

#### SpaceKnow
p <- sn_df %>%
  
  mutate(date = date %>% floor_date(unit = "months")) %>%
  group_by(date, name) %>%
  dplyr::summarise(border_point_adj = border_point_adj %>% mean) %>%
  
  ggplot() +
  geom_col(aes(x = date, y = border_point_adj),
           fill = "dodgerblue4") +
  facet_wrap(~name) +
  
  labs(x = NULL,
       title = "Trends in Traffic Index",
       y = "Traffic Index") +
  
  theme_minimal() +
  theme(strip.text = element_text(face = "bold"),
        plot.title = element_text(face = "bold"))

ggsave(p, filename = file.path(figures_dir, "spaceknow_border_trends.png"),
       height = 3, width = 7)

# Stats ------------------------------------------------------------------------
oi_month_df <- oi_df %>%
  
  mutate(date = date %>% floor_date(unit = "month")) %>%
  group_by(date, object, aoi_name) %>%
  dplyr::summarise(value = max(measured_count)) %>%
  ungroup()

oi_month_df %>%
  #dplyr::filter(date >= ymd("2022-01-01")) %>%
  group_by(object, aoi_name) %>%
  dplyr::summarise(value = mean(value))


# Comparison Time Period -------------------------------------------------------
sn_m_df <- sn_df %>%
  
  mutate(date = date %>% floor_date(unit = "months")) %>%
  group_by(date, name) %>%
  dplyr::summarise(border_point_adj = border_point_adj %>% mean) %>%
  dplyr::rename(value = border_point_adj) %>%
  mutate(source = "SpaceKnow")

ol_m_df <- ol_df %>%
  
  mutate(date = date %>% floor_date(unit = "months")) %>%
  group_by(date, aoi) %>%
  dplyr::summarise(device_count = device_count %>% mean) %>%
  dplyr::rename(name = aoi,
                value = device_count) %>%
  mutate(source = "Outlogic")

oi_m_df <- oi_df %>%
  
  mutate(date = date %>% floor_date(unit = "month")) %>%
  group_by(date, object, aoi_name) %>%
  dplyr::summarise(value = max(measured_count)) %>%
  ungroup() %>%
  
  group_by(date, aoi_name) %>%
  dplyr::summarise(value = sum(value, na.rm = T)) %>%
  dplyr::rename(name = aoi_name) %>%
  mutate(source = "Orbital Insight")

month_df <- bind_rows(ol_m_df,
                      oi_m_df,
                      sn_m_df) %>%
  dplyr::filter(date >= ymd("2021-01-01"),
                date <= ymd("2021-12-31")) 

#### All together
p <- month_df %>%
  ggplot() +
  geom_col(aes(x = date, y = value),
           fill = "dodgerblue4") +
  facet_grid(source~name,
             scales = "free_y") +
  labs(y = "Value",
       title = "Trends in Traffic Across All Sources",
       x = NULL) +
  theme_classic2() +
  theme(plot.title = element_text(face = "bold"))

ggsave(p, filename = file.path(figures_dir, "2021_border_trends.png"),
       height = 6, width = 9)

#### All together - cleaner version
p_ol <- month_df %>%
  dplyr::filter(source == "Outlogic") %>%
  ggplot() +
  geom_col(aes(x = date, y = value), fill = "dodgerblue4") +
  labs(x = NULL,
       y = "Number of Unique Users",
       title = "Number of Unique Users [GPS Mobility Data, Outlogic]") +
  facet_wrap(~name) +
  theme_classic2() +
  theme(plot.title = element_text(face = "bold"),
        strip.text = element_text(face = "bold"),
        strip.background = element_blank())

p_sn <- month_df %>%
  dplyr::filter(source == "SpaceKnow") %>%
  ggplot() +
  geom_col(aes(x = date, y = value), fill = "dodgerblue4") +
  labs(x = NULL,
       y = "Traffic Index",
       title = "Traffic Index [SAR Imagery, SpaceKnow]") +
  facet_wrap(~name) +
  theme_classic2() +
  theme(plot.title = element_text(face = "bold"),
        strip.text = element_text(face = "bold"),
        strip.background = element_blank())

p_oi <- oi_df %>%
  
  mutate(date = date %>% floor_date(unit = "month")) %>%
  group_by(date, object, aoi_name) %>%
  dplyr::summarise(value = max(measured_count)) %>%
  ungroup() %>%
  
  dplyr::filter(date >= ymd("2021-01-01"),
                date <= ymd("2021-12-01")) %>%
  
  mutate(object = object %>% tools::toTitleCase() %>% factor(levels = c("Truck", "Car"))) %>%
  
  ggplot() +
  geom_col(aes(x = date, y = value, fill = object),
           width = 10) +
  facet_wrap(~aoi_name) +
  theme_classic2() +
  theme(strip.text = element_text(face = "bold"),
        strip.background = element_blank(),
        plot.title = element_text(face = "bold"),
        legend.position = "top") +
  labs(x = NULL,
       y = "N Vehicles",
       title = "Number of Vehicles [VHR Imagery, Orbital Insight]",
       fill = NULL) +
  scale_fill_manual(values = c("dodgerblue1", "darkorange")) +
  xlim(c(ymd("2021-01-01"), ymd("2021-12-10")))

p_all <- ggarrange(p_oi,
                   p_sn,
                   p_ol,
                   ncol = 1,
                   heights = c(0.36,0.3,0.3))


ggsave(p_all, filename = file.path(figures_dir, "2021_border_trends_clean.png"),
       height = 9, width = 10)
