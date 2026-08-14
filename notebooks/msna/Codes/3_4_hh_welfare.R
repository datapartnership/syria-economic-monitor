######################################################################
# Syria Economic Monitoring
# Multi-Sectoral Needs Assessment
# 3_4_hh_welfare
######################################################################

# % of HHs by number of hours of access to electricity -------------------------

electr <- msna %>%
  filter(!is.na(q_15_1)) %>%
  mutate(q_15_1 = factor(q_15_1, levels = c("0 hours per day", "1-2 hours per day", "3-8 hours per day", "9-15 hours per day", "16+ hours per day")))

  # Pop type
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
  
  # Region
    subset_data <- electr %>%
      mutate(region = ifelse(year == 2022 & region == "NES", "NES - 2022", region),
             region = ifelse(year == 2022 & region == "NWS", "NWS - 2022", region),
             region = ifelse(year == 2023 & region == "NES", "NES - 2023", region),
             region = ifelse(year == 2023 & region == "NWS", "NWS - 2023", region)) %>%
      group_by(region, q_15_1) %>%
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
      facet_wrap(~region, ncol = 2) 
    
    ggsave(here("Output", paste0("pie_elec_r.png")), plot = pie_chart, width = 9, height = 6, units = "in", dpi = 300)

# Challenges with wastewater disposal (2023) -----------------------------------

waste <- sample_2023 %>%
  select(id, q_7_1, starts_with("waste_"), region) %>%
  pivot_longer(cols = starts_with("waste_"), names_to = "waste_q", values_to = "q_10_4_e") %>%
  filter(q_10_4_e != "Prefer not to answer", q_10_4_e != "Dont know") %>%
  mutate(id = id,
         ones = 1,
         q_10_4_e = ifelse(q_10_4_e %in% c("The toilet bathing site is not safe no lock bolt ",
                                           "The toilet bathing site is not safe no light",
                                           "It is not safe for children",
                                           "It is not safe bothered while in the toilet bathing site",
                                           "It is not safe bothered on the way to the toilet bathing site",
                                           "The toilet bathing site is not safe no lock bolt"),
                           "It's not safe", q_10_4_e),
         q_10_4_e = ifelse(q_10_4_e %in% c("Lack of privacy no separation in toliets  between men and women",
                                           "Lack of privacy no door"), "Lack of privacy", q_10_4_e),
         q_10_4_e = ifelse(q_10_4_e %in% c("Toilets located in hidden not visible area",
                                           "No toilet is avaiblable",
                                           "Lack of ability to get to the toilet without assistance",
                                           "Difficulties of elderly people and PWD to access toilets without assistance"), "No access or availability", q_10_4_e),
         q_10_4_e = ifelse(q_10_4_e %in% c("The toilt has no handwashing station",
                                           "Septic tank not emptied due to unavailability of desludging service",
                                           "Pipes blocked inside the house",
                                           "Not enough facilities too crowded damaged",
                                           "Connection to sewage blocked",
                                           "Sewage overflowing in the neighbourhood",
                                           "no possible to dispose of diapers mentrsual materials etc"), "Lack of functioning infraestructure", q_10_4_e)
         ) 
    
  # Pop type
  waste_pt <- waste %>%
  group_by(q_10_4_e, q_7_1) %>%
  summarise(total = sum(ones, na.rm = TRUE), .groups = 'drop') %>%
  filter(!is.na(q_10_4_e)) %>%
  group_by(q_7_1) %>%
  mutate(percentage = round(total / sum(total) * 100, digits = 1)) %>%
  ungroup()

  bar_chart <- ggplot(waste_pt, aes(x = percentage, y = q_10_4_e, fill = q_7_1)) +
    geom_bar(stat = "identity", position = "dodge", width = 0.7, color = "white") +
    geom_text(aes(label = percentage), position = position_dodge(width = 0.7), hjust = - 0.5, vjust = 0, size = 2) +
    labs(title = "",
         x = "Percentage of Households",
         y = "Challenges") +
    scale_x_continuous(limits = c(0, max(waste_pt$percentage) + (max(waste_pt$percentage)/10))) +
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
  
  ggsave(here("Output", "/bar_cha_waste.png"), bar_chart, width = 7, height = 6)
  
  # Region
  waste_r <- waste %>%
    group_by(q_10_4_e, region) %>%
    summarise(total = sum(ones, na.rm = TRUE), .groups = 'drop') %>%
    filter(!is.na(q_10_4_e)) %>%
    group_by(region) %>%
    mutate(percentage = round(total / sum(total) * 100, digits = 1)) %>%
    ungroup()
  
  bar_chart <- ggplot(waste_r, aes(x = percentage, y = q_10_4_e, fill = region)) +
    geom_bar(stat = "identity", position = "dodge", width = 0.7, color = "white") +
    geom_text(aes(label = percentage), position = position_dodge(width = 0.7), hjust = - 0.5, vjust = 0, size = 2) +
    labs(title = "",
         x = "Percentage of Households",
         y = "Challenges") +
    scale_x_continuous(limits = c(0, max(waste_r$percentage) + (max(waste_r$percentage)/10))) +
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
  
  ggsave(here("Output", "/bar_cha_waste_r_.png"), bar_chart, width = 7, height = 6)

# Type of toilet facility (2023) -----------------------------------------------
  
  toilet <- sample_2023 %>%
    select(id, q_7_1, q_10_4_g, region) %>%
    mutate(id = id,
           ones = 1,
           q_10_4_g = ifelse(q_10_4_g %in% c("Plastic Bag",
                                             "Bucket",
                                             "Composting toilet",
                                             "Hanging toilet/hanging latrine",
                                             "Flush/pour flush to don't know where"), "Other", q_10_4_g)
    ) 
  
  # Pop type
  toilet_pt <- toilet %>%
    group_by(q_10_4_g, q_7_1) %>%
    summarise(total = sum(ones, na.rm = TRUE), .groups = 'drop') %>%
    filter(!is.na(q_10_4_g)) %>%
    group_by(q_7_1) %>%
    mutate(percentage = round(total / sum(total) * 100, digits = 1)) %>%
    ungroup()
  
  bar_chart <- ggplot(toilet_pt, aes(x = percentage, y = q_10_4_g, fill = q_7_1)) +
    geom_bar(stat = "identity", position = "dodge", width = 0.7, color = "white") +
    geom_text(aes(label = percentage), position = position_dodge(width = 0.7), hjust = - 0.5, vjust = 0, size = 2) +
    labs(title = "",
         x = "Percentage of Households",
         y = "Toilet Type") +
    scale_x_continuous(limits = c(0, max(toilet_pt$percentage) + (max(toilet_pt$percentage)/10))) +
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
  
  ggsave(here("Output", "/bar_toilet.png"), bar_chart, width = 7, height = 6)
  
  # Region
  toilet_r <- toilet %>%
    group_by(q_10_4_g, region) %>%
    summarise(total = sum(ones, na.rm = TRUE), .groups = 'drop') %>%
    filter(!is.na(q_10_4_g)) %>%
    group_by(region) %>%
    mutate(percentage = round(total / sum(total) * 100, digits = 1)) %>%
    ungroup()
  
  bar_chart <- ggplot(toilet_r, aes(x = percentage, y = q_10_4_g, fill = region)) +
    geom_bar(stat = "identity", position = "dodge", width = 0.7, color = "white") +
    geom_text(aes(label = percentage), position = position_dodge(width = 0.7), hjust = - 0.5, vjust = 0, size = 2) +
    labs(title = "",
         x = "Percentage of Households",
         y = "Toilet Type") +
    scale_x_continuous(limits = c(0, max(toilet_r$percentage) + (max(toilet_r$percentage)/10))) +
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
  
  ggsave(here("Output", "/bar_toilet_r.png"), bar_chart, width = 7, height = 6)
  
  
# Type of garbage disposal (2023) ----------------------------------------------
  
  garbage <- sample_2023 %>%
    select(id, q_7_1, q_10_4_h, region) %>%
    filter(q_10_4_h != "Prefer not to answer", q_10_4_h != "Don’t know/unsure") %>%
    mutate(ones = 1,
           q_10_4_h = ifelse(q_10_4_h == "Garbage disposed of by household to a dumping location", "Dumping location", q_10_4_h),
           q_10_4_h = ifelse(q_10_4_h == "Public garbage collection free (or Nominal Fees)", "Public collection free / Nominal Fees)", q_10_4_h))
  
  # Pop type
  garbage_pt <- garbage %>%
    group_by(q_10_4_h, q_7_1) %>%
    summarise(total = sum(ones, na.rm = TRUE), .groups = 'drop') %>%
    filter(!is.na(q_10_4_h)) %>%
    group_by(q_7_1) %>%
    mutate(percentage = round(total / sum(total) * 100, digits = 1)) %>%
    ungroup()
  
  bar_chart <- ggplot(garbage_pt, aes(x = percentage, y = q_10_4_h, fill = q_7_1)) +
    geom_bar(stat = "identity", position = "dodge", width = 0.7, color = "white") +
    geom_text(aes(label = percentage), position = position_dodge(width = 0.7), hjust = - 0.5, vjust = 0, size = 2) +
    labs(title = "",
         x = "Percentage of Households",
         y = "Disposal Type") +
    scale_x_continuous(limits = c(0, max(garbage_pt$percentage) + (max(garbage_pt$percentage)/10))) +
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
  
  ggsave(here("Output", "/bar_disposal.png"), bar_chart, width = 7, height = 6)
  
  # Region
  garbage_r <- garbage %>%
    group_by(q_10_4_h, region) %>%
    summarise(total = sum(ones, na.rm = TRUE), .groups = 'drop') %>%
    filter(!is.na(q_10_4_h)) %>%
    group_by(region) %>%
    mutate(percentage = round(total / sum(total) * 100, digits = 1)) %>%
    ungroup()
  
  bar_chart <- ggplot(garbage_r, aes(x = percentage, y = q_10_4_h, fill = region)) +
    geom_bar(stat = "identity", position = "dodge", width = 0.7, color = "white") +
    geom_text(aes(label = percentage), position = position_dodge(width = 0.7), hjust = - 0.5, vjust = 0, size = 2) +
    labs(title = "",
         x = "Percentage of Households",
         y = "Disposal Type") +
    scale_x_continuous(limits = c(0, max(garbage_r$percentage) + (max(garbage_r$percentage)/10))) +
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
  
  ggsave(here("Output", "/bar_disposal_r.png"), bar_chart, width = 7, height = 6)
  
# % of HHs reported access to nutrition services in past 3m (2023) -------------

nutri <- sample_2023 %>%
  mutate(
    nutrition_3m = ifelse(nutrition_3m == "Dont know", NA, nutrition_3m),
    nutrition_3m = ifelse(nutrition_3m == "No not needed", "No needed", nutrition_3m),
    nutrition_3m = ifelse(nutrition_3m != "No needed" & nutrition_3m != "Yes" &
                          !is.na(nutrition_3m), "No", nutrition_3m),
  ) %>%
  filter(!is.na(nutrition_3m))

  # Pop type
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

  # Region
  subset_data <- nutri %>%
    group_by(region, nutrition_3m) %>%
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
    facet_wrap(~region, ncol = 2) 
  
  ggsave(here("Output", "pie_nut_r_2023.png"), plot = pie_chart, width = 8, height = 6, units = "in", dpi = 300)
  
# % of households reporting having had sufficient water for drinking -----------

wat <- msna %>%
  filter(!is.na(q_11_1)) %>%
  mutate()

unique_year <- unique(wat$year)

  # Pop type
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

  # Region
  wat_r <- wat %>%
    mutate(region = ifelse(year == 2022 & region == "NES", "NES - 2022", region),
           region = ifelse(year == 2022 & region == "NWS", "NWS - 2022", region),
           region = ifelse(year == 2023 & region == "NES", "NES - 2023", region),
           region = ifelse(year == 2023 & region == "NWS", "NWS - 2023", region))
    
  subset_data <- wat_r %>%
    group_by(region, q_11_1) %>%
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
      facet_wrap(~region, ncol = 2) 
    
    ggsave(here("Output", "pie_wat_r.png"), plot = pie_chart, width = 8, height = 6, units = "in", dpi = 300)

# % of HHs by ability to meet the basic needs ----------------------------------

  bn <- msna %>%
    filter(!is.na(q_16_2))
    
  unique_year <- unique(bn$year)

  # Pop type
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
  
  # Region
  subset_data <- bn %>%
    mutate(region = ifelse(year == 2022 & region == "NES", "NES - 2022", region),
           region = ifelse(year == 2022 & region == "NWS", "NWS - 2022", region),
           region = ifelse(year == 2023 & region == "NES", "NES - 2023", region),
           region = ifelse(year == 2023 & region == "NWS", "NWS - 2023", region)) %>%
    group_by(region, q_16_2) %>%
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
      facet_wrap(~region, ncol = 2) 
    
    ggsave(here("Output", "pie_bn_r.png"), plot = pie_chart, width = 9, height = 6, units = "in", dpi = 300)

# Main reason limiting household’s ability to meet their basic needs -----------

limits <- msna %>%
  select(id, year, limit, q_7_1, region) %>%
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
  filter(!is.na(limit), limit != "Prefer not to answer", limit != "No other Reasons") 

  # Pop type
  limits_pt <- limits %>%
    group_by(limit, year, q_7_1) %>%
    summarise(total = sum(ones, na.rm = TRUE),
              .groups = 'drop')  %>%
    group_by(q_7_1, year) %>%
    mutate(percentage = round(total / sum(total) * 100, digits = 1)) %>%
    ungroup()
  
  unique_year <- unique(limits$year)

  for (value in unique_year) {
    plot_data <- filter(limits_pt, year == value)
    
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

  # Region
  limits_r <- limits %>%
    group_by(limit, year, region) %>%
    summarise(total = sum(ones, na.rm = TRUE),
              .groups = 'drop')  %>%
    group_by(region, year) %>%
    mutate(percentage = round(total / sum(total) * 100, digits = 1)) %>%
    ungroup()
  
  unique_year <- unique(limits$year)
  
  for (value in unique_year) {
    plot_data <- filter(limits_r, year == value)
    
    bar_chart <- ggplot(plot_data, aes(x = percentage, y = limit, fill = region)) +
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
    
    ggsave(here("Output", paste0("/bar_lim_r_", gsub("/", "_", value), ".png")), bar_chart, width = 7.5, height = 6)
  }
  
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

# % of individuals in age to attend school that attended school ----------------

edu1 <- msna_i %>%
  filter(!is.na(edu_1))

unique_year <- unique(edu1$year)

  # Pop type
  for (value in unique_year) {
    subset_data <- edu1 %>%
      filter(year == value) %>%
      group_by(q_7_1, edu_1) %>%
      summarise(n = n()) %>%
      mutate(percentage = round(n / sum(n) * 100, 1)) %>% 
      mutate(csum = rev(cumsum(rev(percentage))), 
             pos = percentage/2 + lead(csum, 1),
             pos = if_else(is.na(pos), percentage/2, pos))
    
    pie_chart <- ggplot(subset_data, aes(x = "", y = percentage, fill = fct_inorder(edu_1))) +
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
    
    ggsave(here("Output", paste0("pie_edu1_", gsub(" ", "_", value), ".png")), plot = pie_chart, width = 9, height = 6, units = "in", dpi = 300)
  }

  # Region
  subset_data <- edu1 %>%
    mutate(region = ifelse(year == 2022 & region == "NES", "NES - 2022", region),
           region = ifelse(year == 2022 & region == "NWS", "NWS - 2022", region),
           region = ifelse(year == 2023 & region == "NES", "NES - 2023", region),
           region = ifelse(year == 2023 & region == "NWS", "NWS - 2023", region)) %>%
    group_by(region, edu_1) %>%
    summarise(n = n()) %>%
    mutate(percentage = round(n / sum(n) * 100, 1)) %>% 
    mutate(csum = rev(cumsum(rev(percentage))), 
           pos = percentage/2 + lead(csum, 1),
           pos = if_else(is.na(pos), percentage/2, pos))
  
  pie_chart <- ggplot(subset_data, aes(x = "", y = percentage, fill = fct_inorder(edu_1))) +
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
    facet_wrap(~region, ncol = 2) 
  
  ggsave(here("Output", "pie_edu1_r.png"), plot = pie_chart, width = 9, height = 6, units = "in", dpi = 300)

# Main reason not to access formal education -----------------------------------

edu2 <- msna_i %>%
  mutate(id = id,
         ones = 1,
         edu_3 = ifelse(edu_3 %in% c("Other (specify)",
                                     "Joined military or armed group",
                                     "School is not gender segregated",
                                     "Child/ren too young"), "Other", edu_3),
         edu_3 = ifelse(edu_3 %in% c("Can't afford for children to go/Child/ren working to support HH",
                                     "Child/ren working to support the household",
                                     "Household inability to afford child education"),
                        "Can't afford, child/ren working to support HH", edu_3),
         edu_3 = ifelse(edu_3 == "Child/ren don't want to go to school", "Child/ren don’t want to go to school", edu_3),
         edu_3 = ifelse(edu_3 == "Scared of going or being in school (attacks, violence, danger, harassment, or bullying)", "Scared of going or being in school", edu_3),
         edu_3 = ifelse(edu_3 == "There is no school for child's age-group", "There is no school for child’s age-group", edu_3),
         edu_3 = ifelse(edu_3 %in% c("Dropped out after marriage and/or pregnancy",
                                     "Early marriage/early pregnancies (before 18 years of age)"),
                        "Marriage and/or pregnancy", edu_3),
         edu_3 = ifelse(edu_3 %in% c("Poor water, sanitation and hygiene conditions in schools (lack of latrines, access to (clean) water, etc.)",
                                     "The physical condition of the school is not safe/not good enough",
                                     "The physical condition of the school is not safe/not good enough (including WASH facilities)",
                                     "School not able to accommodate child/ren's disabilities", 
                                     "School not able to accommodate child/ren’s disabilities"),
                        "Poor physical and wash facilities", edu_3)
         ) %>%
  filter(!is.na(edu_3), 
         edu_3 != "Don’t know/unsure", 
         edu_3 != "Prefer not to answer" , 
         edu_3 != "No other reasons") 
  
  # Pop type
  edu2_pt <- edu2 %>%
  group_by(edu_3, year, q_7_1) %>%
  summarise(total = sum(ones, na.rm = TRUE),
            .groups = 'drop')  %>%
  group_by(q_7_1, year) %>%
  mutate(percentage = round(total / sum(total) * 100, digits = 1)) %>%
  ungroup()

unique_year <- unique(edu2_pt$year)

for (value in unique_year) {
  plot_data <- filter(edu2_pt, year == value)
  
  bar_chart <- ggplot(plot_data, aes(x = percentage, y = edu_3, fill = q_7_1)) +
    geom_bar(stat = "identity", position = "dodge", width = 0.7, color = "white") +
    geom_text(aes(label = percentage), position = position_dodge(width = 0.7), hjust = - 0.5, vjust = 0, size = 2) +
    labs(title = value,
         x = "Percentage of individuals",
         y = "Main Reason") +
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
  
  ggsave(here("Output", paste0("/bar_edu3", gsub("/", "_", value), ".png")), bar_chart, width = 7, height = 8)
}

  # Region
  edu2_r <- edu2 %>%
    group_by(edu_3, year, region) %>%
    summarise(total = sum(ones, na.rm = TRUE),
              .groups = 'drop')  %>%
    group_by(region, year) %>%
    mutate(percentage = round(total / sum(total) * 100, digits = 1)) %>%
    ungroup()
  
  unique_year <- unique(edu2_r$year)
  
  for (value in unique_year) {
    plot_data <- filter(edu2_r, year == value)
    
    bar_chart <- ggplot(plot_data, aes(x = percentage, y = edu_3, fill = region)) +
      geom_bar(stat = "identity", position = "dodge", width = 0.7, color = "white") +
      geom_text(aes(label = percentage), position = position_dodge(width = 0.7), hjust = - 0.5, vjust = 0, size = 2) +
      labs(title = value,
           x = "Percentage of individuals",
           y = "Main Reason") +
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
    
    ggsave(here("Output", paste0("/bar_edu3_r_", gsub("/", "_", value), ".png")), bar_chart, width = 7, height = 8)
  }

# Main reason limiting household’s ability to access healthcare (2023) ---------

barr <- sample_2023 %>%
  select(id, year, barr_health, q_7_1, region) %>%
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
                                                 "Could not afford transportation to health facility"), "Could not afford related costs", barr_health),
         barr_health = ifelse(barr_health == "Specific medicine treatment or service needed unavailable", "Specific treatment or service unavailable", barr_health)
  ) %>%
  filter(!is.na(barr_health), barr_health != "Dont know", barr_health != "Prefer not to answer") 
  
  # Pop type
  barr_pt <- barr %>%
  group_by(barr_health, year, q_7_1) %>%
  summarise(total = sum(ones, na.rm = TRUE),
            .groups = 'drop')  %>%
  group_by(q_7_1, year) %>%
  mutate(percentage = round(total / sum(total) * 100, digits = 1)) %>%
  ungroup()

  bar_chart <- ggplot(barr_pt, aes(x = percentage, y = barr_health, fill = q_7_1)) +
    geom_bar(stat = "identity", position = "dodge", width = 0.7, color = "white") +
    geom_text(aes(label = percentage), position = position_dodge(width = 0.7), hjust = - 0.5, vjust = 0, size = 2) +
    labs(title = ,
         x = "Percentage of Households",
         y = "Limitation") +
    scale_x_continuous(limits = c(0, max(barr_pt$percentage) + (max(barr_pt$percentage)/10))) +
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
  
  ggsave(here("Output", "/bar_barr_2023.png"), bar_chart, width = 7, height = 6)

  # Region
  barr_r <- barr %>%
    group_by(barr_health, year, region) %>%
    summarise(total = sum(ones, na.rm = TRUE),
              .groups = 'drop')  %>%
    group_by(region, year) %>%
    mutate(percentage = round(total / sum(total) * 100, digits = 1)) %>%
    ungroup()
  
  bar_chart <- ggplot(barr_r, aes(x = percentage, y = barr_health, fill = region)) +
    geom_bar(stat = "identity", position = "dodge", width = 0.7, color = "white") +
    geom_text(aes(label = percentage), position = position_dodge(width = 0.7), hjust = - 0.5, vjust = 0, size = 2) +
    labs(title = ,
         x = "Percentage of Households",
         y = "Limitation") +
    scale_x_continuous(limits = c(0, max(barr_r$percentage) + (max(barr_r$percentage)/10))) +
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
  
  ggsave(here("Output", "/bar_barr_r_2023.png"), bar_chart, width = 7, height = 6)

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

