# Append Syria NTL Aggregations into One Dataset

#### Prep earthquake data
eq_int_to_str <- function(df){
  
  df %>%
    mutate(eq_intensity_str = case_when(
      eq_intensity >= 7 ~ "Very Strong",
      eq_intensity >= 6 & eq_intensity < 7 ~ "Strong",
      eq_intensity >= 5 & eq_intensity < 6 ~ "Moderate",
      eq_intensity >= 4 & eq_intensity < 5 ~ "Light",
      eq_intensity < 4 ~ "Weak"
    ) %>%
      factor(levels = c("Very Strong",
                        "Strong",
                        "Moderate",
                        "Light",
                        "Weak")))
  
}

syr_adm3_eq <- read_csv(file.path(data_dir, "Earthquake Intensity by admin regions", "syria_adm3_earthquake_intensity.csv"))
syr_adm4_eq <- read_csv(file.path(data_dir, "Earthquake Intensity by admin regions", "syria_adm4_earthquake_intensity.csv"))
tur_adm2_eq <- read_csv(file.path(data_dir, "Earthquake Intensity by admin regions", "turkiye_admin2_earthquake_intensity_max.csv"))

syr_adm3_eq <- syr_adm3_eq %>%
  dplyr::rename(eq_intensity = max_intensity_feb6) %>%
  dplyr::select(ADM1_EN, ADM2_EN, ADM3_EN, eq_intensity) %>%
  eq_int_to_str()

syr_adm4_eq <- syr_adm4_eq %>%
  dplyr::rename(eq_intensity = max_intensity_feb06) %>%
  dplyr::select(ADM1_EN, ADM2_EN, ADM3_EN, ADM4_EN, eq_intensity) %>%
  eq_int_to_str()

tur_adm2_eq <- tur_adm2_eq %>%
  dplyr::rename(eq_intensity = mmi_feb06_7p8) %>%
  dplyr::select(pcode, eq_intensity) %>%
  eq_int_to_str()




adm_i <- 2
time_name <- "daily"
country_code <- "tur"
for(adm_i in c(2,3,4)){
  for(time_name in c("monthly", "daily")){
    for(country_code in c("tur", "syr")){
      
      print(paste(adm_i, time_name, country_code))
      
      df <- list.files(file.path(ntl_bm_dir, "FinalData", "aggregated", paste0(country_code, "_temp"), 
                                 time_name),
                       full.names = T,
                       pattern = "*.Rds") %>%
        str_subset(paste0("admin", adm_i, "_")) %>%
        map_df(readRDS) 
      
      if(country_code %in% "tur"){
        if(adm_i %in% 2){
          df <- df %>%
            left_join(tur_adm2_eq, by = "pcode")
        }
      }
      
      if(country_code %in% "syr"){
        if(adm_i %in% 3){
          df <- df %>%
            left_join(syr_adm3_eq, by = c("ADM1_EN", "ADM2_EN", "ADM3_EN"))
        }
      }
      
      if(country_code %in% "syr"){
        if(adm_i %in% 4){
          df <- df %>%
            left_join(syr_adm4_eq, by = c("ADM1_EN", "ADM2_EN", "ADM3_EN", "ADM4_EN"))
        }
      }
      
      df$country_code <- country_code
      
      write_csv(df, file.path(ntl_bm_dir, "FinalData", "aggregated",
                              paste0(country_code, "_admin_adm",
                                     adm_i, "_", time_name, ".csv")))
      
      saveRDS(df, file.path(ntl_bm_dir, "FinalData", "aggregated",
                            paste0(country_code, "_admin_adm",
                                   adm_i, "_", time_name, ".Rds")))
    }
  }
}



