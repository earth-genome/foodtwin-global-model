library(terra)
library(rworldxtra)
library(tidyterra)
library(tidyverse)


#Create shapefiles for coastal areas

#load data with no inner country boundaries
data("countriesHigh")
World <- terra::vect(countriesHigh)
World$World <- "Yes"
World <- World[, "World"]
World <- terra::makeValid(World)
World <- terra::aggregate(World, by = "World", cores = 3)
World <- terra::fillHoles(World) %>% terra::project("+proj=longlat")
World <- terra::makeValid(World)
World <- World[, "World"]

#add 30km buffer from coast inward
World_Inner <- terra::buffer(World, width = -30000)
World_Inner <- terra::makeValid(World_Inner)

#difference to create 30km coastal strips
Coastal_World <- erase(World, World_Inner)

#load shapefiles with country-level data for lookups and joins
filename <- "input_data/ne_110m_admin_0_countries/ne_110m_admin_0_countries.shp"
s <- vect(filename)

#intersect country shapefiles with 30km coastal area
test_s <- terra::intersect(Coastal_World, s)

#remove arctic and antarctic regions (canada/alaska, greenland, norway, russia)
#cross reference with SOU Map for extents
e_can <- ext(-180, -60, 65.5, 90) #canada and alaskan arctic
hbay_can <- ext(-94, -70, 60.5, 65.5) #canadian hudson bay
grn <- ext(-50, 0, 69, 90)#greenland
grn2 <- ext(-60, 0, 80, 90)#greenland
rn <- ext(58, 180, 65.5, 90)#northern russia
art <- ext(-180, 180, -90, -62)#antartica

x_can <- erase(test_s, e_can)
x_can2 <- erase(x_can, hbay_can)
x_can3 <- erase(x_can2, grn)
x_can4 <- erase(x_can3, grn2)
x_can5 <- erase(x_can4, rn)
x_can6 <- erase(x_can5, art)
x_can6 <- buffer(x_can6, 0.001)

outfile <- "input_data/final_coastal_areas_30k.shp"
writeVector(x_can6, outfile, overwrite=TRUE)
