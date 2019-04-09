#' 
#' Análisis espacial de los tweets 
#' durante los partidos

# dependencies ------------------------------------------------------------
source("src/taller/utils.R")
instalation_packages()

library(tidyverse)
library(sf)
library(tmaptools)
library(twitteR)
library(tm)
library(leaflet)


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
#' 

users_mad_val <- lookupUsers(mad_val$screenName) %>%
  
  # transformamos a un "data.frame"...
  twListToDF() %>% 
  
  #y a un  "tibble" por ser más conveniente
  as_tibble() %>% 
  
  # cambiamos 'España' por 'Spain' y todas las palabras a minúsculas
  mutate(location = tolower(gsub('España', 'Spain', location)),
         
         # removemos los emojis y sus códigos
         location = gsub('\\p{So}|\\p{Cn}', 
                         '', 
                         location, 
                         perl = TRUE),
         
         # removemos también las almohadillas
         location = gsub('#', '', location)) %>% 
  
  # quitamos las localizaciones que son numeros y vacías
  filter(is.na(as.numeric(location))) %>% 
  filter(location != "") 


#' con este 'data.frame' podemos buscar las coordenadas geográficas
#' através de la función "geocode_OSM" del paquete "tmaptools". 
#' Utilizaremos ese dato para pintar las coordenadas en un mapa.
#' 
#' Haremos eso con un bucle 'for' que recorrerá todas las 
#' localizaciones dentro de 'users_mad_val$location'.
#' 

#' primero creamos una lista vacía para almacenar los resultados
out <- list()

#' y ahora lanzamos el bucle. Algunas veces la API impede que 
for(i in 1:length(users_mad_val$location)){
  
  # la función 'tryCatch' nos ayuda a seguir ejecutando el bucle 
  # cuando ninguna localización es encontrada. Nos quedamos solo
  # con las coordenadas geográficas (coords)
  out[[i]] <- tryCatch({geocode_OSM(users_mad_val$location[i])$coords})
  
}

#' descarguemos muchos datos a la vez. Si eso sucede, 
#' hay que esperar algunos minutos para seguir con el bucle.
#' Seguimos con el bucle desde donde ha parado. 
for(i in length(out):length(users_mad_val$location)){
  
  out[[i]] <- tryCatch({geocode_OSM(users_mad_val$location[i])$coords})
  
}

#' crearemos un conjunto de datos con las coordenadas 
#' sacadas en el bucle.
#' 
#' Lo primero tenemos que identificar los elementos 
#' que son nulos (NULL) y transformarlos en el mismo formato que 
#' no sale las informaciones con coordenadas.
xy_mad_val <- lapply(out, function(x) if(is.null(x)) c(x = NA, y = NA) else x) %>% 
  
  # juntos en un 'data.frame'
  lapply(bind_rows) %>% 
  bind_rows() %>% 
  
  # creamos una variable para identificar el partido
  mutate(match = "madrid_valencia") %>% 
  
  # cambiamos el nombre de las variables
  rename(longitude = x,
         latitude = y)

# guardamos el 'data.frame' para un futuro.
saveRDS(xy_mad_val, "data/geo_mad_val.RDS")



