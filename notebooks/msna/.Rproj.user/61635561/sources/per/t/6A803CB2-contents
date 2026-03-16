######################################################################
# Syria Economic Monitoring
# Multi-Sectoral Needs Assessment
# 3_1_conflict
######################################################################

# Presence of areas where women and girls feel unsafe --------------------------

unsafety_2022 <- msna_2022 %>%
  group_by(q_8_7, q_k10) %>%
  mutate(ones = 1) %>%
  summarise(total = sum(ones, na.rm = TRUE),
            .groups = 'drop') %>%
  filter(!is.na(q_8_7), q_8_7 != "Prefer not to answer")

unsafety_2022 <- transform(unsafety_2022, percentage = total / tapply(total, q_k10, sum)[q_k10]*100) %>%
  mutate(percentage = round(percentage, 0))

bar_chart <- ggplot(unsafety_2022, aes(x = q_k10, y = percentage, fill = q_8_7)) +
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

safety_2022 <- msna_2022 %>%
  select(id, q_16_8, q_k10) %>%
  separate(
    q_16_8, 
    into = c("safety_1", "safety_2", "safety_3", "safety_4", "safety_5"), 
    sep = "; "
  ) %>%
  pivot_longer(cols = starts_with("safety"), names_to = "safety_q", values_to = "safety_r") %>%
  filter(!is.na(safety_r), safety_r != "Don't know/unsure", safety_r != "Prefer not to answer") %>%
  mutate(ones = 1,
         safety_r = ifelse(safety_r %in% c("Discrimination on the basis of race, political beliefs, religion, class, age, sex, marital status (widow/divorced), disability, etc.",
                                           "Discrimination of any sort",
                                           "Other (please specify)",
                                           "Physical and logistic constraints preventing mobility (roads damaged, buildings damaged, etc.)",
                                           "Presence of UXO, IEDs, landmines, etc. around schools",
                                           "Tensions between host communities and returnees in areas of return",
                                           "Safety or security concerns related to displacement",
                                           "Safety or security concerns related to conflict, i.e. including hostilities, destruction of property, threats, HH members injured/killed",
                                           "Threat of exploitation and abuse (including of a sexual nature) in the community",
                                           "Exploitation due to disability",
                                           "Presence of UXO, IEDs, landmines, etc."),
                           "Other", safety_r)) %>%
  group_by(safety_r, q_k10) %>%
  summarise(total = sum(ones, na.rm = TRUE),
            .groups = 'drop') %>%
  group_by(q_k10) %>%
  mutate(percentage = round(total / sum(total) * 100, digits = 1)) %>%
  ungroup()

bar_chart <- ggplot(safety_2022, aes(x = percentage, y = safety_r, fill = q_k10)) +
  geom_bar(stat = "identity", position = "dodge", width = 0.7, color = "white") +
  geom_text(aes(label = percentage), position = position_dodge(width = 0.7), hjust = - 0.5, vjust = 0, size = 2) +
  labs(title = "",
       x = "Percentage of Households",
       y = "Need") +
  scale_x_continuous(limits = c(0, max(safety_2022$percentage) + (max(safety_2022$percentage)/10))) +
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

ggsave(here("Output", "bar_sec.png"), bar_chart, width = 9, height = 6)


# High levels of stress experienced by a hh member ------------------------------

stress_2022 <- msna_2022 %>%
  select(starts_with("q_8_5_"), q_k10, q_7_1) %>%
  mutate(stress = ifelse(q_8_5_0 == "Yes" | q_8_5_1 == "Yes" | q_8_5_2 == "Yes" | q_8_5_3 == "Yes", "Yes", "No"),
         stress = ifelse((q_8_5_0 == "No" & is.na(stress)) | (q_8_5_1 == "No" & is.na(stress)) | (q_8_5_2 == "No" & is.na(stress)) | (q_8_5_3 == "No" & is.na(stress)), "No", stress),
         ones = 1) %>%
  filter(!is.na(stress)) %>%
  group_by(stress, q_k10, q_7_1) %>%
  summarise(total = sum(ones, na.rm = TRUE),
            .groups = 'drop')

unique_q_k10 <- unique(stress_2022$q_k10)

for (value in unique_q_k10) {
  
  subset_data <- stress_2022 %>%
    filter(q_k10 == value) %>%
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
