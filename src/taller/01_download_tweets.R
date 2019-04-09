
#'
#' TALLER DE TEXT MINING: Extracción de tweets
#' 10 de abril de 2019
#' 
#' En este código se extraen tweets que contengan
#' las palabras Real Madrid, Valencia, Barcelona y Atlético de Madrid.
#' 
#' Para conectarse con la API de twitter, 
#' es necesario obtener las credenciales para acceder.
#' Se puede consultar cómo en
#' https://developer.twitter.com/en/docs.html
#' La cuenta gratuita tiene limitaciones en 
#' la información que se puede extraer.

# dependencies ------------------------------------------------------------

# Para la ejecución de los códigos, necesitamos instalar paquetes.
# En R, los paquetes son colecciones de funciones previamente programadas.
# Estos paquetes suelen estar disponibles publicamente en un repositorio central
# llamado CRAN en el que han que pasar ciertos controles de calidad.
# Algunos paquetes en desarrollo, se pueden descargar directamente desde GitHub.

# En el código utils.R, tenemos una función que comprueba si están instalados
# los paquetes que utilizaremos en este taller y, si no es así, los instala.
source("src/taller/utils.R") # Ejecutamos el código del archivo
instalation_packages()

# Una vez instalados los paquetes es necesario cargarlos en memoria
# con la función library(). 
# Esto cargará todas las funciones del paquete en la memoria del ordenador.
# Si solamente se va a utilizar una función del paquete, 
# no es necesario cargar el paquete entero y se puede acceder 
# directamente a la función como nombrepaquete::nombrefuncion()
# Por ejemplo twitteR::searchTwitter()
library(twitteR)
library(tidyverse)
library(tm)
library(stringr)

# api keys ----------------------------------------------------------------

# Se especifican las credenciales para iniciar la conexión
# con la API de twitter
consumer_key <- "RZwNs55phd6c4xPb2ySIWaEqT"
consumer_secret <- "gU4r84JHsCEkN98H4fLSWB8P5YSrsHxXRm7A6PInoRAo3NDRE9"

access_token <- "1114513154044825601-TCfPtTvGlnp8dttcsgvkHOWZKoPVgh"
access_secret <- "cc4mK695PM9sIuujv2sv8P0mNpIXFsqW2vJ9rLlcTk50V"

setup_twitter_oauth(consumer_key, 
                    consumer_secret,
                    access_token,
                    access_secret
                    )


# download data -----------------------------------------------------------

# Se descargan tweets especificando unos criterios de búsqueda
# Para ello se utiliza la función searchTwitter 
# del paquete twitteR

# Para conocer en detalle el funcionamiento de esta función
# puedes escribir ?searchTwitter en la consola
# para obtener la ayuda.

# spanish
tw_es <- twitteR::searchTwitter(
  # los términos de búsqueda se separan con +
  searchString = 'real madrid + valencia', 
  
  n = 5000, 
  
  since = '2019-04-03', 
  until = '2019-04-04',
  
  # idioma de los tweets
  lang = "es"
  ) 

# Por defecto, la función anterior
# devuelve los tweets como una lista.
# El manejo de la información se vuelve
# más sencillo si los datos están en 
# un formato tabla (en R se denomina data frame).
# El paquete twitteR tiene la función
# twListToDF para convertir los tweets a data frame.
tw_es <- twListToDF(tw_es)


# La función as_tibble convierte a un tipo de data frame especial
# que facilita la visualización de los datos en la consola.
tw_es <- as_tibble(tw_es)

# La extracción de los tweets contiene información que no es relevante
# para el estudio que queremos hacer. 
# Por ejemplo, los usuarios comparten enlaces a páginas web.
# En una limpieza básica de los datos, es necesario eliminar esta información.

# Algo muy útil es utilizar expresiones regulares 
# que permite encontrar patrones en cadenas de caracteres.
# https://en.wikipedia.org/wiki/Regular_expression
#
# Por ejemplo, la expresión regular "http\\S+\\s*"
# significa, encuentra la parte del texto que
# empieza por http, continuan caracteres 
# (a excepción de un espacio en blanco) 
# y termina con un espacio en blanco, /, o tabulador.
# Es decir, estamos buscando partes del texto que
# sean una url.

tw_es <- mutate(tw_es,
                   text = stringr::str_remove(text, "[\n]"),
                   text = stringr::str_remove(text, "http\\S+\\s*")
                   )




# english
# Repetimos el mismo procedimiento para tweets en inglés.
tw_en <- twitteR::searchTwitter('real madrid + valencia', 
                                n = 5000, 
                                since = '2019-04-03', 
                                until = '2019-04-04',
                                lang = "en") %>% 
  twListToDF() %>% 
  as_tibble() %>% 
  mutate(text = stringr::str_remove(text, "[\n]"),
         text = stringr::str_remove(text, "http\\S+\\s*")
         )

# Nota:
# en las líneas anteriores, en vez de hacerlo paso a paso
# como hicimos en castellano, hemos utilizado %>% (operador pipe)
# que es capaz de encadenar varias sentencias en una sola.
# Es una forma más compacta de hacerlo y puede ayudar
# a hacer el código más conciso y expresivo.


# barça vs. atletico de madrid --------------------------------------------

# spanish
tw_barca_atleti <- twitteR::searchTwitter('barcelona OR atletico de madrid OR barça OR atleti', 
                                          n = 100000, 
                                          since = '2019-04-06', 
                                          until = '2019-04-07',
                                          lang = "es") %>% 
  twListToDF() %>% 
  as_tibble() %>% 
  mutate(text = stringr::str_remove(text, "[\n]"),
         text = stringr::str_remove(text, "http\\S+\\s*")
  )

# save data ---------------------------------------------------------------

# Dadas las limitaciones de la API,
# no podemos estar haciendo una nueva extracción
# cada vez que necesitamos utilizar los datos.
# Además, R trabaja en memoria, es decir que
# si cerramos la sesión, perderemos todo lo que 
# tengamos cargado en ese momento.
# 
# Así que, lo habitual es hacer la extracción,
# una limpieza básica de los tweets como la 
# que hemos hecho con la url 
# y almacenar la información en el disco duro
# para poder utilizarla cuando la necesitemos.

# Si vamos a trabajar posteriormente con R,
# lo ideal es guardarlo en .RDS un formato
# binario específico de R que es fácil de cargar.
saveRDS(tw_es, "data/tw_mad_val_es.RDS")

saveRDS(tw_en, "data/tw_mad_val_en.RDS")

saveRDS(tw_barca_atleti, "data/tw_bar_atl_es.RDS")

