######################################################################
# Syria Economic Monitoring
# Multi-Sectoral Needs Assesment
# 0_master
######################################################################

#install.packages(c("here", "tidyverse", "visdat", "summarytools", "readxl", "ggplot2", "Hmisc", "devtools"))
#devtools::install_github("hadley/scales")
#install.packages('RMySQL', repos='http://cran.us.r-project.org')

library(here)
library(tidyverse)
library(readxl)
library(visdat)
library(summarytools)
library(ggplot2)
library(Hmisc)
library(scales)
library(dplyr)
library(viridis)
library(ggrepel)
library(sf)
library(haven)
library(RColorBrewer)

# Colors -----------------------------------------------------------------------

pie_colors <- c("#66c2e0", "#fae10b", "#fc8d62", "darkseagreen3", "lightpink1", "lightsteelblue1")
bar_colors <- c("#66c2e0", "#fae10b", "#fc8d62")

# Codes ------------------------------------------------------------------------

codes <- "C:/Users/wb607344/Downloads/syria-economic-monitor/notebooks/msna/Codes"

  # Data cleaning
  source(file.path(codes, "1_cleaning.R"))

  # Demographic analysis
  source(file.path(codes, "2_demographics.R"))

  # Thematic pillars

    # Conflict and household welfare
    source(file.path(codes, "3_1_conflict.R"))
  
    # Humanitarian Aid
    source(file.path(codes, "3_2_aid.R"))
  
    # Humanitarian Aid
    source(file.path(codes, "3_3_displacement.R"))

    # HH welfare
    source(file.path(codes, "3_4_hh_welfare.R"))
