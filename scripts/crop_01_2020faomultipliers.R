library(tidyverse)
#join faostat 2020 multipliers to earthstat table for referencing crops

fao_df <- read.csv("faostat_prodmultipliers2020.csv")
colnames(fao_df)[colnames(fao_df) == 'Item'] <- 'Cropname_FAO'
test <- fao_df %>% select(Cropname_FAO, Domain) %>% unique()

earthstat_lookup <- read_csv("earthstat_lookup.csv")
earthstat_lookup <- earthstat_lookup %>% filter(!GROUP %in% c("Fiber", "Forage"))
final_lookup <- left_join(earthstat_lookup, test, by="Cropname_FAO")
final_lookup <- left_join(final_lookup, fao_df, by=c("Cropname_FAO", "Domain"))

final_lookup$Multiplier[is.na(final_lookup$Multiplier)] <- 1
final_lookup$Multiplier[!is.finite(final_lookup$Multiplier)] <- 0

write_csv(final_lookup, "earthstat_faostat_joined2020multiplierlookup.csv")


#ff <- final_lookup %>% select(CROPNAME, Cropname_FAO, GROUP, Domain) %>% unique()
