# Percent Change

# Load/prep geometries ---------------------------------------------------------
syr_0_sf <- read_sf(file.path(unocha_dir, "RawData", "syr_admbnda_adm0_uncs_unocha_20201217.json"))

syr_sf <- read_sf(file.path(unocha_dir, "RawData", "syr_admbnda_adm3_uncs_unocha_20201217.json")) %>%
  dplyr::select(ADM1_EN, ADM2_EN, ADM3_EN)

tur_sf <- read_sf(file.path(data_dir, "turkey_administrativelevels0_1_2", "tur_polbna_adm2.shp")) %>%
  dplyr::select(pcode)

syr_sf$dist_syr <- st_distance(syr_0_sf, syr_sf) %>% as.numeric()
tur_sf$dist_syr <- st_distance(syr_0_sf, tur_sf) %>% as.numeric()

# Load/prep data ---------------------------------------------------------------
syr_df <- readRDS(file.path(ntl_bm_dir, "FinalData", "aggregated",
                            paste0("syr", "_admin_adm",
                                   3, "_", "monthly", ".Rds"))) %>%
  mutate(country = "Syria",
         adm = ADM3_EN %>% tolower() %>% tools::toTitleCase())

syr_sf <- syr_sf %>%
  left_join(syr_df, by = c("ADM1_EN", "ADM2_EN", "ADM3_EN"))


tur_df <- readRDS(file.path(ntl_bm_dir, "FinalData", "aggregated",
                            paste0("tur", "_admin_adm",
                                   2, "_", "monthly", ".Rds"))) %>%
  mutate(country = "Turkey",
         adm = adm2_en %>% tolower() %>% tools::toTitleCase())

tur_sf <- tur_sf %>%
  right_join(tur_df, by = "pcode")

df <- bind_rows(
  syr_sf,
  tur_sf
) %>%
  mutate(adm_c = paste0(adm, "\n", country)) %>%
  dplyr::filter(date >= ymd("2021-01-01")) %>%
  dplyr::mutate(uid = paste(adm, country, ADM3_PCODE, pcode) %>% as.factor() %>% as.numeric())

df_wide <- df %>%
  dplyr::mutate(period = case_when(
    date %in% ymd("2022-01-01"):ymd("2022-08-01") ~ "yr2022",
    date %in% ymd("2023-01-01"):ymd("2023-08-01") ~ "yr2023"
  )) %>%
  ungroup() %>%
  dplyr::filter(!is.na(period)) %>%
  st_drop_geometry(geometry) %>%

  group_by(uid, period) %>%
  dplyr::summarise(viirs_bm_mean = mean(viirs_bm_mean),
                   viirs_bm_nogf_mean = mean(viirs_bm_nogf_mean)) %>%
  ungroup() %>%

  dplyr::select(uid, period, viirs_bm_mean, viirs_bm_nogf_mean) %>%
  pivot_wider(id_cols = c(uid),
              names_from = period,
              values_from = c(viirs_bm_mean, viirs_bm_nogf_mean)) %>%
  dplyr::mutate(ntl_pc = (viirs_bm_mean_yr2023 - viirs_bm_mean_yr2022) / viirs_bm_mean_yr2022 * 100,
                ntl_nogf_pc = (viirs_bm_nogf_mean_yr2023 - viirs_bm_nogf_mean_yr2022) / viirs_bm_nogf_mean_yr2022 * 100)


df_geom <- df %>%
  dplyr::filter(date %in% ymd("2021-01-01")) %>%
  dplyr::select(uid, eq_intensity_str, dist_syr, country) %>%
  left_join(df_wide, by = "uid")

# Maps -------------------------------------------------------------------------
df_sub <- df_geom %>%
  dplyr::filter( (eq_intensity_str %in% c("Very Strong", "Strong")) | (country %in% "Syria")  )

vstrong <- df_geom %>%
  dplyr::filter(eq_intensity_str %in% c("Very Strong", "Strong")) %>%
  st_union()

vstrong <- st_intersection(vstrong, df_sub %>%
                             st_union())

df_sub$ntl_pc[df_sub$ntl_pc > 100]  <- 100
df_sub$ntl_pc[df_sub$ntl_pc < -100] <- -100

df_sub$ntl_nogf_pc[df_sub$ntl_nogf_pc > 100]  <- 100
df_sub$ntl_nogf_pc[df_sub$ntl_nogf_pc < -100] <- -100

p <- ggplot() +
  geom_sf(data = syr_0_sf,
          color = "gray30") +
  geom_sf(data = df_sub,
          aes(fill = ntl_pc),
          size = 0,
          color = "gray50") +
  geom_sf(data = vstrong,
          fill = NA,
          color = "black",
          linewidth = 0.5) +
  scale_fill_gradient2(low = "firebrick2",
                       mid = "white",
                       high = "forestgreen",
                       midpoint = 0,
                       breaks = c(-100,
                                  -50,
                                  0,
                                  50,
                                  100),
                       limits = c(-100, 100),
                       labels = c("< -100",
                                  "-50",
                                  "0",
                                  "50",
                                  "> 100")) +
  labs(fill = "Percent\nChange",
       title = "Percent Change: Jan - Aug 2022 to Jan - Aug 2023",
       caption = "Black line indicates Very Strong or Strong earthquake intensity.\nPercent only shown for regions at least moderately effected by earthquake.\nShowing locations in Turkey at least strongly effected by the earthquake.") +
  theme_void() +
  theme(plot.title = element_text(hjust = 0.5, face = "bold"),
        plot.caption = element_text(size = 6))

ggsave(p,
       filename = file.path(figures_dir, "pchange_ntl_2022_2023.png"),
       height = 5, width = 10)




p <- ggplot() +
  geom_sf(data = syr_0_sf,
          color = "gray30") +
  geom_sf(data = df_sub,
          aes(fill = ntl_nogf_pc),
          size = 0,
          color = "gray50") +
  geom_sf(data = vstrong,
          fill = NA,
          color = "black",
          linewidth = 0.5) +
  scale_fill_gradient2(low = "firebrick2",
                       mid = "white",
                       high = "forestgreen",
                       midpoint = 0,
                       breaks = c(-100,
                                  -50,
                                  0,
                                  50,
                                  100),
                       limits = c(-100, 100),
                       labels = c("< -100",
                                  "-50",
                                  "0",
                                  "50",
                                  "> 100")) +
  labs(fill = "Percent\nChange",
       title = "Percent Change: Jan - Aug 2022 to Jan - Aug 2023",
       subtitle = "Nighttime lights from gas flaring locations removed",
       caption = "Black line indicates Very Strong or Strong earthquake intensity.\nPercent only shown for regions at least moderately effected by earthquake.\nShowing locations in Turkey at least strongly effected by the earthquake.") +
  theme_void() +
  theme(plot.title = element_text(hjust = 0.5, face = "bold"),
        plot.subtitle = element_text(hjust = 0.5, face = "italic"),
        plot.caption = element_text(size = 6))

ggsave(p,
       filename = file.path(figures_dir, "pchange_ntl_nogf_2022_2023.png"),
       height = 5, width = 10)

