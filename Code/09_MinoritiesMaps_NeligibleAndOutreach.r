
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
              rename(current_zipcode = zcta5ce10) %>% 
              left_join(., datrdce) %>% 
              mutate(n = replace_na(as.numeric(n), 0))

overall_wgs84 <- extract(svi, zip, layer="overall_wgs84.tif", fun=mean, ID=TRUE, na.rm=TRUE) %>% as_tibble %>% mutate(ID = as.character(ID))
overall_wgs84_nopop <- extract(svi, zip, layer="overall_wgs84_nopop.tif", fun=mean, ID=TRUE, na.rm=TRUE) %>% as_tibble %>% mutate(ID = as.character(ID))
socioeconomic_wgs84_nopop <- extract(svi, zip, layer="socioeconomic_wgs84_nopop.tif", fun=mean, ID=TRUE, na.rm=TRUE) %>% as_tibble %>% mutate(ID = as.character(ID))
household_wgs84_nopop <- extract(svi, zip, layer="household_wgs84_nopop.tif", fun=mean, ID=TRUE, na.rm=TRUE) %>% as_tibble %>% mutate(ID = as.character(ID))
minority_wgs84_nopop <- extract(svi, zip, layer="minority_wgs84_nopop.tif", fun=mean, ID=TRUE, na.rm=TRUE) %>% as_tibble %>% mutate(ID = as.character(ID))

finaldf<-left_join(temp, minority_wgs84_nopop) %>% 
  mutate(OutreachResponse = (n+1)/value,
        patients=n>0 )

zip_wClinical<-zip
values(zip_wClinical)<-finaldf

p2_eligibleZips_MINORITIES_point <- ggplot(zip_wClinical) + 
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

ggsave(p2_eligibleZips_MINORITIES_point, filename = "Outputs/p2_eligibleZips_MINORITIES_point.pdf")


####outreach response

outreachResponse_MINORITIES<- ggplot(zip_wClinical) + 
    geom_sf(aes(fill=OutreachResponse), colour="black") + 
    geom_point(aes(#color = patients, 
                  size = n, 
                  geometry = geometry),
                  stat = "sf_coordinates", alpha=0.5, colour="white") +
  scale_fill_gradient2(midpoint = (max(finaldf$OutreachResponse)-min(finaldf$OutreachResponse))/2, high="#ffe599", mid="#6AA84F", low="darkred", 
                      na.value="transparent") +
  theme_minimal() +
  scale_colour_manual(values = c("grey","black")) 

ggsave(outreachResponse_MINORITIES, filename = "Outputs/outreachResponse_MINORITIES.pdf")



