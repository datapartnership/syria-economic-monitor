# Monthly Trends

# Prep data --------------------------------------------------------------------
syr_df <- readRDS(file.path(ntl_bm_dir, "FinalData", "aggregated",
                            paste0("syr", "_admin_adm",
                                   3, "_", "monthly", ".Rds"))) %>%
  mutate(country = "Syria",
         adm = ADM3_EN %>% tolower() %>% tools::toTitleCase())

tur_df <- readRDS(file.path(ntl_bm_dir, "FinalData", "aggregated",
                            paste0("tur", "_admin_adm",
                                   2, "_", "monthly", ".Rds"))) %>%
  mutate(country = "Turkey",
         adm = adm2_en %>% tolower() %>% tools::toTitleCase())

df <- bind_rows(
  syr_df,
  tur_df
) %>%
  mutate(adm_c = paste0(adm, "\n", country)) %>%
  dplyr::filter(date >= ymd("2021-01-01"))

# Figure, aggregated by intensity ----------------------------------------------
df %>%
  dplyr::filter(country == "Syria") %>%
  group_by(date, eq_intensity_str) %>%
  dplyr::summarise(viirs_bm_mean = mean(viirs_bm_mean),
                   viirs_bm_nogf_mean = mean(viirs_bm_nogf_mean)) %>%
  ggplot() +
  geom_vline(xintercept = ymd("2023-02-01"), color = "red") + 
  geom_line(aes(x = date,
                y = viirs_bm_mean,
                color = "NTL"),
            linewidth = 0.95) +
  geom_line(aes(x = date,
                y = viirs_bm_nogf_mean,
                color = "NTL, Remove\nGas Flaring"),
            linewidth = 0.75) +
  facet_wrap(~eq_intensity_str,
             scales = "free_y") +
  labs(x = NULL,
       y = NULL,
       title = "Syria",
       color = NULL) +
  scale_color_manual(values = c("darkorange", "black")) +
  theme_classic2() +
  theme(strip.background = element_blank(),
        strip.text = element_text(face = "bold"),
        plot.title = element_text(hjust = 0.5, face = "bold")) 

ggsave(filename = file.path(figures_dir, "syr_eqintensity_monthly.png"),
       height = 4, width = 10)

df %>%
  dplyr::filter(country == "Turkey") %>%
  group_by(date, eq_intensity_str) %>%
  dplyr::summarise(viirs_bm_mean = mean(viirs_bm_mean),
                   viirs_bm_nogf_mean = mean(viirs_bm_nogf_mean)) %>%
  ggplot() +
  geom_vline(xintercept = ymd("2023-02-01"), color = "red") + 
  geom_line(aes(x = date,
                y = viirs_bm_mean,
                color = "NTL"),
            linewidth = 0.95) +
  geom_line(aes(x = date,
                y = viirs_bm_nogf_mean,
                color = "NTL, Remove\nGas Flaring"),
            linewidth = 0.75) +
  facet_wrap(~eq_intensity_str,
             scales = "free_y") +
  labs(x = NULL,
       y = NULL,
       title = "Turkey") +
  scale_color_manual(values = c("darkorange", "black")) +
  theme_classic2() +
  theme(strip.background = element_blank(),
        strip.text = element_text(face = "bold"),
        plot.title = element_text(hjust = 0.5, face = "bold"))

ggsave(filename = file.path(figures_dir, "tur_eqintensity_monthly.png"),
       height = 4, width = 10)

# Figure, by admin region ------------------------------------------------------
syr_adm_df <- df %>%
  dplyr::filter(country == "Syria") %>%
  group_by(date, adm, eq_intensity_str) %>%
  dplyr::summarise(viirs_bm_mean = mean(viirs_bm_mean),
                   viirs_bm_nogf_mean = mean(viirs_bm_nogf_mean)) %>%
  ungroup()

syr_adm_df %>%
  dplyr::filter(eq_intensity_str %in% "Very Strong") %>%
  ggplot() +
  geom_vline(xintercept = ymd("2023-02-01"), color = "red") + 
  geom_line(aes(x = date,
                y = viirs_bm_mean,
                color = "NTL"),
            linewidth = 0.95) +
  geom_line(aes(x = date,
                y = viirs_bm_nogf_mean,
                color = "NTL, Remove\nGas Flaring"),
            linewidth = 0.75) +
  facet_wrap(~adm,
             scales = "free_y") +
  labs(x = NULL,
       y = NULL,
       title = "Syria: ADM3 Locations Very Strongly Effected",
       color = NULL) +
  scale_color_manual(values = c("darkorange", "black")) +
  theme_classic2() +
  theme(strip.background = element_blank(),
        strip.text = element_text(face = "bold"),
        plot.title = element_text(hjust = 0.5, face = "bold")) 

ggsave(filename = file.path(figures_dir, "syr_eqintensity_adm_verystrong_monthly.png"),
       height = 4, width = 8)



syr_adm_df %>%
  dplyr::filter(eq_intensity_str %in% "Strong") %>%
  ggplot() +
  geom_vline(xintercept = ymd("2023-02-01"), color = "red") + 
  geom_line(aes(x = date,
                y = viirs_bm_mean,
                color = "NTL"),
            linewidth = 0.95) +
  geom_line(aes(x = date,
                y = viirs_bm_nogf_mean,
                color = "NTL, Remove\nGas Flaring"),
            linewidth = 0.75) +
  facet_wrap(~adm,
             scales = "free_y") +
  labs(x = NULL,
       y = NULL,
       title = "Syria: ADM3 Locations Strongly Effected",
       color = NULL) +
  scale_color_manual(values = c("darkorange", "black")) +
  theme_classic2() +
  theme(strip.background = element_blank(),
        strip.text = element_text(face = "bold"),
        plot.title = element_text(hjust = 0.5, face = "bold")) 

ggsave(filename = file.path(figures_dir, "syr_eqintensity_adm_strong_monthly.png"),
       height = 10, width = 14)




tur_adm_df <- df %>%
  dplyr::filter(country == "Turkey") %>%
  group_by(date, adm, eq_intensity_str) %>%
  dplyr::summarise(viirs_bm_mean = mean(viirs_bm_mean),
                   viirs_bm_nogf_mean = mean(viirs_bm_nogf_mean)) 

tur_adm_df %>%
  dplyr::filter(eq_intensity_str %in% "Very Strong") %>%
  ggplot() +
  geom_vline(xintercept = ymd("2023-02-01"), color = "red") + 
  geom_line(aes(x = date,
                y = viirs_bm_mean,
                color = "NTL"),
            linewidth = 0.95) +
  geom_line(aes(x = date,
                y = viirs_bm_nogf_mean,
                color = "NTL, Remove\nGas Flaring"),
            linewidth = 0.75) +
  facet_wrap(~adm,
             scales = "free_y") +
  labs(x = NULL,
       y = NULL,
       title = "Turkey: ADM2 Locations Very Strongly Effected",
       color = NULL) +
  scale_color_manual(values = c("darkorange", "black")) +
  theme_classic2() +
  theme(strip.background = element_blank(),
        strip.text = element_text(face = "bold"),
        plot.title = element_text(hjust = 0.5, face = "bold")) 

ggsave(filename = file.path(figures_dir, "tur_eqintensity_adm_verystrong_monthly.png"),
       height = 10, width = 14)
