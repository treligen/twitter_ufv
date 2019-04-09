#' 
#' crear mapa de los tweets con los datos descargados.
#' 
#' utilizaremos la librería 'leaflet'  para crear el mapa interactivo.
#' El mapa se hace con el 'data.frame' generado, que es también el 
#' conjunto de datos que hemos guardado previamente ya que se trata 
#' de un análisis bastante denso y que tarda muchos minutos.


# dependencies ------------------------------------------------------------

source("src/taller/utils.R")
instalation_packages()

library(tidyverse)
library(leaflet)

# datos -------------------------------------------------------------------

# datos de los tweets del patido barça vs. atleti
xy_bar_atl <- read_rds("data/geo_bar_atl.RDS")


# Dibujamos el mapa para visualizar la cantidad de tweets 
# según su localización geográfica
xy_bar_atl %>% 
  leaflet() %>% 
  
  # añadimos una capa por debajo
  addProviderTiles(providers$NASAGIBS.ViirsEarthAtNight2012) %>% 
  
  # Calculamos e numero de tweets por local con la función
  # 'markerClusterOptions' y añadismo una label.
  addMarkers(clusterOptions = markerClusterOptions(),
             label = ~htmltools::htmlEscape(match)) %>% 
  
  # con la función 'setview' restringimos la vista del mapa a España.
  setView(lng = -4.4892414,
          lat = 39.6208638,
          zoom = 5)
