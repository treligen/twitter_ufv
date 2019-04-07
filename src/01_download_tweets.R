
# dependencies ------------------------------------------------------------

library(twitteR)
library(tidyverse)
library(tm)
library(stringr)

# api keys ----------------------------------------------------------------

consumer_key <- "RZwNs55phd6c4xPb2ySIWaEqT"
consumer_secret <- "gU4r84JHsCEkN98H4fLSWB8P5YSrsHxXRm7A6PInoRAo3NDRE9"

access_token <- "1114513154044825601-TCfPtTvGlnp8dttcsgvkHOWZKoPVgh"
access_secret <- "cc4mK695PM9sIuujv2sv8P0mNpIXFsqW2vJ9rLlcTk50V"

setup_twitter_oauth(consumer_key, 
                    consumer_secret,
                    access_token,
                    access_secret)


# download data -----------------------------------------------------------

# spanish
tw_es <- twitteR::searchTwitter('real madrid + valencia', 
                                n = 5000, 
                                since = '2019-04-03', 
                                until = '2019-04-04',
                                lang = "es") %>% 
  twListToDF() %>% 
  as_tibble() %>% 
  mutate(text = gsub("[\n]", "", text),
         text = gsub("http\\S+\\s*", "", text))



# english
tw_en <- twitteR::searchTwitter('real madrid + valencia', 
                                n = 5000, 
                                since = '2019-04-03', 
                                until = '2019-04-04',
                                lang = "en") %>% 
  twListToDF() %>% 
  as_tibble() %>% 
  mutate(text = gsub("[\n]", "", text),
         text = gsub("http\\S+\\s*", "", text))


# barça vs. atletico de madrid --------------------------------------------

# spanish
tw_barca_atleti <- twitteR::searchTwitter('barcelona + atletico de madrid', 
                                          n = 10000, 
                                          since = '2019-04-06', 
                                          until = '2019-04-07',
                                          lang = "es") %>% 
  twListToDF() %>% 
  as_tibble() %>% 
  mutate(text = gsub("[\n]", "", text),
         text = gsub("http\\S+\\s*", "", text))

# save data ---------------------------------------------------------------

saveRDS(tw_es, "data/tw_mad_val_es.RDS")

saveRDS(tw_en, "data/tw_mad_val_en.RDS")

saveRDS(tw_barca_atleti, "data/tw_bar_atl_es.RDS")

