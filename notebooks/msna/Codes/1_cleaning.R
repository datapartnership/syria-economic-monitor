######################################################################
# Syria Economic Monitoring
# Multi-Sectoral Needs Assesment
# 1_cleaning
######################################################################

# Import raw data --------------------------------------------------------------

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

# Data preparation -------------------------------------------------------------

  # 2022
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
           q_8_5_2 = ifelse(q_8_7 == "Don't know / unsure", "Don't know", q_8_5_2),
           q_8_5_3 = ifelse(q_8_7 == "Don't know / unsure", "Don't know", q_8_5_3),
           q_11_1 = ifelse(q_11_1 == "Not enough water to meet any of the above needs", "No", "Yes"),
           q_15_1 = ifelse(q_15_1 %in% c("16-21 hours per day", "22+ hours per day"), "16+ hours per day", q_15_1),
           q_16_4_b = q_16_4_b/0.0071,
           q_16_4_a = ifelse(q_16_4_currency == "Turkish Lira (TRY)", q_16_4_b, q_16_4_a), # SYP to TRY on August 1, 2022
           year = 2022
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
      q_15_1, q_9_4_1, q_16_2, limit, income, q_16_4, year
    ) 

  # 2023
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
      q_7_9, 
      into = c("q_7_9_1", "q_7_9_2", "q_7_9_3", "q_7_9_4"), 
      sep = " "
    ) %>%
    separate(
      q_10_4, 
      into = c("issues_1", "issues_2", "issues_3", "issues_4", "issues_5"), 
      sep = "; "
    ) %>%
    separate(
      q_16_3, 
      into = c("limit", "limit_o"), 
      sep = "; "
    ) %>%
    mutate(
      q_7_1 = ifelse(q_7_1 == "Returnees", "Returnees (2023)", q_7_1),
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
      q_17_3 = ifelse(q_17_3 == "Prefer to not answer", NA, q_17_3),
      q_17_3 = ifelse(q_17_3 == "Neither satisfied nor dissatisfied with all assistance/access to services received", "Don’t know/unsure", q_17_3),
      q_17_3 = ifelse(q_17_3 == "No, not satisfied with any of the assistance/access to services received", "No", q_17_3),
      q_17_3 = ifelse(q_17_3 %in% c("Yes, satisfied with some assistance/access to services received",
                                    "Yes, satisfied with all assistance/access to services received"), "Yes", q_17_3),
      q_11_1 = ifelse(q_11_1 %in% c("Never (0 days)", "Don’t know/unsure", " Rarely (1–2 days)", "Sometimes (3–10 days)"), "No", "Yes"),
      q_15_1 = ifelse(q_15_1 == 0, "0 hours per day", q_15_1),
      q_15_1 = ifelse(q_15_1 %in% 1:2, "1-2 hours per day", q_15_1),
      q_15_1 = ifelse(q_15_1 >= 3 & q_15_1 <= 8, "3-8 hours per day", q_15_1),
      q_15_1 = ifelse(q_15_1 >= 9 & q_15_1 <= 15, "9-15 hours per day", q_15_1),
      q_15_1 = ifelse(q_15_1 >= 16, "16+ hours per day", q_15_1),
      income = q_16_4_a + q_16_4_b + q_16_4_c + q_16_4_d + q_16_4_e + q_16_4_f + 
        q_16_4_g + q_16_4_h + q_16_4_i + q_16_4_j + q_16_4_k + q_16_4_l + q_16_4_m,
      income = ifelse(q_16_4_currency == "Turkish Lira (TRY)", income/0.0020, income), # SYP to TRY on September 20, 2023
      income = ifelse(q_16_4_currency == "US Dollars (USD)", income/0.000076, income), # SYP to USD on September 20, 2023
      year = 2023
    ) %>%
    select(
      id, q_7_1, q_k7, q_k8, q_k9, q_r1, q_r2, q_r3, q_r12, q_8_7, safety_1,
      safety_2, safety_3, safety_4, q_8_5_0, q_8_5_1, q_8_5_2, q_8_5_3, q_17_1,
      q_17_3, q_16_1_1, q_16_1_2, q_16_1_3, q_7_2, q_7_2_1, q_7_4, q_7_6, q_7_7,
      aid_kind, q_7_9_1, q_7_9_2, q_7_9_3, issues_1, issues_2, issues_3, q_10_1,
      q_11_1, nutrition_3m, q_15_1, barriers_healthcare, q_16_2, q_16_4, limit, 
      unex_events, event_hh_affected, year
    ) 
 
# Data append ------------------------------------------------------------------
  
  msna <- bind_rows(msna_2022, msna_2023)

# Data quality -----------------------------------------------------------------
  
  # Check missing values for each variable
  #missing_values <- raw_2022 %>%
  #  summarise_all(~sum(is.na(.)))
  
  # Display missing values
  #print(missing_values)
  
  # To see unique values and frequency
  #table(raw_2022$HoH_employ) 
  