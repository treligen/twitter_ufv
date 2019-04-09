#' 
#' Crear nube de palabras (wordcloud) de las palabras
#' más frecuentes en los tweets descargados
#' 
# dependencies ------------------------------------------------------------
source("src/taller/utils.R")
instalation_packages()

library(tidyverse)
library(tm)
library(stringr)
library(tidytext)


# read data ---------------------------------------------------------------
# utlizaremos los datos ya descargados para poder hacer la 
# nube de palabras. Antes es necesario hacer una pequeña limpieza 
# de los datos

bar_atl <- read_rds("data/tw_bar_atl_es.RDS") 
text=str_replace_all(bar_atl$text,"[^[:graph:]]", " ") 

        # pasamos todas las palabras a minúsculas
        text = tolower(text)
               
         # removemos los números y acentos 
         text = removeNumbers(gsub("[\n➔]", "", text))
         text = chartr('áéíóúñ','aeioun', text)
         
         # removemos emojis
         text = gsub('\\p{So}|\\p{Cn}', '', 
                     text, 
                     perl = TRUE)
         
         # cambiamos algunas palabras para evitar confusión
         text = gsub('fcbarcelona_es', 'barça', text)
         text = gsub('camp nou', 'campnou', text)
         text = gsub('diego costa', 'diegocosta', text)
         text = gsub('suarez', 'luis suarez', text)
         text = gsub('luis suarez', 'luissuarez', text)
         text = gsub('luisluissuarez', 'luissuarez', text)
         text = gsub('fc barcelona', 'barça', text)
         text = gsub('barcelona', 'barça', text)
         text = gsub('atletico de madrid', 'atleti', text)
         text = gsub('atletico', 'atleti', text)


# cargamos también el diccionário de insultos disponible en:
# "Inventario de Insultos en Castellano", por  Pancracio Celdrán

insultos <- read_delim('data/insultos.txt',
                       delim = "\t",
                       col_names = F)

# wordcloud ---------------------------------------------------------------
# necesitamos las 'stop words' que incluyen preposiciones, articulos,
# preposiciones y conjunciones. 
# Utilizaremos las 'stop words' en Castellano del paquete 'tidytext'.

stop_words <- get_stopwords("es", source = "snowball")


# para generar la nube de palabras de los insultos en los tweets necesitamos 
# isolar las palabras del texto, eliminar las 'stop words' 
# y calcular su frecuencia

insultos_df <- bar_atl %>% 
  # isolamos las palabras del texto
  unnest_tokens(word, text) %>% 
  
  # eliminamos las 'stop words'
  anti_join(stop_words) %>% 
  
  # quitamos la palabra rt (retweet)
  filter(!word %in% c("rt")) %>%
  
  # nos quedamos con los insultos
  filter(word %in% insultos$X1) %>%
  
  # y por fin contamos las palabras
  count(word, sort = TRUE)


# creamos la nube de palabras
wordcloud2::wordcloud2(insultos_df, color = c("#3ceca8", "firebrick"),2)


# repetimos el procedimiento anterior pero sin remover los insultos para
# crear la nube de todas las palabras 

freq_df <- bar_atl %>% 
  unnest_tokens(word, text) %>% 
  anti_join(stop_words) %>% 
  filter(!word %in% c("rt")) %>% 
  count(word, sort = TRUE)

wordcloud2::wordcloud2(freq_df)
