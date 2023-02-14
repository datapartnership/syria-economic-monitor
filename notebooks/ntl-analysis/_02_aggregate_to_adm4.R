# Trends in Governorate NTL

# Load/prep gas flaring data ---------------------------------------------------
#### Gas Flaring
gf_df <- readRDS(file.path(gas_flare_dir, "FinalData", "gas_flare_locations.Rds"))

coordinates(gf_df) <- ~longitude+latitude
crs(gf_df) <- CRS("+init=epsg:4326")

gf_sf <- gf_df %>% st_as_sf() %>% st_buffer(dist = 5000)
gf_sp <- gf_sf %>% as("Spatial")

## Non GS Locations
gadm_0_sp <- read_sf(file.path(unocha_dir, "RawData", "syr_admbnda_adm0_uncs_unocha_20201217.json")) %>%
  as("Spatial")

gadm_no_gf_sp <- gDifference(gadm_0_sp, gf_sp, byid=F)
gadm_no_gf_sp$id <- 1

# Load data --------------------------------------------------------------------
adm_i <- 4

## GADM
if(adm_i == 3){
  gadm_sp <- read_sf(file.path(unocha_dir, "RawData", "syr_admbnda_adm3_uncs_unocha_20201217.json")) %>%
    as("Spatial")
}

if(adm_i == 4){
  gadm_sp <- read_sf(file.path(unocha_dir, "RawData", "syr_pplp_adm4_unocha_20210113.json")) %>%
    as("Spatial")
  
  gadm_sp <- geo.buffer(gadm_sp, r = 0.5*1000)
  
  gadm_sp <- raster::aggregate(gadm_sp, by = "ADM4_PCODE")
}

gadm_df <- gadm_sp@data %>%
  dplyr::mutate(uid = 1:n())

gadm_id_df <- gadm_df %>%
  dplyr::select(uid)

# Extract VIIRS - Black Marble -------------------------------------------------
ym_df <- cross_df(list(year = 2012:2023,
                       month = 1:12))

ym_df <- ym_df[!((ym_df$year %in% 2023) & (ym_df$month %in% 2:12)),]

viirs_bm_df <- map_df(1:nrow(ym_df), function(i){ # nrow(ym_df)
  print(i)
  
  ym_i_df <- ym_df[i,]
  
  r <- raster(file.path(ntl_bm_dir, "FinalData", "monthly_rasters",
                        paste0("bm_vnp46A3_",ym_i_df$year,"_",ym_i_df$month %>% pad2(),
                               ".tif")))
  
  r_gf   <- r %>% crop(gf_sp) %>% mask(gf_sp)
  r_nogf <- r %>% crop(gadm_no_gf_sp) %>% mask(gadm_no_gf_sp)
  
  gadm_sf <- gadm_sp %>% st_as_sf()
  
  gadm_id_df$viirs_bm_mean <- exact_extract(r, gadm_sf, 'mean')
  gadm_id_df$viirs_bm_sum <- exact_extract(r, gadm_sf, 'sum')
  
  gadm_id_df$viirs_bm_gf_mean <- exact_extract(r_gf, gadm_sf, 'mean')
  gadm_id_df$viirs_bm_gf_sum  <- exact_extract(r_gf, gadm_sf, 'sum')
  
  gadm_id_df$viirs_bm_nogf_mean <- exact_extract(r_nogf, gadm_sf, 'mean')
  gadm_id_df$viirs_bm_nogf_sum  <- exact_extract(r_nogf, gadm_sf, 'sum')
  
  gadm_id_df$year <- ym_i_df$year
  gadm_id_df$month <- ym_i_df$month
  
  return(gadm_id_df)
})

# Merge NTL with GADM data -----------------------------------------------------
data_df <- viirs_bm_df %>%
  left_join(gadm_df, by = c("uid")) %>%
  dplyr::mutate(year_month = paste(year, "-", month, "-01") %>% ymd())

data_df$viirs_bm_mean[data_df$viirs_bm_sum == 0] <- 0
data_df$viirs_bm_gf_mean[data_df$viirs_bm_gf_sum == 0] <- 0
data_df$viirs_bm_nogf_mean[data_df$viirs_bm_nogf_sum == 0] <- 0

# Export -----------------------------------------------------------------------
write_csv(data_df, file.path(ntl_bm_dir, "FinalData", "aggregated", paste0("syr_admin",
                                                                           adm_i, ".csv")))


