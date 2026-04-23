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
  
# Aid kind by region and pop type (2023) ---------------------------------------
  
  # Pop type
  aid_k <- msna %>%
    select(id, q_7_1, starts_with("aid_"), year) %>%
    pivot_longer(cols = starts_with("aid_"), names_to = "aid_q", values_to = "aid_kind") %>%
    mutate(id = id,
           ones = 1,
           aid_kind = ifelse(aid_kind == "Services e g healthcare education nutrition", "Public services", aid_kind),
           aid_kind = ifelse(aid_kind == "Construction rehabilitation of infrastructure water points latrines roads etc", "Construction of infraestructure", aid_kind),
           aid_kind = ifelse(aid_kind == "Prefer not to answer", NA, aid_kind)
    ) %>%
    filter(year == 2023, !is.na(aid_kind)) %>%
    group_by(aid_kind, q_7_1) %>%
    summarise(total = sum(ones, na.rm = TRUE), .groups = 'drop') %>%
    group_by(q_7_1) %>%
    mutate(percentage = round(total / sum(total) * 100, digits = 1)) %>%
    ungroup()
    
    bar_chart <- ggplot(aid_k, aes(x = percentage, y = aid_kind, fill = q_7_1)) +
      geom_bar(stat = "identity", position = "dodge", width = 0.7, color = "white") +
      geom_text(aes(label = percentage), position = position_dodge(width = 0.7), hjust = - 0.5, vjust = 0, size = 2) +
      labs(title = "",
           x = "Percentage of Households",
           y = "Aid Kind") +
      scale_x_continuous(limits = c(0, max(aid_k$percentage) + (max(aid_k$percentage)/10))) +
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
    
    ggsave(here("Output", "/bar_aidk_2023.png"), bar_chart, width = 7, height = 6)
    
    # Region
    aid_k <- msna %>%
      select(id, region, starts_with("aid_"), year) %>%
      pivot_longer(cols = starts_with("aid_"), names_to = "aid_q", values_to = "aid_kind") %>%
      mutate(id = id,
             ones = 1,
             aid_kind = ifelse(aid_kind == "Services e g healthcare education nutrition", "Public services", aid_kind),
             aid_kind = ifelse(aid_kind == "Construction rehabilitation of infrastructure water points latrines roads etc", "Construction of infraestructure", aid_kind),
             aid_kind = ifelse(aid_kind == "Prefer not to answer", NA, aid_kind)
      ) %>%
      filter(year == 2023, !is.na(aid_kind)) %>%
      group_by(aid_kind, region) %>%
      summarise(total = sum(ones, na.rm = TRUE), .groups = 'drop') %>%
      group_by(region) %>%
      mutate(percentage = round(total / sum(total) * 100, digits = 1)) %>%
      ungroup()
    
    bar_chart <- ggplot(aid_k, aes(x = percentage, y = aid_kind, fill = region)) +
      geom_bar(stat = "identity", position = "dodge", width = 0.7, color = "white") +
      geom_text(aes(label = percentage), position = position_dodge(width = 0.7), hjust = - 0.5, vjust = 0, size = 2) +
      labs(title = "",
           x = "Percentage of Households",
           y = "Aid Kind") +
      scale_x_continuous(limits = c(0, max(aid_k$percentage) + (max(aid_k$percentage)/10))) +
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
    
    ggsave(here("Output", "/bar_aidk_r_2023.png"), bar_chart, width = 7, height = 6)
  
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

# Priority needs by pop type and region ----------------------------------------

  needs <- msna %>%
    select(id, q_7_1, q_16_1_1, year, region) %>%
    rename(need = q_16_1_1) %>%
    filter(need != "All needs are met") %>%
    mutate(id = id,
           ones = 1,
           need = ifelse(need %in% c("Dont know", "Don't know/unsure", "Prefer not to answer"), NA, need),
           need = ifelse(need %in% c("Food", "Nutrition nutrition services"), "Food/nutrition", need),
           need = ifelse(need %in% c("Access to safe water", "Sanitation", "Waste disposal"), "WASH access", need),
           need = ifelse(need %in% c("Electricity provisio internet", "Electricity provision"), "Electricity provision", need),
           need = ifelse(need %in% c("Education services", "Formal education", "Non formal education"), 
                         "Education access", need),
           need = ifelse(need %in% c("NFI items", "NFI items (e.g. clothing, blankets, cooking material, sanitation items, fuel and school equipment)"),
                         "NFI items", need),
           need = ifelse(need %in% c("Shelter assistance", "Shelter assistance (emergency shelter provision, shelter repairs, rent subsidies)"), "Shelter assistance", need),
           need = ifelse(need %in% c("Livelihood opportunities ability to work",
                                     "Livelihood opportunities/inability to work",
                                     "Technical and vocational training",
                                     "Technical and vocational trainings"), "Work related", need), 
           need = ifelse(need %in% c("Disability-specific needs (medical equipment, medicine, services)",
                                     "Disability specific needs medical equipment medicine services assistive devices to support access to work or education",
                                     "Health services", "Medicine",
                                     "Mental health and psychosocial support services",
                                     "Mental health and psychosocial support services (e.g. structured group activities in a safe space, invididual or group counseling, etc.)"),
                                     "Health and medical services", need),
           need = ifelse(need %in% c("Risk awareness and clearance (Mine Action)",
                                     "Risk awareness and clearance Mine Action",
                                     "Access to community centers and safe spaces for women and girls",
                                     "GBV post services", "Phone data communication",
                                     "Phone/data/communication"), "Other", need),
           need = ifelse(need %in% c("Legal advice including civil documentation and Housing Land and Property",
                                     "Legal advice including civil documentation and Housing, Land and Property",
                                     "Reintegration services"), "Legal and reintegration assistance", need)
    ) 

  # Pop type
  needs_pt <- needs %>%
    group_by(need, q_7_1, year) %>%
    summarise(total = sum(ones, na.rm = TRUE), .groups = 'drop') %>%
    filter(!is.na(need)) %>%
    group_by(q_7_1, year) %>%
    mutate(percentage = round(total / sum(total) * 100, digits = 1)) %>%
    ungroup()
  
  unique_year <- unique(needs$year)
  
  for (value in unique_year) {
    plot_data <- filter(needs_pt, year == value)
    
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
    
    ggsave(here("Output", paste0("/bar_need", gsub("/", "_", value), ".png")), bar_chart, width = 7, height = 8)
  }
  
  # Region
  needs_r <- needs %>%
    group_by(need, region, year) %>%
    summarise(total = sum(ones, na.rm = TRUE), .groups = 'drop') %>%
    filter(!is.na(need)) %>%
    group_by(region, year) %>%
    mutate(percentage = round(total / sum(total) * 100, digits = 1)) %>%
    ungroup()
  
  unique_year <- unique(needs$year)
  
  for (value in unique_year) {
    plot_data <- filter(needs_r, year == value)
    
    bar_chart <- ggplot(plot_data, aes(x = percentage, y = need, fill = region)) +
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
    
    ggsave(here("Output", paste0("/bar_need_r_", gsub("/", "_", value), ".png")), bar_chart, width = 7, height = 8)
  }
