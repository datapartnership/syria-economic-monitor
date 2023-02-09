# Syria Economic Monitor

# Traffic analysis at three border crossing using three data sources: (1) vehicle
# counts derived from VHR imagery from Orbital Insight, (2) traffic index derived
# from SAR imagery, prepared by SpaceKnow, and (3) mobility data from Outlogic.

# OUTLINE
# 1. Set filepaths
# 2. Load packages
# 3. Load data
# 4. Prep Outlogic data
# 5. Prep SpaceKnow data
# 6. Aggregate to monthly level
# 7. Figure

# 1. Set filepaths -------------------------------------------------------------
#### Root paths
if(Sys.info()[["user"]] == "robmarty"){
  git_dir <- "~/Documents/Github/syria-economic-monitor"
} 

#### From root
traffic_dir <- file.path(git_dir, "notebooks", "ntl-analysis")
data_dir    <- file.path(git_dir, "data")
figures_dir <- file.path(git_dir, "reports", "figures")

# 2. Load packages ------------------------------------------------------------
library(tidyverse)
library(ggtheme)
library(ggpubr)

# 3. Load data -----------------------------------------------------------------
ol_df <- read_csv(file.path(data_dir, "outlogic_bc_counts.csv"))
sn_df <- read_csv(file.path(data_dir, "traffic_index_sentinel1_sar.csv"))
oi_df <- read_csv(file.path(data_dir, "vehicle_count_oi.csv"))

# 4. Prep Outlogic data --------------------------------------------------------
ol_df <- ol_df %>%
  dplyr::filter(aoi %in% c("Al-Abboudiyeh", "Al-Arida", "Matraba")) %>%
  dplyr::mutate(aoi = case_when(
    aoi %in% "Al-Abboudiyeh" ~ "Al Abbudiyah",
    aoi %in% "Al-Arida" ~ "Al Aridah",
    aoi %in% "Matraba" ~ "Matraba"
  ))

ol_df <- ol_df %>%
  complete(date = seq(from = ymd("2020-01-01"),
                      to = ymd("2022-10-15"),
                      by = 1),
           aoi,
           fill = list(device_count = 0))

# 5. Prep SpaceKnow data -------------------------------------------------------
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

# 6. Aggregate to monthly level ------------------------------------------------
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
  dplyr::filter(date >= ymd("2020-01-01"),
                date <= ymd("2022-12-31")) 

# 7. Figure --------------------------------------------------------------------
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
  
  dplyr::filter(date >= ymd("2020-01-01"),
                date <= ymd("2022-12-31")) %>%
  
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
  xlim(c(ymd("2020-01-01"), ymd("2022-12-31")))

p_all <- ggarrange(p_oi + xlim(c(ymd("2020-01-01"), ymd("2022-12-20"))),
                   p_sn + xlim(c(ymd("2020-01-01"), ymd("2022-12-20"))),
                   p_ol + xlim(c(ymd("2020-01-01"), ymd("2022-12-20"))),
                   ncol = 1,
                   heights = c(0.36,0.3,0.3))

ggsave(p_all, filename = file.path(figures_dir, "2021_border_trends_clean.png"),
       height = 9, width = 10)



