# Extract Trends in NTL

pad2 <- function(x){
  if(nchar(x) == 1) x <- paste0("0", x)
  return(x)
}

# Load data --------------------------------------------------------------------
#### AOI
aoi <- st_read(file.path(oi_dir, "RawData", "WorldBank_Master.geojson"))

aoi <- aoi %>%
  dplyr::mutate(uid = case_when(
    name == "Area 9 Small" ~ 10,
    name == "Area 13 Small" ~ 14,
    name == "Area 14 Small" ~ 15
  )) %>%
  dplyr::select(uid)

# Extract VIIRS - Black Marble -------------------------------------------------
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
  
  aoi$viirs_bm_mean <- exact_extract(r, aoi, 'mean')
  aoi$viirs_bm_sum <- exact_extract(r, aoi, 'sum')
  
  aoi$year <- ym_i_df$year
  aoi$month <- ym_i_df$month
  
  aoi$date <- paste0(ym_i_df$year, "-", ym_i_df$month, "-01") %>% ymd()
  
  aoi$geometry <- NULL
  return(aoi)
})

saveRDS(viirs_bm_df, file.path(s1_sar_dir, "FinalData", "ntl.Rds"))


# viirs_bm_df %>%
#   ggplot(aes(x = date, y = viirs_bm_sum)) +
#   geom_line() +
#   facet_wrap(~uid)



