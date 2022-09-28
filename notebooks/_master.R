# Master Script

# Filepaths --------------------------------------------------------------------
if(Sys.info()[["user"]] == "robmarty"){
  proj_dir <- "~/Dropbox/World Bank/Side Work/Syria Economic Monitor"
  git_dir <- "~/Documents/Github/syria-economic-monitor"
} 

data_dir        <- file.path(proj_dir, "Data")
ntl_bm_dir      <- file.path(data_dir, "NTL BlackMarble")
ntl_viirs_dir   <- file.path(data_dir, "NTL VIIRS")
ntl_viirs_c_dir <- file.path(data_dir, "NTL VIIRS Corrected")
gadm_dir        <- file.path(data_dir, "GADM")

# Packages ---------------------------------------------------------------------
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
source("https://raw.githubusercontent.com/ramarty/download_blackmarble/main/R/download_blackmarble.R")
