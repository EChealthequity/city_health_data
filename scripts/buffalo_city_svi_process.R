#====# Buffalo City Health Data #====#

# Library Load-in====
library(tidyverse) # For everything data
library(sf) # For converting shapefiles into workable data and writing them
library(janitor) # For cleaning variables

# Data Load-in====
cityhealth_data <- read_sf('data/NewYork/SVI2018_NEWYORK_tract.shp')

eriehealth_data <- cityhealth_data %>%
  filter(COUNTY == "Erie") %>%
  clean_names() %>%
  mutate(location = str_extract(location, "\\d+\\.*\\d*"))

#Buffalo filtering===
#Buffalo tracts==
buffalo_tracts <- read_csv("../census_data/scripts/utilities/buffalo_tracts.csv",
                           col_types = cols(tract = col_character()))

#filtering for buffalo tracts==
buffalohealth_data <- eriehealth_data %>%
  filter(location %in% buffalo_tracts$tract)

#pulling in more readable variable names==
column_names <- read_csv("data/SVI Var Names.csv")

column_names <- deframe(column_names)

buffalohealth_data <- buffalohealth_data %>%
  rename(!!!column_names)

# Isolating geometry data for the individual metrics data===
buffalo_tract_geo <- buffalohealth_data %>%
  select(tract_fips,tract,geometry)

# Data Load in for Individual Metric Data Per Tract====
metrics_us_data <- read_csv("data/CHDB_data_tract_all_v13.1.csv")

# Filtering for buffalo===
metrics_erie_data <- metrics_us_data %>%
  filter(state_abbr == "NY",
         county_name == "Erie County") %>%
  mutate(stcotr_fips = as.character(stcotr_fips)) %>%
  left_join(.,buffalo_tract_geo, by = c("stcotr_fips" = "tract_fips"))


# Writing out the geometry files for use in Tableau Public==
st_write(metrics_erie_data, "data/buffalo city health metrics.shp")

simple_buff_data <- st_collection_extract(buffalohealth_data, "POLYGON")
st_write(simple_buff_data, "data/buffalo city health SVI metrics.shp")



