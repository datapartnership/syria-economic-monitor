# Maps

# Load data --------------------------------------------------------------------
syr_sf <- getData('GADM', country='SYR', level=1) %>% st_as_sf()

gs_df <- readRDS(file.path(data_dir, "gas_flare_locations.Rds"))
gs_sf <- st_as_sf(gs_df, coords = c("longitude", "latitude"), crs = 4326) %>%
  st_buffer(dist = 10000)

make_raster <- function(year){
  
  ntl_files <- file.path(data_dir, 
                         "NTL BlackMarble",
                         "FinalData",
                         "monthly_rasters") %>%
    list.files(full.names = T) %>%
    str_subset(as.character(year))
  
  ntl_files <- ntl_files[!(ntl_files %>% str_detect("12.tif"))]
  
  r <- lapply(ntl_files, function(file){
    raster(file)
  }) %>%
    stack() %>%
    calc(mean)
  
  r <- r %>% crop(syr_sf) %>% mask(syr_sf) %>% mask(gs_sf)
  
  return(r)
}

r2020 <- make_raster(2020)
r2021 <- make_raster(2021)
r2022 <- make_raster(2022)
r2023 <- make_raster(2023)

# Compute change ---------------------------------------------------------------
make_change_raster <- function(r, r2023, THRESH, year){
  r_cng <- r
  
  r_cng[] <- r2023[] - r[]
  
  r_cng[][ (r_cng[] < THRESH) & (r_cng[] > -THRESH) ] <- 0
  r_cng[][r_cng[] >= THRESH]  <- 1
  r_cng[][r_cng[] <= -THRESH] <- -1
  r_cng[][ (r[] < THRESH) ] <- NA
  
  r_cng_df <- r_cng %>% rasterToPoints() %>%
    as.data.frame() %>%
    mutate(layer = case_when(
      layer == 1 ~ "New Lights",
      layer == 0 ~ "No Change",
      layer == -1 ~ "Lights Lost"
    ))
  
  r_cng_df$year <- year
  
  return(r_cng_df)
}

for(ntl_thresh in c(1,2,3,4,5)){
  
  ntl_chng_df <- bind_rows(
    make_change_raster(r2020, r2023, ntl_thresh, 2020),
    make_change_raster(r2021, r2023, ntl_thresh, 2021),
    make_change_raster(r2022, r2023, ntl_thresh, 2022)
  )
  
  ntl_chng_df <- ntl_chng_df %>%
    mutate(abc = case_when(
      year == 2020 ~ "A",
      year == 2021 ~ "B",
      year == 2022 ~ "C"
    )) %>%
    mutate(title = paste0(abc, ". Change in luminosity,\n2023 relative to ", year)) %>%
    filter(!is.na(layer))
  
  # Maps -------------------------------------------------------------------------
  p <- ntl_chng_df %>%
    ggplot() +
    geom_sf(data = syr_sf,
            fill = NA,
            color = "black") +
    geom_raster(aes(x = x, y = y,
                    fill = layer)) +
    geom_sf_text(data = syr_sf,
                 aes(label = NAME_1),
                 size = 2,
                 fontface = "bold") +
    labs(fill = NULL) +
    theme_void() +
    theme(strip.text = element_text(face = "bold"),
          legend.position = "bottom") +
    scale_fill_manual(values = c("red", "green3", "dodgerblue")) +
    facet_wrap(~title)
  
  ggsave(p,
         filename = file.path(figures_dir, 
                              paste0("maps_new_lost_nochange_2023_gf_ntl_",ntl_thresh,".png")),
         height = 5, width = 10)
}


