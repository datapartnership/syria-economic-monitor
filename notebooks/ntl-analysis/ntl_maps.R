# Trends in NTL

# Country Level: All Types -----------------------------------------------------
gadm_sp <- readRDS(file.path(gadm_dir, "RawData", "gadm36_SYR_0_sp.rds"))

for(year in 2012:2022){
  
  r_paths <- file.path(ntl_bm_dir, "FinalData", "monthly_rasters") %>%
    list.files(pattern = paste0("bm_vnp46A3_", year),
               full.names = T)
  
  r_stack <- stack(r_paths) %>% crop(gadm_sp) %>% mask(gadm_sp)
  
  r_mean <- calc(r_stack, fun = mean)
  
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
  
  ggsave(p,
         filename = file.path(out_ntl_dir, "figures", paste0("ntl_map_", year, ".png")),
         height = 5, width = 6)
  
}




library(raster)

r <- r_mean
r[] <- log(r[]+1)
pal <- colorNumeric(c("#0C2C84", "#41B6C4", "#FFFFCC"), raster::values(r),
                    na.color = "transparent")

leaflet() %>% addTiles() %>%
  addRasterImage(r, colors = pal, opacity = 0.4) %>%
  addLegend(pal = pal, values = raster::values(r),
            title = "Surface temp") 
