library(raster)
library(sp)   
library(purrr)
library(tidyverse)


#Livestock Losses and Diversion
# the FAOSTATconversion ratios of animals to meat volumes used for cattle, pig, goat, sheep and chicken meat 
#were already dressed carcass weights
#no conversion ratio for milk either
#the only conversion here is eggs with shell to eggs without shell

#to convert to calories of shell-less eggs, we will need to load volume raster, subtract weights and recalculate calories
#in discarded weights lookup table, hen eggs with shell have 12% discarded weights
shell_eggs<-'2020_livestockrasters/annual/noloss/tonnage/individualitem/2020_eggs_annual_production_noloss.tif' 
eggswithshell=raster(shell_eggs)
eggswithshell_reduced=eggswithshell*0.88

#check to make sure raster operation was correct
max1 <- eggswithshell@data@max
max2 <- eggswithshell_reduced@data@max
isTRUE(max1*0.88==max2)

#complete for other rasters
shell_eggscal<-'2020_livestockrasters/annual/noloss/calories/individualitem/2020_eggs_annual_calories_noloss.tif' 
eggswithshellcal=raster(shell_eggscal)
eggswithshellcal=eggswithshellcal*0.88

shell_eggsfat<-'2020_livestockrasters/annual/noloss/fats/individualitem/2020_eggs_annual_fats_noloss.tif' 
eggswithshellfat=raster(shell_eggsfat)
eggswithshellfat=eggswithshellfat*0.88

shell_eggspr<-'2020_livestockrasters/annual/noloss/protein/individualitem/2020_eggs_annual_protein_noloss.tif' 
eggswithshellprt=raster(shell_eggspr)
eggswithshellprt=eggswithshellprt*0.88

#write to file
writeRaster(eggswithshell_reduced, '2020_livestockrasters/annual/withloss/tonnage/individualitem/2020_eggs_annual_production_withloss.tif', overwrite=TRUE)
writeRaster(eggswithshellcal, '2020_livestockrasters/annual/withloss/calories/individualitem/2020_eggs_annual_calories_withloss.tif', overwrite=TRUE)
writeRaster(eggswithshellfat, '2020_livestockrasters/annual/withloss/fats/individualitem/2020_eggs_annual_fats_withloss.tif', overwrite=TRUE)
writeRaster(eggswithshellprt, '2020_livestockrasters/annual/withloss/protein/individualitem/2020_eggs_annual_protein_withloss.tif', overwrite=TRUE)


#write other meat files to file
#sheepmeat
sh_vol=raster('2020_livestockrasters/annual/noloss/tonnage/individualitem/2020_sheepmeat_annual_production_noloss.tif')
sh_cal=raster('2020_livestockrasters/annual/noloss/calories/individualitem/2020_sheepmeat_annual_calories_noloss.tif')
sh_fat=raster('2020_livestockrasters/annual/noloss/fats/individualitem/2020_sheepmeat_annual_fats_noloss.tif')
sh_prt=raster('2020_livestockrasters/annual/noloss/protein/individualitem/2020_sheepmeat_annual_protein_noloss.tif')

writeRaster(sh_vol, '2020_livestockrasters/annual/withloss/tonnage/individualitem/2020_sheepmeat_annual_production_withloss.tif')
writeRaster(sh_cal, '2020_livestockrasters/annual/withloss/calories/individualitem/2020_sheepmeat_annual_calories_withloss.tif')
writeRaster(sh_fat, '2020_livestockrasters/annual/withloss/fats/individualitem/2020_sheepmeat_annual_fats_withloss.tif')
writeRaster(sh_prt, '2020_livestockrasters/annual/withloss/protein/individualitem/2020_sheepmeat_annual_protein_withloss.tif')

#beef
bf_vol=raster('2020_livestockrasters/annual/noloss/tonnage/individualitem/2020_beef_annual_production_noloss.tif')
bf_cal=raster('2020_livestockrasters/annual/noloss/calories/individualitem/2020_beef_annual_calories_noloss.tif')
bf_fat=raster('2020_livestockrasters/annual/noloss/fats/individualitem/2020_beef_annual_fats_noloss.tif')
bf_prt=raster('2020_livestockrasters/annual/noloss/protein/individualitem/2020_beef_annual_protein_noloss.tif')

writeRaster(bf_vol, '2020_livestockrasters/annual/withloss/tonnage/individualitem/2020_beef_annual_production_withloss.tif')
writeRaster(bf_cal, '2020_livestockrasters/annual/withloss/calories/individualitem/2020_beef_annual_calories_withloss.tif')
writeRaster(bf_fat, '2020_livestockrasters/annual/withloss/fats/individualitem/2020_beef_annual_fats_withloss.tif')
writeRaster(bf_prt, '2020_livestockrasters/annual/withloss/protein/individualitem/2020_beef_annual_protein_withloss.tif')


#pigmeat
pg_vol=raster('2020_livestockrasters/annual/noloss/tonnage/individualitem/2020_pigmeat_annual_production_noloss.tif')
pg_cal=raster('2020_livestockrasters/annual/noloss/calories/individualitem/2020_pigmeat_annual_calories_noloss.tif')
pg_fat=raster('2020_livestockrasters/annual/noloss/fats/individualitem/2020_pigmeat_annual_fats_noloss.tif')
pg_prt=raster('2020_livestockrasters/annual/noloss/protein/individualitem/2020_pigmeat_annual_protein_noloss.tif')

writeRaster(pg_vol, '2020_livestockrasters/annual/withloss/tonnage/individualitem/2020_pigmeat_annual_production_withloss.tif')
writeRaster(pg_cal, '2020_livestockrasters/annual/withloss/calories/individualitem/2020_pigmeat_annual_calories_withloss.tif')
writeRaster(pg_fat, '2020_livestockrasters/annual/withloss/fats/individualitem/2020_pigmeat_annual_fats_withloss.tif')
writeRaster(pg_prt, '2020_livestockrasters/annual/withloss/protein/individualitem/2020_pigmeat_annual_protein_withloss.tif')

#goatmeat
gt_vol=raster('2020_livestockrasters/annual/noloss/tonnage/individualitem/2020_goatmeat_annual_production_noloss.tif')
gt_cal=raster('2020_livestockrasters/annual/noloss/calories/individualitem/2020_goatmeat_annual_calories_noloss.tif')
gt_fat=raster('2020_livestockrasters/annual/noloss/fats/individualitem/2020_goatmeat_annual_fats_noloss.tif')
gt_prt=raster('2020_livestockrasters/annual/noloss/protein/individualitem/2020_goatmeat_annual_protein_noloss.tif')

writeRaster(gt_vol, '2020_livestockrasters/annual/withloss/tonnage/individualitem/2020_goatmeat_annual_production_withloss.tif')
writeRaster(gt_cal, '2020_livestockrasters/annual/withloss/calories/individualitem/2020_goatmeat_annual_calories_withloss.tif')
writeRaster(gt_fat, '2020_livestockrasters/annual/withloss/fats/individualitem/2020_goatmeat_annual_fats_withloss.tif')
writeRaster(gt_prt, '2020_livestockrasters/annual/withloss/protein/individualitem/2020_goatmeat_annual_protein_withloss.tif')

#chickenmeat
ck_vol=raster('2020_livestockrasters/annual/noloss/tonnage/individualitem/2020_chickenmeat_annual_production_noloss.tif')
ck_cal=raster('2020_livestockrasters/annual/noloss/calories/individualitem/2020_chickenmeat_annual_calories_noloss.tif')
ck_fat=raster('2020_livestockrasters/annual/noloss/fats/individualitem/2020_chickenmeat_annual_fats_noloss.tif')
ck_prt=raster('2020_livestockrasters/annual/noloss/protein/individualitem/2020_chickenmeat_annual_protein_noloss.tif')

writeRaster(ck_vol, '2020_livestockrasters/annual/withloss/tonnage/individualitem/2020_chickenmeat_annual_production_withloss.tif')
writeRaster(ck_cal, '2020_livestockrasters/annual/withloss/calories/individualitem/2020_chickenmeat_annual_calories_withloss.tif')
writeRaster(ck_fat, '2020_livestockrasters/annual/withloss/fats/individualitem/2020_chickenmeat_annual_fats_withloss.tif')
writeRaster(ck_prt, '2020_livestockrasters/annual/withloss/protein/individualitem/2020_chickenmeat_annual_protein_withloss.tif')


#cowsmilk
cm_vol=raster('2020_livestockrasters/annual/noloss/tonnage/individualitem/2020_cowsmilk_annual_production_noloss.tif')
cm_cal=raster('2020_livestockrasters/annual/noloss/calories/individualitem/2020_cowsmilk_annual_calories_noloss.tif')
cm_fat=raster('2020_livestockrasters/annual/noloss/fats/individualitem/2020_cowsmilk_annual_fats_noloss.tif')
cm_prt=raster('2020_livestockrasters/annual/noloss/protein/individualitem/2020_cowsmilk_annual_protein_noloss.tif')

writeRaster(cm_vol, '2020_livestockrasters/annual/withloss/tonnage/individualitem/2020_cowsmilk_annual_production_withloss.tif')
writeRaster(cm_cal, '2020_livestockrasters/annual/withloss/calories/individualitem/2020_cowsmilk_annual_calories_withloss.tif')
writeRaster(cm_fat, '2020_livestockrasters/annual/withloss/fats/individualitem/2020_cowsmilk_annual_fats_withloss.tif')
writeRaster(cm_prt, '2020_livestockrasters/annual/withloss/protein/individualitem/2020_cowsmilk_annual_protein_withloss.tif')


#goatsmilk
gl_vol=raster('2020_livestockrasters/annual/noloss/tonnage/individualitem/2020_goatmilk_annual_production_noloss.tif')
gl_cal=raster('2020_livestockrasters/annual/noloss/calories/individualitem/2020_goatmilk_annual_calories_noloss.tif')
gl_fat=raster('2020_livestockrasters/annual/noloss/fats/individualitem/2020_goatmilk_annual_fats_noloss.tif')
gl_prt=raster('2020_livestockrasters/annual/noloss/protein/individualitem/2020_goatmilk_annual_protein_noloss.tif')

writeRaster(gl_vol, '2020_livestockrasters/annual/withloss/tonnage/individualitem/2020_goatmilk_annual_production_withloss.tif')
writeRaster(gl_cal, '2020_livestockrasters/annual/withloss/calories/individualitem/2020_goatmilk_annual_calories_withloss.tif')
writeRaster(gl_fat, '2020_livestockrasters/annual/withloss/fats/individualitem/2020_goatmilk_annual_fats_withloss.tif')
writeRaster(gl_prt, '2020_livestockrasters/annual/withloss/protein/individualitem/2020_goatmilk_annual_protein_withloss.tif')

