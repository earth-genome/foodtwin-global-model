library(raster)
library(sp)   
library(purrr)
library(tidyverse)

#start with simple generation of all monthlies
filenames <- list.files(path="2020_croprasters/annual", pattern='tif$', full.names=TRUE, recursive = TRUE)
for (i in seq_along(filenames)) {
  r <- raster(filenames[i])
  r12=r/12
  r_stack=stack(replicate(12, r12))
  names(r_stack) <- c("January", "February", "March", "April", "May", "June", "July", "August", "September",
                      "October", "November", "December")
  
  outputFile <- gsub("annual", "monthly", filenames[i], fixed=TRUE)
  writeRaster(r_stack, outputFile, overwrite=TRUE)
}




#subset the crops with associated calendars

world <- sf::read_sf("input_data/ne_110m_admin_0_countries/ne_110m_admin_0_countries.shp")
countrylist <- world %>% dplyr::select(ISO_N3_EH, SOVEREIGNT)
countrylist <- sf::st_drop_geometry(countrylist)


#read in crop calendars countrynames, crops and data, join all three with spatial df
country_lp <- read_csv("input_data/cropcalendarlookupcountrynames.csv")
join1 <- left_join(countrylist, country_lp, by="SOVEREIGNT")
join1 <- na.omit(join1)

month_lp <- read_csv("input_data/cropcalendar_monthlookup.csv")
join2 <- left_join(join1, month_lp, by="Nation.code")

crops_lp <- read_csv("input_data/cropcalendarlookupcrops.csv")
join3 <- left_join(join2, crops_lp, by="Crop.name.in.original.data")
join3 <- join3 %>% dplyr::select(ISO_N3_EH, SOVEREIGNT, newmonth, value, CROPNAME)

uniquecrops <- unique(join3$CROPNAME)

# #first process all non-affected crops, split into 12 and create monthly csvs
# final_lookup <- read.csv("input_data/earthstat_faostat_joined2020multiplierlookup.csv")
# crops_out <- unique(final_lookup$CROPNAME)
# 
# #crops_diff <- setdiff(crops_out, uniquecrops)


#create a ratio for each country


#read in a monthly file
world <- sf::read_sf("input_data/ne_110m_admin_0_countries/ne_110m_admin_0_countries.shp")
sf_as_sp <- sf::as_Spatial(world)

test <- stack("2020_croprasters/monthly/noloss/tonnage/individualcrops/2020_barley_production_noloss.tif")
tonnage <- raster::extract(test,sf_as_sp,cellnumbers=TRUE)


#create table of multipliers for each country and month
#join3_short <- join3 %>% filter(CROPNAME=="barley")
join3 <- join3 %>% unique()
join3 <- join3[!is.na(join3$CROPNAME),]
join3_shortsum <- join3 %>% group_by(ISO_N3_EH, CROPNAME) %>% summarize(valuesum=sum(value, na.rm=TRUE))
join3_shortsum <- join3_shortsum %>% filter(valuesum>0)
join3_shortsum <- join3_shortsum %>% filter(valuesum<12)
join3_shortsum$multi <- 1/join3_shortsum$valuesum

join3_all <- left_join(join3, join3_shortsum, by=c("ISO_N3_EH", "CROPNAME"))
join3_all <- join3_all[!is.na(join3_all$multi),]
join3_all <- join3_all %>% filter(CROPNAME!= "cotton")
unique(join3_all$CROPNAME)
join3_all$multi2 <- join3_all$value*join3_all$multi

join3_all_fin <- join3_all %>% dplyr::select(ISO_N3_EH, CROPNAME, SOVEREIGNT, newmonth, multi)

pairs <- join3_all_fin %>% group_by(ISO_N3_EH, SOVEREIGNT, CROPNAME) %>% summarize(sum=n())

filenames <- list.files(path="2020_croprasters/annual", pattern='tif$', full.names=TRUE, recursive = TRUE)

for (i in 1:length(crops_diff)){
  
  cropid <- crops_diff[i]
  shortlist <- filenames[grepl(cropid, filenames)]
  
  for (i in seq_along(shortlist)) {
    r <- raster(shortlist[i])
    r12=r/12
    r_stack=stack(replicate(12, r12))
    names(r_stack) <- c("January", "February", "March", "April", "May", "June", "July", "August", "September",
                        "October", "November", "December")
    
    outputFile <- gsub("annual", "monthly", shortlist[i], fixed=TRUE)
    writeRaster(r_stack, outputFile, overwrite=TRUE)
  }
  
}


plot(r_stack)




calendar <- read_csv("input_data/sacksetal_cropcalendar.csv")
calendar_lookup <- calendar %>% dplyr::select(Location, Nation.code, Level, State.code)
calendar_lookup_n <-calendar_lookup %>% dplyr::select(Location, Nation.code, Level) %>% filter(Level=="N") %>% unique()


calendar_short <- calendar %>% dplyr::select(Location, Nation.code, Crop, Qualifier, Crop.name.in.original.data, Plant.median, Harvest.median)
calendar_summed <- calendar_short %>% group_by(Nation.code, Crop.name.in.original.data) %>% 
  summarize(med_dat=mean(Plant.median), hrv_dat=mean(Harvest.median))
calendar_summed$hrv_dat <- ifelse((calendar_summed$hrv_dat-calendar_summed$med_dat)<0, calendar_summed$hrv_dat+365, calendar_summed$hrv_dat)

calendar_summed$med_dat_month <-  as.Date(calendar_summed$med_dat-1, origin=("2020-01-01"))
calendar_summed$hrv_dat_month <- as.Date(calendar_summed$hrv_dat-1, origin=("2020-01-01"))

calendar_summed$smonth <- month(calendar_summed$med_dat_month)
calendar_summed$hmonth <- month(calendar_summed$hrv_dat_month)
calendar_summed$hmonth <- ifelse(year(calendar_summed$hrv_dat_month)==2021, calendar_summed$hmonth+12, calendar_summed$hmonth)


# test <- calendar_summed %>% filter(Nation.code==-1 & Crop.name.in.original.data=="Winter Wheat")
# #create empty calendar
# mat_cal <- matrix(1, nrow =nrow(test), ncol = 20)
# col_names <- 1:20
# #col_names <- c("January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December")
# join_cal <- data.frame(matrix = mat_cal)
# colnames(join_cal) <- col_names
# 
# newtest <- cbind(test, join_cal)
# newtest <- newtest %>% gather(key=month,value=value, -Nation.code, -Crop.name.in.original.data, -med_dat, -hrv_dat, -med_dat_month, -hrv_dat_month, -smonth, -hmonth)
# newtest$month <- as.numeric(newtest$month)
# newtest$value <- ifelse(newtest$month>=newtest$smonth & newtest$month<=newtest$hmonth, NA, newtest$value)
# newtest$newmonth <- ifelse(newtest$month>12, newtest$month-12, newtest$month)
# 
# newtest_fin <- newtest %>% group_by(Nation.code, Crop.name.in.original.data, newmonth) %>% summarize(value=sum(value))
# 
# 
# #try full
#create empty calendar
mat_cal <- matrix(1, nrow =nrow(calendar_summed), ncol = 20)
col_names <- 1:20
#col_names <- c("January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December")
join_cal <- data.frame(matrix = mat_cal)
colnames(join_cal) <- col_names


newcal <- cbind(calendar_summed, join_cal)
newcal <- newcal %>% gather(key=month,value=value, -Nation.code, -Crop.name.in.original.data, -med_dat, -hrv_dat, -med_dat_month, -hrv_dat_month, -smonth, -hmonth)
newcal$month <- as.numeric(newcal$month)
newcal$value <- ifelse(newcal$month>=newcal$smonth & newcal$month<=newcal$hmonth, NA, newcal$value)
newcal$newmonth <- ifelse(newcal$month>12, newcal$month-12, newcal$month)

newcal_fin <- newcal %>% group_by(Nation.code, Crop.name.in.original.data, newmonth) %>% summarize(value=sum(value))
newcal_fin$value <- ifelse(newcal_fin$value==2, 1, newcal_fin$value)
write_csv(newcal_fin, "input_data/cropcalendar_monthlookup.csv")


#cleanupnames and countries
cropnames <- calendar %>% dplyr::select(Crop, Crop.name.in.original.data) %>% unique()
write_csv(cropnames, "input_data/cropcalendarlookupcrops.csv")


#add country combos
countrynames <- calendar_lookup_n %>% dplyr::select(-Level) %>% unique()
write_csv(countrynames, "input_data/cropcalendarlookupcountrynames.csv")




library(tidyverse)



#load in calendar, clean up
#get country numbers
#if country is not in calendar, assume equal division for all 12 months

#from 1+ harvest month to 1- plant month
#available otherwise not
calendar <- read_csv("input_data/sacksetal_cropcalendar.csv")
calendar_lookup <- calendar %>% dplyr::select(Location, Nation.code, Level, State.code)
calendar_lookup_n <-calendar_lookup %>% dplyr::select(Location, Nation.code, Level) %>% filter(Level=="N") %>% unique()


calendar_short <- calendar %>% dplyr::select(Location, Nation.code, Crop, Qualifier, Crop.name.in.original.data, Plant.median, Harvest.median)
calendar_summed <- calendar_short %>% group_by(Nation.code, Crop.name.in.original.data) %>% 
  summarize(med_dat=mean(Plant.median), hrv_dat=mean(Harvest.median))
calendar_summed$hrv_dat <- ifelse((calendar_summed$hrv_dat-calendar_summed$med_dat)<0, calendar_summed$hrv_dat+365, calendar_summed$hrv_dat)

calendar_summed$med_dat_month <-  as.Date(calendar_summed$med_dat-1, origin=("2020-01-01"))
calendar_summed$hrv_dat_month <- as.Date(calendar_summed$hrv_dat-1, origin=("2020-01-01"))


#create empty calendar
mat_cal <- matrix(1, nrow =nrow(calendar_summed), ncol = 12)
col_names <- 1:12
#col_names <- c("January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December")
join_cal <- data.frame(matrix = mat_cal)
colnames(join_cal) <- col_names

newcal <- cbind(calendar_summed, join_cal)
newcal <- newcal %>% gather(key=month,value=value, -Nation.code, -Crop.name.in.original.data, -med_dat, -hrv_dat, -med_dat_month, -hrv_dat_month)






newcal$ind <- mdy(paste0(newcal$month,"-01-2020"))>=newcal$med_dat_month & 
  mdy(paste0(newcal$month,"-01-2020"))<=newcal$hrv_dat_month &
  mdy(paste0(newcal$month,"-01-2021"))<=newcal$hrv_dat_month

newcal2 <- newcal %>% 
  mutate(ind=(as.Date(mdy(paste0(month,"-01-2020")))>=as.Date(med_dat_month) & as.Date(mdy(paste0(month,"-01-2020")))<=as.Date(hrv_dat_month))) #check valid 
newcal2$value <- ifelse(newcal2$ind==FALSE, NA, newcal2$value)
newcal2$value <- ifelse()

newcal2 <- newcal2 %>% dplyr::select(-ind) %>% spread(key=month, value=value)
newcal2 <- newcal2[, c(1:7, 11:18, 8,9,10)]

#check valid 
mutate(value=replace(value,!ind,NA))



#convert months from 1-24



as.month(1)


df1=data.frame(matrix(NA,10,6))
df1[,1]=(c(seq(as.Date("2012-01-01"),as.Date("2012-10-01"),by="1 month")))
df1[,2]=c(1:10); df1[,3]=c(12:21); df1[,4]=c(0.5:10); df1[,5]=c(5:14); df1[,6]=c(10:19)
colnames(df1)=c("Date","X1","X2","X3","X4","X5")
df2=data.frame(matrix(data=c("X1","X2","X4","2012-02-01","2012-04-01","2012-06-01","2012-09-01","2012-06-01","2012-10-01"),3,3))
colnames(df2)=c("Name","Start","End")

df3 <- df1 %>% gather(key=Name,value=value,-Date) %>% #convert to long form
  left_join(df2) %>% mutate(ind=(as.Date(Date)>=as.Date(Start) & as.Date(Date)<=as.Date(End)))  #check valid 
mutate(value=replace(value,!ind,NA)) %>% #replace invalid with NA
  select(Date,Name,value) %>% #remove unnecessary variables
  spread(key=Name,value=value) #convert back to rectangular form









