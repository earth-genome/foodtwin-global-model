
library(raster)
library(sp)   
library(purrr)
library(tidyverse)


###Pigmeat
#load country polygons
world <- sf::read_sf("input_data/ne_110m_admin_0_countries/ne_110m_admin_0_countries.shp")
sf_as_sp <- sf::as_Spatial(world)

#extract cell numbers from polygon overlay on raster
lv<-'input_data/glw/pigs/5_Pg_2015_Da.tif' 
lv_raster=raster(lv)
animals_dens <- raster::extract(lv_raster,sf_as_sp,cellnumbers=TRUE)

#get list of country polygons
countrylist <- world %>% dplyr::select(ISO_N3_EH, SOVEREIGNT)
countrylist <- sf::st_drop_geometry(countrylist)

#create summaries by country of total production volumes
#divide by totals to get a fraction for each cell
#exclude countrys have zeros in FAOSTAT
sum15 <- animals_dens %>% 
  set_names(seq_along(.)) %>% 
  enframe %>%
  unnest(cols=c(value))
sum15_2 <- data.frame(as.numeric(sum15$name), as.data.frame(sum15$value))
colnames(sum15_2) <- c("num", "cellID", "animaldens_15")
sum15_2_sum <- sum15_2 %>% group_by(num) %>% 
  summarize(totalanimaldens_15=sum(animaldens_15, na.rm=TRUE))
sum15_2_sum <- cbind(countrylist, sum15_2_sum)
sum15_2_sum <- sum15_2_sum %>%
  mutate(totalanimaldens_15 = if_else(num %in% c(3, 15, 21, 23, 24, 80, 84:89, 100, 103, 104, 109, 155, 158:161, 165,
                                                 167, 168, 175, 177), 0, totalanimaldens_15))
frac <- sum15_2_sum$totalanimaldens_15

#apply fractionater to each cell of each country polgy to get fraction of animal density
for (i in 1:length(animals_dens)) {
  animals_dens[[i]][,2] <- animals_dens[[i]][,2]/frac[i]
}


#join lookup tables to country shapefiles
final_lookup <- read.csv("input_data/faostat_livmultipliers2020_total.csv")
final_lookup <- final_lookup %>%
  mutate(Animal = if_else(Animal=="pigmean", "pigmeat", Animal))
energy_lookup <- read.csv(("input_data/prod_energylookup.csv"))
energy_lookup <- energy_lookup %>% dplyr::select(-name2, -name3)
colnames(energy_lookup)[colnames(energy_lookup) == 'name1'] <- 'Animal'
final_lookup2 <- left_join(final_lookup, energy_lookup, by="Animal")
colnames(final_lookup2)[colnames(final_lookup2) == "Area.Code..M49."] <- 'ISO_N3_EH'
final_lookup2$ISO_N3_EH <- as.character(final_lookup2$ISO_N3_EH)
final_lookup2$ISO_N3_EH <- str_pad(final_lookup2$ISO_N3_EH, 3, pad = "0")


#filter joint shapefile table for crop of interest, extract multipliers
#divide multiplier to go from 100g/an to tonnage
final_lookup3 <- final_lookup2 %>% filter(Animal=="pigmeat")
final_lookup3_dens <- final_lookup3 %>% filter(Unit=="An")
countrylist$num <- seq.int(nrow(countrylist))
final_lookup3_dens <- left_join(countrylist, final_lookup3_dens, by="ISO_N3_EH")
final_lookup3_dens <- final_lookup3_dens %>%
  mutate(Value_20 = if_else(is.na(Value_20), 1, Value_20))
multi <- final_lookup3_dens$Value_20

final_lookup3_vol <- final_lookup3 %>% filter(Unit=="100 g/An")
final_lookup3_vol <- left_join(countrylist, final_lookup3_vol, by="ISO_N3_EH")
final_lookup3_vol <- final_lookup3_vol %>%
  mutate(Value_20 = if_else(is.na(Value_20), 1, Value_20))
multi2 <- final_lookup3_vol$Value_20
multi2 <- multi2/1E4



#apply multiplier to each cell of each country polgy to get animals for 2020
for (i in 1:length(animals_dens)) {
  animals_dens[[i]][,2] <- animals_dens[[i]][,2]*multi[i]
}


#need to get multipler of country specific multiplier to get tonnage 
animals_vol <- animals_dens
for (i in 1:length(animals_vol)) {
  animals_vol[[i]][,2] <- animals_vol[[i]][,2]*multi2[i]
}


#also convert to calories, fats and proteins (convert from per 100g to 1T)
energy_lookup2 <- energy_lookup %>% filter(Animal=="pigmeat")
cal <- energy_lookup2$calories[1]
calories <- animals_vol
for (i in 1:length(calories)) {
  calories[[i]][,2] <- calories[[i]][,2]*1e+4*cal
}

fats <- animals_vol
fat <- energy_lookup2$fat[1]
for (i in 1:length(fats)) {
  fats[[i]][,2] <- fats[[i]][,2]*1e+4*fat
}

protein <- animals_vol
prt <- energy_lookup2$protein[1]
for (i in 1:length(protein)) {
  protein[[i]][,2] <- protein[[i]][,2]*1e+4*prt
}


#convert animal density rasters to tonnage, calories, fats and proteins
lv_raster_newvol=lv_raster

for(i in 1:length(animals_vol)) {
  lv_raster_newvol[animals_vol[[i]][,1]] <- animals_vol[[i]][,2] 
}

#remove inf from zeroing extraneous countries
lv_raster_newvol[is.infinite(lv_raster_newvol[])] <- 0 

lv_raster_calories=lv_raster_newvol*1e+4*cal
lv_raster_fats=lv_raster_newvol*1e+4*fat
lv_raster_prt=lv_raster_newvol*1e+4*prt


for(i in 1:length(calories)) {
  lv_raster_calories[calories[[i]][,1]] <- calories[[i]][,2] 
}

for(i in 1:length(fats)) {
  lv_raster_fats[fats[[i]][,1]] <- fats[[i]][,2] 
}

for(i in 1:length(protein)) {
  lv_raster_prt[protein[[i]][,1]] <- protein[[i]][,2] 
}

#remove inf from zeroing extraneous countries
lv_raster_calories[is.infinite(lv_raster_calories[])] <- 0 
lv_raster_fats[is.infinite(lv_raster_fats[])] <- 0 
lv_raster_fats[is.infinite(lv_raster_fats[])] <- 0 

#create summaries by country of total production volumes, 2000 avg vs 2020 avg for balancing later
sum20 <- animals_dens %>% 
  set_names(seq_along(.)) %>% 
  enframe %>%
  unnest(cols=c(value))
sum20_2 <- data.frame(as.numeric(sum20$name), as.data.frame(sum20$value))
colnames(sum20_2) <- c("num", "cellID", "animaldens_20")
sum20_2 <- sum20_2 %>% group_by(num) %>% 
  summarize(totalanimaldens_20=sum(animaldens_20, na.rm=TRUE))


sum20v <- animals_vol %>% 
  set_names(seq_along(.)) %>% 
  enframe %>%
  unnest(cols=c(value))
sum20_2v <- data.frame(as.numeric(sum20v$name), as.data.frame(sum20v$value))
colnames(sum20_2v) <- c("num", "cellID", "animalvol_20")
sum20_2v <- sum20_2v %>% group_by(num) %>% 
  summarize(totalanimalvol_20=sum(animalvol_20, na.rm=TRUE))

#join summaries
summaries <- left_join(sum15_2_sum, sum20_2, by="num")
summaries <- left_join(summaries, sum20_2v, by="num")
summaries$totalcalories_20 <- summaries$totalanimalvol_20*1e+4*cal
summaries$totalfats_20 <- summaries$totalanimalvol_20*1e+4*fat
summaries$totalprt_20 <- summaries$totalanimalvol_20*1e+4*prt
summaries$animal <- "pigmeat"
summaries <- do.call(data.frame,lapply(summaries, function(x) replace(x, is.infinite(x),0)))
write_csv(summaries, paste0("2020_livestocksummaries/noloss/2020_pigmeat_summary_noloss.csv"))



#write rasters to file
writeRaster(lv_raster_newvol, '2020_livestockrasters/annual/noloss/tonnage/individualitem/2020_pigmeat_annual_production_noloss.tif')
writeRaster(lv_raster_calories, '2020_livestockrasters/annual/noloss/calories/individualitem/2020_pigmeat_annual_calories_noloss.tif')
writeRaster(lv_raster_fats, '2020_livestockrasters/annual/noloss/fats/individualitem/2020_pigmeat_annual_fats_noloss.tif')
writeRaster(lv_raster_prt, '2020_livestockrasters/annual/noloss/protein/individualitem/2020_pigmeat_annual_protein_noloss.tif')


#look at pig density in China before and after correction
testog <- raster('glw/pigs/5_Pg_2015_Da.tif' )
test <-raster("2020_livestockrasters/annual/noloss/tonnage/individualitem/2020_pigmeat_annual_production_noloss.tif")
my_window2 <- extent(90, 150, 0, 50)
plot(my_window2, col=NA)
plot(testog, add=T)
plot(test, add=T)
#we can see patterns of density stayed the same, although absolute values changed