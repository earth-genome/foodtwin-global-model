library(tidyverse)
library(raster)
library(sp)




#for loss diversion
#load in all files
#look up % food calories by country, to each raster, and then read in
cassidy <- read_csv("cassidyetal2013_cropconversions.csv")
colnames(cassidy)[colnames(cassidy) == "Country_code"] <- 'ADM0_A3'

#get all crop names
final_lookup <- read.csv("earthstat_faostat_joined2020multiplierlookup.csv")
crops <- unique(final_lookup$CROPNAME)

for (i in 1:length(crops)){

cropid <- crops[i]

#load polygons, convert to spatial polygon dataframe
world <- sf::read_sf("ne_110m_admin_0_countries/ne_110m_admin_0_countries.shp")
sf_as_sp <- sf::as_Spatial(world)

#extract cell numbers from polygon overlay on raster
r_tonnage<-paste0('2020_croprasters/annual/noloss/tonnage/2020_', cropid, '_production_noloss.tif')
r_calories<-paste0('2020_croprasters/annual/noloss/calories/2020_', cropid, '_calories_noloss.tif') 
r_fats<-paste0('2020_croprasters/annual/noloss/fats/2020_', cropid, '_fats_noloss.tif') 
r_protein<-paste0('2020_croprasters/annual/noloss/protein/2020_', cropid, '_protein_noloss.tif') 

crop_tonnage=raster(r_tonnage)
crop_calories=raster(r_calories)
crop_fats=raster(r_fats)
crop_protein=raster(r_protein)

tonnage <- raster::extract(crop_tonnage,sf_as_sp,cellnumbers=TRUE)
calories <- raster::extract(crop_calories,sf_as_sp,cellnumbers=TRUE)
fats <- raster::extract(crop_fats,sf_as_sp,cellnumbers=TRUE)
protein <- raster::extract(crop_protein,sf_as_sp,cellnumbers=TRUE)


#get list of country polygons
countrylist <- world %>% dplyr::select(ISO_N3_EH, SOVEREIGNT, ADM0_A3)
countrylist <- sf::st_drop_geometry(countrylist)

#join lookup tables to country shapefiles
#energy_lookup <- read.csv(("prod_energylookup.csv"))
#energy_lookup <- energy_lookup %>% dplyr::select(-name2, -name3)
#colnames(energy_lookup)[colnames(energy_lookup) == 'name1'] <- 'CROPNAME'
#final_lookup2 <- left_join(final_lookup, energy_lookup, by="CROPNAME")
final_lookup2 <- final_lookup %>% dplyr::filter(!CROPNAME %in% c("vanilla", "tobacco", "pyrethrum", "rubber"))
colnames(final_lookup2)[colnames(final_lookup2) == "Area.Code..M49."] <- 'ISO_N3_EH'
final_lookup2$ISO_N3_EH <- as.character(final_lookup2$ISO_N3_EH)
final_lookup2$ISO_N3_EH <- str_pad(final_lookup2$ISO_N3_EH, 3, pad = "0")

#filter joint shapefile table for crop of interest, extract multipliers
final_lookup3 <- final_lookup2 %>% filter(CROPNAME==cropid)
country_list <- left_join(countrylist, final_lookup3, by="ISO_N3_EH")
country_list2 <- left_join(country_list, cassidy, by="ADM0_A3")
country_list2 <- country_list2 %>%
  mutate(food_calorie = if_else(is.na(food_calorie), 1, food_calorie))
country_list2 <- country_list2 %>%
  mutate(food_volume = if_else(is.na(food_volume), 1, food_volume))

multi_macro <- country_list2$food_calorie
multi_vol <- country_list2$food_volume

#apply multiplier to each cell of each country polygon to get volumes for 2020
for (i in 1:length(tonnage)) {
  tonnage[[i]][,2] <- tonnage[[i]][,2]*multi_vol[i]
}

for (i in 1:length(calories)) {
  calories[[i]][,2] <- calories[[i]][,2]*multi_macro[i]
}

for (i in 1:length(fats)) {
  fats[[i]][,2] <- fats[[i]][,2]*multi_macro[i]
}

for (i in 1:length(protein)) {
  protein[[i]][,2] <- protein[[i]][,2]*multi_macro[i]
}


#replace new values for corresponding cell# in rasters for tonnage, calories, fats and proteins
for(i in 1:length(tonnage)) {
  crop_tonnage[tonnage[[i]][,1]] <- tonnage[[i]][,2] 
}

for(i in 1:length(calories)) {
  crop_calories[calories[[i]][,1]] <- calories[[i]][,2] 
}

for(i in 1:length(fats)) {
  crop_fats[fats[[i]][,1]] <- fats[[i]][,2] 
}

for(i in 1:length(protein)) {
  crop_protein[protein[[i]][,1]] <- protein[[i]][,2] 
}


#create summaries by country of total production volumes, 2000 avg vs 2020 avg for balancing later
sum20 <- tonnage %>% 
  set_names(seq_along(.)) %>% 
  enframe %>%
  unnest(cols=c(value))
sum20_2 <- data.frame(as.numeric(sum20$name), as.data.frame(sum20$value))
colnames(sum20_2) <- c("num", "cellID", "tonnage_loss")
sum20_2 <- sum20_2 %>% group_by(num) %>% 
  summarize(totaltonnage_loss=sum(tonnage_loss))

sumc20 <- calories %>% 
  set_names(seq_along(.)) %>% 
  enframe %>%
  unnest(cols=c(value))
sumc20_2 <- data.frame(as.numeric(sumc20$name), as.data.frame(sumc20$value))
colnames(sumc20_2) <- c("num", "cellID", "cal_loss")
sumc20_2 <- sumc20_2 %>% group_by(num) %>% 
  summarize(totalcal_loss=sum(cal_loss))


#join summaries
summaries <- left_join(sum20_2, sumc20_2, by="num")
summaries <- cbind(countrylist, summaries)
summaries$crop <- cropid

##save files
#summaries
write_csv(summaries, paste0("2020_cropsummaries/withloss/2020_", cropid, "_summary_withloss.csv"))

#rasters
writeRaster(crop_tonnage, paste0('2020_croprasters/annual/withloss/tonnage/2020_', cropid, '_production_withloss.tif'))
writeRaster(crop_calories, paste0('2020_croprasters/annual/withloss/calories/2020_', cropid, '_calories_withloss.tif'))
writeRaster(crop_fats, paste0('2020_croprasters/annual/withloss/fats/2020_', cropid, '_fats_withloss.tif'))
writeRaster(crop_protein, paste0('2020_croprasters/annual/withloss/protein/2020_', cropid, '_protein_withloss.tif'))

}




