library(terra)

setwd("/Users/tg625/Documents/PDA/Directory/LearningCollabMap")

states<-terra::vect("Data/tl_2012_us_state")

terra::plot(states)

ct<-states[states$NAME=="Connecticut"]

writeVector(ct, "Outputs/ct", overwrite=TRUE)
