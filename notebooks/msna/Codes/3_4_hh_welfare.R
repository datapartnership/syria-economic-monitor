######################################################################
# Syria Economic Monitoring
# Multi-Sectoral Needs Assessment
# 3_4_hh_welfare
######################################################################

# % of HHs by number of hours of access to electricity -------------------------

electr <- msna %>%
  filter(!is.na(q_15_1)) %>%
  mutate(q_15_1 = factor(q_15_1, levels = c("0 hours per day", "1-2 hours per day", "3-8 hours per day", "9-15 hours per day", "16+ hours per day")))

unique_year <- unique(electr$year)

for (value in unique_year) {
  subset_data <- electr %>%
    filter(year == value) %>%
    group_by(q_7_1, q_15_1) %>%
    summarise(n = n()) %>%
    mutate(percentage = round(n / sum(n) * 100, 1)) %>% 
    mutate(csum = rev(cumsum(rev(percentage))), 
           pos = percentage/2 + lead(csum, 1),
           pos = if_else(is.na(pos), percentage/2, pos))
  
  pie_chart <- ggplot(subset_data, aes(x = "", y = percentage, fill = fct_inorder(q_15_1))) +
    geom_bar(stat = "identity", width = 1, color = "white") +
    coord_polar(theta = "y") +
    geom_label_repel(data = subset_data,
                     aes(y = pos, label = paste0(percentage, "%")),
                     size = 3, nudge_x = 0.7, show.legend = FALSE) +
    labs(fill = "") +
    theme_minimal() +
    theme(legend.position = "right",
          plot.title = element_text(hjust = 0.5, size = 16, face = "bold"),
          plot.caption = element_text(hjust = 0.5, size = 10),
          axis.text = element_blank(),
          axis.title = element_blank(),
          panel.grid = element_blank()) +
    scale_fill_manual(values = pie_colors) +
    facet_wrap(~q_7_1, ncol = 3) 
  
  ggsave(here("Output", paste0("pie_elec_", gsub(" ", "_", value), ".png")), plot = pie_chart, width = 9, height = 6, units = "in", dpi = 300)
}


# % of HHs reported access to nutrition services in past 3m (2023) -------------

nutri <- sample_2023 %>%
  mutate(
    nutrition_3m = ifelse(nutrition_3m == "Dont know", NA,
                          ifelse(nutrition_3m == "Yes", "Yes", "No")
    )
  ) %>%
  filter(!is.na(nutrition_3m))

  subset_data <- nutri %>%
    group_by(q_7_1, nutrition_3m) %>%
    summarise(n = n()) %>%
    mutate(percentage = round(n / sum(n) * 100, 1)) %>% 
    mutate(csum = rev(cumsum(rev(percentage))), 
           pos = percentage/2 + lead(csum, 1),
           pos = if_else(is.na(pos), percentage/2, pos))
  
  pie_chart <- ggplot(subset_data, aes(x = "", y = percentage, fill = fct_inorder(nutrition_3m))) +
    geom_bar(stat = "identity", width = 1, color = "white") +
    coord_polar(theta = "y") +
    geom_label_repel(data = subset_data,
                     aes(y = pos, label = paste0(percentage, "%")),
                     size = 3, nudge_x = 0.7, show.legend = FALSE) +
    labs(fill = "") +
    theme_minimal() +
    theme(legend.position = "right",
          plot.title = element_text(hjust = 0.5, size = 16, face = "bold"),
          plot.caption = element_text(hjust = 0.5, size = 10),
          axis.text = element_blank(),
          axis.title = element_blank(),
          panel.grid = element_blank()) +
    scale_fill_manual(values = pie_colors) +
    facet_wrap(~q_7_1, ncol = 3) 
  
  ggsave(here("Output", "pie_nut_2023.png"), plot = pie_chart, width = 9, height = 6, units = "in", dpi = 300)

# % of households reporting having had sufficient water for drinking -----------

wat <- msna %>%
  filter(!is.na(q_11_1)) %>%
  mutate()

unique_year <- unique(wat$year)

for (value in unique_year) {
  subset_data <- wat %>%
    filter(year == value) %>%
    group_by(q_7_1, q_11_1) %>%
    summarise(n = n()) %>%
    mutate(percentage = round(n / sum(n) * 100, 1)) %>% 
    mutate(csum = rev(cumsum(rev(percentage))), 
           pos = percentage/2 + lead(csum, 1),
           pos = if_else(is.na(pos), percentage/2, pos))
  
  pie_chart <- ggplot(subset_data, aes(x = "", y = percentage, fill = fct_inorder(q_11_1))) +
    geom_bar(stat = "identity", width = 1, color = "white") +
    coord_polar(theta = "y") +
    geom_label_repel(data = subset_data,
                     aes(y = pos, label = paste0(percentage, "%")),
                     size = 3, nudge_x = 0.7, show.legend = FALSE) +
    labs(fill = "") +
    theme_minimal() +
    theme(legend.position = "right",
          plot.title = element_text(hjust = 0.5, size = 16, face = "bold"),
          plot.caption = element_text(hjust = 0.5, size = 10),
          axis.text = element_blank(),
          axis.title = element_blank(),
          panel.grid = element_blank()) +
    scale_fill_manual(values = pie_colors) +
    facet_wrap(~q_7_1, ncol = 3) 
  
  ggsave(here("Output", paste0("pie_wat_", gsub(" ", "_", value), ".png")), plot = pie_chart, width = 9, height = 6, units = "in", dpi = 300)
}

# Main reason limiting household’s ability to access healthcare (2023) ---------

barr <- sample_2023 %>%
  select(id, year, barr_health, q_7_1) %>%
  mutate(id = id,
         ones = 1,
         barr_health = ifelse(barr_health %in% c("Turned away at the health facility", 
                                                 "Poor water sanitation and hygiene conditions in health care facilities lack of latrines access to clean water etc",
                                                 "Not trained staff at health facility",
                                                 "Not safe insecurity while travelling to health facility",
                                                 "Not enough staff at health facility",
                                                 "No means of transport",
                                                 "Lack of female staff at facility",
                                                 "Judgemntal attitude or negative treatment",
                                                 "Health facility is too far away",
                                                 "Fear or distrust of health workers examination or treatment",
                                                 "Disability prevents access to health facility",
                                                 "Did not receive correct medications",
                                                 "No functional health facility nearby"), "Other", barr_health),
         barr_health = ifelse(barr_health %in% c("Could not afford cost of consultation", 
                                                 "Could not afford cost of treatment",
                                                 "Could not afford transportation to health facility"), "Could not afford related costs", barr_health)
  ) %>%
  filter(!is.na(barr_health), barr_health != "Dont know", barr_health != "Prefer not to answer") %>%
  group_by(barr_health, year, q_7_1) %>%
  summarise(total = sum(ones, na.rm = TRUE),
            .groups = 'drop')  %>%
  group_by(q_7_1, year) %>%
  mutate(percentage = round(total / sum(total) * 100, digits = 1)) %>%
  ungroup()
  
  bar_chart <- ggplot(barr, aes(x = percentage, y = barr_health, fill = q_7_1)) +
    geom_bar(stat = "identity", position = "dodge", width = 0.7, color = "white") +
    geom_text(aes(label = percentage), position = position_dodge(width = 0.7), hjust = - 0.5, vjust = 0, size = 2) +
    labs(title = ,
         x = "Percentage of Households",
         y = "Limitation") +
    scale_x_continuous(limits = c(0, max(barr$percentage) + (max(barr$percentage)/10))) +
    scale_fill_manual(values = bar_colors) +
    theme_minimal() +
    theme(
      axis.text.y = element_text(size = 8),
      axis.text.x = element_text(size = 10),
      axis.title = element_text(size = 12, face = "bold"),
      plot.title = element_text(size = 16, face = "bold"),
      legend.position = "top",
      legend.title = element_blank(),
      legend.text = element_text(size = 10),
      panel.grid.major.y = element_blank(),
      panel.grid.minor.y = element_blank(),
      panel.grid.major.x = element_line(color = "lightgray", size = 0.5),
      panel.grid.minor.x = element_blank()
    )
  
  ggsave(here("Output", "/bar_barr_2023.png"), bar_chart, width = 9, height = 6)

# % of HHs by ability to meet the basic needs ----------------------------------

bn <- msna %>%
  filter(!is.na(q_16_2))

unique_year <- unique(bn$year)

for (value in unique_year) {
  subset_data <- bn %>%
    filter(year == value) %>%
    group_by(q_7_1, q_16_2) %>%
    summarise(n = n()) %>%
    mutate(percentage = round(n / sum(n) * 100, 1)) %>% 
    mutate(csum = rev(cumsum(rev(percentage))), 
           pos = percentage/2 + lead(csum, 1),
           pos = if_else(is.na(pos), percentage/2, pos))
  
  pie_chart <- ggplot(subset_data, aes(x = "", y = percentage, fill = fct_inorder(q_16_2))) +
    geom_bar(stat = "identity", width = 1, color = "white") +
    coord_polar(theta = "y") +
    geom_label_repel(data = subset_data,
                     aes(y = pos, label = paste0(percentage, "%")),
                     size = 3, nudge_x = 0.7, show.legend = FALSE) +
    labs(fill = "") +
    theme_minimal() +
    theme(legend.position = "right",
          plot.title = element_text(hjust = 0.5, size = 16, face = "bold"),
          plot.caption = element_text(hjust = 0.5, size = 10),
          axis.text = element_blank(),
          axis.title = element_blank(),
          panel.grid = element_blank()) +
    scale_fill_manual(values = pie_colors) +
    facet_wrap(~q_7_1, ncol = 3) 
  
  ggsave(here("Output", paste0("pie_bn_", gsub(" ", "_", value), ".png")), plot = pie_chart, width = 9, height = 6, units = "in", dpi = 300)
}

# Main reason limiting household’s ability to meet their basic needs -----------

limits <- msna %>%
  select(id, year, limit, q_7_1) %>%
  mutate(id = id,
         ones = 1,
         limit = ifelse(limit %in% c("Other (please specify)",
                                     "Lack of access to services (health, education, electricity, etc.)",
                                     "Lack of availability of services (health, education, electricity, etc.)",
                                     "Restrictions on movement for non COVID-19 reasons (such as general insecurity, checkpoints, regulations by authorities, presence of explosive ordnance, or others)",
                                     "Unavailability of items (medicines, bread, water, fuel, etc.)",
                                     "Disability of one or more members in the HH",
                                     "Issues related to lack of civil documentation",
                                     "HH no longer receiving assistance",
                                     "Loss of remittances",
                                     "Restrictions on movement",
                                     "Unavailability of items medicines bread water fuel etc",
                                     "Direct losses and or displacement due to the earthquakes"), "Other", limit),
         limit = ifelse(limit %in% c("Death absence of primary breadwinner",
                                     "Disability illness of one or more members in the HH leading to bigger expenses",
                                     "Expensive services health education electricity etc",
                                     "Loss of remittances general",
                                     "Eviction housing unable to pay rent",
                                     "Loss of remittances value of money received has decreased no modality to receive"), "Insufficient/lack of income", limit),
         limit = ifelse(limit == "Unemployment loss of job", "Unemployment/loss of job", limit)
         ) %>%
  filter(!is.na(limit), limit != "Prefer not to answer", limit != "No other Reasons") %>%
  group_by(limit, year, q_7_1) %>%
  summarise(total = sum(ones, na.rm = TRUE),
            .groups = 'drop')  %>%
  group_by(q_7_1, year) %>%
  mutate(percentage = round(total / sum(total) * 100, digits = 1)) %>%
  ungroup()

unique_year <- unique(limits$year)

for (value in unique_year) {
  plot_data <- filter(limits, year == value)
  
  bar_chart <- ggplot(plot_data, aes(x = percentage, y = limit, fill = q_7_1)) +
    geom_bar(stat = "identity", position = "dodge", width = 0.7, color = "white") +
    geom_text(aes(label = percentage), position = position_dodge(width = 0.7), hjust = - 0.5, vjust = 0, size = 2) +
    labs(title = value,
         x = "Percentage of Households",
         y = "Limitation") +
    scale_x_continuous(limits = c(0, max(plot_data$percentage) + (max(plot_data$percentage)/10))) +
    scale_fill_manual(values = bar_colors) +
    theme_minimal() +
    theme(
      axis.text.y = element_text(size = 8),
      axis.text.x = element_text(size = 10),
      axis.title = element_text(size = 12, face = "bold"),
      plot.title = element_text(size = 16, face = "bold"),
      legend.position = "top",
      legend.title = element_blank(),
      legend.text = element_text(size = 10),
      panel.grid.major.y = element_blank(),
      panel.grid.minor.y = element_blank(),
      panel.grid.major.x = element_line(color = "lightgray", size = 0.5),
      panel.grid.minor.x = element_blank()
    )
  
  ggsave(here("Output", paste0("/bar_lim", gsub("/", "_", value), ".png")), bar_chart, width = 7.5, height = 6)
}

# Access to healthcare (Only 2022) ---------------------------------------------

health_2022 <- sample_2022 %>%
  filter(!is.na(q_9_4_1)) %>%
  mutate(
    health = ifelse(q_9_4_1 > 0, "Not all members got access", "All members got access")
  ) %>%
  select(health, q_7_1)

  subset_data <- health_2022 %>%
    group_by(q_7_1, health) %>%
    summarise(n = n()) %>%
    mutate(percentage = round(n / sum(n) * 100, 1)) %>% 
    mutate(csum = rev(cumsum(rev(percentage))), 
           pos = percentage/2 + lead(csum, 1),
           pos = if_else(is.na(pos), percentage/2, pos))
  
  pie_chart <- ggplot(subset_data, aes(x = "", y = percentage, fill = fct_inorder(health))) +
    geom_bar(stat = "identity", width = 1, color = "white") +
    coord_polar(theta = "y") +
    geom_label_repel(data = subset_data,
                     aes(y = pos, label = paste0(percentage, "%")),
                     size = 3, nudge_x = 0.7, show.legend = FALSE) +
    labs(fill = "") +
    theme_minimal() +
    theme(legend.position = "right",
          plot.title = element_text(hjust = 0.5, size = 16, face = "bold"),
          plot.caption = element_text(hjust = 0.5, size = 10),
          axis.text = element_blank(),
          axis.title = element_blank(),
          panel.grid = element_blank()) +
    scale_fill_manual(values = pie_colors) +
    facet_wrap(~q_7_1, ncol = 3) 
  
  ggsave(here("Output", "pie_health_2022.png"), plot = pie_chart, width = 9, height = 6, units = "in", dpi = 300)

# Household income over the last 3 months --------------------------------------

income <- msna %>%
  select(income, year, q_16_4, q_7_1) %>%
  filter(q_16_4 == "Yes") 
  
unique_year <- unique(income$year)

for (value in unique_year) {
    
    subset_data <- income %>%
      filter(year == value) %>%
      mutate(
        income = ifelse(income > quantile(income, 0.95, na.rm = TRUE), NA, income)
      )
    
    hist_chart <- ggplot(subset_data, aes(x = factor(q_7_1), y = income)) +
      geom_boxplot(fill = "lightblue", color = "blue") +
      labs(title = "Outliers treated at 95%",
           x = "Population type",
           y = "Syrian Pounds (SYP)") +
      theme_minimal() +
      theme(
        axis.text.y = element_text(size = 8),
        axis.text.x = element_text(size = 10),
        axis.title = element_text(size = 12, face = "bold"),
        plot.title = element_text(size = 16, face = "bold"),
        legend.position = "top",
        legend.title = element_blank(),
        legend.text = element_text(size = 10),
        panel.grid.major.y = element_blank(),
        panel.grid.minor.y = element_blank(),
        panel.grid.major.x = element_line(color = "lightgray", size = 0.5),
        panel.grid.minor.x = element_blank()
      )
    
    ggsave(here("Output", paste0("box_income", gsub(" ", "_", value), ".png")), plot = hist_chart, width = 7, height = 6, units = "in", dpi = 300)
}