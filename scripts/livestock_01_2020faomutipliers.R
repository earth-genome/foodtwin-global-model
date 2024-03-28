library(tidyverse)
#load faostat data, average 1997-2003, determine 2020 multiplier for all animals/countries
#sheep, pigs, goats, ducks, chickens, cattle
#get carcass weights

#crops
df <- read_csv("input_data/FAOSTAT_data_livestock_fin.csv") 
df <- df %>% select(Domain, `Area Code (M49)`, Area, `Element Code`, Element, `Item Code (CPC)`, Item, Year, Unit, Value)
#df_00 <- df %>% filter(!Year == 2020)
#df_00 <- df_00 %>% group_by(Area, Item, Unit) %>% summarize(Value_00=mean(Value, na.rm = TRUE))

df_20 <- df %>% filter(Year == 2020)
df_20 <- df_20 %>% filter(Element %in% c("Yield", "Yield/Carcass Weight", "Producing Animals/Slaughtered",
                                         "Milk Animals", "Laying"))


df_20 <- df_20 %>% select(Area, Item,  `Area Code (M49)`, Unit, Value) %>% mutate(Value_20=Value) %>% select(-Value)

Items <- c("Hen eggs in shell, fresh", "Meat of cattle with the bone, fresh or chilled", 
              "Meat of chickens, fresh or chilled", "Meat of goat, fresh or chilled", 
              "Meat of sheep, fresh or chilled", "Raw milk of cattle", "Raw milk of goats",
              "Meat of pig with the bone, fresh or chilled", "Meat of ducks, fresh or chilled")

df_20 <- df_20 %>% filter(Item %in% Items)
Animal <- c("eggs", "beef", "chickenmeat", "goatmeat", "sheepmeat", "cowsmilk", "goatmilk", "pigmean", "duckmeat")
animal_lookup <- data.frame(Items, Animal)
colnames(animal_lookup) <- c("Item", "Animal")
df_20 <- left_join(df_20, animal_lookup, by="Item")
write_csv(df_20, "input_data/faostat_livmultipliers2020_total.csv")
