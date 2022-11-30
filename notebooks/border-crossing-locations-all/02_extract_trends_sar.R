# Extract Trends in SAR

# r <- raster(file.path(s1_sar_dir, "RawData", "syria_bc_1500m_uid10.tif"))
# r <- r %>% crop(aoi[aoi$uid %in% 10,]) %>% mask(aoi[aoi$uid %in% 10,])
# 
#rr <- glcm(r, statistics=c('second_moment'))
# 
#plot(rr)
# 
# mean, variance, homogeneity, contrast, dissimilarity, entropy, second moment,
# correlation
# 


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
  
  r <- stack(file.path(s1_sar_dir, "RawData", paste0("syria_bc_sar_vv_1500m_uid",uid,".tif")))
  n_r <- dim(r)[3]
  
  dates_df <- read.csv(file.path(s1_sar_dir, "RawData", paste0("syria_bc_sar_vv_1500m_uid",uid,".csv")),
                       stringsAsFactors = F)
  
  sar_df <- map_df(1:n_r, function(i){
    print(i)
    
    r_vv  <- raster(file.path(s1_sar_dir, "RawData", paste0("syria_bc_sar_vv_1500m_uid",uid,".tif")), i) %>% crop(aoi[aoi$uid %in% uid,]) %>% mask(aoi[aoi$uid %in% uid,])
    r_vh  <- raster(file.path(s1_sar_dir, "RawData", paste0("syria_bc_sar_vh_1500m_uid",uid,".tif")), i) %>% crop(aoi[aoi$uid %in% uid,]) %>% mask(aoi[aoi$uid %in% uid,])
    
    # https://sentinels.copernicus.eu/web/sentinel/user-guides/sentinel-1-sar/product-overview/polarimetry
    r_blue <- abs(r_vv) / abs(r_vh)
    
    r_rgb <- (r_vv + r_vh + r_blue)/3
    

    # https://cran.r-project.org/web/packages/glcm/glcm.pdf
    
    out_df <- data.frame(i = i,
                         uid = uid,
                         date = dates_df$date[i] %>% substring(1,10) %>% ymd(),
                         n_pixel = sum(!is.na(r_vv[]))
    )
    
    
    # Wrap GCLM, allowing "none"
    trans_r <- function(r, stat){
      if(stat == "none"){
        r_out <- r
      } else{
        r_out <- glcm(r, statistics=c(stat))
      }
      
      return(r_out)
    }
    
    for(stat in c("none", "contrast", "dissimilarity", "correlation", "variance",
                  "mean", "homogeneity", "entropy", "second_moment")){
      for(r_type in c("rgb", "vv", "vh", "blue")){
        #print(paste(stat, r_type))
        
        if(r_type %in% "rgb")  r <- r_rgb
        if(r_type %in% "vv")   r <- r_vv
        if(r_type %in% "vh")   r <- r_vh
        if(r_type %in% "blue") r <- r_blue
        
        out_df[[paste0("sar_",r_type,"_",stat,"_sum")]] = r %>% trans_r(stat) %>% as.vector() %>% sum(na.rm = T)
        out_df[[paste0("sar_",r_type,"_",stat,"_max")]] = r %>% trans_r(stat) %>% as.vector() %>% max(na.rm = T)
        out_df[[paste0("sar_",r_type,"_",stat,"_p5")]]  = r %>% trans_r(stat) %>% as.vector() %>% quantile(0.5, na.rm=T) %>% as.numeric()
        out_df[[paste0("sar_",r_type,"_",stat,"_p8")]]  = r %>% trans_r(stat) %>% as.vector() %>% quantile(0.8, na.rm=T) %>% as.numeric()
        out_df[[paste0("sar_",r_type,"_",stat,"_p85")]] = r %>% trans_r(stat) %>% as.vector() %>% quantile(0.85, na.rm=T) %>% as.numeric()
        out_df[[paste0("sar_",r_type,"_",stat,"_p9")]]  = r %>% trans_r(stat) %>% as.vector() %>% quantile(0.9, na.rm=T) %>% as.numeric()
        out_df[[paste0("sar_",r_type,"_",stat,"_p95")]] = r %>% trans_r(stat) %>% as.vector() %>% quantile(0.95, na.rm=T) %>% as.numeric()
        
      }
    }
    
    return(out_df)
  })
  
  saveRDS(sar_df, file.path(s1_sar_dir, "FinalData", "individual_files", 
                            paste0("sar_1500m_uid", uid, ".Rds")))
}





uid <- 14
sar_df <- readRDS(file.path(s1_sar_dir, "FinalData", "individual_files", 
                            paste0("sar_1500m_uid", uid, ".Rds")))

sar_df$sar_rgb_correlation_p85

sar_df %>%
  dplyr::mutate(date = date %>% floor_date(unit = "month")) %>%
  group_by(date) %>%
  dplyr::summarise_if(is.numeric, max) %>%
  ggplot(aes(x = date)) +
  geom_line(aes(y = sar_rgb_correlation_p85))

leaflet() %>%
  addTiles() %>%
  addPolygons(data =aoi[aoi$uid %in% 10,])
