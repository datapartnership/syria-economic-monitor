# NTL Change

# Load data --------------------------------------------------------------------
gadm_sp <- readRDS(file.path(gadm_dir, "RawData", "gadm36_SYR_1_sp.rds"))

r_2013 <- file.path(ntl_bm_dir, "FinalData", "monthly_rasters") %>%
  list.files(pattern = paste0("bm_vnp46A3_", 2013),
             full.names = T) %>%
  str_subset(paste0("0", 1:8, ".tif")) %>%
  stack() %>% 
  calc(fun = mean) %>%
  crop(gadm_sp) %>% 
  mask(gadm_sp)

r_2015 <- file.path(ntl_bm_dir, "FinalData", "monthly_rasters") %>%
  list.files(pattern = paste0("bm_vnp46A3_", 2015),
             full.names = T) %>%
  str_subset(paste0("0", 1:8, ".tif")) %>%
  stack() %>% 
  calc(fun = mean) %>%
  crop(gadm_sp) %>% 
  mask(gadm_sp)

r_2017 <- file.path(ntl_bm_dir, "FinalData", "monthly_rasters") %>%
  list.files(pattern = paste0("bm_vnp46A3_", 2017),
             full.names = T) %>%
  str_subset(paste0("0", 1:8, ".tif")) %>%
  stack() %>% 
  calc(fun = mean) %>%
  crop(gadm_sp) %>% 
  mask(gadm_sp)

r_2019 <- file.path(ntl_bm_dir, "FinalData", "monthly_rasters") %>%
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

r_2021 <- file.path(ntl_bm_dir, "FinalData", "monthly_rasters") %>%
  list.files(pattern = paste0("bm_vnp46A3_", 2021),
             full.names = T) %>%
  stack() %>% 
  calc(fun = mean) %>%
  crop(gadm_sp) %>% 
  mask(gadm_sp)

r_2022 <- file.path(ntl_bm_dir, "FinalData", "monthly_rasters") %>%
  list.files(pattern = paste0("bm_vnp46A3_", 2022),
             full.names = T) %>%
  str_subset(paste0("0", 1:8, ".tif")) %>%
  stack() %>% 
  calc(fun = mean) %>%
  crop(gadm_sp) %>% 
  mask(gadm_sp)

## GF
gf_df <- readRDS(file.path(gas_flare_dir, "FinalData", "gas_flare_locations.Rds"))

coordinates(gf_df) <- ~longitude+latitude
crs(gf_df) <- CRS("+init=epsg:4326")

gf_sf <- gf_df %>% st_as_sf() %>% st_buffer(dist = 5000)
gf_sp <- gf_sf %>% as("Spatial")

## Names
gadm1_sp <- readRDS(file.path(gadm_dir, "RawData", "gadm36_SYR_1_sp.rds"))

gadm1_sp_c <- gadm1_sp %>% gCentroid(byid = T)
gadm1_sp_df <- gadm1_sp_c %>% as.data.frame()
gadm1_sp_df$NAME_1 <- gadm1_sp$NAME_1

# Log Diff ---------------------------------------------------------------------
# r_start <- r_2019
# r_end   <- r_2022
# 
# r_diff <- r_end - r_start
# 
# r_diff_df <- rasterToPoints(r_diff, spatial = TRUE) %>% as.data.frame()
# names(r_diff_df) <- c("value", "x", "y")
# 
# r_diff_df <- r_diff_df %>%
#   mutate(value_clean = case_when(
#     value < 1 & value > -1 ~ NA_real_,
#     TRUE ~ value
#   ))
# 
# r_diff_df$value_clean[which(r_diff_df$value_clean >= 1)]  <- log(r_diff_df$value_clean[which(r_diff_df$value_clean >= 1)])
# r_diff_df$value_clean[which(r_diff_df$value_clean <= -1)] <- -log(abs(r_diff_df$value_clean[which(r_diff_df$value_clean <= -1)]))
# 
# ## Plot
# 
# 
# p <- ggplot() +
#   # geom_raster(data = r_mean_df[r_mean_df$value > 1,], 
#   #             aes(x = x, y = y, 
#   #                 fill = value)) +
#   # geom_raster(data = r_mean_df[r_mean_df$value < -1,], 
#   #             aes(x = x, y = y, 
#   #                 fill = value)) +
#   geom_raster(data = r_diff_df, 
#               aes(x = x, y = y, 
#                   fill = value_clean)) +
#   geom_polygon(data = gadm_sp,
#                aes(x = long, y = lat, group = group),
#                color = "black",
#                fill = NA,
#                size = 0.1) +
#   scale_fill_gradient2(low = "firebrick4",
#                        mid = "white",
#                        high = "forestgreen",
#                        midpoint = 0) +
#   labs(title = "NTL Change: 2019 to 2021",
#        fill = "Growth\nRate") +
#   coord_quickmap() + 
#   theme_void() +
#   theme(plot.title = element_text(face = "bold", hjust = 0.5),
#         legend.position = "right")
# 
# p
# 
# ggsave(p,
#        filename = file.path(out_ntl_dir, "figures", "ntl_change_logdiff.png"),
#        height = 5, width = 6)

# Difference Category ----------------------------------------------------------
mk_r_diff_cat <- function(r_start, r_end){
  
  r_diff <- r_end - r_start
  
  r_out <- r_diff
  r_out[] <- NA
  
  r_out[r_start > 1] <- 0
  r_out[r_diff > 1]  <- 1
  r_out[r_diff < -1] <- -1
  
  #r_out[r_start <= 3] <- NA
  #r_out[r_end <= 3] <- NA
  
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
    geom_text(data = gadm1_sp_df,
              aes(x = x, y = y, label = NAME_1),
              size = 2,
              fontface = "bold") +
    geom_polygon(data = gf_sp,
                 aes(x = long, y = lat, group = group),
                 color = NA,
                 fill = "white") +
    geom_polygon(data = gadm_sp,
                 aes(x = long, y = lat, group = group),
                 color = "black",
                 fill = NA,
                 size = 0.1) +
    labs(fill = NULL,
         title = paste0(base_year," to 2022")) +
    theme_void() +
    theme(strip.text = element_text(face = "bold", hjust = 0.5),
          plot.title = element_text(face = "bold", hjust = 0.5),
          legend.position = c(0.8, 0.2)) +
    scale_fill_manual(values = c("firebrick3", "green3", "dodgerblue")) +
    coord_quickmap() 
  
  ggsave(p,
         filename = file.path(out_ntl_dir, "figures", paste0("ntl_change_cat_",base_year,".png")),
         height = 4, width = 4)
  
}

# Difference Category ----------------------------------------------------------
# mk_r_diff_cat <- function(r_start, r_end){
#   
#   r_diff <- r_end - r_start
#   
#   r_out <- r_diff
#   r_out[] <- NA
#   
#   r_out[r_start > 1] <- 0
#   r_out[r_diff > 1]  <- 1
#   r_out[r_diff < -1] <- -1
#   
#   #r_out[r_start <= 3] <- NA
#   #r_out[r_end <= 3] <- NA
#   
#   r_out_df <- rasterToPoints(r_out, spatial = TRUE) %>% as.data.frame()
#   names(r_out_df) <- c("value", "x", "y")
#   
#   return(r_out_df)  
# }
# 
# r_df <- bind_rows(mk_r_diff_cat(r_2013, r_2022) %>% mutate(title = "2013 to 2021"),
#                   mk_r_diff_cat(r_2015, r_2022) %>% mutate(title = "2015 to 2022"),
#                   mk_r_diff_cat(r_2017, r_2022) %>% mutate(title = "2017 to 2022"))
# 
# ## Plot
# p <- ggplot() +
#   geom_raster(data = r_df[r_df$value == 0,], 
#               aes(x = x, y = y,
#                   fill = "No Change")) +
#   geom_raster(data = r_df[r_df$value == 1,], 
#               aes(x = x, y = y,
#                   fill = "New Lights")) +
#   geom_raster(data = r_df[r_df$value == -1,], 
#               aes(x = x, y = y,
#                   fill = "Lights Lost")) +
#   geom_polygon(data = gf_sp,
#                aes(x = long, y = lat, group = group),
#                color = NA,
#                fill = "white") +
#   geom_polygon(data = gadm_sp,
#                aes(x = long, y = lat, group = group),
#                color = "black",
#                fill = NA,
#                size = 0.1) +
#   labs(fill = NULL,
#        title = NULL) +
#   theme_void() +
#   theme(strip.text = element_text(face = "bold", hjust = 0.5),
#         legend.position = "bottom") +
#   scale_fill_manual(values = c("firebrick3", "green3", "dodgerblue")) +
#   coord_quickmap() +
#   facet_wrap(~title)
# 
# ggsave(p,
#        filename = file.path(out_ntl_dir, "figures", "ntl_change_cat_older_noflare.png"),
#        height = 4, width = 9)
# 
