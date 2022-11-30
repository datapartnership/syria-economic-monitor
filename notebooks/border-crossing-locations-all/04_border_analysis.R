# Border Analysis

# Load data --------------------------------------------------------------------
sar_df <- readRDS(file.path(s1_sar_dir, "FinalData", "sar.Rds"))
ntl_df <- readRDS(file.path(s1_sar_dir, "FinalData", "ntl.Rds"))

# Clean data -------------------------------------------------------------------
ntl_df <- ntl_df %>%
  group_by(uid) %>%
  mutate(viirs_bm_mean = viirs_bm_mean %>% scale()) %>%
  ungroup()

sar_df <- sar_df %>%
  group_by(uid) %>%
  mutate(across(contains("sar_"), scale)) %>%
  ungroup() %>%
  dplyr::mutate(date = date %>% round_date(unit = "month"),
                year = date %>% year) %>%
  group_by(uid, date, year) %>%
  dplyr::summarise_if(is.numeric, max) %>%
  ungroup()

sar_df <- sar_df %>%
  mutate(bc_name = case_when(
    uid == 10 ~ "Al Aridah",
    uid == 14 ~ "Al Abbudiyah",
    uid == 15 ~ "Matraba"
  ))

ntl_df <- ntl_df %>%
  mutate(bc_name = case_when(
    uid == 10 ~ "Al Aridah",
    uid == 14 ~ "Al Abbudiyah",
    uid == 15 ~ "Matraba"
  ))

# Figures ----------------------------------------------------------------------
sar_2022_df <- sar_df %>%
  dplyr::filter(year == 2022)

ggplot() +
  geom_line(data = sar_2022_df,
            aes(x = date, 
                y = sar_vv_dissimilarity_sum),
            color = "blue") +
  facet_wrap(~bc_name)

ggplot() +
  geom_line(data = sar_df,
            aes(x = date, 
                y = sar_vv_none_p85),
            color = "blue") +
  geom_line(data = sar_df,
            aes(x = date, 
                y = sar_vv_dissimilarity_p85),
            color = "orange") +
  facet_wrap(~uid)
