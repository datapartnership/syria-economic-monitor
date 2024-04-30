# NTL Change

# Load data --------------------------------------------------------------------
## GADM
gadm_sp <- getData('GADM', country='SYR', level=0)

## Average Annual NTL
r_2013 <- file.path(data_dir) %>%
  list.files(pattern = paste0("bm_vnp46A3_", 2013),
             full.names = T) %>%
  str_subset(paste0("0", 1:8, ".tif")) %>%
  stack() %>%
  calc(fun = mean) %>%
  crop(gadm_sp) %>%
  mask(gadm_sp)

r_2015 <- file.path(data_dir) %>%
  list.files(pattern = paste0("bm_vnp46A3_", 2015),
             full.names = T) %>%
  str_subset(paste0("0", 1:8, ".tif")) %>%
  stack() %>%
  calc(fun = mean) %>%
  crop(gadm_sp) %>%
  mask(gadm_sp)

r_2017 <- file.path(data_dir) %>%
  list.files(pattern = paste0("bm_vnp46A3_", 2017),
             full.names = T) %>%
  str_subset(paste0("0", 1:8, ".tif")) %>%
  stack() %>%
  calc(fun = mean) %>%
  crop(gadm_sp) %>%
  mask(gadm_sp)

r_2019 <- file.path(data_dir) %>%
  list.files(pattern = paste0("bm_vnp46A3_", 2019),
             full.names = T) %>%
  str_subset(paste0("0", 1:8, ".tif")) %>%
  stack() %>%
  calc(fun = mean) %>%
  crop(gadm_sp) %>%
  mask(gadm_sp)

r_2020 <- file.path(ntl_bm_dir, "FinalData", "monthly_rasters") %>%
  list.files(pattern = paste0("bm_vnp46A3_", 2020),
             full.names = T) %>%
  str_subset(paste0("0", 1:8, ".tif")) %>%
  stack() %>%
  calc(fun = mean) %>%
  crop(gadm_sp) %>%
  mask(gadm_sp)

r_2021 <- file.path(data_dir) %>%
  list.files(pattern = paste0("bm_vnp46A3_", 2021),
             full.names = T) %>%
  stack() %>%
  calc(fun = mean) %>%
  crop(gadm_sp) %>%
  mask(gadm_sp)

r_2022 <- file.path(data_dir) %>%
  list.files(pattern = paste0("bm_vnp46A3_", 2022),
             full.names = T) %>%
  str_subset(paste0("0", 1:8, ".tif")) %>%
  stack() %>%
  calc(fun = mean) %>%
  crop(gadm_sp) %>%
  mask(gadm_sp)

## Gas Flare Locations
gf_df <- readRDS(file.path(data_dir, "gas_flare_locations.Rds"))

# Spatially define gas flare locations -----------------------------------------
coordinates(gf_df) <- ~longitude+latitude
crs(gf_df) <- CRS("+init=epsg:4326")

gf_sf <- gf_df %>% st_as_sf() %>% st_buffer(dist = 5000)
gf_sp <- gf_sf %>% as("Spatial")

# Adjust names: GADM -----------------------------------------------------------
gadm1_sp <- readRDS(file.path(gadm_dir, "RawData", "gadm36_SYR_1_sp.rds"))

gadm1_sp@data <- gadm1_sp@data %>%
  dplyr::mutate(NAME_1 = case_when(
    NAME_1 == "Al Ḥasakah" ~ "Al-Hasakeh",
    NAME_1 == "Aleppo" ~ "Aleppo",
    NAME_1 == "Ar Raqqah" ~ "Ar-Raqqa",
    NAME_1 == "As Suwayda'" ~ "As-Sweida",
    NAME_1 == "Damascus" ~ "Damascus",
    NAME_1 == "Dar`a" ~ "Dar'a",
    NAME_1 == "Dayr Az Zawr" ~ "Deir-ez-Zor",
    NAME_1 == "Hamah" ~ "Hama",
    NAME_1 == "Hims" ~ "Homs",
    NAME_1 == "Idlib" ~ "Idleb",
    NAME_1 == "Lattakia" ~ "Lattakia",
    NAME_1 == "Quneitra" ~ "Quneitra",
    NAME_1 == "Rif Dimashq" ~ "Rular Damascus",
    NAME_1 == "Tartus" ~ "Tartous"
  ))

gadm1_sp_c <- gadm1_sp %>% gCentroid(byid = T)
gadm1_sp_df <- gadm1_sp_c %>% as.data.frame()
gadm1_sp_df$NAME_1 <- gadm1_sp$NAME_1

# Maps -------------------------------------------------------------------------
# Function to make raster change object
mk_r_diff_cat <- function(r_start, r_end){

  r_diff <- r_end - r_start

  r_out <- r_diff
  r_out[] <- NA

  r_out[r_start > 1] <- 0
  r_out[r_diff > 1]  <- 1
  r_out[r_diff < -1] <- -1

  r_out_df <- rasterToPoints(r_out, spatial = TRUE) %>% as.data.frame()
  names(r_out_df) <- c("value", "x", "y")

  return(r_out_df)
}

for(base_year in c(2019, 2020, 2021)){

  if(base_year %in% 2019) r_base <- r_2019
  if(base_year %in% 2020) r_base <- r_2020
  if(base_year %in% 2021) r_base <- r_2021

  r_df <- mk_r_diff_cat(r_base, r_2022)

  ## Plot
  p <- ggplot() +
    geom_raster(data = r_df[r_df$value == 0,],
                aes(x = x, y = y,
                    fill = "No Change"),
                alpha = 0.8) +
    geom_raster(data = r_df[r_df$value == 1,],
                aes(x = x, y = y,
                    fill = "New Lights"),
                alpha = 0.8) +
    geom_raster(data = r_df[r_df$value == -1,],
                aes(x = x, y = y,
                    fill = "Lights Lost"),
                alpha = 0.8) +
    geom_polygon(data = gf_sp,
                 aes(x = long, y = lat, group = group),
                 color = NA,
                 fill = "white") +
    geom_polygon(data = gadm_sp,
                 aes(x = long, y = lat, group = group),
                 color = "black",
                 fill = NA,
                 size = 0.1) +
    geom_text(data = gadm1_sp_df,
              aes(x = x, y = y, label = NAME_1),
              size = 2.25,
              fontface = "bold") +
    labs(fill = NULL,
         title = paste0(base_year," to 2022")) +
    theme_void() +
    theme(strip.text = element_text(face = "bold", hjust = 0.5),
          plot.title = element_text(face = "bold", hjust = 0.5),
          legend.position = c(0.8, 0.2),
          plot.background = element_rect(fill = "white")) +
    scale_fill_manual(values = c("firebrick3", "green3", "dodgerblue")) +
    coord_quickmap()

  ggsave(p,
         filename = file.path(figures_dir, paste0("ntl_change_cat_",base_year,".png")),
         height = 4, width = 4, dpi = 1000)

}
