library(raster)
library(sp)   
library(purrr)
library(tidyverse)

final_lookup <- read.csv("input_data/earthstat_faostat_joined2020multiplierlookup.csv")
crops <- unique(final_lookup$CROPNAME)

for (i in 1:length(crops)){
  
  cropid <- crops[i]
  
  #load polygons, convert to spatial polygon dataframe
  world <- sf::read_sf("input_data/ne_110m_admin_0_countries/ne_110m_admin_0_countries.shp")
  sf_as_sp <- sf::as_Spatial(world)
  
  
  #extract cell numbers from polygon overlay on raster
  crop<-paste0('input_data/earthstat/GeoTiff/', cropid, '/', cropid, '_Production.tif') 
  crop_raster=raster(crop)
  tonnage <- raster::extract(crop_raster,sf_as_sp,cellnumbers=TRUE)
  
  #get list of country polygons
  countrylist <- world %>% dplyr::select(ISO_N3_EH, SOVEREIGNT)
  countrylist <- sf::st_drop_geometry(countrylist)
  
  #create summaries by country of total production volumes, 2000 avg vs 2020 avg for balancing later
  sum00 <- tonnage %>% 
    set_names(seq_along(.)) %>% 
    enframe %>%
    unnest(cols=c(value))
  sum00_2 <- data.frame(as.numeric(sum00$name), as.data.frame(sum00$value))
  colnames(sum00_2) <- c("num", "cellID", "tonnage_00")
  sum00_2_sum <- sum00_2 %>% group_by(num) %>% 
    summarize(totaltonnage_00=sum(tonnage_00, na.rm=TRUE))
  sum00_2_sum <- cbind(countrylist, sum00_2_sum)
  frac <- sum00_2_sum$totaltonnage_00
  
  
  #apply fractionater to each cell of each country polgy to get fraction of crop prod density
  for (i in 1:length(tonnage)) {
    tonnage[[i]][,2] <- tonnage[[i]][,2]/frac[i]
  }
  
  
  #join lookup tables to country shapefiles
  energy_lookup <- read.csv(("input_data/prod_energylookup.csv"))
  energy_lookup <- energy_lookup %>% dplyr::select(-name2, -name3)
  colnames(energy_lookup)[colnames(energy_lookup) == 'name1'] <- 'CROPNAME'
  final_lookup2 <- left_join(final_lookup, energy_lookup, by="CROPNAME")
  final_lookup2 <- final_lookup2 %>% dplyr::filter(!CROPNAME %in% c("vanilla", "tobacco", "pyrethrum", "rubber"))
  colnames(final_lookup2)[colnames(final_lookup2) == "Area.Code..M49."] <- 'ISO_N3_EH'
  final_lookup2$ISO_N3_EH <- as.character(final_lookup2$ISO_N3_EH)
  final_lookup2$ISO_N3_EH <- str_pad(final_lookup2$ISO_N3_EH, 3, pad = "0")
  
  #filter joint shapefile table for crop of interest, extract multipliers
  final_lookup3 <- final_lookup2 %>% filter(CROPNAME==cropid)
  country_list <- left_join(countrylist, final_lookup3, by="ISO_N3_EH")
  country_list$num <- seq.int(nrow(country_list))
  country_list <- country_list %>%
    mutate(Value_20 = if_else(is.na(Value_20), 0, Value_20))
  multi <- country_list$Value_20
  
  
  
#apply multiplier to each cell of each country polygon to get volumes for 2020
  for (i in 1:length(tonnage)) {
    tonnage[[i]][,2] <- tonnage[[i]][,2]*multi[i]
  }
  
  #also convert to calories, fats and proteins (convert from per 100g to 1T)
  energy_lookup2 <- energy_lookup %>% filter(CROPNAME==cropid)
  cal <- energy_lookup2$calories[1]
  calories <- tonnage
  for (i in 1:length(calories)) {
    calories[[i]][,2] <- calories[[i]][,2]*1e+4*cal
  }
  
  fats <- tonnage
  fat <- energy_lookup2$fat[1]
  for (i in 1:length(fats)) {
    fats[[i]][,2] <- fats[[i]][,2]*1e+4*fat
  }
  
  protein <- tonnage
  prt <- energy_lookup2$protein[1]
  for (i in 1:length(protein)) {
    protein[[i]][,2] <- protein[[i]][,2]*1e+4*prt
  }
  
  #convert crop rasters to calories, fats and proteins
  new_crop_raster=crop_raster
  
  for(i in 1:length(tonnage)) {
    new_crop_raster[tonnage[[i]][,1]] <- tonnage[[i]][,2] 
  }
  
  
  #remove inf from zeroing extraneous countries
  new_crop_raster[is.infinite(new_crop_raster[])] <- 0 
  
  cr_raster_calories=new_crop_raster*1e+4*cal
  cr_raster_fats=new_crop_raster*1e+4*fat
  cr_raster_prt=new_crop_raster*1e+4*prt
  
  
  for(i in 1:length(calories)) {
    cr_raster_calories[calories[[i]][,1]] <- calories[[i]][,2] 
  }
  
  for(i in 1:length(fats)) {
    cr_raster_fats[fats[[i]][,1]] <- fats[[i]][,2] 
  }
  
  for(i in 1:length(protein)) {
    cr_raster_prt[protein[[i]][,1]] <- protein[[i]][,2] 
  }
  
  #remove inf from zeroing extraneous countries
  cr_raster_calories[is.infinite(cr_raster_calories[])] <- 0 
  cr_raster_fats[is.infinite(cr_raster_fats[])] <- 0 
  cr_raster_prt[is.infinite(cr_raster_prt[])] <- 0 
  
  #create summaries by country of total production volumes, 2000 avg vs 2020 avg for balancing later
  sum20 <- tonnage %>% 
    set_names(seq_along(.)) %>% 
    enframe %>%
    unnest(cols=c(value))
  sum20_2 <- data.frame(as.numeric(sum20$name), as.data.frame(sum20$value))
  colnames(sum20_2) <- c("num", "cellID", "tonnage_20")
  sum20_2 <- sum20_2 %>% group_by(num) %>% 
    summarize(totaltonnage_20=sum(tonnage_20, na.rm=TRUE))
  

  #join summaries
  summaries <- left_join(sum00_2_sum, sum20_2, by="num")
  summaries$totalcalories_20 <- summaries$totaltonnage_20*1e+4*cal
  summaries$totalfats_20 <- summaries$totaltonnage_20*1e+4*fat
  summaries$totalprt_20 <- summaries$totaltonnage_20*1e+4*prt
  summaries$crop <- cropid
  
  ##save files
  #summaries
  write_csv(summaries, paste0("2020_cropsummaries/noloss/2020_", cropid, "_summary_noloss.csv"))
  
  #rasters
  writeRaster(new_crop_raster, paste0('2020_croprasters/annual/noloss/tonnage/individualcrops/2020_', cropid, '_production_noloss.tif'))
  writeRaster(cr_raster_calories, paste0('2020_croprasters/annual/noloss/calories/individualcrops/2020_', cropid, '_calories_noloss.tif'))
  writeRaster(cr_raster_fats, paste0('2020_croprasters/annual/noloss/fats/individualcrops/2020_', cropid, '_fats_noloss.tif'))
  writeRaster(cr_raster_prt, paste0('2020_croprasters/annual/noloss/protein/individualcrops/2020_', cropid, '_protein_noloss.tif'))
  
}

#california check
# plot(crop_raster)
# plot(new_crop_raster)
# 
# my_window <- extent(-130, -110, 30, 50)
# plot(my_window, col=NA)
# plot(crop_raster, add=T)
# plot(new_crop_raster, add=T)



