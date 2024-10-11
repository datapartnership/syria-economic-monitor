# Annual NTL Data

bearer <- read_csv("~/Desktop/bearer_bm.csv") %>% pull(token)

# Load data --------------------------------------------------------------------
#### Syria
syr_sf <- gadm(country = "SYR", level=1, path = tempdir()) |> st_as_sf()

#### Gas Flaring
gf_df <- readRDS(file.path(gas_flare_dir, "FinalData", "gas_flare_locations.Rds"))

gf_sf <- st_as_sf(gf_df, coords = c("longitude", "latitude"), crs = 4326)
gf_sf <- gf_sf %>% st_buffer(dist = 5000)
gf_sf <- st_intersection(gf_sf, syr_sf)

# Difference -------------------------------------------------------------------
gf_combine_sf <- gf_sf %>%
  mutate(id = 1) %>%
  group_by(id) %>%
  summarise(geometry = geometry %>%
              st_union() %>%
              st_make_valid())

gf_combine_sf <- gf_combine_sf[2,]

syr_nogf_sf <- st_difference(syr_sf, gf_combine_sf)
syr_gf_sf <- st_intersection(syr_sf, gf_combine_sf)

# Black Marble -----------------------------------------------------------------
bm_raster(roi_sf = syr_sf,
          product_id = "VNP46A4",
          date = 2012:2023,
          bearer = bearer,
          output_location_type = "file",
          file_dir = file.path(data_dir, 
                               "NTL Annual",
                               "blackmarble"))

# Extract ----------------------------------------------------------------------
year_i <- 2014
ntl_source <- "bm"

proc_ntl <- function(year_i, ntl_source){
  
  if(ntl_source == "bm"){
    r <- raster(file.path(data_dir, 
                          "NTL Annual",
                          "blackmarble",
                          paste0("VNP46A4_t",year_i,".tif")))
  } else if(ntl_source == "viirs"){
    r <- raster(file.path(data_dir, 
                          "NTL Annual",
                          "viirs",
                          paste0("SYR_viirs_mean_",year_i,".tif")))
  } else{
    r <- raster(file.path(data_dir, 
                          "NTL Annual",
                          "viirs_corrected",
                          paste0("SYR_viirs_corrected_mean_",year_i,".tif")))
  }
  
  ## BM
  syr_ntl      <- exact_extract(r, syr_sf, c("mean", "sum"))
  gf_ntl       <- exact_extract(r, syr_gf_sf, c("mean", "sum"))
  syr_nogf_ntl <- exact_extract(r, syr_nogf_sf, c("mean", "sum"))
  
  names(syr_ntl)       <- paste0(ntl_source, "_",      names(syr_ntl))
  names(gf_ntl)        <- paste0(ntl_source, "_gf_",   names(gf_ntl))
  names(syr_nogf_ntl)  <- paste0(ntl_source, "_nogf_", names(syr_nogf_ntl))
  
  df_out <- bind_cols(syr_ntl,
                      gf_ntl,
                      syr_nogf_ntl)
  df_out$year <- year_i
  
  df_out$NAME_1 <- syr_sf$NAME_1
  
  return(df_out)
}

bm_df     <- map_df(2012:2023, proc_ntl, "bm")
viirs_df  <- map_df(2012:2023, proc_ntl, "viirs")
viirsc_df <- map_df(2014:2023, proc_ntl, "viirs_corrected")

ntl_df <- bm_df %>%
  left_join(viirs_df, by = "year") %>%
  left_join(viirsc_df, by = "year")

write_dta(ntl_df, "~/Desktop/syria_ntl_adm1.dta")

# ntl_df %>%
#   ggplot() +
#   geom_line(aes(x = year,
#                 y = bm_sum))
# 
# ntl_df %>%
#   ggplot() +
#   geom_line(aes(x = year,
#                 y = bm_nogf_sum))
# 
# ntl_df %>%
#   ggplot() +
#   geom_line(aes(x = year,
#                 y = bm_gf_sum))
# 
# ntl_df %>%
#   ggplot() +
#   geom_line(aes(x = year,
#                 y = viirs_sum))
# 
# ntl_df %>%
#   ggplot() +
#   geom_line(aes(x = year,
#                 y = viirs_corrected_sum))
