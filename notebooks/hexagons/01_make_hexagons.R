# Extract Nighttime Lights to Different Sources

# Load data --------------------------------------------------------------------
adm_sp <- readRDS(file.path(gadm_dir, "RawData", "gadm36_SYR_2_sp.rds"))

for(res_i in 4:6){
  hex_sp <- spsample(adm_sp, 500000, type = "regular") %>%
    as.data.frame() %>%
    dplyr::rename(latitude = x1,
                  longitude = x2) %>%
    point_to_h3(res = res_i) %>%
    unique() %>%
    h3_to_polygon(simple=F) %>%
    mutate(uid = 1:n()) %>%
    dplyr::select(uid)
  
  saveRDS(hex_sp, file.path(hex_dir, "RawData", paste0("hex_", res_i, ".Rds")))
}


