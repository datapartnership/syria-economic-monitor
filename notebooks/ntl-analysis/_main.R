# Syria Economic Monitor
# Nighttime Lights Analysis: Main Script

# Filepaths --------------------------------------------------------------------
#### Root paths
if(Sys.info()[["user"]] == "robmarty"){
  git_dir <- "~/Documents/Github/syria-economic-monitor"
} 

#### From root
ntl_dir     <- file.path(git_dir, "notebooks", "ntl-analysis")
data_dir    <- file.path(git_dir, "data")
figures_dir <- file.path(git_dir, "reports", "figures")

# Packages and functions -------------------------------------------------------
## R packages
library(dplyr)
library(readr)
library(purrr)
library(rgdal)
library(rgeos)
library(sp)
library(sf)
library(raster) #install.packages('raster', repos='https://rspatial.r-universe.dev')
library(ggplot2)
library(exactextractr)
library(lubridate)
library(tidyr)
library(ggtheme)
library(ggpubr)
library(leaflet)
library(leaflet.extras)
library(h3jsr)
library(readxl)
library(janitor)
library(glcm)

## User written script to facilitating downloading black marble NTL data
source("https://raw.githubusercontent.com/ramarty/download_blackmarble/main/R/download_blackmarble.R")

# Scripts ----------------------------------------------------------------------
RUN_SCRIPTS <- F

if(RUN_SCRIPTS){
  
  # Download black marble nighttime lights data into monthly rasters 
  # for Syria
  source(file.path(ntl_dir, "01_download_black_marble.R"))
  
  # Clean dataset of gas flaring locations; produces a dataset of gas flaring
  # locations in Syria
  source(file.path(ntl_dir, "01_clean_gas_flaring_data.R"))
  
  # Produce a map of nighttime lights, using the latest month of data
  source(file.path(ntl_dir, "02_map_ntl_latest.R"))
  
  # Produce maps showing locations with increases, decreases, and no change
  # in nighttime lights, using different start and end years
  source(file.path(ntl_dir, "02_maps_of_ntl_changes.R"))
  
  # Produce a figure showing trends in nighttime lights at the Governorate level,
  # showing trends using (1) all lights, (2) lights just in gas flaring locations,
  # and (3) lights excluding gas flaring locations
  source(file.path(ntl_dir, "02_trends_in_ntl.R"))
  
}






