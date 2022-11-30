# Trends in NTL

# Country Level: All Types -----------------------------------------------------
gadm_df <- readRDS(file.path(gadm_dir, "FinalData", paste0("gadm_", 0, "_ntl.Rds")))

gadm_long_df <- gadm_df %>%
  pivot_longer(contains("viirs_")) %>%
  dplyr::mutate(name = case_when(
    name == "viirs_bm_mean" ~ "VIIRS: BlackMarble",
    name == "viirs_c_mean" ~ "VIIRS: Stray Light Corrected",
    name == "viirs_mean" ~ "VIIRS"
  )) %>%
  dplyr::mutate(name = name %>% factor(levels = c("VIIRS: BlackMarble",
                                                  "VIIRS: Stray Light Corrected",
                                                  "VIIRS")))

p <- gadm_long_df %>%
  ggplot() +
  geom_line(aes(x = year_month,
                y = value)) +
  facet_wrap(~name,
             scales = "free_y",
             ncol = 1) +
  labs(x = NULL,
       y = "NTL Radiance") +
  theme_classic() +
  theme(strip.text = element_text(face = "bold"),
        strip.background = element_blank())

ggsave(p,
       filename = file.path(out_ntl_dir, "figures", "ntl_trends_adm0.png"),
       height = 4, width = 4)

# ADM 1 ------------------------------------------------------------------------
gadm_df <- readRDS(file.path(gadm_dir, "FinalData", paste0("gadm_", 1, "_ntl.Rds")))

gadm_df <- gadm_df %>%
  dplyr::mutate(viirs_bm_sum = viirs_bm_sum / 1000000,
                viirs_bm_gf_sum = viirs_bm_gf_sum / 1000000,
                viirs_bm_nogf_sum = viirs_bm_nogf_sum / 1000000)

p_bm <- gadm_df %>%
  ggplot() +
  geom_line(aes(x = year_month,
                y = viirs_bm_sum)) +
  facet_wrap(~NAME_1,
             scales = "free_y",
             nrow = 14) +
  labs(x = NULL,
       y = "NTL Radiance",
       title = "NTL") +
  theme_classic() +
  theme(strip.text = element_text(face = "bold"),
        strip.background = element_blank(),
        plot.title = element_text(face = "bold", hjust = 0.5))

p_bm_gf <- gadm_df %>%
  ggplot() +
  geom_line(aes(x = year_month,
                y = viirs_bm_gf_sum)) +
  facet_wrap(~NAME_1,
             scales = "free_y",
             nrow = 14) +
  labs(x = NULL,
       y = "NTL Radiance",
       title = "NTL - Gas Flares") +
  theme_classic() +
  theme(strip.text = element_text(face = "bold"),
        strip.background = element_blank(),
        plot.title = element_text(face = "bold", hjust = 0.5))

p_bm_nogf <- gadm_df %>%
  ggplot() +
  geom_line(aes(x = year_month,
                y = viirs_bm_nogf_sum)) +
  facet_wrap(~NAME_1,
             scales = "free_y",
             nrow = 14) +
  labs(x = NULL,
       y = "NTL Radiance",
       title = "NTL - Gas Flares Removed") +
  theme_classic() +
  theme(strip.text = element_text(face = "bold"),
        strip.background = element_blank(),
        plot.title = element_text(face = "bold", hjust = 0.5))

p <- ggarrange(p_bm, p_bm_gf, p_bm_nogf,
               nrow = 1)

ggsave(p,
       filename = file.path(out_ntl_dir, "figures", "ntl_trends_adm1.png"),
       height = 13, width = 11)


# ADM 2 ------------------------------------------------------------------------
gadm_df <- readRDS(file.path(gadm_dir, "FinalData", paste0("gadm_", 1, "_ntl.Rds")))

p <- gadm_df %>%
  ggplot() +
  geom_line(aes(x = year_month,
                y = viirs_bm_gf_mean)) +
  facet_wrap(~NAME_1,
             scales = "free_y") +
  labs(x = NULL,
       y = "NTL Luminosity") +
  theme_classic() +
  theme(strip.text = element_text(face = "bold", size = 8),
        axis.text.x = element_text(size = 5),
        strip.background = element_blank())

p

ggsave(p,
       filename = file.path(out_ntl_dir, "figures", "ntl_trends_adm2.png"),
       height = 8, width = 14)



# ADM 2 ------------------------------------------------------------------------
gadm_df <- readRDS(file.path(gadm_dir, "FinalData", paste0("gadm_", 2, "_ntl.Rds")))

p <- gadm_df %>%
  ggplot() +
  geom_line(aes(x = year_month,
                y = viirs_bm_mean)) +
  facet_wrap(~NAME_2,
             scales = "free_y") +
  labs(x = NULL,
       y = "NTL Radiance") +
  theme_classic() +
  theme(strip.text = element_text(face = "bold", size = 8),
        axis.text.x = element_text(size = 5),
        strip.background = element_blank())

ggsave(p,
       filename = file.path(out_ntl_dir, "figures", "ntl_trends_adm2.png"),
       height = 8, width = 14)
