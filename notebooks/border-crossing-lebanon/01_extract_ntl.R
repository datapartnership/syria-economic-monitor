# Extract NTL to Border Crossing Locations

# Load data --------------------------------------------------------------------
df <- read_csv(file.path(data_dir, "Border Crossing Locations - Lebanon", "border_crossings_lebanon.csv"))

coordinates(df) <- ~longitude+latitude
crs(df) <- CRS("+init=epsg:4326")
df <- df %>% st_as_sf() %>% st_buffer(dist = 2000)

# Extract NTL ------------------------------------------------------------------
ym_df <- cross_df(list(year = 2012:2022,
                       month = 1:12))

ym_df <- ym_df[!((ym_df$year %in% 2022) & (ym_df$month %in% 9:12)),]

viirs_bm_df <- map_df(1:nrow(ym_df), function(i){ # 
  print(i)
  
  ym_i_df <- ym_df[i,]
  
  ym_i_df$year
  
  r <- raster(file.path(ntl_bm_dir, "FinalData", "monthly_rasters",
                        paste0("bm_vnp46A3_",ym_i_df$year,"_",ym_i_df$month %>% pad2(),
                               ".tif")))
  
  df$viirs_bm_mean <- exact_extract(r, df, 'mean')
  df$viirs_bm_sum <- exact_extract(r, df, 'sum')
  
  df$year <- ym_i_df$year
  df$month <- ym_i_df$month
  
  df$date <- paste0(ym_i_df$year, "-", ym_i_df$month, "-01") %>% ymd()
  
  df$geometry <- NULL
  return(df)
})

# Figures - All Locations ------------------------------------------------------
viirs_bm_df %>%
  dplyr::filter(year %in% 2019:2022) %>%
  ggplot() +
  geom_line(aes(x = date, y = viirs_bm_mean),
            size = 1) +
  facet_wrap(~name) +
  theme_classic2() +
  theme(strip.background = element_blank(),
        plot.title = element_text(face = "bold"),
        strip.text = element_text(face = "bold")) +
  labs(x = NULL,
       y = "Luminosity",
       title = "Trends in Nighttime Lights Near Syria-Lebanon Border Crossings")

ggsave(filename = file.path(figures_dir, "syria_leb_bc_ntl.png"),
       height = 4, width = 8)

write.csv(viirs_bm_df, file.path(figures_dir, "syria_leb_bc_ntl_data.csv"), row.names = F)

