# Append NTL Data at Border Crossings

# Load data --------------------------------------------------------------------
daily_df <- file.path(ntl_bm_dir, "FinalData", "aggregated", "border_xing_temp", "daily_files") %>%
  list.files(pattern = "*.Rds",
             full.names = T) %>%
  map_df(readRDS)

monthly_df <- file.path(ntl_bm_dir, "FinalData", "aggregated", "border_xing_temp", "monthly_files") %>%
  list.files(pattern = "*.Rds",
             full.names = T) %>%
  map_df(readRDS)

# Export -----------------------------------------------------------------------
write_csv(daily_df, file.path(ntl_bm_dir, "FinalData", "aggregated", "border_xing_daily.csv"))
write_csv(monthly_df, file.path(ntl_bm_dir, "FinalData", "aggregated", "border_xing_monthly.csv"))

saveRDS(daily_df, file.path(ntl_bm_dir, "FinalData", "aggregated", "border_xing_daily.Rds"))
saveRDS(monthly_df, file.path(ntl_bm_dir, "FinalData", "aggregated", "border_xing_monthly.Rds"))
