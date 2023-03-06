library(rgdal)
library(raster)
library(sf)
library(ggnewscale)
library(spatialEco)
library(ggrepel)

ALPHA = 0.5

# https://earthquake.usgs.gov/earthquakes/eventpage/us6000jllz/shakemap/intensity?source=us&code=us6000jllz

gadm_sp <- readRDS(file.path(gadm_dir, "RawData", "gadm36_SYR_0_sp.rds"))
gadm_1_sp <- readRDS(file.path(gadm_dir, "RawData", "gadm36_SYR_1_sp.rds"))

gadm1_c <- gCentroid(gadm_1_sp, 
          byid=T) %>%
  coordinates() %>%
  as.data.frame()
gadm1_c$name <- gadm_1_sp$NAME_1

gf_sp <- readRDS(file.path(gas_flare_dir, "FinalData", "gas_flare_locations.Rds"))

coordinates(gf_sp) <- ~longitude+latitude
crs(gf_sp) <- CRS("+init=epsg:4326")
gf_sp <- geo.buffer(gf_sp, r = 10*1000)

#gadm_no_gf_sp <- gDifference(gadm_sp, gf_sp, byid=F)

eq <- readOGR(dsn = file.path(data_dir, "USGS Earthquake Location", "RawData", "mi.shp"))
eq$PGAPOL_ <- as.numeric(eq$PARAMVALUE)

r_2022 <- file.path(ntl_bm_dir, "FinalData", "monthly_rasters") %>%
  list.files(pattern = paste0("bm_vnp46A3_", 2022),
             full.names = T) %>%
  str_subset(paste0("0", 1:12, ".tif")) %>%
  stack() %>% 
  calc(fun = mean) %>%
  crop(gadm_sp) %>% 
  mask(gadm_sp)

r_2022[][r_2022[] < 2] <- NA
r_2022[] <- log(r_2022[]+1)

r_mean_df <- rasterToPoints(r_2022, spatial = TRUE) %>% as.data.frame()
names(r_mean_df) <- c("Log NTL", "x", "y")

eq_sf <- eq %>% st_as_sf()

eq_sf$Intensity = eq_sf$PGAPOL_

R_MIN <- min(r_2022[], na.rm = T)
R_MAX <- max(r_2022[], na.rm = T)

p <- ggplot() +
  geom_sf(data = eq_sf,
          aes(fill = Intensity),
          color = NA) +
  scale_fill_distiller(palette = "Spectral") +
  new_scale_fill() +
  geom_raster(data = r_mean_df, 
              aes(x = x, y = y, 
                  fill = `Log NTL`)) +
  scale_fill_gradient2(low = "white",
                       mid = "firebrick3",
                       high = "firebrick4",
                       midpoint = 5,
                       limits = c(R_MIN, R_MAX)) +
  geom_polygon(data = gadm_sp,
               aes(x = long, y = lat, group = group),
               fill = NA,
               alpha = ALPHA,
               color = "black") +
  
  geom_polygon(data = gadm_1_sp,
               aes(x = long, y = lat, group = group),
               fill = NA,
               alpha = ALPHA,
               color = "black") +
  
  geom_text_repel(data = gadm1_c,
             aes(x = x, y = y, label = name),
             seed = 4442,
             fontface = "bold") +
  
  labs(title = "Earthquake Intensity and 2022 Nighttime Lights") +
  coord_sf() + 
  theme_void() +
  theme(plot.title = element_text(face = "bold", hjust = 0.5),
        legend.position = "none") +
  scale_x_continuous(limits = c(35, 43), expand = c(0, 0)) +
  scale_y_continuous(limits = c(32, 38.5), expand = c(0, 0)) +
  theme(legend.position = c(0.85,0.3),
        legend.text = element_text(size = 12),
        legend.title = element_text(size = 12),
        legend.margin=margin(c(0.2,0.2,0.2,0.2), unit='cm'),
        legend.box.background = element_rect(fill = "white",
                                             color = "black")) 

ggsave(p, filename = "~/Desktop/ntl_eq.png",
       height = 8, 
       width = 8)

# Gas Flare Only ---------------------------------------------------------------

r_2022 <- mask(r_2022, gf_sp)

r_mean_df <- rasterToPoints(r_2022, spatial = TRUE) %>% as.data.frame()
names(r_mean_df) <- c("Log NTL", "x", "y")

p <- ggplot() +
  geom_sf(data = eq_sf,
          aes(fill = Intensity),
          color = NA) +
  scale_fill_distiller(palette = "Spectral") +
  new_scale_fill() +
  geom_raster(data = r_mean_df, 
              aes(x = x, y = y, 
                  fill = `Log NTL`)) +
  scale_fill_gradient2(low = "white",
                       mid = "firebrick3",
                       high = "firebrick4",
                       midpoint = 5,
                       limits = c(R_MIN, R_MAX)) +
  geom_polygon(data = gadm_sp,
               aes(x = long, y = lat, group = group),
               fill = NA,
               alpha = ALPHA,
               color = "black") +
  
  geom_polygon(data = gadm_1_sp,
               aes(x = long, y = lat, group = group),
               fill = NA,
               alpha = ALPHA,
               color = "black") +
  
  geom_text_repel(data = gadm1_c,
                  aes(x = x, y = y, label = name),
                  seed = 4442,
                  fontface = "bold") +
  
  labs(title = "Earthquake Intensity and 2022 Nighttime Lights in Gas Flaring Locations") +
  coord_sf() + 
  theme_void() +
  theme(plot.title = element_text(face = "bold", hjust = 0.5),
        legend.position = "none") +
  scale_x_continuous(limits = c(35, 43), expand = c(0, 0)) +
  scale_y_continuous(limits = c(32, 38.5), expand = c(0, 0)) +
  theme(legend.position = c(0.85,0.3),
        legend.text = element_text(size = 12),
        legend.title = element_text(size = 12),
        legend.margin=margin(c(0.2,0.2,0.2,0.2), unit='cm'),
        legend.box.background = element_rect(fill = "white",
                                             color = "black")) 

ggsave(p, filename = "~/Desktop/ntl_eq_gasflare.png",
       height = 8, 
       width = 8)




# 
# pal_r <- colorNumeric(c("white", "firebrick4", "orange"), unique(r_2022[]),
#                     na.color = "transparent")
# 
# pal <- colorNumeric(
#   palette = "Blues",
#   domain = as.numeric(eq$PGAPOL_),
#   reverse = T
# )
# 
# 
# 
# leaflet() %>%
#   #addTiles() %>%
#   # addPolygons(data = gadm_sp, 
#   #             color = "white", 
#   #             opacity = 1,
#   #             fillOpacity = 1) %>%
#   addPolygons(data = eq[eq$PGAPOL_ >= 2,],
#               color = ~pal(PGAPOL_),
#               opacity = 0.8,
#               fillOpacity = 0.8,
#               weight = 1) %>%
#   addRasterImage(r_2022, colors = pal_r, opacity = 1) 
#   
#   
