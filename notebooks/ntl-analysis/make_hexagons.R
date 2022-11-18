# Extract Nighttime Lights to Different Sources

# Load data --------------------------------------------------------------------
adm_sp <- readRDS(file.path(gadm_dir, "RawData", "gadm36_SYR_2_sp.rds"))

hex_sp <- spsample(adm_sp, 1000, type = "regular") %>%
  as.data.frame() %>%
  dplyr::rename(latitude = x1,
                longitude = x2) %>%
  point_to_h3(res = 5) %>%
  unique() %>%
  h3_to_polygon()

# Extract nighttime lights -----------------------------------------------------

plot(hex_sp)

hex_dir


a
geo_to_h3(4)

