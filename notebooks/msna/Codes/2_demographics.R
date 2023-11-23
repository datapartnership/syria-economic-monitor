######################################################################
# Syria Economic Monitoring
# Multi-Sectoral Needs Assessment
# 2_demographics
######################################################################

# Population distribution ------------------------------------------------------

  pop_2022 <- msna_2022 %>%
    group_by(q_7_1, q_k9) %>%
    summarise(pop = sum(q_r12, na.rm = TRUE),
              .groups = 'drop')
  
  # Variables processing
  pop_2022 <- pop_2022 %>%
    mutate(
      subdis_code = str_split(q_k9, " - ", simplify = TRUE)[, 1],
      subdis_name = str_split(q_k9, " - ", simplify = TRUE)[, 2],
      hh_pop_type = as.numeric(as.character(case_when(
        q_7_1 == "Host population" ~ "1",
        q_7_1 == "Internally displaced person (IDP)" ~ "2",
        q_7_1 == "Returnee (returned in 2022)" ~ "3",
        TRUE ~ as.character(q_7_1)
      ))),
      ADM3_PCODE = subdis_code,
      catIDPs_new = cut(pop, breaks = c(-Inf, 0, 325, 650, 975, 1300, 1625, 1950, 2275, Inf),
                        labels = c("0", "1 - 325", "326 - 650", "651 - 975", "976 - 1300", "1301 - 1625", "1626 - 1950", "1951 - 2275", "2276 - 2600"))
    ) %>%
    select(ADM3_PCODE, subdis_code, subdis_name, hh_pop_type, pop, catIDPs_new)
  
  pop_2022 %>%
    write_csv(
      here("Data",
           "Coded",
           "pop_2022.csv"
      )
    )
  
# HH characteristics ----------------------------------------------------

# # HH population type
# msna_2022$q_7_1 <- factor(msna_2022$q_7_1, levels = names(sort(table(msna_2022$q_7_1), decreasing = TRUE)))
# 
# ggplot(msna_2022, aes(x = q_7_1)) +
#   geom_bar(fill = "skyblue", color = "darkblue", alpha = 0.7) +
#   geom_text(stat = "count", aes(label = ..count..), vjust = -0.5) +  # Add labels
#   labs(title = "What population type is this household?", x = "Population Type", y = "Count") +
#   theme_minimal()
# 
# # HH members
# ggplot(msna_2022, aes(x = q_r12)) +
#   geom_histogram(binwidth = 1, fill = "skyblue", color = "darkblue", alpha = 0.7) +
#   labs(title = "House hold members", x = "Age", y = "Frequency") +
#   theme_minimal() 

# Respondent's demographics ----------------------------------------------------

# # Age
#  ggplot(msna_2022, aes(y = q_r2)) +
#   geom_boxplot(fill = "skyblue", color = "darkblue", alpha = 0.7) +
#   labs(title = "Respondent's Age", y = "Age") +
#   theme_minimal()
#   
# ggplot(msna_2022, aes(x = q_r2)) +
#   geom_histogram(binwidth = 2, fill = "skyblue", color = "darkblue", alpha = 0.7) +
#   labs(title = "Respondent's Age", x = "Age", y = "Frequency") +
#   theme_minimal()
# 
# # Marital status
# msna_2022$q_r3 <- factor(msna_2022$q_r3, levels = names(sort(table(msna_2022$q_r3), decreasing = TRUE)))
# 
# ggplot(msna_2022, aes(x = q_r3)) +
#   geom_bar(fill = "skyblue", color = "darkblue", alpha = 0.7) +
#   geom_text(stat = "count", aes(label = ..count..), vjust = -0.5) +  # Add labels
#   labs(title = "Respondent's Marital Status", x = "Marital Status", y = "Count") +
#   theme_minimal()
