# Make Base Data

# Load data --------------------------------------------------------------------
adm_sp <- readRDS(file.path(gadm_dir, "RawData", "gadm36_SYR_2_sp.rds"))

adm_sp$uid <- 1:nrow(adm_sp)

adm_uid_sp <- adm_sp
adm_uid_sp@data <- adm_uid_sp@data %>%
  dplyr::select(uid)

saveRDS(adm_uid_sp, file.path(gov_stats_dir, "FinalData", "individual_files", "adm_blank.Rds"))
saveRDS(adm_sp@data, file.path(gov_stats_dir, "FinalData", "individual_files", "adm_info.Rds"))