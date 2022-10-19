# Oil Data to RDS

oil_sf <- read_sf(file.path(oil_fields_dir, "RawData", "harvard-glb-oilgas-geojson.json"))
syr_sf <- readRDS(file.path(gadm_dir, "RawData", "gadm36_SYR_0_sp.rds")) %>% st_as_sf()

oil_sf$dist_syr <- st_distance(oil_sf, syr_sf) %>% as.vector()
