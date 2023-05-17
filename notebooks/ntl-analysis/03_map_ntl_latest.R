# Nighttime Lights Map: Latest Month

# Load data --------------------------------------------------------------------
r_mean  <- raster(file.path(data_dir, "bm_vnp46A3_2022_08.tif"))
gadm_sp <- getData('GADM', country='SYR', level=0) 

# Prep data --------------------------------------------------------------------
r_mean <- r_mean %>% crop(gadm_sp) %>% mask(gadm_sp) 

r_mean_df <- rasterToPoints(r_mean, spatial = TRUE) %>% as.data.frame()
names(r_mean_df) <- c("value", "x", "y")

## Transform NTL
r_mean_df$value_adj <- log(r_mean_df$value+1)

r_mean_df$value_adj[r_mean_df$value_adj <= 0.5] <- 0

# Map --------------------------------------------------------------------------
p <- ggplot() +
  geom_raster(data = r_mean_df, 
              aes(x = x, y = y, 
                  fill = value_adj)) +
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
       filename = file.path(figures_dir, "ntl_syria_2022.png"),
       height = 5, width = 6,
       dpi = 1000)

