
# dependencies ------------------------------------------------------------

library(tidyverse)
library(sf)
library(tmaptools)
library(twitteR)
library(tm)



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

for(i in 1:length(res$location)){
  
  out[[i]] <- tryCatch({geocode_OSM(res$location[i])$coords})
  
}
