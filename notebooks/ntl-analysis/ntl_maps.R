# Trends in NTL

# Country Level: All Types -----------------------------------------------------
## GADM
gadm_sp <- readRDS(file.path(gadm_dir, "RawData", "gadm36_SYR_0_sp.rds"))

## GF
gf_df <- readRDS(file.path(gas_flare_dir, "FinalData", "gas_flare_locations.Rds"))

coordinates(gf_df) <- ~longitude+latitude
crs(gf_df) <- CRS("+init=epsg:4326")

gf_sf <- gf_df %>% st_as_sf() %>% st_buffer(dist = 7000)
gf_sp <- gf_sf %>% as("Spatial")

## GADM, remove GF
gadm_no_gf_sp <- gDifference(gadm_sp, gf_sp, byid=F)
gadm_no_gf_sp$id <- 1

gadm_no_gf_sf <- gadm_no_gf_sp %>% st_as_sf()


for(year in 2021:2022){
  for(flare_only in c(F)){
    
    # r_paths <- file.path(ntl_bm_dir, "FinalData", "monthly_rasters") %>%
    #   list.files(pattern = paste0("bm_vnp46A3_", year),
    #              full.names = T)
    
    r_paths <- file.path("~/Desktop/monthly_rasters") %>%
      list.files(pattern = paste0("bm_vnp46A3_", year),
                 full.names = T)
    
    r_stack <- stack(r_paths)
    
    r_mean <- calc(r_stack, fun = mean)
    if(flare_only %in% F) r_mean[gf_sp] <- 0
    r_mean <- r_mean %>% crop(gadm_sp) %>% mask(gadm_sp)
    
    r_mean[gadm_no_gf_sp] <- NA
    
    ## Plot
    r_mean_df <- rasterToPoints(r_mean, spatial = TRUE) %>% as.data.frame()
    names(r_mean_df) <- c("value", "x", "y")
    
    r_mean_df$value_adj <- log(r_mean_df$value+1)
    
    p <- ggplot() +
      geom_raster(data = r_mean_df, 
                  aes(x = x, y = y, 
                      fill = value_adj)) +
      scale_fill_gradient2(low = "black",
                           mid = "yellow",
                           high = "red",
                           midpoint = 5) +
      labs(title = year) +
      coord_quickmap() + 
      theme_void() +
      theme(plot.title = element_text(face = "bold", hjust = 0.5),
            legend.position = "none")
    
    if(flare_only){
      p <- p + geom_sf(data = gadm_no_gf_sf,
                       fill = "black",
                       color = "black")
    }
    
    ggsave(p,
           filename = file.path(out_ntl_dir, "figures", paste0("ntl_map_", year, "_flareonly",flare_only,".png")),
           height = 5, width = 6)
    
  }
}

# Latest Month -----------------------------------------------------------------
r_mean <- raster(file.path(ntl_bm_dir, "FinalData", "monthly_rasters", "bm_vnp46A3_2022_08.tif"))

r_mean[gf_sp] <- 0
r_mean <- r_mean %>% crop(gadm_sp) %>% mask(gadm_sp) 

## Plot
r_mean_df <- rasterToPoints(r_mean, spatial = TRUE) %>% as.data.frame()
names(r_mean_df) <- c("value", "x", "y")

r_mean_df$value_adj <- log(r_mean_df$value+1)

r_mean_df$value_adj[r_mean_df$value_adj <= 0.5] <- 0

p <- ggplot() +
  geom_raster(data = r_mean_df, 
              aes(x = x, y = y, 
                  fill = value_adj)) +
  # geom_polygon(data = gf_sp,
  #              aes(x = long, y = lat, group = group),
  #              fill = "black") +
  scale_fill_gradient2(low = "black",
                       mid = "yellow",
                       high = "red",
                       midpoint = 5) +
  labs(title = "NTL, August 2022") +
  coord_quickmap() + 
  theme_void() +
  theme(plot.title = element_text(face = "bold", hjust = 0.5),
        legend.position = "none")

ggsave(p,
       filename = file.path(out_ntl_dir, "figures", paste0("ntl_map_", "202208", ".png")),
       height = 5, width = 6)

