######################################################################
# Syria Economic Monitoring
# Multi-Sectoral Needs Assessment
# 3_1_conflict
######################################################################

# Presence of areas where women and girls feel unsafe --------------------------

unsafety <- msna %>%
  group_by(q_8_7, year) %>%
  filter(!is.na(q_8_7), q_8_7 != "Prefer not to answer") %>%
  mutate(ones = 1) %>%
  summarise(total = sum(ones, na.rm = TRUE),
            .groups = 'drop') %>%
  group_by(year) %>%
  mutate(percentage = total / sum(total) * 100) %>%
  mutate(percentage = round(percentage, 0)) %>%
  ungroup() 

bar_chart <- ggplot(unsafety, aes(x = year, y = percentage, fill = q_8_7)) +
  geom_bar(stat = "identity") +
  geom_text(aes(label = scales::percent(percentage, scale = 1)),  # Add percentage labels
            position = position_stack(vjust = 0.5),    # Adjust the vertical position of labels
            size = 3,                                   # Set label size
            color = "black",                            # Set label color
            show.legend = FALSE) +
  labs(title = "",
       x = "Location type",
       y = "Percentage of households",
       fill = "") +
  theme_minimal() +
  coord_flip() +
  theme(
    legend.position = "bottom",
    legend.box = "horizontal" 
  ) +
  scale_fill_manual(values = bar_colors)

ggsave(here("Output", "bar_unsaf_girls.png"), bar_chart, width = 10, height = 6)

# Main safety and security concerns in the past 3 months -----------------------

safety <- msna %>%
  select(id, starts_with("safety_"), year, region) %>%
  pivot_longer(cols = starts_with("safety"), names_to = "safety_q", values_to = "safety_r") %>%
  filter(!is.na(safety_r), safety_r != "Don't know/unsure", safety_r != "Dont know", safety_r != "Prefer not to answer") %>%
  mutate(ones = 1,
         safety_r = ifelse(safety_r %in% c("Safety or security concerns related to conflict, i.e. including hostilities, destruction of property, threats, HH members injured/killed",
                                           "Presence of UXO, IEDs, landmines, etc.",
                                           "Mine UXOs",
                                           "Fear of shelling airstrikes",
                                           "Community tensions host IDP etc unsafe neighborhood due to crime",
                                           "Being threatened with violence",
                                           "Suffering from technology facilitated harrassment violence and blackmail",
                                           "Suffering from physical harassment or violence not sexual",
                                           "Suffering from sexual harassment or violence",
                                           "Threat of exploitation and abuse (including of a sexual nature) in the community",
                                           "Tensions between host communities and returnees in areas of return",
                                           "Suffering from verbal harassment",
                                           "Being recruited by armed groups",
                                           "Being killed", "Being robbed", "Being kidnapped",
                                           "Being injured killed by an explosive hazard",
                                           "Being exploited", "Being detained",
                                           "Exploitation due to disability",
                                           "Safety and security issues at home",
                                           "Presence of UXO, IEDs, landmines, etc. around schools"), "Safety concerns related to conflict and violence", safety_r),
         safety_r = ifelse(safety_r %in% c("Potential arrest violence at checkpoint", "Checkpoints", 
                                           "Arbitrary arrest or detention or risk of this happening", 
                                           "Arbitrary arrest, or detention, or risk of this happening"), "Arbitrary arrest, detention, checkpoints", safety_r),
         safety_r = ifelse(safety_r %in% c("Other (please specify)",
                                           "Shelter is unsafe lacks privacy separation doors risk of eviction",
                                           "Shelter is unsafe at risk of collapse",
                                           "Fear of drugs drug usage",
                                           "Engage in hazardous work to generate more income",
                                           "Being sent abroad to find work",
                                           "Being forcibly married",
                                           "Physical and logistic constraints preventing mobility (roads damaged, buildings damaged, etc.)",
                                           "Discrimination on the basis of race political beliefs religion class age sex marital status widow divorced disability",
                                           "Discrimination on the basis of race, political beliefs, religion, class, age, sex, marital status (widow/divorced), disability, etc."), "Other", safety_r),
         safety_r = ifelse(safety_r == "Natural disaster earthquake", "Natural disaster (earthquake)", safety_r)
         ) %>%
  group_by(safety_r, year, region) %>%
  summarise(total = sum(ones, na.rm = TRUE),
            .groups = 'drop') %>%
  group_by(year, region) %>%
  mutate(percentage = round(total / sum(total) * 100, digits = 1)) %>%
  ungroup()

unique_year <- unique(safety$year)

for (value in unique_year) {
  
  subset_data <- safety %>%
    filter(year == value) 
  
  bar_chart <- ggplot(subset_data, aes(x = percentage, y = safety_r, fill = region)) +
    geom_bar(stat = "identity", position = "dodge", width = 0.7, color = "white") +
    geom_text(aes(label = percentage), position = position_dodge(width = 0.7), hjust = - 0.5, vjust = 0, size = 2) +
    labs(title = value,
         x = "Percentage of Households",
         y = "Security Concern") +
    scale_x_continuous(limits = c(0, max(subset_data$percentage) + (max(subset_data$percentage)/10))) +
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
  
  ggsave(here("Output", paste0("bar_sec_", gsub(" ", "_", value), ".png")), bar_chart, width = 6, height = 7)
}

# Levels of stress experienced by a hh member ----------------------------------

stress <- msna %>%
    mutate(stress = ifelse(q_8_5_0 == "Yes" | q_8_5_1 == "Yes" | q_8_5_2 == "Yes" | q_8_5_3 == "Yes", "Yes", "No"),
           stress = ifelse((q_8_5_0 == "No" & is.na(stress)) | (q_8_5_1 == "No" & is.na(stress)) | (q_8_5_2 == "No" & is.na(stress)) | (q_8_5_3 == "No" & is.na(stress)), "No", stress),
           ones = 1) %>%
    filter(!is.na(stress)) %>%
    group_by(stress, q_7_1, year) %>%
    summarise(total = sum(ones, na.rm = TRUE),
              .groups = 'drop')

unique_year <- unique(stress$year)

for (value in unique_year) {
  
  subset_data <- stress %>%
    filter(year == value) %>%
    transform(percentage = total / tapply(total, q_7_1, sum)[q_7_1]*100) %>%
    mutate(percentage = round(percentage, 0))

  bar_chart <- ggplot(subset_data, aes(x = q_7_1, y = percentage, fill = stress)) +
    geom_bar(stat = "identity") +
    geom_text(aes(label = scales::percent(percentage, scale = 1)),
              position = position_stack(vjust = 0.5),   
              size = 3,                                   
              color = "black",                            
              show.legend = FALSE) +
    labs(title = value,
         x = "Population type",
         y = "Percentage of households",
         fill = "") +
    theme_minimal() +
    coord_flip() +
    theme(
      axis.text.y = element_text(size = 8),
      axis.text.x = element_text(size = 10),
      axis.title = element_text(size = 12, face = "bold"),
      plot.title = element_text(size = 16, face = "bold"),
      panel.grid.major.y = element_blank(),
      panel.grid.minor.y = element_blank(),
      panel.grid.major.x = element_line(color = "lightgray", size = 0.5),
      panel.grid.minor.x = element_blank(),
      legend.position = "bottom",
      legend.box = "horizontal" 
    ) +
    scale_fill_manual(values = bar_colors)
  
  ggsave(here("Output", paste0("bar_stress_", gsub(" ", "_", value), ".png")), bar_chart, width = 6, height = 6.5)

}

# Levels of stress experienced by a hh member (Region) -------------------------

stress <- msna %>%
  mutate(stress = ifelse(q_8_5_0 == "Yes" | q_8_5_1 == "Yes" | q_8_5_2 == "Yes" | q_8_5_3 == "Yes", "Yes", "No"),
         stress = ifelse((q_8_5_0 == "No" & is.na(stress)) | (q_8_5_1 == "No" & is.na(stress)) | (q_8_5_2 == "No" & is.na(stress)) | (q_8_5_3 == "No" & is.na(stress)), "No", stress),
         ones = 1) %>%
  filter(!is.na(stress)) %>%
  group_by(stress, region, year) %>%
  summarise(total = sum(ones, na.rm = TRUE),
            .groups = 'drop')

unique_year <- unique(stress$year)

for (value in unique_year) {
  
  subset_data <- stress %>%
    filter(year == value) %>%
    transform(percentage = total / tapply(total, region, sum)[region]*100) %>%
    mutate(percentage = round(percentage, 0))
  
  bar_chart <- ggplot(subset_data, aes(x = region, y = percentage, fill = stress)) +
    geom_bar(stat = "identity") +
    geom_text(aes(label = scales::percent(percentage, scale = 1)),
              position = position_stack(vjust = 0.5),   
              size = 3,                                   
              color = "black",                            
              show.legend = FALSE) +
    labs(title = value,
         x = "Population type",
         y = "Percentage of households",
         fill = "") +
    theme_minimal() +
    coord_flip() +
    theme(
      axis.text.y = element_text(size = 8),
      axis.text.x = element_text(size = 10),
      axis.title = element_text(size = 12, face = "bold"),
      plot.title = element_text(size = 16, face = "bold"),
      panel.grid.major.y = element_blank(),
      panel.grid.minor.y = element_blank(),
      panel.grid.major.x = element_line(color = "lightgray", size = 0.5),
      panel.grid.minor.x = element_blank(),
      legend.position = "bottom",
      legend.box = "horizontal" 
    ) +
    scale_fill_manual(values = bar_colors)
  
  ggsave(here("Output", paste0("bar_stress_r", gsub(" ", "_", value), ".png")), bar_chart, width = 6, height = 6.5)
  
}

