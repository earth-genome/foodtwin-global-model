# Food Twin Global Model Datasets
Repository for data development for the global foodtwin model and application. The application developed to visualize this model is in the Food Twin Global App repo. 

## Overview
This repository contains data sources and scripts to compute both global production and demand for food in the year 2020.  Global production of primary crops, livestock and fisheries/catch products are presented as gridded data at 10km x 10km resolution, with scaling for all products to 2020 values to match with FAO reported country level data. Production is computed both at annual and monthly timescales and products are aggregated to 9 major food groups. Consumption-based demand of food is also presented as gridded data at a 10km x 10km resolution, with dietary demand augmented by demographic characteristics as well as population maps for 2020.


## Input Data
Our input data included collating and updating datasets from a variety of sources to develop updated global maps of production and demand.  For production, our input data included historical gridded maps of crop production, livestock density, and fisheries catch data (see Input Data Table below). Augmenting this production data includes FAO statistics, nutrition data tables to convert production values to macronutrients, crop calendars and updated crop harvested area data.

For demand, our input data included gridded maps of 2020 population density, demographics (age & gender groups), locale (urban vs rural), as well as dietary demand by country, demographics and locale.



 **Input Data Source** | **Description**
 ---               | ---        
[Earthstat Crop Maps](http://www.earthstat.org)            |  Harvested area, yields and production for 175 crops on a five arc minute by five arc minute (~10km by ~10km) latitude/longitiude grid for the year 2000
[CROPGRIDS Harvested Area Maps](https://figshare.com/articles/dataset/CROPGRIDS/22491997)            |  Updated harvested areas for 173 crops on a three arc minute by three arc minute (~5.6km by ~5.6km) latitude/longitude grid for the year 2020
[Gridded Livestock of the World](https://data.apps.fao.org/catalog/dataset/glw)            |  Population densities of major livestock animals (cattle, sheep, goats, pigs, chickens and ducks) on a five arc minute by five arc minute (~10km by ~10km) latitude/longitiude grid for the year 2015
[Sea Around Us](http://www.seaaroundus.org/data/#/spatial-catch)            |  Reconstructed reported and unreported catch data based on Exclusive Economic Zones on a three arc minute by three arc minute (~5.6km by ~5.6km) latitude/longitude grid for the year 2019
[FAO Nutritional Annex](https://www.fao.org/3/X9892E/X9892e05.htm)            |  FAO annexes of nutritional content by food commodity type
[USDA Nutrition Database](https://fdc.nal.usda.gov)            |  USDA additional nutritional content data
[SAGE Crop Calendars](https://sage.nelson.wisc.edu/data-and-models/datasets/crop-calendar-dataset/)            |  Crop planting and harvesting dates for 19 crops on a five arc minute by five arc minute (~10km by ~10km) latitude/longitiude grid for the year 2000
[Worldpop Population Count](https://hub.worldpop.org/geodata/summary?id=24777)            |  Spatial distribution of global population for 2020 on a 1km by 1km resolution
[Worldpop Age & Sex Structures](https://hub.worldpop.org/geodata/summary?id=24798)            |  Estimates of total number of people per grid square broken down by sex and age groupings (including 0-1 and by 5-year up to 80+) in 2020 on a 1km by 1km resolution
[FAO Urban Rural Catchments](https://data.apps.fao.org/catalog/iso/9dc31512-a438-4b59-acfd-72830fbd6943)            |  Spatial mask to identify urban and rural areas in 2021 on a 1km by 1 km resolution
[Global Dietary Database Diets](https://www.globaldietarydatabase.org/available-gdd-2018-estimates-datafiles)            |  Estimates of dietary intake by country, food group, sex, age, education level and residence (urban vs rural) for 185 countries for the year 2018

## Output Data
Production: Output data includes commodity level updated 2020 10km x 10km rasters at either an annual or monthly timescale for crops, livestock and catch.  Summaries (csv format) of the raster calculations to update data to 2020 are also included in the crop, livestock and catch summaries.  9 food groups (dairy & eggs, meat & fish, fruits, vegetables, starches, pulses, oilseeds, treenuts, sugars & sweeteners) were computed, also at both annual and monthly timescales. At this time we have not included the loss or diversion calculations for crops, which will be finalized after trade balancing.

Demand: Output data includes total and foodgroup level demand rasters at either an annual or monthly timescale 


 **Output Data** | **Description**
 ---               | ---        
[Total Production Maps](link) | Rasters of summed annual production of crops, livestock and catch for 2020 on a 10km x 10km grid (tonnage, calories, protein, fat)
[Food Group Production Maps](link) | Rasters of summed annual production by food groups for 2020 on a 10km x 10km grid (tonnage, calories, protein, fat)
[Crop Production Maps](link) | Rasters of summed crop production for X commodity for 2020 on a 10km x 10km grid (tonnage, calories, protein, fat)
[Livestock Production Maps](link) | Rasters of summed livestock production for Y meat, dairy or egg products for 2020 on a 10km x 10km grid (tonnage, calories, protein, fat)
[Catch Production Maps](link) | Rasters of summed catch production for Y commercial fish groups for 2020 on a 10km x 10km grid (tonnage, calories, protein, fat)
[Total Demand Maps](link) | Rasters of summed annual dietary demand for 2020 on a 10km x 10km grid (calories, protein, fat)
[Food Group Demand Maps](link) | Rasters of summed annual dietary demand by food group for 2020 on a 10km x 10km grid (calories, protein, fat)
[Demographic Demand Maps](link) | Rasters of summed annual dietary demand by demographics (age & sex) for 2020 on a 10km x 10km grid (calories, protein, fat)
[Locale Demand Maps](link) | Rasters of summed annual dietary demand by locale (urban vs rural) for 2020 on a 10km x 10km grid (calories, protein, fat)
