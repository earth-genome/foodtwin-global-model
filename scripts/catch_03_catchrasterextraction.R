library(raster)
library(sf)
library(tidyverse)

#load coastal data and SAU catch data
#by taxon, spread data over coastal pixels, save rasters and csvs


#read in shapefile
sf::sf_use_s2(FALSE)
coastal_areas <- read_sf("input_data/final_coastal_areas_30k.shp")
coastal_areas <- st_make_valid(coastal_areas)
sf_as_sp <- as_Spatial(coastal_areas)

#create raster for overlay
firstRaster <- raster::raster(xmn = -180,   
                              xmx = 180,    
                              ymn = -90,    
                              ymx = 90,     
                              res = c(0.08333333,0.08333333)) # resolution in c(x,y) direction
firstRaster
firstRaster[] <- 0

#get data from coastal shapefile
df_cells <- as.data.frame(coastal_areas)
df_cells <- df_cells %>% dplyr::select(SOVEREIGNT, ADMIN, ADM0_A3, ISO_N3)

#join with SAU data, to be able to spread catch over coastal pixels by country
sau_all_new <- read_csv("input_data/sau_groups_all.csv")
sau_all_new <- sau_all_new %>% group_by(area_name, year, commercial_group) %>% 
  summarize(totaltonne=sum(totaltonne, na.rm=TRUE))
colnames(sau_all_new)[colnames(sau_all_new) == 'area_name'] <- 'ADMIN'

#join calorie/protein lookup
fish_cal <- read_csv("input_data/fish_calorie_lookup.csv")
sau_all_new <- left_join(sau_all_new, fish_cal, by="commercial_group")
groups <- unique(sau_all_new$commercial_group)


#create loop by taxon type
#extract files in masked area, create ratio of all pixels for each country
#multiply by volumes of each taxon, derive calories, fats, protein
#save raster and associated csv file

for (i in 1:length(groups)){

fishid <- groups[i]
fish1 <- sau_all_new %>% filter(commercial_group==fishid)
anch_dens <- raster::extract(firstRaster,sf_as_sp,cellnumbers=TRUE)


#get total number of cells per polygon
sum15 <- anch_dens %>% 
  set_names(seq_along(.)) %>% 
  enframe %>%
  unnest(cols=c(value))
sum15_2 <- data.frame(as.numeric(sum15$name), as.data.frame(sum15$value))
colnames(sum15_2) <- c("num", "cellID", "animaldens_15")
sum15_2_sum <- sum15_2 %>% group_by(num) %>% 
  summarize(totalcells=n())
sum15_2_sum$layer <- 1/sum15_2_sum$totalcells
frac <- sum15_2_sum$layer

#add contry level data
sum15_2_sum <- cbind(sum15_2_sum, df_cells)


#join to other lookuptable
sum_15_fin_fish <- left_join(sum15_2_sum, fish1, by="ADMIN")
sum_15_fin_fish$totaltonne <- sum_15_fin_fish$totaltonne*sum_15_fin_fish$layer
sum_15_fin_fish$calories <- sum_15_fin_fish$totaltonne*sum_15_fin_fish$calories*1e+4
sum_15_fin_fish$proteins <- sum_15_fin_fish$totaltonne*sum_15_fin_fish$proteins*1e+4
sum_15_fin_fish$fats <- sum_15_fin_fish$totaltonne*sum_15_fin_fish$fats*1e+4

sum_15_fin_fish <- sum_15_fin_fish %>%
  mutate(totaltonne = if_else(is.na(totaltonne), 0, totaltonne))
sum_15_fin_fish <- sum_15_fin_fish %>%
  mutate(calories = if_else(is.na(calories), 0, calories))
sum_15_fin_fish <- sum_15_fin_fish %>%
  mutate(proteins = if_else(is.na(proteins), 0, proteins))
sum_15_fin_fish <- sum_15_fin_fish %>%
  mutate(fats = if_else(is.na(fats), 0, fats))

#extract numbers to add to rasters
to <- sum_15_fin_fish$totaltonne
ca <- sum_15_fin_fish$calories
pr <- sum_15_fin_fish$proteins
ft <- sum_15_fin_fish$fats

#add fractionater to each cell of each country polgy to get fraction of fish volume density
anch_t <- anch_dens
anch_c <- anch_dens
anch_p <- anch_dens
anch_f <- anch_dens


for (i in 1:length(anch_t)) {
  anch_t[[i]][,2] <- anch_t[[i]][,2]+to[i]
}

for (i in 1:length(anch_c)) {
  anch_c[[i]][,2] <- anch_c[[i]][,2]+ca[i]
}

for (i in 1:length(anch_p)) {
  anch_p[[i]][,2] <- anch_p[[i]][,2]+pr[i]
}

for (i in 1:length(anch_f)) {
  anch_f[[i]][,2] <- anch_f[[i]][,2]+ft[i]
}


#create new rasters for tonnage, calories, protein and fats
anch_to_r=firstRaster
anch_ca_r=firstRaster
anch_pr_r=firstRaster
anch_ft_r=firstRaster


for(i in 1:length(anch_t)) {
  anch_to_r[anch_t[[i]][,1]] <- anch_t[[i]][,2] 
}


for(i in 1:length(anch_c)) {
  anch_ca_r[anch_c[[i]][,1]] <- anch_c[[i]][,2] 
}

for(i in 1:length(anch_p)) {
  anch_pr_r[anch_p[[i]][,1]] <- anch_p[[i]][,2] 
}

for(i in 1:length(anch_f)) {
  anch_ft_r[anch_f[[i]][,1]] <- anch_f[[i]][,2] 
}


#some leaking of rasters due to polygons with duplicate vertices in medium-sized island states
#add an additional inner mask to remove
innerworld <- read_sf("input_data/world_inner.shp")
anch_to_r <- raster::mask(anch_to_r, innerworld, inverse=TRUE)
anch_ca_r <- raster::mask(anch_ca_r, innerworld, inverse=TRUE)
anch_pr_r <- raster::mask(anch_pr_r, innerworld, inverse=TRUE)
anch_ft_r <- raster::mask(anch_ft_r, innerworld, inverse=TRUE)



#savefiles
write_csv(sum_15_fin_fish, paste0("2020_catchsummaries/noloss/2020_", fishid, "_summary_noloss.csv"))

#write rasters to file
writeRaster(anch_to_r, paste0('2020_catchrasters/annual/noloss/tonnage/individualitem/2020_', fishid, '_annual_production_noloss.tif'), overwrite=TRUE)
writeRaster(anch_ca_r, paste0('2020_catchrasters/annual/noloss/calories/individualitem/2020_', fishid, '_annual_calories_noloss.tif'), overwrite=TRUE)
writeRaster(anch_ft_r, paste0('2020_catchrasters/annual/noloss/fats/individualitem/2020_', fishid, '_annual_fats_noloss.tif'), overwrite=TRUE)
writeRaster(anch_pr_r, paste0('2020_catchrasters/annual/noloss/protein/individualitem/2020_', fishid, '_annual_protein_noloss.tif'), overwrite=TRUE)
}


#plot checks
plot(anch_to_r)

my_window <- extent(0, 50, -75, 0)
plot(my_window, col=NA)
plot(anch_to_r, add=T)

test_rs <- as.data.frame(anch_to_r, xy = TRUE)
test_rs$layer <- ifelse(test_rs$layer==0, NA, test_rs$layer)

ggplot() +
  geom_raster(data = test_rs , aes(x = x, y = y, fill = layer)) +
  scale_fill_viridis_c(na.value="white") +
  coord_quickmap() +
  xlim(80,180)

ggplot() +
  geom_polygon(data=coastal_areas, mapping=aes(x=x, y=y))
mapview::mapview(sf_as_sp)  


#read shapefile
innerworld <- read_sf("input_data/world_inner.shp")
testcase <- raster::mask(anch_to_r, innerworld, inverse=TRUE)

test_rs2 <- as.data.frame(testcase, xy = TRUE)
test_rs2$layer <- ifelse(test_rs2$layer==0, NA, test_rs2$layer)

ggplot() +
  geom_raster(data = test_rs2 , aes(x = x, y = y, fill = layer)) +
  scale_fill_viridis_c(na.value="white") +
  coord_quickmap() 

