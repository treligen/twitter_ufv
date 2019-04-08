
# dependencies ------------------------------------------------------------
library(tidyverse)
library(tm)
library(stringr)
library(tidytext)



# read data ---------------------------------------------------------------

bar_atl <- read_rds("data/tw_bar_atl_es.RDS") %>% 
  mutate(text = tolower(text),
         text = removeNumbers(gsub("[\n➔]", "", text)),
         text = chartr('áéíóú','aeiou', text),
         text = gsub('ñ', 'n', text),
         text = gsub('\\p{So}|\\p{Cn}', '', 
                     text, 
                     perl = TRUE),
         text = gsub('fcbarcelona_es', 'barça', text),
         text = gsub('camp nou', 'campnou', text),
         text = gsub('diego costa', 'diegocosta', text),
         text = gsub('fc barcelona', 'barça', text))

insultos <- read_delim('/Users/lucianopataro/Downloads/text_mining/insultos_utf8.txt',
                       delim = "\t",
                       col_names = F)

# wordcloud ---------------------------------------------------------------
stop_words <- get_stopwords("es", source = "snowball")

# wordcloud for insults
insultos_df <- bar_atl %>% 
  unnest_tokens(word, text) %>% 
  anti_join(stop_words) %>% 
  filter(!word %in% c("rt")) %>%
  filter(word %in% insultos$X1) %>% 
  count(word, sort = TRUE)

wordcloud2::wordcloud2(insultos_df, color = c("#3ceca8", "firebrick"))


# wordcloud for frequency
freq_df <- bar_atl %>% 
  unnest_tokens(word, text) %>% 
  anti_join(stop_words) %>% 
  filter(!word %in% c("rt")) %>% 
  count(word, sort = TRUE)

wordcloud2::wordcloud2(freq_df)
