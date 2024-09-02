library(terra)

towns<-terra::vect("Data/CT_Vicinity_Town_Polygon")
ct<-terra::vect("Outputs/ct")

ct_towns<-towns[towns$STATE_NAME=="Connecticut" & !is.na(towns$TOWN_NAME) & towns$LABEL_FLAG=="True"]

ct_towns<-project(ct_towns, terra::crs(ct))

writeVector(ct_towns, "Outputs/towns", overwrite=TRUE)