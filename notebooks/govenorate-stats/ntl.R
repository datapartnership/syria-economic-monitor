# Govenorate NTL Stats

add_pcode <- function(df){
  
  data_df <- data_df %>%
    mutate(pcode = case_when(
      NAME_1 == "Al Ḥasakah" ~ "SY08",
      NAME_1 == "Aleppo" ~ "SY02",
      NAME_1 == "Ar Raqqah" ~ "SY11",
      NAME_1 == "As Suwayda'" ~ "SY13",
      NAME_1 == "Damascus" ~ "SY01",
      NAME_1 == "Dar`a" ~ "SY12",
      NAME_1 == "Dayr Az Zawr" ~ "SY09",
      NAME_1 == "Hamah" ~ "SY05",
      NAME_1 == "Hims" ~ "SY04",
      NAME_1 == "Idlib" ~ "SY07",
      NAME_1 == "Lattakia" ~ "SY06",
      NAME_1 == "Quneitra" ~ "SY14",
      NAME_1 == "Rif Dimashq" ~ "SY03",
      NAME_1 == "Tartus" ~ "SY10"
    ))
  
  return(data_df)
  
}

# NTL --------------------------------------------------------------------------
data_df <- readRDS(file.path(gadm_dir, "FinalData", paste0("gadm_", 1, "_ntl.Rds")))

data_df <- add_pcode(data_df)

data_sum_df <- data_df %>%
  dplyr::filter(year %in% c(2020, 2021, 2022)) %>%
  group_by(pcode, year) %>%
  dplyr::summarise(viirs_bm_sum      = mean(viirs_bm_sum),
                   viirs_bm_gf_sum   = mean(viirs_bm_gf_sum),
                   viirs_bm_nogf_sum = mean(viirs_bm_nogf_sum)) %>%
  ungroup()

data_sum_df %>%
  arrange(pcode) %>%
  pivot_wider(id_cols = pcode,
              names_from = year,
              values_from = c(viirs_bm_sum)) %>%
  write_csv(file.path(out_dir, "gov_data", "viirs_bm_sum.csv"))

data_sum_df %>%
  arrange(pcode) %>%
  pivot_wider(id_cols = pcode,
              names_from = year,
              values_from = c(viirs_bm_gf_sum)) %>%
  write_csv(file.path(out_dir, "gov_data", "viirs_bm_gf_sum.csv"))

data_sum_df %>%
  arrange(pcode) %>%
  pivot_wider(id_cols = pcode,
              names_from = year,
              values_from = c(viirs_bm_nogf_sum)) %>%
  write_csv(file.path(out_dir, "gov_data", "viirs_bm_nogf_sum.csv"))


