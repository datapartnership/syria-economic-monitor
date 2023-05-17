# NTL Maps: Annually

# Load data --------------------------------------------------------------------
adm2_sf <- read_sf(dsn = file.path(unocha_dir, "RawData", "syr_admbnda_adm0_uncs_unocha_20201217.json")) 

# Annual map -------------------------------------------------------------------
for(year_i in 2012:2021){

  r <- raster(file.path(data_dir, 
            "NTL BlackMarble",
            "FinalData",
            "VNP46A4_rasters",
            paste0("bm_VNP46A4_",year_i,".tif")))
  
  #### Prep data
  r <- r %>% crop(adm2_sf) %>% mask(adm2_sf) 
  
  r_df <- rasterToPoints(r, spatial = TRUE) %>% as.data.frame()
  names(r_df) <- c("value", "x", "y")
  
  ## Remove very low values of NTL; can be considered noise 
  r_df$value[r_df$value <= 2] <- 0
  
  ## Distribution is skewed, so log
  r_df$value_adj <- log(r_df$value+1)
  
  ##### Map 
  p <- ggplot() +
    geom_raster(data = r_df, 
                aes(x = x, y = y, 
                    fill = value_adj)) +
    scale_fill_gradient2(low = "black",
                         mid = "yellow",
                         high = "red",
                         midpoint = 5.5) +
    labs(title = paste0("Nighttime Lights ", year_i)) +
    coord_quickmap() + 
    theme_void() +
    theme(plot.title = element_text(face = "bold", hjust = 0.5),
          legend.position = "none")
  
  ggsave(p, filename = file.path(figures_dir, paste0("syr_ntl_bm_",year_i,".png")),
         height = 3, width = 5)
}