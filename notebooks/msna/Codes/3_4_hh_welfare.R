######################################################################
# Syria Economic Monitoring
# Multi-Sectoral Needs Assessment
# 3_4_hh_welfare
######################################################################

# % of HHs by number of hours of access to electricity -------------------------

electr_2022 <- msna_2022 %>%
  filter(!is.na(q_15_1))

unique_q_k10 <- unique(wat_2022$q_k10)

for (value in unique_q_k10) {
  subset_data <- electr_2022 %>%
    filter(q_k10 == value) %>%
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
    scale_fill_manual(values = pie_colors4) +
    facet_wrap(~q_7_1, ncol = 3) 
  
  ggsave(here("Output", paste0("pie_elec_", gsub(" ", "_", value), ".png")), plot = pie_chart, width = 9, height = 6, units = "in", dpi = 300)
}

# % of households reporting having had sufficient water for drinking -----------

wat_2022 <- msna_2022 %>%
  filter(!is.na(q_11_1)) %>%
  mutate()

unique_q_k10 <- unique(wat_2022$q_k10)

for (value in unique_q_k10) {
  subset_data <- wat_2022 %>%
    filter(q_k10 == value) %>%
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

# % of HHs by ability to meet the basic needs ----------------------------------

bn_2022 <- msna_2022 %>%
  filter(!is.na(q_16_2))
unique_q_k10 <- unique(bn_2022$q_k10)

for (value in unique_q_k10) {
  subset_data <- bn_2022 %>%
    filter(q_k10 == value) %>%
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
    scale_fill_manual(values = pie_colors4) +
    facet_wrap(~q_7_1, ncol = 3) 
  
  ggsave(here("Output", paste0("pie_bn_", gsub(" ", "_", value), ".png")), plot = pie_chart, width = 9, height = 6, units = "in", dpi = 300)
}

# Main reason limiting household’s ability to meet their basic needs -----------

limits_2022 <- msna_2022 %>%
  select(id, q_k10, limit, q_7_1) %>%
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
                                     "Loss of remittances"), "Other", limit)
         ) %>%
  filter(!is.na(limit), limit != "Prefer not to answer", limit != "No other Reasons") %>%
  group_by(limit, q_k10, q_7_1) %>%
  summarise(total = sum(ones, na.rm = TRUE),
            .groups = 'drop')  %>%
  group_by(q_7_1, q_k10) %>%
  mutate(percentage = round(total / sum(total) * 100, digits = 1)) %>%
  ungroup()

unique_q_k10 <- unique(safety_2022$q_k10)

for (value in unique_q_k10) {
  plot_data <- filter(limits_2022, q_k10 == value)
  
  bar_chart <- ggplot(plot_data, aes(x = percentage, y = limit, fill = q_7_1)) +
    geom_bar(stat = "identity", position = "dodge", width = 0.7, color = "white") +
    geom_text(aes(label = percentage), position = position_dodge(width = 0.7), hjust = - 0.5, vjust = 0, size = 2) +
    labs(title = "",
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
  
  ggsave(here("Output", paste0("/bar_lim", gsub("/", "_", value), ".png")), bar_chart, width = 9, height = 6)
}

# Access to healthcare ---------------------------------------------------------

health_2022 <- msna_2022 %>%
  filter(!is.na(q_9_4_1)) %>%
  mutate(
    health = ifelse(q_9_4_1 > 0, "Not all members got access", "All members got access")
  ) %>%
  select(health, q_k10, q_7_1)

unique_q_k10 <- unique(health_2022$q_k10)

for (value in unique_q_k10) {
  subset_data <- health_2022 %>%
    filter(q_k10 == value) %>%
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
  
  ggsave(here("Output", paste0("pie_health_", gsub(" ", "_", value), ".png")), plot = pie_chart, width = 9, height = 6, units = "in", dpi = 300)
}

# Household income over the last 3 months --------------------------------------

income_2022 <- msna_2022 %>%
  select(income, q_k10, q_16_4, q_7_1) %>%
  filter(q_16_4 == "Yes")

unique_q_k10 <- unique(income_2022$q_k10)

for (value in unique_q_k10) {
    
    subset_data <- income_2022 %>%
      filter(q_k10 == value)
    
    hist_chart <- ggplot(subset_data, aes(x = factor(q_7_1), y = income)) +
      geom_boxplot(fill = "lightblue", color = "blue") +
      labs(title = "",
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
    
    ggsave(here("Output", paste0("box_income", gsub(" ", "_", value), ".png")), plot = hist_chart, width = 9, height = 6, units = "in", dpi = 300)

}