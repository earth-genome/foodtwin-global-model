library(tidyverse)

#create monthly catch data from annual
#divide year by 12, create labels raster stack
filenames <- list.files(path="2020_catchrasters/annual", pattern='tif$', full.names=TRUE, recursive = TRUE)
for (i in seq_along(filenames)) {
  r <- raster(filenames[i])
  r12=r/12
  r_stack=stack(replicate(12, r12))
  names(r_stack) <- c("January", "February", "March", "April", "May", "June", "July", "August", "September",
                      "October", "November", "December")
  
  outputFile <- gsub("annual", "monthly", filenames[i], fixed=TRUE)
  writeRaster(r_stack, outputFile)
}
