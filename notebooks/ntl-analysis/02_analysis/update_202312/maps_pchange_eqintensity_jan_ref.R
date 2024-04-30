# Percent Change: Month Before Earthquake!

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

df <- df %>%
  group_by(uid) %>%
  dplyr::mutate(viirs_bm_mean_202301 = viirs_bm_mean[date %in% ymd("2023-01-01")][1]) %>%
  ungroup() %>%
  dplyr::mutate(ntl_pc = ((viirs_bm_mean - viirs_bm_mean_202301) / viirs_bm_mean_202301)*100)

df$ntl_pc[df$ntl_pc %in% Inf] <- 0

# Maps -------------------------------------------------------------------------
df_sub <- df %>%
  dplyr::filter(date >= ymd("2023-02-01"),
                dist_syr <= 300*111.12)

vstrong <- df %>%
  dplyr::filter(eq_intensity_str %in% c("Very Strong", "Strong")) %>%
  st_union()

vstrong <- st_intersection(vstrong, df_sub[df_sub$date %in% ymd("2023-02-01"),] %>%
                             st_union())

df_sub$ntl_pc[df_sub$ntl_pc > 100]  <- 100
df_sub$ntl_pc[df_sub$ntl_pc < -100] <- -100
p <- ggplot() +
  geom_sf(data = df_sub[df_sub$eq_intensity_str %in% c("Very Strong", "Strong", "Moderate"),],
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
                       labels = c("< -100",
                                  "-50",
                                  "0",
                                  "50",
                                  "> 100")) +
  labs(fill = "Percent\nChange",
       title = "Percent Change since January, 2023",
       caption = "Black line indicates Very Strong or Strong earthquake intensity") +
  facet_wrap(~date, nrow = 2) +
  theme_void() +
  theme(plot.title = element_text(hjust = 0.5, face = "bold"))

ggsave(p,
       filename = file.path(figures_dir, "pchange_ntl_monthly.png"),
       height = 5, width = 10)
