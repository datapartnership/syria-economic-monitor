# Clean SpaceKnow Data

# Load data --------------------------------------------------------------------
aoi1_df <- read_xlsx(file.path(spaceknow_dir, "RawData", "AOI1_Al-Dabbouseh_data.xlsx"))
aoi2_df <- read_xlsx(file.path(spaceknow_dir, "RawData", "AOI2_Tartous_data.xlsx"))
aoi3_df <- read_xlsx(file.path(spaceknow_dir, "RawData", "AOI3_Matraba_data.xlsx"))

# Clean data -------------------------------------------------------------------
aoi1_df <- aoi1_df %>%
  janitor::clean_names() %>%
  dplyr::rename(border_point = aoi1_1_border_point) %>%
  dplyr::select(datetime, date, border_point, orbit) %>%
  mutate(name = "Al-Dabbouseh") 

aoi2_df <- aoi2_df %>%
  janitor::clean_names() %>%
  dplyr::rename(border_point = aoi2_1_border_point,
                datetime = date_1,
                date = date_2) %>%
  dplyr::select(datetime, date, border_point, orbit) %>%
  mutate(name = "Tartous") 

aoi3_df <- aoi3_df %>%
  janitor::clean_names() %>%
  dplyr::rename(border_point = aoi3_1_border_point) %>%
  mutate(orbit = "orbit1") %>%
  dplyr::select(datetime, date, border_point, orbit) %>%
  mutate(name = "Matraba") 

aoi_df <- bind_rows(aoi1_df,
                    aoi2_df,
                    aoi3_df)

saveRDS(aoi_df, file.path(spaceknow_dir, "FinalData", "spaceknow.Rds"))

# 
# 
# aoi_df %>%
#   ggplot(aes(x = datetime,
#              y = border_point)) +
#   geom_col() +
#   facet_wrap(border_point~orbit)
# 
# 
