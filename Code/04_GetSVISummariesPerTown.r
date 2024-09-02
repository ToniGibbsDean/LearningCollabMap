
library(tidyverse)
library(terra)

svi<-terra::rast("Outputs/svi.tif")
towns<-terra::vect("Outputs/towns")

df<-terra::extract(svi, towns) %>%
    group_by(ID) %>%
    summarise_all(mean, na.rm=TRUE)

df$town<-towns$TOWN_NAME

df %>%
    select(overall_wgs84.tif, town) %>%
    arrange(overall_wgs84.tif) %>%
    print(n=999)


