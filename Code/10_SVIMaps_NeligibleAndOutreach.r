
library(tidyverse)
library(terra)
library(tidyterra)

# load spatial data
svi<-terra::rast("Outputs/svi.tif")
towns<-terra::vect("Outputs/towns")
zip<-terra::vect("Data/zip")

# load clinical data
dat_full <- read.csv("Data/RedCapData-LC-Allvariable.csv")
dat <- dat_full[-c(1,19:22), ]
datrdce <- dat %>% 
                select("current_zipcode") %>% 
                group_by(current_zipcode) %>% 
                summarise(n=n()) %>% 
                drop_na() %>% 
                mutate(current_zipcode = paste0("0",as.character(current_zipcode)))

# adding clinical columns to zipcode spatvector
temp <- as_tibble(values(zip)) %>% 
        select(zcta5ce10) %>% 
        rownames_to_column("ID") %>% 
        rename(current_zipcode = zcta5ce10)  %>% 
        left_join(., datrdce) %>% 
        mutate(n = replace_na(as.numeric(n), 0))

overall_wgs84 <- extract(svi, zip, layer="overall_wgs84.tif", fun=mean, ID=TRUE, na.rm=TRUE) %>% 
                            as_tibble %>% 
                            mutate(ID = as.character(ID))
overall_wgs84_nopop <- extract(svi, zip, layer="overall_wgs84_nopop.tif", fun=mean, ID=TRUE, na.rm=TRUE) %>% 
                            as_tibble %>% 
                            mutate(ID = as.character(ID))

finaldf<-left_join(temp, overall_wgs84_nopop) %>% 
  mutate(OutreachResponse = (n+1)/value,
        patients=n>0 )

zip_wClinical<-zip
values(zip_wClinical)<-finaldf


p1_eligibleZips <- ggplot() +
  geom_spatvector(data=zip_wClinical, aes(fill=n), colour="lightgrey") +
  #scale_fill_manual(values=c("#f9570c","#3e6487")) #+
  theme_minimal() + scale_fill_gradient2(high="#f9570c", mid="#3e6487", low="#3e6487", 
                      na.value="transparent")
   #would be good to add region + cant even get labels to work
  #geom_spatvector_text(aes(label = current_zipcode),
   # fontface = "bold",
   # color = "red"
 # )
ggsave(p1_eligibleZips, filename = "Outputs/map_p1_eligibleZips.pdf")


 newzip_wClinical<-zip_wClinical %>% arrange(., desc(n))

p1b_eligibleZips <- ggplot(data=newzip_wClinical) +
  geom_sf(aes(fill=patients, alpha=0.2)) +
  scale_fill_manual(values=c("#f9570c","#3e6487")) +
  geom_point(aes(#color = patients, 
                  size = n, 
                  geometry = geometry),
                  stat = "sf_coordinates", alpha=0.5) +
  theme_minimal() + 
  guides(fill = guide_legend(override.aes = list(alpha = 0.5)), alpha = FALSE) 

ggsave(p1b_eligibleZips, filename = "Outputs/map_p1b_eligibleZips_wPoints.pdf")


p2_eligibleZips_SVI_point <- ggplot(newzip_wClinical) + 
    geom_sf(aes(fill=value)) + 
    geom_point(aes(#color = patients, 
                  size = n, 
                  geometry = geometry),
                  stat = "sf_coordinates", alpha=0.5) +
  #scale_color_viridis_c(option = "C") +
  theme(legend.position = "bottom") +
   scale_fill_distiller(palette = "Spectral") + 
  guides(fill = guide_legend(override.aes = list(alpha = 0.9)), alpha = FALSE) +
  theme_minimal()

ggsave(p2_eligibleZips_SVI_point, filename = "Outputs/p2_eligibleZips_SVI_point.pdf")


####outreach response

ggplot() +
  #geom_spatraster(data = select(zip, overall_wgs84.tif))+
  #geom_spatvector(data=towns, fill=NA, colour="red") +
  geom_spatvector(data=zip_wClinical, aes(fill=OutreachResponse, color=patients)) +
  scale_fill_gradient2(midpoint = 20, high="blue", mid="white", low="red", 
                      na.value="transparent")

outreachResponse <- ggplot() +
  #geom_spatraster(data = select(zip, overall_wgs84.tif))+
  #geom_spatvector(data=towns, fill=NA, colour="red") +
  geom_spatvector(data=zip_wClinical, aes(fill=OutreachResponse), colour="black") +
  scale_fill_gradient2(midpoint = 20, high="#ffe599", mid="#6AA84F", low="#fe6b40", 
                      na.value="transparent") +
  theme_minimal() +
  scale_colour_manual(values = c("grey","black")) 
  
  


ggsave(outreachResponse, filename = "Outputs/outreachResponse.pdf")



outreachResponse<- ggplot(newzip_wClinical) + 
    geom_sf(aes(fill=OutreachResponse), colour="black") + 
    geom_point(aes(#color = patients, 
                  size = n, 
                  geometry = geometry),
                  stat = "sf_coordinates", alpha=0.5) +
  scale_fill_gradient2(midpoint = 20, high="#ffe599", mid="#6AA84F", low="#fe6b40", 
                      na.value="transparent") +
  theme_minimal() +
  scale_colour_manual(values = c("grey","black")) 
ggsave(outreachResponse, filename = "Outputs/outreachResponse.pdf")


v <- vect(towns)


