# Create Dataset for GEE

# Load data --------------------------------------------------------------------
bc_df <- read_csv(file.path(bc_all_dir, "RawData", "syria_border_crossings.csv"))

bc_df <- bc_df %>%
  mutate(crossing_name_1 = crossing_name_1 %>% 
           tolower() %>%
           str_replace_all("[:punct:]", "") %>%
           str_replace_all(" ", "_")) %>%
  dplyr::select(uid, crossing_name_1, latitude, longitude) %>%
  dplyr::rename(name = crossing_name_1)

coordinates(bc_df) <- ~longitude+latitude
crs(bc_df) <- CRS("+init=epsg:4326")

bc_sf <- bc_df %>% st_as_sf() %>% st_buffer(dist = 1500)

write_sf(bc_sf, 
         file.path(bc_all_dir, "FinalData", "border_crossings_1500m.shp"),
         delete_dsn = T)



