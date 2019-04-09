
# dependencies ------------------------------------------------------------

library(tidyverse)
library(sf)
library(tmaptools)
library(twitteR)
library(tm)
library(leaflet)

# api keys ----------------------------------------------------------------

consumer_key <- "RZwNs55phd6c4xPb2ySIWaEqT"
consumer_secret <- "gU4r84JHsCEkN98H4fLSWB8P5YSrsHxXRm7A6PInoRAo3NDRE9"

access_token <- "1114513154044825601-TCfPtTvGlnp8dttcsgvkHOWZKoPVgh"
access_secret <- "cc4mK695PM9sIuujv2sv8P0mNpIXFsqW2vJ9rLlcTk50V"

setup_twitter_oauth(consumer_key, 
                    consumer_secret,
                    access_token,
                    access_secret)


# data --------------------------------------------------------------------

bar_atl <- read_rds("data/tw_bar_atl_es.RDS") %>% 
  mutate(latitude = as.numeric(latitude),
         longitude = as.numeric(longitude))


users_bar_atl <- lookupUsers(bar_atl$screenName) %>% 
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
for(i in 1:length(users_bar_atl$location)){
  
  out[[i]] <- tryCatch({geocode_OSM(users_bar_atl$location[i])$coords})
  
}

# so we carry on the loop
for(i in length(out):length(users_bar_atl$location)){
  
  out[[i]] <- tryCatch({geocode_OSM(users_bar_atl$location[i])$coords})
  
}


xy_bar_atl <- lapply(out, function(x) if(is.null(x)) c(x = NA, y = NA) else x) %>% 
  lapply(., bind_rows) %>% 
  bind_rows() %>% 
  mutate(match = "barca_atletico") %>% 
  rename(longitude = x,
         latitude = y)

# save data
saveRDS(xy_bar_atl, "data/geo_bar_atl.RDS")


# leaflet map -------------------------------------------------------------
xy_bar_atl %>% 
  leaflet() %>% 
  addProviderTiles(providers$CartoDB.DarkMatter) %>% 
  addMarkers(clusterOptions = markerClusterOptions(),
             label = ~htmltools::htmlEscape(match)) %>% 
  setView(lng = -4.4892414,
          lat = 39.6208638,
          zoom = 5)


