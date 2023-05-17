# Pixel Level Change

## Load data
gadm_sp <- getData('GADM', country='SYR', level=0)

r_start <- raster(file.path(data_dir, 
                      "NTL BlackMarble",
                      "FinalData",
                      "VNP46A3_rasters",
                      "bm_VNP46A3_2023_01.tif")) %>% crop(gadm_sp) %>% mask(gadm_sp)

r_end <- raster(file.path(data_dir, 
                      "NTL BlackMarble",
                      "FinalData",
                      "VNP46A3_rasters",
                      "bm_VNP46A3_2023_02.tif")) %>% crop(gadm_sp) %>% mask(gadm_sp)

r <- r %>% crop(gadm_sp) %>% mask(gadm_sp)


r_diff <- r_end - r_start

r_out <- r_diff
r_out[] <- NA

THRESH <- 3
r_out[r_start > THRESH] <- 0
r_out[r_diff > THRESH]  <- 1
r_out[r_diff < -THRESH] <- -1

r_df <- rasterToPoints(r_out, spatial = TRUE) %>% as.data.frame()
names(r_df) <- c("value", "x", "y")

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
  geom_polygon(data = gadm_sp,
               aes(x = long, y = lat, group = group),
               color = "black",
               fill = NA,
               size = 0.1) +
  scale_fill_manual(values = c("firebrick3", "green3", "dodgerblue")) +
  labs(fill = NULL) +
  theme_void() +
  coord_sf()
  
ggsave(p,
       filename = file.path(figures_dir, paste0("ntl_change_cat_","janfeb2023",".png")),
       height = 7, width = 6, dpi = 1000)
