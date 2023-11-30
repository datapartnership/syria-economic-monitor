######################################################################
# Syria Economic Monitoring
# Multi-Sectoral Needs Assesment
# 3_2_aid
######################################################################

# % of HH having received aid in the 3 months ----------------------------------

  aid <- msna %>%
    group_by(year, q_k9, q_7_1) %>%
    summarise(
      per_aid_hh = mean(q_17_1 == "Yes", na.rm = TRUE) * 100,
      .groups = 'drop'
    ) %>%
    mutate(
      subdis_code = str_split(q_k9, " - ", simplify = TRUE)[, 1],
      subdis_name = str_split(q_k9, " - ", simplify = TRUE)[, 2],
      ADM3_PCODE = subdis_code) %>%
    select(ADM3_PCODE, subdis_code, subdis_name, year, per_aid_hh, q_7_1)
  
  unique_year <- unique(aid$year)
  unique_pop <- unique(aid$q_7_1)
  
  for (i in unique_pop) {
    for (j in unique_year) {
    
    subset_data <- aid %>% filter(q_7_1 == i, year == j)
    pop_map <- left_join(syria_shp, subset_data, by = "ADM3_PCODE")
    merged_data <- left_join(pop_map, earthquake, by = "ADM3_PCODE") %>%
      mutate(earthquake = ifelse(is.na(earthquake), 0, 1))
    
    pop_map <- ggplot(merged_data) +
      geom_sf(aes(fill = per_aid_hh), color = "black") +
      geom_sf(data = merged_data[merged_data$earthquake == 1, ], 
              fill = "transparent", color = "red", size = 5, alpha = 0) + # Set alpha to 0 for transparency
      scale_fill_gradient(low = "lightblue", high = "darkblue", na.value = "white") +
      ggtitle(i) +
      theme_minimal() +
      theme(legend.position = "right") +
      labs(fill = "Percentage of HHs")
    
    ggsave(here("Output", paste0("/aid_", i, "_", j, ".png")), plot = pop_map, width = 7, height = 6, units = "in", dpi = 300)
    }
  }
  
  
# Aid satisfaction -------------------------------------------------------------

aid <- msna %>%
  filter(!is.na(q_17_3)) 

unique_year <- unique(aid$year)

for (value in unique_year) {
  subset_data <- aid %>%
    filter(year == value) %>%
    group_by(q_7_1, q_17_3) %>%
    summarise(n = n()) %>%
    mutate(percentage = round(n / sum(n) * 100, 1)) %>% 
    mutate(csum = rev(cumsum(rev(percentage))), 
           pos = percentage/2 + lead(csum, 1),
           pos = if_else(is.na(pos), percentage/2, pos))

  pie_chart <- ggplot(subset_data, aes(x = "", y = percentage, fill = fct_inorder(q_17_3))) +
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

  ggsave(here("Output", paste0("pie_aid_sat_", gsub(" ", "_", value), ".png")), plot = pie_chart, width = 9, height = 6, units = "in", dpi = 300)
}

# Priority needs ---------------------------------------------------------------

needs <- msna %>%
  select(id, q_7_1, q_16_1_1, year) %>%
  rename(need = q_16_1_1) %>%
  filter(need != "All needs are met") %>%
  mutate(id = id,
         ones = 1,
         need = ifelse(need %in% c("Dont know", "Don't know/unsure", "Prefer not to answer"), NA, need),
         need = ifelse(need %in% c("Food", "Nutrition nutrition services"), "Food/nutrition", need),
         need = ifelse(need %in% c("Access to safe water", "Electricity provisio internet",
                                   "Electricity provision", "Sanitation", "Waste disposal"), "WASH and electricity", need),
         need = ifelse(need %in% c("Access to community centers and safe spaces for women and girls",
                                   "NFI items", "NFI items (e.g. clothing, blankets, cooking material, sanitation items, fuel and school equipment)",
                                   "Shelter assistance", "Shelter assistance (emergency shelter provision, shelter repairs, rent subsidies)"), "Shelter and NFI items", need),
         need = ifelse(need %in% c("Disability-specific needs (medical equipment, medicine, services)",
                                   "Disability specific needs medical equipment medicine services assistive devices to support access to work or education",
                                   "Health services", "Medicine",
                                   "Mental health and psychosocial support services", 
                                   "Mental health and psychosocial support services (e.g. structured group activities in a safe space, invididual or group counseling, etc.)"), "Health and medical services", need),
         need = ifelse(need %in% c("Education services", "Formal education",
                                   "GBV post services", "Legal advice including civil documentation and Housing Land and Property",
                                   "Legal advice including civil documentation and Housing, Land and Property",
                                   "Livelihood opportunities ability to work",
                                   "Livelihood opportunities/inability to work",
                                   "Non formal education",
                                   "Phone data communication", 
                                   "Phone/data/communication",
                                   "Reintegration services", "Risk awareness and clearance (Mine Action)",
                                   "Risk awareness and clearance Mine Action",
                                   "Technical and vocational training",
                                   "Technical and vocational trainings"), "Other", need)
  ) %>%
  group_by(need, q_7_1, year) %>%
  summarise(total = sum(ones, na.rm = TRUE), .groups = 'drop') %>%
  filter(!is.na(need)) %>%
  group_by(q_7_1, year) %>%
  mutate(percentage = round(total / sum(total) * 100, digits = 1)) %>%
  ungroup()

unique_year <- unique(needs$year)

for (value in unique_year) {
  plot_data <- filter(needs, year == value)
  
  bar_chart <- ggplot(plot_data, aes(x = percentage, y = need, fill = q_7_1)) +
    geom_bar(stat = "identity", position = "dodge", width = 0.7, color = "white") +
    geom_text(aes(label = percentage), position = position_dodge(width = 0.7), hjust = - 0.5, vjust = 0, size = 2) +
    labs(title = value,
         x = "Percentage of Households",
         y = "Need") +
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
  
  ggsave(here("Output", paste0("/bar_need", gsub("/", "_", value), ".png")), bar_chart, width = 7.5, height = 6)
}

# GoS-issued documentation -----------------------------------------------------
