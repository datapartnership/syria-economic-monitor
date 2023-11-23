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

# Data quality -----------------------------------------------------------------

# Check missing values for each variable
#missing_values <- raw_2022 %>%
#  summarise_all(~sum(is.na(.)))

# Display missing values
#print(missing_values)

# To see unique values and frequency
#table(raw_2022$HoH_employ)

# Data preparation -------------------------------------------------------------

msna_2022 <-
  raw_2022 %>%
  select(
    id, q_k7, q_k8, q_k9, q_k10, q_k11, q_k6, q_k12, q_r1, q_r2, q_r3, q_r12, q_r1, 
    q_r2, q_r3, q_r12, q_h3, q_h1, q_h2, q_8_4_1, q_16_8_b, q_8_7, q_16_8, q_16_8, 
    q_16_8, q_16_8, q_8_5_0, q_8_5_1, q_8_5_2, q_8_5_3, q_8_1, q_8_1_1, q_17_1, 
    q_17_3, q_16_1_1, q_16_1_2, q_16_1_3, q_7_1, q_7_2, q_7_2_1, q_7_4,
    q_7_6, q_7_7, q_7_9_1, q_7_9_2, q_7_9_3, q_10_1, q_10_4, q_11_1, q_10_4_e,
    q_15_1, q_9_2, q_9_4, q_9_4_1, q_9_3, q_16_2, q_16_3_1, q_16_3_2, q_16_3_3,
    q_16_4_currency, q_16_4_a, q_16_4_b, starts_with("q_8_1_1_"), q_16_4
  ) %>%
  mutate(q_17_1 = ifelse(q_17_1 %in% c("Don't know / unsure", "Prefer not to answer"), NA, q_17_1),
         q_17_3 = ifelse(q_17_3 %in% c("Don't know/unsure", "Prefer to not answer"), NA, q_17_3),
         q_17_3 = ifelse(q_17_3 == "No, not satisfied with any of the assistance/access to services received", "No", q_17_3),
         q_17_3 = ifelse(q_17_3 %in% c("Yes, satisfied with some assistance/access to services received",
                                       "Yes, satisfied with all assistance/access to services received"), "Yes", q_17_3),
         q_7_1 = ifelse(q_7_1 == "Internally displaced person (IDP)", "IDP", q_7_1),
         q_7_1 = ifelse(q_7_1 == "Returnee (returned in 2022)", "Returnee (2022)", q_7_1)
         ) %>%
  filter(q_k10 != "Neighborhood")
  