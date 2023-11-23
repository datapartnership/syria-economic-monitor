# Assuming you have loaded the necessary libraries
#install.packages(c("dplyr", "sf", "tmap"))

library(dplyr)
library(sf)
library(tmap)
library(haven)

# Location type
for (i in 1:3) {

  subset_data <- pop_2022 %>% filter(hh_pop_type == i)

  merged_data <- merge(subset_data, read_dta(here("Data", "Raw", "syria3.dta")), by.x = "ADM3_PCODE", by.y = "ADM3_PCODE", all.x = TRUE)

  sp_obj <- st_as_sf(merged_data, coords = c("longitude", "latitude"), crs = 4326)
  
  # Create map
  png(here("Output", paste0("/pop_", i, ".png")))
  plot(sp_obj, col = "Reds", main = "Total population", add = TRUE)
  dev.off()
}
