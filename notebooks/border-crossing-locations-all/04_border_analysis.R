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
ntl_df$viirs_bm_mean <- NULL

ntl_df %>%
  dplyr::filter(year %in% c(2019, 2020, 2021, 2022)) %>%
  
  ggplot(aes(x = month, y = viirs_bm_sum)) +
  geom_line() +
  geom_point() +
  facet_grid(year~bc_name) +
  scale_x_continuous(labels = 1:12,
                     breaks = 1:12) +
  labs(x = "Month",
       y = "NTL")

a <- aa %>%
  dplyr::filter(year %in% 2013,
                bc_name %in% "Matraba")


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
