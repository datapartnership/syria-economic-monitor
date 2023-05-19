# Maps

# Load / clean NTL data --------------------------------------------------------
ntl_df <- read_csv(file.path(ntl_bm_dir, "FinalData", "aggregated", "syr_temp", 
                             "syr_admin_adm3_daily.csv"))

eq3_df <- read_xlsx(file.path(eq_intensity_dir, "RawData", "Intensity_ADM3.xlsx"))
eq3_df <- eq3_df %>%
  dplyr::select(ADM3_CODE, POPULATION, intensity) %>%
  dplyr::rename(ADM3_PCODE = ADM3_CODE)

ntl_df <- ntl_df %>%
  left_join(eq3_df, by = "ADM3_PCODE")

ntl_df <- ntl_df %>%
  group_by(ADM3_PCODE, intensity) %>%
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

## Merge with GADM
gadm_sp <- read_sf(file.path(unocha_dir, "RawData", "syr_admbnda_adm3_uncs_unocha_20201217.json")) %>%
  as("Spatial")
gadm_sp$date <- NULL
gadm_sp <- merge(gadm_sp, ntl_df, by = "ADM3_PCODE")

gadm_sf <- gadm_sp %>% st_as_sf()

# Map --------------------------------------------------------------------------
gadm_sub_sf <- gadm_sf %>%
  dplyr::filter(intensity %in% c("Strong", "Very Strong", "Moderate"))

gadm_strong_sf <- gadm_sf %>%
  dplyr::filter(intensity %in% c("Very Strong", "Strong")) %>%
  st_union()

gadm_all_sf <- gadm_sf %>%
  dplyr::filter(intensity %in% c("Very Strong", "Strong", "Moderate")) %>%
  st_union()

# Just EQ Affected -------------------------------------------------------------

#### 3 Days - focus
mm <- gadm_sub_sf$viirs_bm_mean_3d_pc %>% abs() %>% max()

ggplot() +
  geom_sf(data = gadm_sub_sf,
          aes(fill = viirs_bm_mean_3d_pc),
          color = NA) +
  # geom_sf(data = gadm_all_sf,
  #         fill = NA,
  #         color = "black") +
  geom_sf(data = gadm_strong_sf,
          fill = NA,
          color = "black") +
  theme_void() +
  theme(plot.title = element_text(face = "bold", hjust = 0.5)) +
  labs(fill = "Percent\nChange\nNTL",
       title = "Nighttime Lights Percent Change\nJan to 3 Days After Earthquake") +
  scale_fill_gradient2(low = "red",
                       mid = "white",
                       high = "forestgreen",
                       midpoint = 0,
                       limits = c(-mm, mm)) 

ggsave(filename = file.path(figures_dir, "map_ntl_eq_3d_strong.png"),
       height = 4.5, 
       width = 4.5)

#### 7 Days - focus
mm <- gadm_sub_sf$viirs_bm_mean_14d_pc %>% abs() %>% max()

ggplot() +
  geom_sf(data = gadm_sub_sf,
          aes(fill = viirs_bm_mean_14d_pc),
          color = NA) +
  # geom_sf(data = gadm_all_sf,
  #         fill = NA,
  #         color = "black") +
  geom_sf(data = gadm_strong_sf,
          fill = NA,
          color = "black") +
  theme_void() +
  theme(plot.title = element_text(face = "bold", hjust = 0.5)) +
  labs(fill = "Percent\nChange\nNTL",
       title = "Nighttime Lights Percent Change\nJan to 2 Weeks After Earthquake") +
  scale_fill_gradient2(low = "red",
                       mid = "white",
                       high = "forestgreen",
                       midpoint = 0,
                       limits = c(-mm, mm))

ggsave(filename = file.path(figures_dir, "map_ntl_eq_14d_strong.png"),
       height = 4.5, 
       width = 4.5)

#### March - focus
mm <- gadm_sub_sf$viirs_bm_mean_mar_pc %>% abs() %>% max()

ggplot() +
  geom_sf(data = gadm_sub_sf,
          aes(fill = viirs_bm_mean_mar_pc),
          color = NA) +
  # geom_sf(data = gadm_all_sf,
  #         fill = NA,
  #         color = "black") +
  geom_sf(data = gadm_strong_sf,
          fill = NA,
          color = "black") +
  theme_void() +
  theme(plot.title = element_text(face = "bold", hjust = 0.5)) +
  labs(fill = "Percent\nChange\nNTL",
       title = "Nighttime Lights Percent Change\nJan to March 2023") +
  scale_fill_gradient2(low = "red",
                       mid = "white",
                       high = "forestgreen",
                       midpoint = 0,
                       limits = c(-mm, mm))

ggsave(filename = file.path(figures_dir, "map_ntl_eq_march_strong.png"),
       height = 4.5, 
       width = 4.5)

# All Syria --------------------------------------------------------------------

#### 3 Days - focus
mm <- gadm_sf$viirs_bm_mean_3d_pc %>% abs() %>% max()

ggplot() +
  geom_sf(data = gadm_sf,
          aes(fill = viirs_bm_mean_3d_pc),
          color = NA) +
  geom_sf(data = gadm_all_sf,
          fill = NA,
          color = "black") +
  geom_sf(data = gadm_strong_sf,
          fill = NA,
          color = "black") +
  theme_void() +
  theme(plot.title = element_text(face = "bold", hjust = 0.5)) +
  labs(fill = "Percent\nChange\nNTL",
       title = "Nighttime Lights Percent Change\nJan to 3 Days After Earthquake") +
  scale_fill_gradient2(low = "red",
                       mid = "white",
                       high = "forestgreen",
                       midpoint = 0,
                       limits = c(-mm, mm))

ggsave(filename = file.path(figures_dir, "map_ntl_eq_3d.png"),
       height = 4.5, 
       width = 4.5)

#### 14 Days - focus
mm <- gadm_sf$viirs_bm_mean_14d_pc %>% abs() %>% max()

ggplot() +
  geom_sf(data = gadm_sf,
          aes(fill = viirs_bm_mean_14d_pc),
          color = NA) +
  geom_sf(data = gadm_all_sf,
          fill = NA,
          color = "black") +
  geom_sf(data = gadm_strong_sf,
          fill = NA,
          color = "black") +
  theme_void() +
  theme(plot.title = element_text(face = "bold", hjust = 0.5)) +
  labs(fill = "Percent\nChange\nNTL",
       title = "Nighttime Lights Percent Change\nJan to 2 Weeks After Earthquake") +
  scale_fill_gradient2(low = "red",
                       mid = "white",
                       high = "forestgreen",
                       midpoint = 0,
                       limits = c(-mm, mm))

ggsave(filename = file.path(figures_dir, "map_ntl_eq_14d.png"),
       height = 4.5, 
       width = 4.5)

#### March - all
mm <- gadm_sf$viirs_bm_mean_mar_pc %>% abs() %>% max()

ggplot() +
  geom_sf(data = gadm_sf,
          aes(fill = viirs_bm_mean_mar_pc),
          color = NA) +
  geom_sf(data = gadm_all_sf,
          fill = NA,
          color = "black") +
  geom_sf(data = gadm_strong_sf,
          fill = NA,
          color = "black") +
  theme_void() +
  theme(plot.title = element_text(face = "bold", hjust = 0.5)) +
  labs(fill = "Percent\nChange\nNTL",
       title = "Nighttime Lights Percent Change\nJan to March 2023") +
  scale_fill_gradient2(low = "red",
                       mid = "white",
                       high = "forestgreen",
                       midpoint = 0,
                       limits = c(-mm, mm))

ggsave(filename = file.path(figures_dir, "map_ntl_eq_march.png"),
       height = 4.5, 
       width = 4.5)

# All Syria: Gas Flaring -------------------------------------------------------

#### 3 Days - focus
mm <- gadm_sf$viirs_bm_gf_mean_3d_pc %>% abs() %>% max()

ggplot() +
  geom_sf(data = gadm_sf,
          aes(fill = viirs_bm_gf_mean_3d_pc),
          color = NA) +
  geom_sf(data = gadm_all_sf,
          fill = NA,
          color = "black") +
  geom_sf(data = gadm_strong_sf,
          fill = NA,
          color = "black") +
  theme_void() +
  theme(plot.title = element_text(face = "bold", hjust = 0.5)) +
  labs(fill = "Percent\nChange\nNTL",
       title = "Nighttime Lights Percent Change\nJan to 3 Days After Earthquake") +
  scale_fill_gradient2(low = "red",
                       mid = "white",
                       high = "forestgreen",
                       midpoint = 0,
                       limits = c(-mm, mm))

ggsave(filename = file.path(figures_dir, "map_ntl_gf_eq_3d.png"),
       height = 4.5, 
       width = 4.5)

#### 14 Days - focus
mm <- gadm_sf$viirs_bm_gf_mean_14d_pc %>% abs() %>% max()

ggplot() +
  geom_sf(data = gadm_sf,
          aes(fill = viirs_bm_gf_mean_14d_pc),
          color = NA) +
  geom_sf(data = gadm_all_sf,
          fill = NA,
          color = "black") +
  geom_sf(data = gadm_strong_sf,
          fill = NA,
          color = "black") +
  theme_void() +
  theme(plot.title = element_text(face = "bold", hjust = 0.5)) +
  labs(fill = "Percent\nChange\nNTL",
       title = "Nighttime Lights Percent Change\nJan to 2 Weeks After Earthquake") +
  scale_fill_gradient2(low = "red",
                       mid = "white",
                       high = "forestgreen",
                       midpoint = 0,
                       limits = c(-mm, mm))

ggsave(filename = file.path(figures_dir, "map_ntl_gf_eq_14d.png"),
       height = 4.5, 
       width = 4.5)

#### March - all
mm <- gadm_sf$viirs_bm_gf_mean_mar_pc %>% abs() %>% max()

ggplot() +
  geom_sf(data = gadm_sf,
          aes(fill = viirs_bm_gf_mean_mar_pc),
          color = NA) +
  geom_sf(data = gadm_all_sf,
          fill = NA,
          color = "black") +
  geom_sf(data = gadm_strong_sf,
          fill = NA,
          color = "black") +
  theme_void() +
  theme(plot.title = element_text(face = "bold", hjust = 0.5)) +
  labs(fill = "Percent\nChange\nNTL",
       title = "Nighttime Lights Percent Change\nJan to March 2023") +
  scale_fill_gradient2(low = "red",
                       mid = "white",
                       high = "forestgreen",
                       midpoint = 0,
                       limits = c(-mm, mm))

ggsave(filename = file.path(figures_dir, "map_ntl_gf_eq_march.png"),
       height = 4.5, 
       width = 4.5)