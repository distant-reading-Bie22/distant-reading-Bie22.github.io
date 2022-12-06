
library(tidyverse)
library(readxl)
library(tidytext)
library(readtext)
library(sjPlot)

# what if we wanted to see how gender plays a role in our corpus?

# gender applies here to two aspects at least: author gender and represented gender.
# how can we investigate these?

# we can manually match a sentiment lexicon onto the corpus. it sometime comes with a cost: more processing effort. we will therefore use a reduced version of our corpus today.

# let's first empty our environment:
## and load the new datasets


### 1) we will need a sentiment lexicon: for this tutorial we'll use sentiWS

load("resources/sentiws.RData")

# and then execute the following script to create the corpus and apply the sentiws lexicon

corpus_files <- list.files(path = "corpus", pattern = "*.txt", full.names = T)

corpus <- readtext::readtext(corpus_files) %>%
  left_join(read.csv("metadata.csv", stringsAsFactors = F) %>%
              rename(doc_id = filename) %>%
              mutate(doc_id = stringr::str_replace_all(
                string = doc_id,
                pattern = "corpus/", 
                replacement = "")
              )) %>%
  
  select(text, doc_id, author.name, book.title, year, gender.cat) %>%
  rename(sentence = text) %>%
  rename(author_gender = gender.cat) %>%
  unnest_sentences(input = sentence, output = sentence, to_lower = F) %>%
  mutate(sentence_id = seq_along(sentence)) %>%
  group_by(doc_id) %>%
  slice_sample(n = 300) %>% # random 300 sentences per text
  ungroup() %>%
  unnest_tokens(input = sentence, output = token, to_lower = F, drop = F) %>%
  
  left_join(sentiws %>%
              rename(sentiment = SentiWS_neg_pos) %>%
              rename(polarity = SentiWS_polarity)) %>%
  ungroup() %>%
  
  mutate(sentiment_count = ifelse(
    sentiment == "pos" | sentiment == "neg", 1, 0))

remove(corpus_files, sentiws)


# we can check how many authors by gender

corpus %>%
  select(author.name, author_gender) %>%
  distinct() %>%
  group_by(author_gender) %>%
  count()

# or plot the same, adding the year to see how this feature over time

corpus %>%
  select(author.name, author_gender, year) %>%
  distinct() %>%
  group_by(author_gender, year) %>%
  count() %>%
  ggplot(aes(y=n, x=year, color=author_gender)) +
  geom_point() +
  geom_smooth(aes())


## as we have mentioned before, SA allows us to see how sentiment or emotions are encoded in a text.
## we can use the gender factor to examine whether there is a difference in how sentiment
## is encoded by gender. 




## for instance, we can plot the mean sentiment in corpus by author gender

corpus %>%
  filter(!is.na(sentiment)) %>%
  ggplot(aes(x=sentiment, y=polarity, fill=author_gender)) +
  geom_boxplot(position = "dodge") +
  ggpubr::stat_compare_means() +
  ylim(-1,1.2)

# if we want to have a better "comparing" view, we can flip the negatives up

corpus %>%
  ungroup() %>%
  mutate(polarity = ifelse(sentiment == "neg", -polarity, polarity)) %>%
  filter(!is.na(sentiment)) %>%
  ggplot(aes(x=sentiment, y=polarity, fill=author_gender)) +
  geom_boxplot(position = "dodge") +
  ggpubr::stat_compare_means() +
  ylim(0,1.2)


# we might also be interested in the represented gender rather than the author's, so how can we analyse it?

# again, we need to be able to identify names or words that somehow define gender.
# We decided here to look at a list of proper first names, as well as words that are stereotypically considered as representative of a gender 
# (apologies for the binary structure, for the purpose of this workshop we will have to limit to female/male dualism here.)

load("resources/german_proper_names.RData")

# represented gender -----------------


## proper names index -----------

### FEMALE corpus --------

corpus_gender_female <- corpus %>%
  select(author.name,
         book.title,
         doc_id,
         sentence,
         sentence_id,
         token) %>%
  distinct() %>%
  left_join(german_names %>%
              filter(gender == "f") %>%
              rename(name_gender = gender),
            by = c("token" = "first_name")) %>%
  filter(grepl("Frau", token) |
           grepl("Mutter", token) |
           # token == "sie" |
           grepl("Schwester", token) |
           grepl("Tante", token) |
           grepl("Mädchen", token) |
           grepl("Dame", token) |
           grepl("Tochter", token) |
           grepl("Lehrerin", token) |
           grepl("rerin", token) |
           grepl("Fräulein", token) |
           name_gender == "w") %>%
  mutate(is_gender_word = 1)  %>%
  mutate(gender_type = "female") %>%
  dplyr::group_by(author.name,
                  book.title,
                  doc_id,
                  sentence,
                  sentence_id,
  ) %>%
  summarise(gender_words_n = sum(is_gender_word, na.rm=T),
            gender_item = paste0(list(token[!is.na(token)])),
            gender_type = "f",
            is_gender_word = 1)


# MALE corpus

corpus_gender_male <- corpus %>%
  select(author.name,
         book.title,
         doc_id,
         sentence,
         sentence_id,
         token,
         sentiment) %>%
  distinct() %>%
  left_join(german_names %>%
              filter(gender == "m") %>%
              rename(name_gender = gender),
            by = c("token" = "first_name")) %>%
  filter(grepl("Herr", token) |
           grepl("Vater", token) |
           token == "er" |
           grepl("Bruder", token) |
           grepl("Onkel", token) |
           grepl("Ritter", token) |
           grepl("Sohn", token) |
           token == "Lehrer" |
           name_gender == "m") %>%
  mutate(is_gender_word = 1)  %>%
  mutate(gender_type = "m") %>%
  dplyr::group_by(author.name,
                  book.title,
                  doc_id,
                  sentence_id,
                  sentence) %>%
  summarise(gender_words_n = sum(is_gender_word, na.rm=T),
            gender_item = paste0(list(token[!is.na(token)])),
            gender_type = "m",
            is_gender_word = 1)

# GENDER CORPUS

corpus_gender <- bind_rows(corpus_gender_female, corpus_gender_male)

remove(corpus_gender_female, corpus_gender_male)

corpus_sentences <- corpus %>%
  group_by(author.name, 
           book.title, 
           doc_id,
           author_gender,
           year, 
           sentence, 
           sentence_id, 
           sentiment) %>%
  summarise(polarity = sum(polarity, na.rm = T)) %>%
  left_join(corpus_gender)


remove(german_names)


# now we have a corpus with values aggregated by sentence, where we can see both how many "gendered" words we have, and the sentiment value.

# we can plot a count of sentiment words by represented gender

corpus_sentences %>%
  group_by(gender_type, sentiment) %>%
  filter(!is.na(gender_type)) %>%
  summarise(sentiment_count = n()) %>%
  mutate(gendered_sent_total = case_when(
    gender_type == "f" ~ nrow(corpus_gender[corpus_gender$gender_type == "f",]),
    gender_type == "m" ~ nrow(corpus_gender[corpus_gender$gender_type == "m",])
  )) %>%
  mutate(sentiment_prop = (sentiment_count*100)/gendered_sent_total) %>%
  filter(!is.na(sentiment)) %>%
  ggplot(aes(y=sentiment_prop, sentiment, fill=gender_type)) +
  geom_col(position="dodge") +
  # geom_text(nudge_y = -.04)
  # facet_wrap(. ~ sentiment) +
  ggtitle("proportional count of sentiment words in sentences with gendered words")


# schematic representations

table1::table1(~ gender_type | sentiment, 
               data=corpus_sentences, overall=F, na.rm=T,
               caption="n of sentences with gendered terms")





