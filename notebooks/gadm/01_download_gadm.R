# Download GADM

for(i in 0:2){
  getData('GADM', country='SYR', level=i, path = file.path(gadm_dir, "FinalData"))
}

