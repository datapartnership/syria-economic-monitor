# Clean Gas Flaring Data

# Create dataset of gas flaring locations in Syria
# Raw data from: https://datacatalog.worldbank.org/search/dataset/0037743

# Load data --------------------------------------------------------------------
clean_data <- function(x) x %>% clean_names() %>% dplyr::filter(iso_code %in% c("SYR", "TUR"))

df_2021 <- read_xlsx(file.path(gas_flare_dir, "RawData", "2021 Global Gas Flaring Volumes.xlsx"), 2) %>% clean_data()

df_2020_1 <- read_xlsx(file.path(gas_flare_dir, "RawData",  "2020 Global Gas Flaring Volumes.xlsx"), 1) %>% clean_data()
df_2020_2 <- read_xlsx(file.path(gas_flare_dir, "RawData",  "2020 Global Gas Flaring Volumes.xlsx"), 2) %>% clean_data()
df_2020_3 <- read_xlsx(file.path(gas_flare_dir, "RawData",  "2020 Global Gas Flaring Volumes.xlsx"), 3) %>% clean_data()

df_2019 <- read_xlsx(file.path(gas_flare_dir, "RawData",  "viirs_global_flaring_d.7_slope_0.029353_2019_web_v20201114-3.xlsx"), 1) %>% clean_data()

df_2018_4 <- read_xlsx(file.path(gas_flare_dir, "RawData",  "viirs_global_flaring_d.7_slope_0.029353_2018_web.xlsx"), 4) %>% clean_data()
df_2018_5 <- read_xlsx(file.path(gas_flare_dir, "RawData",  "viirs_global_flaring_d.7_slope_0.029353_2018_web.xlsx"), 5) %>% clean_data()
df_2018_6 <- read_xlsx(file.path(gas_flare_dir, "RawData",  "viirs_global_flaring_d.7_slope_0.029353_2018_web.xlsx"), 6) %>% clean_data()

df_2017_1 <- read_xlsx(file.path(gas_flare_dir, "RawData",  "viirs_global_flaring_d.7_slope_0.029353_2017_web_v1.xlsx"), 1) %>% clean_data()
df_2017_2 <- read_xlsx(file.path(gas_flare_dir, "RawData",  "viirs_global_flaring_d.7_slope_0.029353_2017_web_v1.xlsx"), 2) %>% clean_data()
df_2017_3 <- read_xlsx(file.path(gas_flare_dir, "RawData",  "viirs_global_flaring_d.7_slope_0.029353_2017_web_v1.xlsx"), 3) %>% clean_data()

gs_df <- bind_rows(
  df_2021,
  df_2020_1,
  df_2020_2,
  df_2020_3,
  df_2019,
  df_2018_4,
  df_2018_5,
  df_2018_6,
  df_2017_1,
  df_2017_2,
  df_2017_3
)

gs_df <- gs_df %>%
  dplyr::select(latitude, longitude) %>%
  distinct() %>%
  dplyr::mutate(uid = 1:n())

saveRDS(gs_df, file.path(gas_flare_dir, "FinalData", "gas_flare_locations.Rds"))
write_csv(gs_df, file.path(gas_flare_dir, "FinalData", "gas_flare_locations.csv"))


