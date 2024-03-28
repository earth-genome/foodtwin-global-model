# Food Twin Global Model
Repository for our work on the global foodtwin model and application. The application developed to visualize this model is in the Food Twin Global App repo. 

## Overview
This repository contains data sources for global production of primary crops, livestock and fisheries/catch products at a 10km x 10km resolution, with scaling for all products to 2020 values (to match with FAOSTAT reported country level data). Production was computed both at annual and monthly timescales and products were aggregated to 9 major food groups.

## Input Data
Input data includes historical crop maps from Earthstat, livestock density maps for Global Livestock of the World and fisheries/catch data from Sea Around Us.  Augmenting this data includes FAOSTAT data for crops and livestock for the base year of the data and target year of 2020, nutrition data (mostly also from FAO Annexes), crop calendars from SAGE and updated harvested area data from CROPGRIDS.  Shapefiles of countries were retrieved from Natural Earth.

## Output Data
Output data includes commodity level updated 2020 rasters at either an annual or monthly timescale for crops, livestock and catch.  Summaries (csv format) of the raster calculations to update data to 2020 are also included in the crop, livestock and catch summaries.  9 food groups (dairy & eggs, meat & fish, fruits, vegetables, starches, pulses, oilseeds, treenuts, sugars & sweeteners) were computed, also at both annual and monthly timescales.  At this time we have not included the loss or diversion calculations for crops, which will be finalized after trade balancing.
