# Extract Trends in SAR

# Load data --------------------------------------------------------------------
#### AOI
aoi <- st_read(file.path(oi_dir, "RawData", "WorldBank_Master.geojson"))

aoi <- aoi %>%
  dplyr::mutate(uid = case_when(
    name == "Area 9 Small" ~ 10,
    name == "Area 13 Small" ~ 14,
    name == "Area 14 Small" ~ 15
  ))

# Make timeseries of SAR -------------------------------------------------------
uid <- 10

for(uid in c(10, 14, 15)){
  
  r <- stack(file.path(s1_sar_dir, "RawData", paste0("syria_bc_1500m_uid",uid,".tif")))
  n_r <- dim(r)[3]
  
  dates_df <- read.csv(file.path(s1_sar_dir, "RawData", paste0("syria_bc_1500m_uid",uid,".csv")),
                       stringsAsFactors = F)
  
  sar_df <- map_df(1:n_r, function(i){
    print(i)
    r <- raster(file.path(s1_sar_dir, "RawData", paste0("syria_bc_1500m_uid",uid,".tif")), i)
    
    r <- r %>% crop(aoi[aoi$uid %in% uid,]) %>% mask(aoi[aoi$uid %in% uid,])
    
    out <- data.frame(i = i,
                      uid = uid,
                      date = dates_df$date[i] %>% substring(1,10) %>% ymd(),
                      sar_mean = r[] %>% mean(na.rm = T),
                      sar_sum = r[] %>% sum(na.rm = T))
    
    return(out)
  })
  
  saveRDS(sar_df, file.path(s1_sar_dir, "FinalData", "individual_files", 
                            paste0("sar_1500m_uid", uid, ".Rds")))
}




