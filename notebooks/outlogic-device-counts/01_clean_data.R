# Clean Outlogic Device Count Data

# Load/clean data --------------------------------------------------------------
ol_df <- read_xlsx(file.path(outlogic_dir, "RawData", "count_devices_at_aoi.xlsx"))

ol_df <- ol_df %>%
  mutate(aoi = case_when(
    aoi %in% "id=2&name=Tartous (Al-Arida)" ~ "Al-Arida",
    aoi %in% "id=3&name=Al-Dabbousieh (Al- Abboudiyeh)" ~ "Al-Abboudiyeh",
    aoi %in% "id=4&name=Tel Kalakh (Al-Buqayaa)" ~ "Al-Buqayaa",
    aoi %in% "id=6&name=Matraba" ~ "Matraba",
    aoi %in% "id=1&name=Jdeidet Yabbous (Al- Masnaa)" ~ "Al-Masnaa",
    aoi %in% "id=5&name=Joussieh (Al-Qaa)" ~ "Al-Qaa",
    TRUE ~ aoi
  ),
  date = date %>% as.Date()) %>%
  dplyr::rename(device_count = count)

saveRDS(ol_df, file.path(outlogic_dir, "FinalData", "outlogic_bc_counts.Rds"))
