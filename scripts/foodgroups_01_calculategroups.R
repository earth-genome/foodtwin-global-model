library(terra)


#create foodgroups
#for now focus on no loss, as loss will be computed after trade balancing

#dairy and eggs annual & monthly
group1 <- "dairyeggs"
commoditynames <- c("cowsmilk", "eggs", "goatmilk")
categories <- c("tonnage", "calories", "fats", "protein")


for (i in seq_along(categories)) {
c1 <-categories[1]  
path=paste0("2020_livestockrasters/annual/noloss/", c1,"/", "individualitem/")
f <- list.files(path=path, pattern='tif$', full.names=TRUE)
new_f <- unique(grep(paste(commoditynames, collapse="|"), f, value=TRUE, ignore.case = TRUE))
r1=rast(new_f[1])
r2=rast(new_f[2])
r3=rast(new_f[3])
s <- sds(r1, r2, r3)
a <- app(s, sum, na.rm=TRUE)
writeRaster(a, paste0("2020_foodgroups/annual/2020_", group1, "_annual_", c1, "_noloss.tif"), overwrite=TRUE)
}

for (i in seq_along(categories)) {
  c1 <-categories[i]  
  path=paste0("2020_livestockrasters/monthly/noloss/", c1,"/", "individualitem/")
  f <- list.files(path=path, pattern='tif$', full.names=TRUE)
  new_f <- unique(grep(paste(commoditynames, collapse="|"), f, value=TRUE, ignore.case = TRUE))
  r1=rast(new_f[1])
  r2=rast(new_f[2])
  r3=rast(new_f[3])
  s <- sds(r1, r2, r3)
  a <- app(s, sum, na.rm=TRUE)
  writeRaster(a, paste0("2020_foodgroups/monthly/2020_", group1, "_monthly_", c1, "_noloss.tif"), overwrite=TRUE)
}





#livestock and fish products
group2 <- "meatfish"
commoditynames <- c("beef", "chickenmeat", "goatmeat", "pigmeat", "sheepmeat")
categories <- c("tonnage", "calories", "fats", "protein")

for (i in seq_along(categories)) {
  c1 <-categories[i]  
  path=paste0("2020_livestockrasters/annual/noloss/", c1,"/", "individualitem")
  f <- list.files(path=path, pattern='tif$', full.names=TRUE)
  new_f <- unique(grep(paste(commoditynames, collapse="|"), f, value=TRUE, ignore.case = TRUE))

  path2=paste0("2020_catchrasters/annual/noloss/", c1,"/", "individualitem")
  f2 <- list.files(path=path2, pattern='tif$', full.names=TRUE)
  f3 <- c(new_f, f2)
  
  ic <- sprc(lapply(f3, rast))
  a <- mosaic(ic)
  
  writeRaster(a, paste0("2020_foodgroups/annual/2020_", group2, "_annual_", c1, "_noloss.tif"), overwrite=TRUE)
}


for (i in seq_along(categories)) {
  c1 <-categories[i]  
  path=paste0("2020_livestockrasters/monthly/noloss/", c1,"/", "individualitem")
  f <- list.files(path=path, pattern='tif$', full.names=TRUE)
  new_f <- unique(grep(paste(commoditynames, collapse="|"), f, value=TRUE, ignore.case = TRUE))
  
  path2=paste0("2020_catchrasters/monthly/noloss/", c1,"/", "individualitem")
  f2 <- list.files(path=path2, pattern='tif$', full.names=TRUE)
  f3 <- c(new_f, f2)
  
  ic <- sprc(lapply(f3, rast))
  a <- mosaic(ic)
  
  writeRaster(a, paste0("2020_foodgroups/monthly/2020_", group2, "_monthly_", c1, "_noloss.tif"), overwrite=TRUE)
}


#sugar and sweetners
es_lookup <- read_csv("input_data/earthstat_lookup.csv")
es_lookup <- es_lookup %>% dplyr::select(CROPNAME, NEWGROUP)
es_lookup <- na.omit(es_lookup)
sweet <- es_lookup %>% filter(NEWGROUP=="Sugars & Sweetners")

commoditynames <- sweet$CROPNAME
group3 <- "sugarssweetners"
categories <- c("tonnage", "calories", "fats", "protein")

for (i in seq_along(categories)) {
  c1 <-categories[i]  
  path=paste0("2020_croprasters/annual/noloss/", c1,"/", "individualcrops")
  f <- list.files(path=path, pattern='tif$', full.names=TRUE)
  new_f <- unique(grep(paste(commoditynames, collapse="|"), f, value=TRUE, ignore.case = TRUE))

  ic <- sprc(lapply(new_f, rast))
  a <- mosaic(ic)
  
  writeRaster(a, paste0("2020_foodgroups/annual/2020_", group3, "_annual_", c1, "_noloss.tif"), overwrite=TRUE)
}


for (i in seq_along(categories)) {
  c1 <-categories[i]  
  path=paste0("2020_croprasters/monthly/noloss/", c1,"/", "individualcrops")
  f <- list.files(path=path, pattern='tif$', full.names=TRUE)
  new_f <- unique(grep(paste(commoditynames, collapse="|"), f, value=TRUE, ignore.case = TRUE))
  
  ic <- sprc(lapply(new_f, rast))
  a <- mosaic(ic)
  
  writeRaster(a, paste0("2020_foodgroups/monthly/2020_", group3, "_monthly_", c1, "_noloss.tif"), overwrite=TRUE)
}


#Treenuts
es_lookup <- read_csv("input_data/earthstat_lookup.csv")
es_lookup <- es_lookup %>% dplyr::select(CROPNAME, NEWGROUP)
es_lookup <- na.omit(es_lookup)
treenuts <- es_lookup %>% filter(NEWGROUP=="Treenuts")

commoditynames <- treenuts$CROPNAME
group3 <- "treenuts"
categories <- c("tonnage", "calories", "fats", "protein")

for (i in seq_along(categories)) {
  c1 <-categories[i]  
  path=paste0("2020_croprasters/annual/noloss/", c1,"/", "individualcrops")
  f <- list.files(path=path, pattern='tif$', full.names=TRUE)
  new_f <- unique(grep(paste(commoditynames, collapse="|"), f, value=TRUE, ignore.case = TRUE))
  
  ic <- sprc(lapply(new_f, rast))
  a <- mosaic(ic)
  
  writeRaster(a, paste0("2020_foodgroups/annual/2020_", group3, "_annual_", c1, "_noloss.tif"), overwrite=TRUE)
}

for (i in seq_along(categories)) {
  c1 <-categories[i]  
  path=paste0("2020_croprasters/monthly/noloss/", c1,"/", "individualcrops")
  f <- list.files(path=path, pattern='tif$', full.names=TRUE)
  new_f <- unique(grep(paste(commoditynames, collapse="|"), f, value=TRUE, ignore.case = TRUE))
  
  ic <- sprc(lapply(new_f, rast))
  a <- mosaic(ic)
  
  writeRaster(a, paste0("2020_foodgroups/monthly/2020_", group3, "_monthly_", c1, "_noloss.tif"), overwrite=TRUE)
}



#Fruits
es_lookup <- read_csv("input_data/earthstat_lookup.csv")
es_lookup <- es_lookup %>% dplyr::select(CROPNAME, NEWGROUP)
es_lookup <- na.omit(es_lookup)
fruits <- es_lookup %>% filter(NEWGROUP=="Fruits")

commoditynames <- fruits$CROPNAME
group3 <- "fruits"
categories <- c("tonnage", "calories", "fats", "protein")

for (i in seq_along(categories)) {
  c1 <-categories[i]  
  path=paste0("2020_croprasters/annual/noloss/", c1,"/", "individualcrops")
  f <- list.files(path=path, pattern='tif$', full.names=TRUE)
  new_f <- unique(grep(paste(commoditynames, collapse="|"), f, value=TRUE, ignore.case = TRUE))
  
  ic <- sprc(lapply(new_f, rast))
  a <- mosaic(ic)
  
  writeRaster(a, paste0("2020_foodgroups/annual/2020_", group3, "_annual_", c1, "_noloss.tif"), overwrite=TRUE)
}

for (i in seq_along(categories)) {
  c1 <-categories[i]  
  path=paste0("2020_croprasters/monthly/noloss/", c1,"/", "individualcrops")
  f <- list.files(path=path, pattern='tif$', full.names=TRUE)
  new_f <- unique(grep(paste(commoditynames, collapse="|"), f, value=TRUE, ignore.case = TRUE))
  
  ic <- sprc(lapply(new_f, rast))
  a <- mosaic(ic)
  
  writeRaster(a, paste0("2020_foodgroups/monthly/2020_", group3, "_monthly_", c1, "_noloss.tif"), overwrite=TRUE)
}




#Vegetables
es_lookup <- read_csv("input_data/earthstat_lookup.csv")
es_lookup <- es_lookup %>% dplyr::select(CROPNAME, NEWGROUP)
es_lookup <- na.omit(es_lookup)
vegetables <- es_lookup %>% filter(NEWGROUP=="Vegetables")

commoditynames <- vegetables$CROPNAME
group3 <- "vegetables"
categories <- c("tonnage", "calories", "fats", "protein")

for (i in seq_along(categories)) {
  c1 <-categories[i]  
  path=paste0("2020_croprasters/annual/noloss/", c1,"/", "individualcrops")
  f <- list.files(path=path, pattern='tif$', full.names=TRUE)
  new_f <- unique(grep(paste(commoditynames, collapse="|"), f, value=TRUE, ignore.case = TRUE))
  
  ic <- sprc(lapply(new_f, rast))
  a <- mosaic(ic)
  
  writeRaster(a, paste0("2020_foodgroups/annual/2020_", group3, "_annual_", c1, "_noloss.tif"), overwrite=TRUE)
}

for (i in seq_along(categories)) {
  c1 <-categories[i]  
  path=paste0("2020_croprasters/monthly/noloss/", c1,"/", "individualcrops")
  f <- list.files(path=path, pattern='tif$', full.names=TRUE)
  new_f <- unique(grep(paste(commoditynames, collapse="|"), f, value=TRUE, ignore.case = TRUE))
  
  ic <- sprc(lapply(new_f, rast))
  a <- mosaic(ic)
  
  writeRaster(a, paste0("2020_foodgroups/monthly/2020_", group3, "_monthly_", c1, "_noloss.tif"), overwrite=TRUE)
}


#Starches
es_lookup <- read_csv("input_data/earthstat_lookup.csv")
es_lookup <- es_lookup %>% dplyr::select(CROPNAME, NEWGROUP)
es_lookup <- na.omit(es_lookup)
starches <- es_lookup %>% filter(NEWGROUP=="Starches")

commoditynames <- starches$CROPNAME
group3 <- "starches"
categories <- c("tonnage", "calories", "fats", "protein")

for (i in seq_along(categories)) {
  c1 <-categories[i]  
  path=paste0("2020_croprasters/annual/noloss/", c1,"/", "individualcrops")
  f <- list.files(path=path, pattern='tif$', full.names=TRUE)
  new_f <- unique(grep(paste(commoditynames, collapse="|"), f, value=TRUE, ignore.case = TRUE))
  
  ic <- sprc(lapply(new_f, rast))
  a <- mosaic(ic)
  
  writeRaster(a, paste0("2020_foodgroups/annual/2020_", group3, "_annual_", c1, "_noloss.tif"), overwrite=TRUE)
}

for (i in seq_along(categories)) {
  c1 <-categories[i]  
  path=paste0("2020_croprasters/monthly/noloss/", c1,"/", "individualcrops")
  f <- list.files(path=path, pattern='tif$', full.names=TRUE)
  new_f <- unique(grep(paste(commoditynames, collapse="|"), f, value=TRUE, ignore.case = TRUE))
  
  ic <- sprc(lapply(new_f, rast))
  a <- mosaic(ic)
  
  writeRaster(a, paste0("2020_foodgroups/monthly/2020_", group3, "_monthly_", c1, "_noloss.tif"), overwrite=TRUE)
}



#Pulses
es_lookup <- read_csv("input_data/earthstat_lookup.csv")
es_lookup <- es_lookup %>% dplyr::select(CROPNAME, NEWGROUP)
es_lookup <- na.omit(es_lookup)
pulses <- es_lookup %>% filter(NEWGROUP=="Pulses")

commoditynames <- pulses$CROPNAME
group3 <- "pulses"
categories <- c("tonnage", "calories", "fats", "protein")

for (i in seq_along(categories)) {
  c1 <-categories[i]  
  path=paste0("2020_croprasters/annual/noloss/", c1,"/", "individualcrops")
  f <- list.files(path=path, pattern='tif$', full.names=TRUE)
  new_f <- unique(grep(paste(commoditynames, collapse="|"), f, value=TRUE, ignore.case = TRUE))
  
  ic <- sprc(lapply(new_f, rast))
  a <- mosaic(ic)
  
  writeRaster(a, paste0("2020_foodgroups/annual/2020_", group3, "_annual_", c1, "_noloss.tif"), overwrite=TRUE)
}

for (i in seq_along(categories)) {
  c1 <-categories[i]  
  path=paste0("2020_croprasters/monthly/noloss/", c1,"/", "individualcrops")
  f <- list.files(path=path, pattern='tif$', full.names=TRUE)
  new_f <- unique(grep(paste(commoditynames, collapse="|"), f, value=TRUE, ignore.case = TRUE))
  
  ic <- sprc(lapply(new_f, rast))
  a <- mosaic(ic)
  
  writeRaster(a, paste0("2020_foodgroups/monthly/2020_", group3, "_monthly_", c1, "_noloss.tif"), overwrite=TRUE)
}


#Oilseed
es_lookup <- read_csv("input_data/earthstat_lookup.csv")
es_lookup <- es_lookup %>% dplyr::select(CROPNAME, NEWGROUP)
es_lookup <- na.omit(es_lookup)
oilseed <- es_lookup %>% filter(NEWGROUP=="Oilseed")

commoditynames <- oilseed$CROPNAME
group3 <- "oilseed"
categories <- c("tonnage", "calories", "fats", "protein")

for (i in seq_along(categories)) {
  c1 <-categories[i]  
  path=paste0("2020_croprasters/annual/noloss/", c1,"/", "individualcrops")
  f <- list.files(path=path, pattern='tif$', full.names=TRUE)
  new_f <- unique(grep(paste(commoditynames, collapse="|"), f, value=TRUE, ignore.case = TRUE))
  
  ic <- sprc(lapply(new_f, rast))
  a <- mosaic(ic)
  
  writeRaster(a, paste0("2020_foodgroups/annual/2020_", group3, "_annual_", c1, "_noloss.tif"), overwrite=TRUE)
}

for (i in seq_along(categories)) {
  c1 <-categories[i]  
  path=paste0("2020_croprasters/monthly/noloss/", c1,"/", "individualcrops")
  f <- list.files(path=path, pattern='tif$', full.names=TRUE)
  new_f <- unique(grep(paste(commoditynames, collapse="|"), f, value=TRUE, ignore.case = TRUE))
  
  ic <- sprc(lapply(new_f, rast))
  a <- mosaic(ic)
  
  writeRaster(a, paste0("2020_foodgroups/monthly/2020_", group3, "_monthly_", c1, "_noloss.tif"), overwrite=TRUE)
}



# 
# test_rs2 <- as.data.frame(r3, xy = TRUE)
# test_rs2$`2020_goatmilk_annual_production_noloss` <- ifelse(test_rs2$`2020_goatmilk_annual_production_noloss`==0, NA, test_rs2$`2020_goatmilk_annual_production_noloss`)

# ggplot() +
#   geom_raster(data = test_rs2 , aes(x = x, y = y, fill = `2020_goatmilk_annual_production_noloss`)) +
#   scale_fill_viridis_c(na.value="white") +
#   coord_quickmap()  +
#   labs(fill="")
