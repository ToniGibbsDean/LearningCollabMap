library(terra)
library(tidyverse)

ct<-terra::vect("Outputs/ct")

files<-list.files(  "Data/usgrid-us-social-vulnerability-index-rev01-tract-2020-wgs84-geotiff", 
                    pattern='.tif', all.files= T, full.names= T) 
                        
filenames <-files %>%
    str_sub(., start = 89, end = -1L)

svi<-terra::rast(x=files) %>%
    project(., terra::crs(ct))

names(svi)<-filenames

svi_ct<-terra::crop(svi, ct, mask=TRUE)

writeRaster(svi_ct, "Outputs/svi.tif")
