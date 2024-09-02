library(terra)
library(tidyverse)

ct<-terra::vect("Outputs/ct")

files<-list.files(  "Data/pop/Unconfirmed 469908.crdownload", 
                    pattern='.tif', all.files= T, full.names= T) 
                        
filenames <-files %>%
    str_sub(., start = 89, end = -1L)

pop<-terra::rast(x=files) %>%
    project(., terra::crs(ct))

names(pop)<-filenames

pop_ct<-terra::crop(pop, ct, mask=TRUE)

writeRaster(pop_ct, "Outputs/pop.tif")
