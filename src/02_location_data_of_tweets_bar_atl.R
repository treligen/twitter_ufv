#' 
#' Análisis espacial de los tweets 
#' durante los partidos
#' 
# dependencies ------------------------------------------------------------
source("src/taller/utils.R")
instalation_packages()

library(tidyverse)
library(sf)
library(tmaptools)
library(twitteR)
library(tm)
library(leaflet)

# api keys ----------------------------------------------------------------
# cargamos las API keys necesarias para ejectuar las funciones del paquete
# 'twitteR'
consumer_key <- "RZwNs55phd6c4xPb2ySIWaEqT"
consumer_secret <- "gU4r84JHsCEkN98H4fLSWB8P5YSrsHxXRm7A6PInoRAo3NDRE9"

access_token <- "1114513154044825601-TCfPtTvGlnp8dttcsgvkHOWZKoPVgh"
access_secret <- "cc4mK695PM9sIuujv2sv8P0mNpIXFsqW2vJ9rLlcTk50V"

setup_twitter_oauth(consumer_key, 
                    consumer_secret,
                    access_token,
                    access_secret)


# data --------------------------------------------------------------------

#' vamos a utilizar los datos ya descargados para generar un mapa 
#' interactivo de los tweets.
#' 
#' Es conveniente transfomar nuestro objeto tipo
#' "list" en un objeto tipo "data.frame". Utilizaremos la función 
#' "twListToDF" para luego analizar la localización de los usuários
#' con la función 'lookupUsers', ambas del paquete "tweetR". 
#' 
#' La variable necesaria para sacar la información se llama "screenName".

bar_atl <- read_rds("data/tw_bar_atl_es.RDS") %>% 
  mutate(latitude = as.numeric(latitude),
         longitude = as.numeric(longitude))

fake_addr <- "street gang blood.  ripspeakeknockerz  rip lil peep ✞ fredo santana i love yu bitch rip a real savage longlive\U0001f499 freedom all my rappers \U0001f54a️abla..."


users_bar_atl <- lookupUsers(bar_atl$screenName) %>%
  
  # transformamos a un "data.frame"...
  twListToDF() %>% 
  
  # y a un  "tibble" por ser más conveniente
  as_tibble() %>% 
  
  # cambiamos 'España' por 'Spain' y todas las palabras a minúsculas
  mutate(location = tolower(gsub('España', 'Spain', location)),
         
         # removemos los emojis y sus códigos
         location = gsub('\\p{So}|\\p{Cn}', 
                         '', 
                         location, 
                         perl = TRUE),
         
         # removemos también las almohadillas
         location = str_remove(location, '#'),
         
         # removemos algunas localidades...
         location = str_remove(location, fake_addr),
         location = str_remove(location, "córdoba | #madrid")) %>%
  
  # quitamos las localizaciones que son numeros y vacías
  filter(is.na(as.numeric(location))) %>% 
  filter(location != "") 


# con este 'data.frame' podemos buscar las coordenadas geográficas
# através de la función "geocode_OSM" del paquete "tmaptools". 
# Utilizaremos ese dato para pintar las coordenadas en un mapa.
# 
# Haremos eso con un bucle 'for' que recorrerá todas las 
# localizaciones dentro de 'users_mad_val$location'.

# primero creamos una lista vacía para almacenar los resultados
out <- list()

# y ahora lanzamos el bucle.
for(i in 1:length(users_bar_atl$location)){
  
  # la función 'tryCatch' nos ayuda a seguir ejecutando el bucle 
  # cuando ninguna localización es encontrada. Nos quedamos solo
  # con las coordenadas geográficas (coords)
  out[[i]] <- tryCatch({geocode_OSM(users_bar_atl$location[i])$coords})
  
}

# Algunas veces la API impede que  descarguemos muchos datos a la vez. 
# Si eso sucede, hay que esperar algunos minutos para seguir con el bucle.
# Seguimos con el bucle desde donde ha parado. 
for(i in length(out):length(users_bar_atl$location)){
  
  out[[i]] <- tryCatch({geocode_OSM(users_bar_atl$location[i])$coords})
  
}

# crearemos un conjunto de datos con las coordenadas 
# sacadas en el bucle.
# 
# Lo primero tenemos que identificar los elementos 
# que son nulos (NULL) y transformarlos en el mismo formato que 
# no sale las informaciones con coordenadas.

xy_bar_atl <- lapply(out, function(x) if(is.null(x)) c(x = NA, y = NA) else x) %>% 
  
  # juntos en un 'data.frame'
  lapply(bind_rows) %>% 
  bind_rows() %>% 
  
  # creamos una variable para identificar el partido
  mutate(match = "madrid_valencia") %>% 
  
  # cambiamos el nombre de las variables
  rename(longitude = x,
         latitude = y)

# guardamos el 'data.frame' para un futuro.
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


