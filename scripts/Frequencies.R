
library(tidyverse)
library(quanteda)
library(quanteda.textmodels)
library(quanteda.textplots)
library(quanteda.textstats)
library(ggplot2)


corpus_files <- list.files(path = "corpus", pattern = "*.txt", full.names = T)


corpus_source <- corpus_files %>%  
  set_names(.) %>% 
  map_df(read.delim, fileEncoding = "utf-8", 
         .id = "filename", 
         header = F) %>%
  rename(text = V1) %>%
  
  # read the metadata
  left_join(read.csv("metadata.csv", stringsAsFactors = F))

quanteda_texts <- quanteda::corpus(corpus_source)

# Corpus summary and plots ------------------

tokeninfo <- summary(quanteda_texts)

print(tokeninfo)

colnames(quanteda_texts_dfm@docvars)

# Tokens corpus ---------------

## remove stopwords, update language encoding (de) and remove names

library(readxl)

# create a dfm corpus

quanteda_texts_tok <- quanteda::tokens(quanteda_texts, 
                                       remove_punct = T,
                                       split_hyphens = F,
                                       remove_symbols = T)
  
  
quanteda_texts_dfm <- dfm(quanteda_texts_tok) %>%
  dfm_trim(min_termfreq = 4, max_docfreq = 10)



# Stats ---------------

## frequencies

textstat_frequency(quanteda_texts_dfm, n = 5)

textstat_frequency(quanteda_texts_dfm, n = 100) %>%
  as.tibble() %>%
  view()
                   
textstat_frequency(quanteda_texts_dfm, n = 5, groups = year) %>%
  as.tibble() %>%
  view()


### plots

quanteda_texts_dfm %>% 
  textstat_frequency(n = 15) %>% 
  ggplot(aes(x = reorder(feature, frequency), y = frequency)) +
  geom_point() +
  coord_flip() +
  labs(x = NULL, y = "Frequency") +
  theme_minimal()


quanteda_texts_dfm %>% 
  textstat_frequency(n = 15, groups = as.factor(year)) %>% 
  ggplot(aes(x = frequency, y = group)) +
  geom_point() +
  coord_flip() +
  labs(x = NULL, y = "Frequency") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))
  theme_minimal()

### wordcould

textplot_wordcloud(quanteda_texts_dfm, max_words = 100)

