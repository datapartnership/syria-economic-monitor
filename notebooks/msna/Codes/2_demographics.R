######################################################################
# Syria Economic Monitoring
# Multi-Sectoral Needs Assessment
# 2_demographics
######################################################################

###############################
# MSNA 2022
###############################

# Population distribution ------------------------------------------------------

  # 2022
  pop_2022 <- msna_2022 %>%
    group_by(q_7_1, q_k9) %>%
    summarise(pop = sum(q_r12, na.rm = TRUE),
              .groups = 'drop') %>%
    mutate(
      subdis_code = str_split(q_k9, " - ", simplify = TRUE)[, 1],
      subdis_name = str_split(q_k9, " - ", simplify = TRUE)[, 2],
      ADM3_PCODE = subdis_code) %>%
    select(ADM3_PCODE, subdis_code, subdis_name, q_7_1, pop)

  unique_pop <- unique(pop_2022$q_7_1)
  
  for (i in unique_pop) {
    
    subset_data <- pop_2022 %>% filter(q_7_1 == i)
    merged_data <- left_join(syria_shp, subset_data, by = "ADM3_PCODE")
    
    pop_map <- ggplot(merged_data) +
      geom_sf(aes(fill = pop)) +
      scale_fill_gradient(low = "lightblue", high = "darkblue", na.value = "white") +
      ggtitle(i) +
      theme_minimal() +
      theme(legend.position = "right") +
      labs(fill = "Population")
    
    ggsave(here("Output", "2022", paste0("/pop_", i, ".png")), plot = pop_map, width = 7, height = 6, units = "in", dpi = 300)
  }
  
  # 2023
  pop_2023 <- msna_2023 %>%
    group_by(q_7_1, q_k9) %>%
    summarise(pop = sum(q_r12, na.rm = TRUE),
              .groups = 'drop') %>%
    mutate(
      subdis_code = str_split(q_k9, " - ", simplify = TRUE)[, 1],
      subdis_name = str_split(q_k9, " - ", simplify = TRUE)[, 2],
      ADM3_PCODE = subdis_code) %>%
    select(ADM3_PCODE, subdis_code, subdis_name, q_7_1, pop)
  
  unique_pop <- unique(pop_2023$q_7_1)
  
  for (i in unique_pop) {
    
    subset_data <- pop_2023 %>% filter(q_7_1 == i)
    merged_data <- left_join(syria_shp, subset_data, by = "ADM3_PCODE")
    
    pop_map <- ggplot(merged_data) +
      geom_sf(aes(fill = pop)) +
      scale_fill_gradient(low = "lightblue", high = "darkblue", na.value = "white") +
      ggtitle(i) +
      theme_minimal() +
      theme(legend.position = "right") +
      labs(fill = "Population")
    
    ggsave(here("Output", "2023", paste0("/pop_", i, ".png")), plot = pop_map, width = 7, height = 6, units = "in", dpi = 300)
  }
  
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
