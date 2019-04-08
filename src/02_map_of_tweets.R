
# dependencies ------------------------------------------------------------

library(tidyverse)
library(sf)
library(tmaptools)
library(twitteR)
library(tm)
library(leaflet)


# data --------------------------------------------------------------------

mad_val <- read_rds("data/tw_mad_val_es.RDS") %>% 
  mutate(latitude = as.numeric(latitude),
         longitude = as.numeric(longitude))


res <- lookupUsers(mad_val$screenName) %>% 
  twListToDF() %>% 
  as_tibble() %>% 
  mutate(location = tolower(gsub('España', 'Spain', location)),
         location = gsub('\\p{So}|\\p{Cn}', # remove emojis code
                         '', 
                         location, 
                         perl = TRUE),
         location = gsub('#', '', location)) %>% 
  filter(is.na(as.numeric(location))) %>% 
  filter(location != "") 


out <- list()

# sometimes the API stops due to the large amount of request
for(i in 1209:length(res$location)){
  
  out[[i]] <- tryCatch({geocode_OSM(res$location[i])$coords})
  
}

xy_mad_val <- bind_rows(lapply(out, bind_rows)) %>% 
  bind_cols() %>% 
  mutate(match = "barca_atletico") %>% 
  rename(long = x,
         lat = y)


# leaflet map -------------------------------------------------------------
xy_mad_val %>% 
  leaflet() %>% 
  addProviderTiles(providers$CartoDB.DarkMatter) %>% 
  addMarkers(clusterOptions = markerClusterOptions(),
             label = ~htmltools::htmlEscape(match))


