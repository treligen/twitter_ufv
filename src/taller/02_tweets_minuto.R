#'
#' Análisis del número de tweets
#' durante el partido
#' 


# dependencies -------------------------------------------------------------
source("src/taller/utils.R")
instalation_packages()

library(tidyverse)
library(lubridate)



# data --------------------------------------------------------------------

tw_barca_atleti <- read_rds("data/tw_bar_atl_es.RDS")



# data preparation --------------------------------------------------------

# Para el análisis de los tweets que se hacen durante el partido,
# solo se necesitan las variables text y created

tw_barca_atleti <- tw_barca_atleti %>% 
  select(text, created)

# Cuando se trabajan con fechas siempre hay que tener cuidado
# con el huso horario en el que está la fecha.
# Le especificamos a R que queremos que nos convierta created
# al uso horario de España
tw_barca_atleti$created <- with_tz(tw_barca_atleti$created, tzone = "Europe/Madrid")

# Además, vamos a querer agrupar la información minuto a minuto.
# Por lo tanto, en este contexto, los segundos en los que se
# publicó un tweet es irrelevante
second(tw_barca_atleti$created) <- 0

# Nos podemos asegurar rápidamente de que hemos
# hecho las transformaciones correctamente.
# Por ejemplo, sabemos que el partido comenzó
# a las 20:45. Alrededor de ese momento deberíamos
# tener tweets que reflejen el inicio.
tw_barca_atleti %>% 
  filter(created == ymd_hms("2019-04-06 20:47:00", tz = "Europe/Madrid"))


# Queremos ver cómo se comportó twitter durante el partido.
# En este caso, queremos saber la cantidad de tweets que hubo por minuto.

tw_per_minute <- tw_barca_atleti %>%
  group_by(created) %>% 
  summarise(n = n())

# Además, solo estamos interesados en los tweets
# que se escribieron durante el desarrollo del partido.
# Sabiendo que el partido comenzó a las 20:45,
# vamos a filtrar los tweets escritos entre las 20:15 y 23:00

tw_per_minute <- tw_per_minute %>% 
  filter(
    created > ymd_hms("2019-04-06 20:15:00", tz = "Europe/Madrid"),
    created < ymd_hms("2019-04-06 23:00:00", tz = "Europe/Madrid")
    )

# Si representamos la información

p <- tw_per_minute %>%
  ggplot(
    aes(x = created,
        y = n
        )
  ) +
  geom_line(color = "#3eaca8") +
  labs(
    title = "Número de tweets por minuto",
    caption = "Treligen: Taller de text mining",
    y = "",
    x = ""
  ) +
  theme_minimal() +
  scale_x_datetime(date_breaks = "15 mins",
                   date_labels = "%H:%M"
                   )

p

# En el gráfico se puede apreciar algunos patrones.
# ¿Podrías identificarlos?
 
# Según en qué contexto, puede ser útil tener un
# gráfico dinámico.
# La librería plotly nos permite convertir el 
# gráfico estático que hemos hecho antes
# en uno interactivo de forma muy sencilla.
plotly::ggplotly(p)
