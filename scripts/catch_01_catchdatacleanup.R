library(raster)
library(sp)   
library(purrr)
library(tidyverse)

#fisheries and catch data
#read in SAU data, join, get EEZs and species for lookup tables
filenames <- list.files(path="input_data/sau_data", pattern='csv$', full.names=TRUE, recursive = TRUE)
test1<- read_csv(filenames[14], col_types=list(col_character(), col_character(), col_character(), col_double(), col_double(),
                                              col_character(), col_character(), col_character(), col_character(), col_character(),
                                              col_character(), col_character(), col_character(), col_character(), col_character(),
                                              col_double(), col_double()))

sau_all <- filenames[11:14] %>% 
  lapply(read_csv, col_types=list(col_character(), col_character(), col_character(), col_double(), col_double(),
                                  col_character(), col_character(), col_character(), col_character(), col_character(),
                                  col_character(), col_character(), col_character(), col_character(), col_character(),
                                  col_double(), col_double())) %>% bind_rows 



sau_all <- list.files(path="sau_data", pattern='csv$', full.names=TRUE, recursive = TRUE) %>% 
  lapply(read_csv) %>% 
  bind_rows 


sau_all <- list.files(path="sau_data", pattern='csv$', full.names=TRUE, recursive = TRUE) %>% 
  map_df(~read_csv(.x, col_types = cols(.default = "c")))

myfiles = lapply(temp, read.delim, colClasses = a_vector_of_col_classes)

cols <- c("col_character()", "col_character()", "col_character()", "col_double()", "col_double()",
          "col_character()", "col_character()", "col_character()", "col_character()", "col_character()",
          "col_character()", "col_character()", "col_character()", "col_character()", "col_character()",
          "col_double()", "col_double()")

sau_all_short <- sau_all %>% filter(uncertainty_score==2015)


tbl_fread <- 
  filenames %>% 
  map_df(~data.table::fread(.))

select(area_name, year, common_name, functional_group, commercial_group, catch_type, end_use_type, tonnes)



test<- read_csv(filenames[3])
test <- test %>% select(area_name, year, common_name, functional_group, commercial_group, catch_type, end_use_type, tonnes)
#test$year <- as.numeric(test$year)
test <- test %>% filter(year==2019)
test <- test %>% filter(catch_type=="Landings")
test <- test %>% filter(end_use_type=="Direct human consumption")
test2 <- test %>% group_by(area_name, year,  commercial_group) %>% 
  summarize(totaltonnes=sum(tonnes, na.rm=TRUE))
write_csv(test2, "input_data/sau_short/sau_short_29.csv")

#fix 1, 2, 5, 15, 16, 18, 24, 27
 test<- read_csv(filenames[1])
#test <- test %>% select(area_name, year, common_name, functional_group, commercial_group, catch_type, end_use_type, tonnes)
test <- test %>% filter(uncertainty_score==2019)
test <- test %>% filter(fishing_sector=="Landings")
test <- test %>% filter(gear_type=="Direct human consumption")
test$end_use_type <- as.numeric(test$end_use_type )
test2 <- test %>% group_by(commercial_group, uncertainty_score,  functional_group) %>% 
  summarize(totaltonnes=sum(end_use_type, na.rm=TRUE))
colnames(test2) <- c("area_name", "year", "commercial_group", "totaltonnes")
write_csv(test2, "input_data/sau_short/sau_short_1.csv")

test<- read_csv(filenames[2])
#test <- test %>% select(area_name, year, common_name, functional_group, commercial_group, catch_type, end_use_type, tonnes)
test <- test %>% filter(uncertainty_score==2019)
test <- test %>% filter(fishing_sector=="Landings")
test <- test %>% filter(gear_type=="Direct human consumption")
test$end_use_type <- as.numeric(test$end_use_type )
test2 <- test %>% group_by(commercial_group, uncertainty_score,  functional_group) %>% 
  summarize(totaltonnes=sum(end_use_type, na.rm=TRUE))
colnames(test2) <- c("area_name", "year", "commercial_group", "totaltonnes")
write_csv(test2, "input_data/sau_short/sau_short_2.csv")

test<- read_csv(filenames[5])
#test <- test %>% select(area_name, year, common_name, functional_group, commercial_group, catch_type, end_use_type, tonnes)
test <- test %>% filter(uncertainty_score==2019)
test <- test %>% filter(fishing_sector=="Landings")
test <- test %>% filter(gear_type=="Direct human consumption")
test$end_use_type <- as.numeric(test$end_use_type )
test2 <- test %>% group_by(commercial_group, uncertainty_score,  functional_group) %>% 
  summarize(totaltonnes=sum(end_use_type, na.rm=TRUE))
colnames(test2) <- c("area_name", "year", "commercial_group", "totaltonnes")
write_csv(test2, "input_data/sau_short/sau_short_5.csv")

test5<- read_csv(filenames[16])
#test <- test %>% select(area_name, year, common_name, functional_group, commercial_group, catch_type, end_use_type, tonnes)
test5 <- test5 %>% filter(uncertainty_score==2019)
test5 <- test5 %>% filter(fishing_sector=="Landings")
test5 <- test5 %>% filter(gear_type=="Direct human consumption")
test5$end_use_type <- as.numeric(test5$end_use_type )
test25 <- test5 %>% group_by(commercial_group, uncertainty_score,  functional_group) %>% 
  summarize(totaltonnes=sum(end_use_type, na.rm=TRUE))
colnames(test25) <- c("area_name", "year", "commercial_group", "totaltonnes")
write_csv(test25, "input_data/sau_short/sau_short_16.csv")

test5<- read_csv(filenames[18])
#test <- test %>% select(area_name, year, common_name, functional_group, commercial_group, catch_type, end_use_type, tonnes)
test5 <- test5 %>% filter(uncertainty_score==2019)
test5 <- test5 %>% filter(fishing_sector=="Landings")
test5 <- test5 %>% filter(gear_type=="Direct human consumption")
test5$end_use_type <- as.numeric(test5$end_use_type )
test25 <- test5 %>% group_by(commercial_group, uncertainty_score,  functional_group) %>% 
  summarize(totaltonnes=sum(end_use_type, na.rm=TRUE))
colnames(test25) <- c("area_name", "year", "commercial_group", "totaltonnes")
write_csv(test25, "input_data/sau_short/sau_short_18.csv")

test5<- read_csv(filenames[24])
#test <- test %>% select(area_name, year, common_name, functional_group, commercial_group, catch_type, end_use_type, tonnes)
test5 <- test5 %>% filter(data_layer==2019)
test5 <- test5 %>% filter(fishing_entity=="Landings")
test5 <- test5 %>% filter(reporting_status=="Direct human consumption")
test5$gear_type <- as.numeric(test5$gear_type)
test25 <- test5 %>% group_by(landed_value, data_layer,  common_name) %>% 
  summarize(totaltonnes=sum(gear_type, na.rm=TRUE))
colnames(test25) <- c("area_name", "year", "commercial_group", "totaltonnes")
write_csv(test25, "input_data/sau_short/sau_short_24.csv")

test5<- read_csv(filenames[27])
#test <- test %>% select(area_name, year, common_name, functional_group, commercial_group, catch_type, end_use_type, tonnes)
test5 <- test5 %>% filter(data_layer==2019)
test5 <- test5 %>% filter(fishing_entity=="Landings")
test5 <- test5 %>% filter(reporting_status=="Direct human consumption")
test5$gear_type <- as.numeric(test5$gear_type)
test25 <- test5 %>% group_by(landed_value, data_layer,  common_name) %>% 
  summarize(totaltonnes=sum(gear_type, na.rm=TRUE))
colnames(test25) <- c("area_name", "year", "commercial_group", "totaltonnes")
write_csv(test25, "input_data/sau_short/sau_short_27.csv")




#read and join all new layers
sau_all <- list.files(path="sau_short", pattern='csv$', full.names=TRUE) %>% 
  lapply(read_csv) %>% 
  bind_rows 

sau_all_groups <- sau_all %>% group_by(area_name, year, commercial_group) %>% 
  summarize(totaltonne=sum(totaltonnes, na.rm=TRUE))
write_csv(sau_all_groups, "input_data/sau_groups_all.csv")


