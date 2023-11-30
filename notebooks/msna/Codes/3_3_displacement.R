######################################################################
# Syria Economic Monitoring
# Multi-Sectoral Needs Assessment
# 3_3_displacement
######################################################################

# If host population, have you ever been displaced? ----------------------------
# Title: Percentage of host population households that have been displaced

displaced <- msna %>%
  filter(!is.na(q_7_2)) %>%
  group_by(year, q_7_2) %>%
  summarise(n = n()) %>%
  mutate(percentage = round(n / sum(n) * 100, 1)) %>% 
  mutate(csum = rev(cumsum(rev(percentage))), 
         pos = percentage/2 + lead(csum, 1),
         pos = if_else(is.na(pos), percentage/2, pos))
  
  pie_chart <- ggplot(displaced, aes(x = "", y = percentage, fill = fct_inorder(q_7_2))) +
    geom_bar(stat = "identity", width = 1, color = "white") +
    coord_polar(theta = "y") +
    geom_label_repel(data = displaced,
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
    facet_wrap(~year, ncol = 2) 
  
  ggsave(here("Output", "pie_hh_dis.png"), plot = pie_chart, width = 8, height = 6, units = "in", dpi = 300)

# Host HHs coming back to their current location after being displaced ---------

  host_date <- msna %>%
    filter(!is.na(q_7_2_1)) %>%
    group_by(year, q_7_2_1) %>%
    summarise(obs = cumsum(n()))
  
  time_chart <- host_date %>%
    ggplot(aes(x = q_7_2_1, y = obs, color = year)) +
    geom_line(size = 1.2) +
    scale_y_continuous(limits = c(0, 100), expand = c(0, 0)) +
    labs(title = "",
         x = "Date",
         y = "Households") +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1),
          axis.title = element_text(face = "bold"),
          plot.title = element_text(hjust = 0.5, size = 16, face = "bold"),
          panel.grid.major = element_line(color = "lightgray", linetype = "dashed"),
          panel.grid.minor = element_blank(),
          axis.line = element_line(color = "black"))
  
ggsave(here("Output", "time_host_ret.png"), plot = time_chart, width = 10, height = 6, units = "in", dpi = 300)

# Where did the hh reside prior to returning to their original community -------

returnee <- msna %>%
  filter(!is.na(q_7_4)) %>%
  group_by(year, q_7_4) %>%
  summarise(n = n()) %>%
  mutate(percentage = round(n / sum(n) * 100, 1)) %>% 
  mutate(csum = rev(cumsum(rev(percentage))), 
         pos = percentage/2 + lead(csum, 1),
         pos = if_else(is.na(pos), percentage/2, pos))
  
  pie_chart <- ggplot(returnee, aes(x = "", y = percentage, fill = fct_inorder(q_7_4))) +
    geom_bar(stat = "identity", width = 1, color = "white") +
    coord_polar(theta = "y") +
    geom_label_repel(data = returnee,
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
    scale_fill_manual(values = pie_colors)  +
    facet_wrap(~year, ncol = 2) 
  
  ggsave(here("Output", "pie_returnee.png"), plot = pie_chart, width = 8, height = 6, units = "in", dpi = 300)

# IDP HHs arriving to their current location -----------------------------------

idp_date <- msna %>%
  filter(!is.na(q_7_6)) %>%
  group_by(year, q_7_6) %>%
  summarise(obs = cumsum(n()))

  time_chart <- idp_date %>%
    ggplot(aes(x = q_7_6, y = obs, color = year)) +
    geom_line(size = 1.2) +
    scale_y_continuous(limits = c(0, 100), expand = c(0, 0)) +
    labs(title = "",
         x = "Date",
         y = "Households") +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1),
          axis.title = element_text(face = "bold"),
          plot.title = element_text(hjust = 0.5, size = 16, face = "bold"),
          panel.grid.major = element_line(color = "lightgray", linetype = "dashed"),
          panel.grid.minor = element_blank(),
          axis.line = element_line(color = "black"))
  
ggsave(here("Output", "time_idp_arr.png"), plot = time_chart, width = 10, height = 6, units = "in", dpi = 300)

# For IDPs, how many times have you and your HH been displaced since 2011? -----
# Title: Times IDP households have been displaced since 2011

  subset_data <- msna %>%
    filter(!is.na(q_7_7))

  hist_chart <- ggplot(subset_data, aes(x = q_7_7, fill = year)) +
    geom_histogram(binwidth = 1, position = "identity", color = "white", alpha = 0.4) +
    labs(title = "", x = "Number of Times", y = "Frequency") +
    theme_minimal() +
    theme(plot.title = element_text(hjust = 0.5)) 
  
  ggsave(here("Output", "hist_time_disp.png"), plot = hist_chart, width = 9, height = 6, units = "in", dpi = 300)

# Main reasons for displacement for IPS households -----------------------------

push <- msna %>%
  select(id, year, q_7_9_1) %>%
  rename(
    push = q_7_9_1
  ) %>%
  mutate(id = id,
         ones = 1,
         push = ifelse(push == "Worse security situation in last place lived", "Security reasons", push),
         push = ifelse(push %in% c("Pursuit of better economic situation lower prices livelihood opportunities",
                                   "Worse economic situation last place lived",
                                   "Worse livelihood opportunities in last placce lived",
                                   "Unacceptable living conditions (lack of water, power, sewage, privacy/overcrowding, heating, safety, etc.) in last place lived"), "Economic and livelihood reasons", push),
         push = ifelse(push %in% c("Family reasons to reunite with family or to be close to family",
                                   "Insufficient/no availability of humanitarian assistance in last place lived",
                                   "Insufficient/no availability of public services in last place lived (health, education, markets, WASH, etc.)",
                                   "Pursuit of better public services",
                                   "Separated from my family in last place lived",
                                   "Pursuit of humanitarian assistance"), "Other", push)
         ) %>%
  group_by(push, year) %>%
  summarise(total = sum(ones, na.rm = TRUE),
            .groups = 'drop') %>%
  filter(!is.na(push)) %>%
  group_by(year) %>%
  mutate(percentage = round(total / sum(total) * 100, digits = 1)) %>%
  ungroup()

bar_chart <- ggplot(push, aes(x = percentage, y = push, fill = year)) +
  geom_bar(stat = "identity", position = "dodge", width = 0.7, color = "white") +
  geom_text(aes(label = percentage), position = position_dodge(width = 0.7), hjust = - 0.5, vjust = 0, size = 2) +
  labs(title = "",
       x = "Percentage of Households",
       y = "Push Factor") +
  scale_x_continuous(limits = c(0, max(push$percentage) + (max(push$percentage)/10))) +
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
  
ggsave(here("Output", "bar_push.png"), bar_chart, width = 9, height = 6)

# Type of shelter / housing the hh currently reside (by population type) -------

type_hh <- msna %>%
  select(id, q_7_1, q_10_1, year) %>%
  mutate(ones = 1,
         q_10_1 = ifelse(q_10_1 %in% c("Other (specify)",
                                       "Substandard building (factory, farm, shop)",
                                       "Prefabricated unit",
                                       "Collective shelter (religious building, school, warehouse)",
                                       "Makeshift shelter",
                                       "Concrete block shelter",
                                       "House/ apartment (unfinished)"), "Other", q_10_1))

unique_year <- unique(type_hh$year)

for (value in unique_year) {
  subset_data <- type_hh %>%
    filter(year == value) %>%
    group_by(q_7_1, q_10_1) %>%
    summarise(n = n()) %>%
    mutate(percentage = round(n / sum(n) * 100, 1)) %>% 
    mutate(csum = rev(cumsum(rev(percentage))), 
           pos = percentage/2 + lead(csum, 1),
           pos = if_else(is.na(pos), percentage/2, pos))
  
  pie_chart <- ggplot(subset_data, aes(x = "", y = percentage, fill = fct_inorder(q_10_1))) +
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
  
  ggsave(here("Output", paste0("pie_st_", gsub(" ", "_", value), ".png")), pie_chart, width = 9, height = 6)
}

# Adequacy issues in the hh shelter --------------------------------------------

issues <- msna %>%
  select(id, starts_with("issues_"), year, q_7_1) %>%
  pivot_longer(cols = starts_with("issues"), names_to = "issues_q", values_to = "issues_r") %>%
  filter(!is.na(issues_r)) %>%
  mutate(ones = 1,
         issues_r = ifelse(issues_r %in% c("Lack of electricity/ lighting (fixtures/ associated connections)",
                                           "Lack of water (fixtures, associated connections)",
                                           "Lack domestic lighting lamps and wiring",
                                           "Lack of or defective sanitation toilet handbasin and plumbing",
                                           "Lack of water taps basins and plumbing",
                                           "Lack or defective sanitation (toilet, handbasin, associated connections/sewage system)"),
                           "Lack of WASH or electricity", issues_r),
         issues_r = ifelse(issues_r == "None (cannot be selected with any other option)", "None", issues_r),
         issues_r = ifelse(issues_r == "Lack of insulation from heat cold", "Lack of insulation from heat, cold", issues_r),
         issues_r = ifelse(issues_r %in% c("Lack of privacy (space/ partitions, doors)",
                                           "Unable to lock home securely"), "Lack of privacy or security", issues_r),
         issues_r = ifelse(issues_r %in% c("Leakage from roof/ ceiling",
                                           "Leakage from roof ceiling",
                                           "Windows/ doors not sealed",
                                           "Windows doors not sealed",
                                           "Poor facilities for persons with specific needs (PwSN) i.e. unable to access due to physical/ health condition"),
                           "Infraestructure issues", issues_r),
         issues_r = ifelse(issues_r %in% c("Other (please specify)", "Other"), NA, issues_r)
  ) %>%
  group_by(issues_r, year, q_7_1) %>%
  summarise(total = sum(ones, na.rm = TRUE), .groups = 'drop') %>%
  filter(!is.na(issues_r)) %>%
  group_by(q_7_1, year) %>%
  mutate(percentage = round(total / sum(total) * 100, digits = 1)) %>%
  ungroup()

unique_year <- unique(needs$year)

for (value in unique_year) {
  plot_data <- filter(issues, year == value)
  
  bar_chart <- ggplot(plot_data, aes(x = percentage, y = issues_r, fill = q_7_1)) +
    geom_bar(stat = "identity", position = "dodge", width = 0.7, color = "white") +
    geom_text(aes(label = percentage), position = position_dodge(width = 0.7), hjust = - 0.5, vjust = 0, size = 2) +
    labs(title = value,
         x = "Percentage of Households",
         y = "Adequacy Issue") +
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
  
  ggsave(here("Output", paste0("bar_issue_", gsub(" ", "_", value), ".png")), bar_chart, width = 7.5, height = 6)
}