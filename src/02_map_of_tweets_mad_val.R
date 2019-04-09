
# dependencies ------------------------------------------------------------

library(tidyverse)
library(sf)
library(tmaptools)
library(twitteR)
library(tm)
library(leaflet)


# data --------------------------------------------------------------------

users_mad_val <- lookupUsers(mad_val$screenName) %>% 
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

# sometimes the API stops due to the large amount of request.....
for(i in 1:length(users_mad_val$location)){
  
  out[[i]] <- tryCatch({geocode_OSM(users_mad_val$location[i])$coords})
  
}

# so we carry on the loop
for(i in length(out):length(users_mad_val$location)){
  
  out[[i]] <- tryCatch({geocode_OSM(users_mad_val$location[i])$coords})
  
}


xy_mad_val <- lapply(out, function(x) if(is.null(x)) c(x = NA, y = NA) else x) %>% 
  lapply(., bind_rows) %>% 
  bind_rows() %>% 
  mutate(match = "madrid_valencia") %>% 
  rename(longitude = x,
         latitude = y)

# save data
saveRDS(xy_mad_val, "data/geo_mad_val.RDS")

# leaflet map -------------------------------------------------------------
xy_mad_val %>% 
  leaflet() %>% 
  addProviderTiles(providers$CartoDB.DarkMatter) %>% 
  addMarkers(clusterOptions = markerClusterOptions(),
             label = ~htmltools::htmlEscape(match))


