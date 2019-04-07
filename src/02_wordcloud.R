
# dependencies ------------------------------------------------------------
library(tidyverse)
library(tm)
library(stringr)
library(tidytext)


# read data ---------------------------------------------------------------

mad_val <- read_rds("data/tw_mad_val_es.RDS") %>% 
  mutate(text = tolower(text),
         text = removeNumbers(gsub("[\n➔]", "", text)),
         text = chartr('áéíóú','aeiou', text),
         text = gsub('ñ', 'n', text),
         text = gsub('\\p{So}|\\p{Cn}', '', 
                     text, 
                     perl = TRUE),
         text = gsub('madrid.', "madrid", text),
         text = gsub('[[:punct:]]', '', text),
         text = gsub('valenciacf', "valencia", text),
         text = gsub('real madrid', "realmadrid", text))

insultos <- read_delim('/Users/lucianopataro/Downloads/text_mining/insultos_utf8.txt',
                       delim = "\t",
                       col_names = F)

# wordcloud ---------------------------------------------------------------
stop_words <- get_stopwords("es", source = "snowball")


insultos_df <- mad_val %>% 
  unnest_tokens(word, text) %>% 
  anti_join(stop_words) %>% 
  filter(!word %in% c("mestalla", 
                      "guedes",
                      "garay",
                      "rt")) %>%
  filter(word %in% insultos$X1) %>% 
  count(word, sort = TRUE)

wordcloud2(insultos_df, color = c("#3ceca8", "firebrick"))
