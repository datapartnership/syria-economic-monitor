######################################################################
# Syria Economic Monitoring
# Multi-Sectoral Needs Assesment
# 1_cleaning
######################################################################

# Import raw data --------------------------------------------------------------

  # Households
  raw_2022 <- 
    read_xlsx(
      here(
        "Data", 
        "Raw",
        "2022-09-06_SYR_MSNA2022_dataset_HHs.xlsx"
      ),
      sheet = "Dataset - households"
    )
  
  raw_2023 <- 
    read_xlsx(
      here(
        "Data", 
        "Raw",
        "MSNA2023_dataset.xlsx"
      ),
      sheet = "Dataset - households"
    )

  # Individuals
  raw_i_2022 <- 
    read_xlsx(
      here(
        "Data", 
        "Raw",
        "2022-09-06_SYR_MSNA2022_dataset_individuals.xlsx"
      ),
      sheet = "Dataset - individuals"
    )
  
  raw_i_2023 <- 
    read_xlsx(
      here(
        "Data", 
        "Raw",
        "MSNA2023_dataset.xlsx"
      ),
      sheet = "Dataset - individual"
    )

  # Earthquake
  raw_e <- 
    read_xlsx(
      here(
        "Data", 
        "Raw",
        "syria-earthquake-impact-20-march-2023.xlsx"
      ),
      sheet = "DATASET"
    ) 
  
  # Shapefile Syria
  syria_shp <- 
    st_read(
      here(
        "Data", 
        "Raw", 
        "syr_admbnda_adm3_uncs_unocha_20201217-polygon.shp"
      )
    )

# Data preparation -------------------------------------------------------------

  # Earthquake
  earthquake <- raw_e %>%
    select(ADM3_EN, ADM3_PCODE, ADM4_EN, ADM4_PCODE, casualties, injuries, 
           des_houses, damag_houses) %>%
    group_by(ADM3_PCODE) %>%
    summarise(
      total_casualties = sum(casualties, na.rm = TRUE),
      total_injuries = sum(injuries, na.rm = TRUE),
      total_des_houses = sum(des_houses, na.rm = TRUE),
      total_damag_houses = sum(damag_houses, na.rm = TRUE)
    ) %>%
    mutate(
      earthquake = 1
    )
  
  # 2022 - Individuals
  msna_i_2022 <- 
    raw_i_2022 %>%
    separate(
      edu_3, 
      into = c("edu3_1", "edu3_2"), 
      sep = "; "
    ) %>%
    rename(
      id = id_hh,
      edu_3 = edu3_1
    ) %>%
    select(id_individual,	id, edu_1, edu_3, q_7_1, region) %>%
    mutate(
      year = 2022
    )
  
  # 2023 - Individuals
  msna_i_2023 <- 
    raw_i_2023 %>%
    select(id_individual, id, edu_1, edu_3, q_7_1, region) %>%
    mutate(
      year = 2023
    )
  
  # 2022 - Households
  msna_2022 <-
    raw_2022 %>%
    filter(q_k10 != "Neighborhood") %>%
    separate(
      q_16_8, 
      into = c("safety_1", "safety_2", "safety_3", "safety_4", "safety_5"), 
      sep = "; "
    ) %>%
    separate(
      q_10_4, 
      into = c("issues_1", "issues_2", "issues_3", "issues_4", "issues_5"), 
      sep = "; "
    ) %>%
    mutate(q_17_1 = ifelse(q_17_1 %in% c("Don't know / unsure", "Prefer not to answer"), NA, q_17_1),
           q_17_3 = ifelse(q_17_3 %in% c("Don't know/unsure", "Don’t know/unsure"), NA, q_17_3),
           q_17_3 = ifelse(q_17_3 == "Prefer to not answer", NA, q_17_3),
           q_17_3 = ifelse(q_17_3 == "No, not satisfied with any of the assistance/access to services received", "No", q_17_3),
           q_17_3 = ifelse(q_17_3 %in% c("Yes, satisfied with some assistance/access to services received",
                                         "Yes, satisfied with all assistance/access to services received"), "Yes", q_17_3),
           q_7_1 = ifelse(q_7_1 == "Internally displaced person (IDP)" & q_k10 == "Camp", "IDPs in camps", q_7_1),
           q_7_1 = ifelse(q_7_1 == "Internally displaced person (IDP)" & q_k10 != "Camp", "IDPs out of camps", q_7_1),
           q_7_1 = ifelse(q_7_1 == "Host population", "Host (Residents)", q_7_1),
           q_7_1 = ifelse(q_7_1 == "Returnee (returned in 2022)", "Returnees (2022)", q_7_1),
           q_r3 = ifelse(q_r3 == "Widow / Widower", "Widowed", q_r3),
           q_8_7 = ifelse(q_8_7 == "Don't know / unsure", "Don't know", q_8_7),
           q_8_5_0 = ifelse(q_8_5_0 == "Don't know / unsure", "Don't know", q_8_5_0),
           q_8_5_1 = ifelse(q_8_5_1 == "Don't know / unsure", "Don't know", q_8_5_1),
           q_8_5_2 = ifelse(q_8_5_2 == "Don't know / unsure", "Don't know", q_8_5_2),
           q_8_5_3 = ifelse(q_8_5_3 == "Don't know / unsure", "Don't know", q_8_5_3),
           q_11_1 = ifelse(q_11_1 == "Not enough water to meet any of the above needs", "No", "Yes"),
           q_15_1 = ifelse(q_15_1 %in% c("16-21 hours per day", "22+ hours per day"), "16+ hours per day", q_15_1),
           q_16_4_b = q_16_4_b/0.0071,
           q_16_4_a = ifelse(q_16_4_currency == "Turkish Lira (TRY)", q_16_4_b, q_16_4_a), # SYP to TRY on August 1, 2022
           year = 2022,
           year = as.character(year)
    ) %>%
    rename(
      limit = q_16_3_1,
      income = q_16_4_a
    ) %>%
    select(
      id, q_7_1, q_k7, q_k8, q_k9, q_r1, q_r2, q_r3, q_r12, q_8_7, safety_1, 
      safety_2, safety_3, safety_4, q_8_5_0, q_8_5_1, q_8_5_2, q_8_5_3, q_17_1, 
      q_17_3, q_16_1_1, q_16_1_2, q_16_1_3, q_7_2, q_7_2_1, q_7_4, q_7_6, q_7_7,
      q_7_9_1, q_7_9_2, q_7_9_3, issues_1, issues_2, issues_3, q_10_1, q_11_1,
      q_15_1, q_9_4_1, q_16_2, limit, income, q_16_4, year, q_k11, region
    ) %>%
    filter(
      q_7_1 != "IDPs in camps"
    )
  
  # 2023 - Households
  msna_2023 <-
    raw_2023 %>%
    separate(
      safety_boys, 
      into = c("safety_1", "safetyb"), 
      sep = " "
    ) %>%
    separate(
      safety_girls, 
      into = c("safety_2", "safetyg"), 
      sep = " "
    ) %>%
    separate(
      safety_women, 
      into = c("safety_3", "safetyw"), 
      sep = " "
    ) %>%
    separate(
      safety_men, 
      into = c("safety_4", "safetym"), 
      sep = " "
    ) %>%
    separate(
      unmet_needs, 
      into = c("q_16_1_1", "q_16_1_2", "q_16_1_3"), 
      sep = " "
    ) %>%
    separate(
      aid_kind, 
      into = c("aid_1", "aid_2", "aid_3", "aid_4"), 
      sep = " "
    ) %>%
    separate(
      q_7_9, 
      into = c("q_7_9_1", "q_7_9_2", "q_7_9_3", "q_7_9_4"), 
      sep = " "
    ) %>%
    separate(
      q_10_4, 
      into = c("issues_1", "issues_2", "issues_3", "issues_4", "issues_5"), 
      sep = " "
    ) %>%
    separate(
      q_16_3, 
      into = c("limit", "limit_o"), 
      sep = " "
    ) %>%
    separate(
      barriers_healthcare, 
      into = c("barr_health", "barriers_0"), 
      sep = " "
    ) %>%
    separate(
      unex_events, 
      into = c("event_1", "event_2", "event_3", "event_4"), 
      sep = " "
    ) %>%
    separate(
      event_hh_affected, 
      into = c("affect_1", "affect_2", "affect_3", "affect_4"), 
      sep = " "
    )  %>%
    separate(
      q_10_4_e, 
      into = c("waste_1", "waste_2", "waste_3", "waste_4"), 
      sep = " "
    )  %>%
    mutate(
      q_7_1 = ifelse(q_7_1 == "Returnees", "Returnees (2023)", q_7_1),
      barr_health = str_replace_all(barr_health, "_", " "),
      affect_1 = str_replace_all(affect_1, "_", " "),
      affect_2 = str_replace_all(affect_2, "_", " "),
      affect_3 = str_replace_all(affect_3, "_", " "),
      waste_1 = str_replace_all(waste_1, "_", " "),
      waste_2 = str_replace_all(waste_2, "_", " "),
      waste_3 = str_replace_all(waste_3, "_", " "),
      event_1 = str_replace_all(event_1, "_", " "),
      event_2 = str_replace_all(event_2, "_", " "),
      event_3 = str_replace_all(event_3, "_", " "),
      safety_1 = str_replace_all(safety_1, "_", " "),
      safety_2 = str_replace_all(safety_2, "_", " "),
      safety_3 = str_replace_all(safety_3, "_", " "),
      safety_4 = str_replace_all(safety_4, "_", " "),
      q_16_1_1 = str_replace_all(q_16_1_1, "_", " "),
      q_16_1_2 = str_replace_all(q_16_1_2, "_", " "),
      q_16_1_3 = str_replace_all(q_16_1_3, "_", " "),
      q_7_9_1 = str_replace_all(q_7_9_1, "_", " "),
      q_7_9_2 = str_replace_all(q_7_9_2, "_", " "),
      q_7_9_3 = str_replace_all(q_7_9_3, "_", " "),
      issues_1 = str_replace_all(issues_1, "_", " "),
      issues_2 = str_replace_all(issues_2, "_", " "),
      issues_3 = str_replace_all(issues_3, "_", " "),
      limit = str_replace_all(limit, "_", " "),
      q_17_3 = ifelse(q_17_3 %in% c("Prefer not to answer", "Don't know"), NA, q_17_3),
      q_17_3 = ifelse(q_17_3 == "Neither satisfied nor dissatisfied with all assistance/access to services received", "Don’t know/unsure", q_17_3),
      q_17_3 = ifelse(q_17_3 == "No, not satisfied with any of the assistance/access to services received", "No", q_17_3),
      q_17_3 = ifelse(q_17_3 %in% c("Yes, satisfied with some assistance/access to services received",
                                    "Yes, satisfied with all assistance/access to services received"), "Yes", q_17_3),
      q_11_1 = ifelse(q_11_1 %in% c("Never (0 days)", "Don’t know/unsure", " Rarely (1–2 days)", "Sometimes (3–10 days)"), "No", "Yes"),
      q_15_1 = ifelse(q_15_1 == 0, "0 hours per day",
                      ifelse(q_15_1 %in% 1:2, "1-2 hours per day",
                             ifelse(q_15_1 >= 3 & q_15_1 <= 8, "3-8 hours per day",
                                    ifelse(q_15_1 >= 9 & q_15_1 <= 15, "9-15 hours per day",
                                           ifelse(q_15_1 >= 16, "16+ hours per day", q_15_1))))),
      income = coalesce(q_16_4_a, 0) + coalesce(q_16_4_b, 0) + coalesce(q_16_4_c, 0) +
        coalesce(q_16_4_d, 0) + coalesce(q_16_4_e, 0) + coalesce(q_16_4_f, 0) +
        coalesce(q_16_4_g, 0) + coalesce(q_16_4_h, 0) + coalesce(q_16_4_i, 0) +
        coalesce(q_16_4_j, 0) + coalesce(q_16_4_k, 0) + coalesce(q_16_4_l, 0) +
        coalesce(q_16_4_m, 0),
      income = ifelse(q_16_4_currency == "Turkish Lira (TRY)", income/0.0020, income), # SYP to TRY on September 20, 2023
      income = ifelse(q_16_4_currency == "US Dollars (USD)", income/0.000076, income), # SYP to USD on September 20, 2023
      aid_1 = str_replace_all(aid_1, "_", " "),
      aid_2 = str_replace_all(aid_2, "_", " "),
      aid_3 = str_replace_all(aid_3, "_", " "),
      nutrition_3m = str_replace_all(nutrition_3m, "_", " "),
      community = str_split(q_k11, " - ", simplify = TRUE)[, 2],
      q_k11 = str_split(q_k11, " - ", simplify = TRUE)[, 1],
      q_7_1 = ifelse(q_7_1 == "Residents", "Host (Residents)", q_7_1),
      year = 2023,
      q_8_5_2 = ifelse(q_8_5_2 == "Don't know / unsure", "Don't know", q_8_5_2),
      q_8_5_3 = ifelse(q_8_5_3 == "Don't know / unsure", "Don't know", q_8_5_3),
      q_17_3 = ifelse(q_17_3 %in% c("Don't know/unsure", "Don’t know/unsure"), NA, q_17_3), # Revisar este
      year = as.character(year)
    ) %>%
    select(
      id, q_7_1, q_k7, q_k8, q_k9, q_r1, q_r2, q_r3, q_r12, q_8_7, safety_1,
      safety_2, safety_3, safety_4, q_8_5_0, q_8_5_1, q_8_5_2, q_8_5_3, q_17_1,
      q_17_3, q_16_1_1, q_16_1_2, q_16_1_3, q_7_2, q_7_2_1, q_7_4, q_7_6, q_7_7,
      aid_1, aid_2, aid_3, q_7_9_1, q_7_9_2, q_7_9_3, issues_1, issues_2, issues_3, q_10_1,
      q_11_1, nutrition_3m, q_15_1, barr_health, q_16_2, q_16_4, limit, income,
      event_1, event_2, event_3, affect_1, affect_2, affect_3, year, q_k11, community,
      q_10_4_g, q_10_4_h, waste_1, waste_2, waste_3, region
    ) %>%
    filter(
      q_7_1 != "IDPs in camps"
    )

# Data append ------------------------------------------------------------------

  # Select values of communities in common between 2022 and 2023
  common_values <- intersect(msna_2022$q_k11, msna_2023$q_k11)

  # Sample de household databases with the communities in common
  sample_2022 <- msna_2022 %>%
    filter(q_k11 %in% common_values)
  
  sample_2023 <- msna_2023 %>%
    filter(q_k11 %in% common_values)

  # Select the unique values of households in the sample
  hh_2022 <- unique(sample_2022$id)
  hh_2023 <- unique(sample_2023$id)

  # Sample de invidiavuals databases with the unique households in the sample
  sample_i_2022 <- msna_i_2022 %>%
    filter(id %in% hh_2022)
  
  sample_i_2023 <- msna_i_2023 %>%
    filter(id %in% hh_2023)

  # Append databases
  msna <- bind_rows(sample_2022, sample_2023)
  msna_i <- bind_rows(sample_i_2022, sample_i_2023)

# Data quality -----------------------------------------------------------------

# Check missing values for each variable
#missing_values <- raw_2022 %>%
#  summarise_all(~sum(is.na(.)))

# Display missing values
#print(missing_values)

# To see unique values and frequency
#table(raw_2022$HoH_employ) 

# Data coded saving ------------------------------------------------------------

# MSNA 2022
msna_2022 %>%
  write_csv(
    path = here(
      "Data",
      "Coded",
      "msna_2022.csv")
  )

# MSNA 2023
msna_2023 %>%
  write_csv(
    path = here(
      "Data",
      "Coded",
      "msna_2023.csv")
  )

# MSNA SAMPLE SEM
msna %>%
  write_csv(
    path = here(
      "Data",
      "Coded",
      "msna_2023.csv")
  )

# Earthquake
earthquake %>%
  write_csv(
    path = here(
      "Data",
      "Coded",
      "earthquake.csv")
  )

# Shapefiles
syria_shp %>%
  write_csv(
    path = here(
      "Data",
      "Coded",
      "syria_shp.csv")
  )
