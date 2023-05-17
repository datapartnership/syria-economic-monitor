# Trends in Governorate NTL

# Load/prep gas flaring data ---------------------------------------------------
#### Gas Flaring
gf_df <- readRDS(file.path(data_dir, "gas_flare_locations.Rds"))

coordinates(gf_df) <- ~longitude+latitude
crs(gf_df) <- CRS("+init=epsg:4326")

gf_sf <- gf_df %>% st_as_sf() %>% st_buffer(dist = 5000)
gf_sp <- gf_sf %>% as("Spatial")

## Non GS Locations
gadm_0_sp <- readRDS(file.path(data_dir, "GADM", "RawData", "gadm36_SYR_0_sp.rds"))

gadm_no_gf_sp <- gDifference(gadm_0_sp, gf_sp, byid=F)
gadm_no_gf_sp$id <- 1

# Load data --------------------------------------------------------------------
adm_i <- 1

## GADM
gadm_sp <- readRDS(file.path(data_dir, "GADM", "RawData", paste0("gadm36_SYR_",adm_i,"_sp.rds")))

gadm_df <- gadm_sp@data %>%
  dplyr::select(paste0("NAME_", 0:adm_i), paste0("GID_", 0:adm_i)) %>%
  dplyr::mutate(uid = 1:n())

gadm_id_df <- gadm_df %>%
  dplyr::select(uid)

# Extract VIIRS - Black Marble -------------------------------------------------
ym_df <- cross_df(list(year = 2012:2022,
                       month = 1:12))

ym_df <- ym_df[!((ym_df$year %in% 2022) & (ym_df$month %in% 9:12)),]

viirs_bm_df <- map_df(1:nrow(ym_df), function(i){
  print(i)
  
  ym_i_df <- ym_df[i,]
  
  r <- raster(file.path(data_dir, "NTL BlackMarble",
                        paste0("bm_vnp46A3_",ym_i_df$year,"_",ym_i_df$month %>% pad2(),
                               ".tif")))
  
  r_gf   <- r %>% crop(gf_sp) %>% mask(gf_sp)
  r_nogf <- r %>% crop(gadm_no_gf_sp) %>% mask(gadm_no_gf_sp)
  
  gadm_id_df$viirs_bm_mean <- exact_extract(r, gadm_sp, 'mean')
  gadm_id_df$viirs_bm_sum <- exact_extract(r, gadm_sp, 'sum')
  
  gadm_id_df$viirs_bm_gf_mean <- exact_extract(r_gf, gadm_sp, 'mean')
  gadm_id_df$viirs_bm_gf_sum  <- exact_extract(r_gf, gadm_sp, 'sum')
  
  gadm_id_df$viirs_bm_nogf_mean <- exact_extract(r_nogf, gadm_sp, 'mean')
  gadm_id_df$viirs_bm_nogf_sum  <- exact_extract(r_nogf, gadm_sp, 'sum')
  
  gadm_id_df$year <- ym_i_df$year
  gadm_id_df$month <- ym_i_df$month
  
  return(gadm_id_df)
})

# Merge NTL with GADM data -----------------------------------------------------
data_df <- viirs_bm_df %>%
  left_join(gadm_df, by = c("uid")) %>%
  dplyr::mutate(year_month = paste(year, "-", month, "-01") %>% ymd())

# Figure -----------------------------------------------------------------------
data_df <- data_df %>%
  dplyr::mutate(viirs_bm_sum = viirs_bm_sum / 1000000,
                viirs_bm_gf_sum = viirs_bm_gf_sum / 1000000,
                viirs_bm_nogf_sum = viirs_bm_nogf_sum / 1000000)

p_bm <- data_df %>%
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

p_bm_gf <- data_df %>%
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

p_bm_nogf <- data_df %>%
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
       filename = file.path(figures_dir, "ntl_trends_adm1.png"),
       height = 13, width = 11)


