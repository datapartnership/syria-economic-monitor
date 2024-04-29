# Maps

# Load / clean NTL data ========================================================

# Lights -----------------------------------------------------------------------
ntl_syr_df <- read_csv(file.path(ntl_bm_dir, "FinalData", "aggregated", "syr_temp",
                                 "syr_admin_adm3_daily.csv"))

ntl_tur_df <- readRDS(file.path(data_tur_dir, "NTL BlackMarble", "FinalData", "aggregated",
                                paste0("adm2", "_", "VNP46A2", ".Rds")))

ntl_syr_df <- ntl_syr_df %>%
  mutate(adm = ADM3_PCODE) %>%
  dplyr::select(viirs_bm_mean, viirs_bm_gf_mean, adm, date)

ntl_tur_df <- ntl_tur_df %>%
  dplyr::select(ntl_bm_mean, ntl_bm_gf_mean, pcode, date) %>%
  dplyr::rename(viirs_bm_mean = ntl_bm_mean,
                viirs_bm_gf_mean = ntl_bm_gf_mean,
                adm = pcode)

ntl_df <- bind_rows(ntl_syr_df,
                    ntl_tur_df)

# Earthquake -------------------------------------------------------------------
eq_syr_df <- read_csv(file.path(data_dir, "Earthquake Intensity by admin regions", "syria_adm3_earthquake_intensity.csv"))
eq_tur_df <- read_csv(file.path(data_dir, "Earthquake Intensity by admin regions", "turkiye_admin2_earthquake_intensity_max.csv"))

syr_pcode <- read_csv(file.path(ntl_bm_dir, "FinalData", "aggregated", "syr_temp",
                                "syr_admin_adm3_daily.csv")) %>%
  distinct(ADM2_EN, ADM3_EN, ADM3_PCODE) %>%
  dplyr::mutate(adm23 = paste(ADM2_EN, ADM3_EN),
                adm = ADM3_PCODE) %>%
  dplyr::select(adm23, adm)

eq_syr_df <- eq_syr_df %>%
  dplyr::mutate(adm23 = paste(ADM2_EN, ADM3_EN)) %>%
  left_join(syr_pcode, by = "adm23") %>%
  dplyr::select(max_intensity_feb6, adm) %>%
  dplyr::rename(mi = max_intensity_feb6)

eq_tur_df <- eq_tur_df %>%
  dplyr::rename(adm = pcode,
                mi = mmi_feb06_7p8) %>%
  dplyr::select(adm, mi)

eq_df <- bind_rows(eq_syr_df,
                   eq_tur_df)

eq_df <- eq_df %>%
  mutate(intensity = case_when(
    mi >= 7 ~ "Very Strong",
    mi >= 6 ~ "Strong",
    mi >= 5 ~ "Moderate",
    mi >= 4 ~ "Light",
    mi >= 3 ~ "Weak",
    mi >= 2 ~ "Weak",
    mi < 2 ~ "Not felt"
  ))

# Append NTL / MI --------------------------------------------------------------
ntl_df <- ntl_df %>%
  left_join(eq_df, by = "adm")

ntl_df <- ntl_df %>%
  group_by(adm, intensity) %>%
  summarise(viirs_bm_mean_jan = mean(viirs_bm_mean[date %in% ymd("2023-01-01"):ymd("2023-01-31")]),
            viirs_bm_mean_3d = mean(viirs_bm_mean[date %in% ymd("2023-02-07"):ymd("2023-02-09")]),
            viirs_bm_mean_14d = mean(viirs_bm_mean[date %in% ymd("2023-02-07"):ymd("2023-02-20")]),
            viirs_bm_mean_mar = mean(viirs_bm_mean[date %in% ymd("2023-03-01"):ymd("2023-03-31")]),

            viirs_bm_gf_mean_jan = mean(viirs_bm_gf_mean[date %in% ymd("2023-01-01"):ymd("2023-01-31")]),
            viirs_bm_gf_mean_3d = mean(viirs_bm_gf_mean[date %in% ymd("2023-02-07"):ymd("2023-02-09")]),
            viirs_bm_gf_mean_14d = mean(viirs_bm_gf_mean[date %in% ymd("2023-02-07"):ymd("2023-02-20")]),
            viirs_bm_gf_mean_mar = mean(viirs_bm_gf_mean[date %in% ymd("2023-03-01"):ymd("2023-03-31")])) %>%
  ungroup() %>%
  mutate(viirs_bm_mean_3d_pc = (viirs_bm_mean_3d - viirs_bm_mean_jan)/viirs_bm_mean_jan*100,
         viirs_bm_mean_14d_pc = (viirs_bm_mean_14d - viirs_bm_mean_jan)/viirs_bm_mean_jan*100,
         viirs_bm_mean_mar_pc = (viirs_bm_mean_mar - viirs_bm_mean_jan)/viirs_bm_mean_jan*100,

         viirs_bm_gf_mean_3d_pc = (viirs_bm_gf_mean_3d - viirs_bm_gf_mean_jan)/viirs_bm_gf_mean_jan*100,
         viirs_bm_gf_mean_14d_pc = (viirs_bm_gf_mean_14d - viirs_bm_gf_mean_jan)/viirs_bm_gf_mean_jan*100,
         viirs_bm_gf_mean_mar_pc = (viirs_bm_gf_mean_mar - viirs_bm_gf_mean_jan)/viirs_bm_gf_mean_jan*100)

# Merge with polygons ----------------------------------------------------------

#### ADM0 Polygons
gadm_syr0_sf <- read_sf(file.path(unocha_dir, "RawData", "syr_admbnda_adm0_uncs_unocha_20201217.json"))

#### Polygons
## Syr
gadm_syr_sp <- read_sf(file.path(unocha_dir, "RawData", "syr_admbnda_adm3_uncs_unocha_20201217.json")) %>%
  as("Spatial")

gadm_syr_sp@data <- gadm_syr_sp@data %>%
  dplyr::mutate(adm = ADM3_PCODE) %>%
  dplyr::select(adm) %>%
  dplyr::mutate(country = "syr")

## Tur
gadm_tur_sp <- read_sf(dsn = file.path(data_tur_dir,
                                       "turkey_administrativelevels0_1_2",
                                       "tur_polbna_adm2.shp")) %>%
  as("Spatial")

gadm_tur_sp@data <- gadm_tur_sp@data %>%
  dplyr::mutate(adm = pcode) %>%
  dplyr::select(adm) %>%
  dplyr::mutate(country = "tur")

## Append
dist <- st_distance(gadm_tur_sp %>% st_as_sf(), gadm_syr0_sf) %>% as.vector()
gadm_tur_sp <- gadm_tur_sp[dist <= 40000,]

gadm_sp <- rbind(gadm_tur_sp, gadm_syr_sp)

gadm_sp <- merge(gadm_sp, ntl_df, by = "adm")

gadm_sf <- gadm_sp %>% st_as_sf()

# Map --------------------------------------------------------------------------
leaflet() %>%
  addTiles() %>%
  addPolygons(data = gadm_sf[gadm_sf$intensity != "Moderate",],
              popup = ~adm)

gadm_sf$intensity[gadm_sf$adm %in% c("SY100002",
                                     "SY050404",
                                     "SY100403",
                                     "SY100303",
                                     "SY100301",
                                     "SY040303",
                                     "SY040304",
                                     "SY040111",
                                     "SY050403",
                                     "SY100302",
                                     "SY100001",
                                     "SY100400")] <- "Moderate"


gadm_sub_sf <- gadm_sf %>%
  st_buffer(dist = 2000) %>%
  dplyr::filter(intensity %in% c("Strong", "Very Strong", "Moderate"))

gadm_strong_sf <- gadm_sf %>%
  dplyr::filter(intensity %in% c("Very Strong", "Strong")) %>%
  st_buffer(dist = 2000) %>%
  st_union()

gadm_all_sf <- gadm_sf %>%
  st_buffer(dist = 2000) %>%
  dplyr::filter(intensity %in% c("Very Strong", "Strong", "Moderate")) %>%
  st_union()

## Syr
gadm_syr_sub_sf <- gadm_sf %>%
  dplyr::filter(country == "syr",
                intensity %in% c("Strong", "Very Strong", "Moderate"))

gadm_syr_strong_sf <- gadm_sf %>%
  dplyr::filter(country == "syr",
                intensity %in% c("Very Strong", "Strong")) %>%
  st_union()

gadm_syr_all_sf <- gadm_sf %>%
  dplyr::filter(country == "syr",
                intensity %in% c("Very Strong", "Strong", "Moderate")) %>%
  st_union()

# Just EQ Affected -------------------------------------------------------------

#### 3 Days - focus
mm <- gadm_sub_sf$viirs_bm_mean_3d_pc %>% abs() %>% max()

p <- ggplot() +
  geom_sf(data = gadm_sub_sf,
          aes(fill = viirs_bm_mean_3d_pc),
          color = NA) +
  geom_sf(data = gadm_syr_sub_sf %>% st_union(),
          fill = NA,
          aes(color = "Syria"),
          size = 0.5) +
  geom_sf(data = gadm_syr_strong_sf,
          fill = NA,
          color = "black") +
  theme_void() +
  theme(plot.title = element_text(face = "bold", hjust = 0.5)) +
  labs(fill = "Percent\nChange\nNTL",
       color = NULL,
       title = "Nighttime Lights Percent Change\nJan to 3 Days After Earthquake") +
  scale_fill_gradient2(low = "red",
                       mid = "white",
                       high = "forestgreen",
                       midpoint = 0,
                       limits = c(-mm, mm)) +
  scale_color_manual(values = c("dodgerblue3"))

ggsave(p, filename = file.path(figures_dir, "map_ntl_eq_3d_strong.png"),
       height = 4.5,
       width = 4.5)

#### 7 Days - focus
mm <- gadm_sub_sf$viirs_bm_mean_14d_pc %>% abs() %>% max()

p <- ggplot() +
  geom_sf(data = gadm_sub_sf,
          aes(fill = viirs_bm_mean_14d_pc),
          color = NA) +
  geom_sf(data = gadm_syr_sub_sf %>% st_union(),
          fill = NA,
          aes(color = "Syria"),
          size = 0.5) +
  geom_sf(data = gadm_syr_strong_sf,
          fill = NA,
          color = "black") +
  theme_void() +
  theme(plot.title = element_text(face = "bold", hjust = 0.5)) +
  labs(fill = "Percent\nChange\nNTL",
       color = NULL,
       title = "Nighttime Lights Percent Change\nJan to 2 Weeks After Earthquake") +
  scale_fill_gradient2(low = "red",
                       mid = "white",
                       high = "forestgreen",
                       midpoint = 0,
                       limits = c(-mm, mm)) +
  scale_color_manual(values = c("dodgerblue3"))

ggsave(p,
       filename = file.path(figures_dir, "map_ntl_eq_14d_strong.png"),
       height = 4.5,
       width = 4.5)

#### March - focus
mm <- gadm_sub_sf$viirs_bm_mean_mar_pc %>% abs() %>% max()

p <- ggplot() +
  geom_sf(data = gadm_sub_sf,
          aes(fill = viirs_bm_mean_mar_pc),
          color = NA) +
  geom_sf(data = gadm_syr_sub_sf %>% st_union(),
          fill = NA,
          aes(color = "Syria"),
          size = 0.5) +
  geom_sf(data = gadm_syr_strong_sf,
          fill = NA,
          color = "black") +
  theme_void() +
  theme(plot.title = element_text(face = "bold", hjust = 0.5)) +
  labs(fill = "Percent\nChange\nNTL",
       color = NULL,
       title = "Nighttime Lights Percent Change\nJan to March 2023") +
  scale_fill_gradient2(low = "red",
                       mid = "white",
                       high = "forestgreen",
                       midpoint = 0,
                       limits = c(-mm, mm)) +
  scale_color_manual(values = c("dodgerblue3"))

ggsave(p,
       filename = file.path(figures_dir, "map_ntl_eq_march_strong.png"),
       height = 4.5,
       width = 4.5)

# All Syria --------------------------------------------------------------------
# gadm_sf <- gadm_sf %>%
#   dplyr::filter((country == "syr") |
#                   (country == "tur") & (intensity %in% c("Strong",
#                                                          "Very Strong",
#                                                          "Moderate")))

#### 3 Days - focus
mm <- gadm_sf$viirs_bm_mean_3d_pc %>% abs() %>% max()

p <- ggplot() +
  geom_sf(data = gadm_sf,
          aes(fill = viirs_bm_mean_3d_pc),
          color = NA) +
  geom_sf(data = gadm_syr0_sf,
          fill = NA,
          aes(color = "Syria")) +
  geom_sf(data = gadm_syr_all_sf,
          fill = NA,
          color = "black") +
  geom_sf(data = gadm_syr_strong_sf,
          fill = NA,
          color = "black") +
  theme_void() +
  theme(plot.title = element_text(face = "bold", hjust = 0.5)) +
  labs(fill = "Percent\nChange\nNTL",
       color = NULL,
       title = "Nighttime Lights Percent Change\nJan to 3 Days After Earthquake") +
  scale_fill_gradient2(low = "red",
                       mid = "white",
                       high = "forestgreen",
                       midpoint = 0,
                       limits = c(-mm, mm)) +
  scale_color_manual(values = c("dodgerblue3"))

ggsave(p,
       filename = file.path(figures_dir, "map_ntl_eq_3d.png"),
       height = 4.5,
       width = 4.5)

#### 14 Days - focus
mm <- gadm_sf$viirs_bm_mean_14d_pc %>% abs() %>% max()

p <- ggplot() +
  geom_sf(data = gadm_sf,
          aes(fill = viirs_bm_mean_14d_pc),
          color = NA) +
  geom_sf(data = gadm_syr0_sf,
          fill = NA,
          aes(color = "Syria")) +
  geom_sf(data = gadm_syr_all_sf,
          fill = NA,
          color = "black") +
  geom_sf(data = gadm_syr_strong_sf,
          fill = NA,
          color = "black") +
  theme_void() +
  theme(plot.title = element_text(face = "bold", hjust = 0.5)) +
  labs(fill = "Percent\nChange\nNTL",
       color = NULL,
       title = "Nighttime Lights Percent Change\nJan to 2 Weeks After Earthquake") +
  scale_fill_gradient2(low = "red",
                       mid = "white",
                       high = "forestgreen",
                       midpoint = 0,
                       limits = c(-mm, mm)) +
  scale_color_manual(values = c("dodgerblue3"))

ggsave(p,
       filename = file.path(figures_dir, "map_ntl_eq_14d.png"),
       height = 4.5,
       width = 4.5)

#### March - all
mm <- gadm_sf$viirs_bm_mean_mar_pc %>% abs() %>% max()

p <- ggplot() +
  geom_sf(data = gadm_sf,
          aes(fill = viirs_bm_mean_mar_pc),
          color = NA) +
  geom_sf(data = gadm_syr0_sf,
          fill = NA,
          aes(color = "Syria")) +
  geom_sf(data = gadm_syr_all_sf,
          fill = NA,
          color = "black") +
  geom_sf(data = gadm_syr_strong_sf,
          fill = NA,
          color = "black") +
  theme_void() +
  theme(plot.title = element_text(face = "bold", hjust = 0.5)) +
  labs(fill = "Percent\nChange\nNTL",
       color = NULL,
       title = "Nighttime Lights Percent Change\nJan to March 2023") +
  scale_fill_gradient2(low = "red",
                       mid = "white",
                       high = "forestgreen",
                       midpoint = 0,
                       limits = c(-mm, mm)) +
  scale_color_manual(values = c("dodgerblue3"))

ggsave(p,
       filename = file.path(figures_dir, "map_ntl_eq_march.png"),
       height = 4.5,
       width = 4.5)

# All Syria: Gas Flaring -------------------------------------------------------

#### 3 Days - focus
mm <- gadm_sf$viirs_bm_gf_mean_3d_pc %>% na.omit() %>% as.vector() %>% abs() %>% max()

p <- ggplot() +
  geom_sf(data = gadm_sf,
          aes(fill = viirs_bm_gf_mean_3d_pc),
          color = NA) +
  geom_sf(data = gadm_syr0_sf,
          fill = NA,
          aes(color = "Syria")) +
  geom_sf(data = gadm_syr_all_sf,
          fill = NA,
          color = "black") +
  geom_sf(data = gadm_syr_strong_sf,
          fill = NA,
          color = "black") +
  theme_void() +
  theme(plot.title = element_text(face = "bold", hjust = 0.5)) +
  labs(fill = "Percent\nChange\nNTL",
       color = NULL,
       title = "Nighttime Lights Percent Change\nJan to 3 Days After Earthquake") +
  scale_fill_gradient2(low = "red",
                       mid = "white",
                       high = "forestgreen",
                       midpoint = 0,
                       limits = c(-mm, mm)) +
  scale_color_manual(values = c("dodgerblue3"))

ggsave(p,
       filename = file.path(figures_dir, "map_ntl_gf_eq_3d.png"),
       height = 4.5,
       width = 4.5)

#### 14 Days - focus
mm <- gadm_sf$viirs_bm_gf_mean_14d_pc %>% na.omit() %>% as.vector() %>% abs() %>% max()

p <- ggplot() +
  geom_sf(data = gadm_sf,
          aes(fill = viirs_bm_gf_mean_14d_pc),
          color = NA) +
  geom_sf(data = gadm_syr0_sf,
          fill = NA,
          aes(color = "Syria")) +
  geom_sf(data = gadm_syr_all_sf,
          fill = NA,
          color = "black") +
  geom_sf(data = gadm_syr_strong_sf,
          fill = NA,
          color = "black") +
  theme_void() +
  theme(plot.title = element_text(face = "bold", hjust = 0.5)) +
  labs(fill = "Percent\nChange\nNTL",
       color = NULL,
       title = "Nighttime Lights Percent Change\nJan to 2 Weeks After Earthquake") +
  scale_fill_gradient2(low = "red",
                       mid = "white",
                       high = "forestgreen",
                       midpoint = 0,
                       limits = c(-mm, mm)) +
  scale_color_manual(values = c("dodgerblue3"))

ggsave(p,
       filename = file.path(figures_dir, "map_ntl_gf_eq_14d.png"),
       height = 4.5,
       width = 4.5)

#### March - all
mm <- gadm_sf$viirs_bm_gf_mean_mar_pc %>% na.omit() %>% as.vector() %>% abs() %>% max()

p <- ggplot() +
  geom_sf(data = gadm_sf,
          aes(fill = viirs_bm_gf_mean_mar_pc),
          color = NA) +
  geom_sf(data = gadm_syr0_sf,
          fill = NA,
          aes(color = "Syria")) +
  geom_sf(data = gadm_syr_all_sf,
          fill = NA,
          color = "black") +
  geom_sf(data = gadm_syr_strong_sf,
          fill = NA,
          color = "black") +
  theme_void() +
  theme(plot.title = element_text(face = "bold", hjust = 0.5)) +
  labs(fill = "Percent\nChange\nNTL",
       color = NULL,
       title = "Nighttime Lights Percent Change\nJan to March 2023") +
  scale_fill_gradient2(low = "red",
                       mid = "white",
                       high = "forestgreen",
                       midpoint = 0,
                       limits = c(-mm, mm)) +
  scale_color_manual(values = c("dodgerblue3"))

ggsave(p,
       filename = file.path(figures_dir, "map_ntl_gf_eq_march.png"),
       height = 4.5,
       width = 4.5)
