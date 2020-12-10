library(readxl)
library(tidyverse)
library(tidytext)
library(topicmodels)
library(here)
library(tm)
library(tictoc)

set.seed(1234)

PT_stop_words <- read_excel("PT_stop_words.xlsx") #load Portuguese stop words
COVID_Religion_Data <- read_excel("COVID_religion_data.xlsx",
                                  col_types = c("text", "numeric", "date",
                                                "text", "text", "text", "text", "text",
                                                "text", "date", "text", "text"))

n_grams <- 1:5                          # extract n-grams for n=1,2,3,4,5

corpus_tokens <- map_df(n_grams, ~ COVID_Religion_Data %>%
                         # combine title and body
                         unite(col = title_body, Title, `Text Data`, sep = " ") %>%
                         # tokenize
                         unnest_tokens(output = word,
                                       input = title_body,
                                       token = "ngrams",
                                       n = .x) %>%
                         mutate(ngram = .x,
                                token_id = row_number()) %>%
                         # remove tokens that are missing values
                         drop_na(word))

# remove stop words or n-grams beginning or ending with stop word
corpus_stop_words <- corpus_tokens %>%
  # separate ngrams into separate columns
  separate(col = word,
           into = c("word1", "word2", "word3", "word4", "word5"),
           sep = " ") %>%
  # find last word
  mutate(last = if_else(ngram == 5, word5,
                        if_else(ngram == 4, word4,
                                if_else(ngram == 3, word3,
                                        if_else(ngram == 2, word2, word1))))) %>%
  # remove tokens where the first or last word is a stop word
  filter(word1 %in% PT_stop_words$word |
           last %in% PT_stop_words$word) %>%
  select(ngram, token_id)

# convert to dtm
corpus_dtm <- corpus_tokens %>%
  # remove stop word tokens
  anti_join(corpus_stop_words) %>%
  # get count of each token in each document
  count(id, word) %>%
  # create a document-term matrix with all features and tf weighting
  cast_dtm(document = id, term = word, value = n) %>%
  removeSparseTerms(sparse = .999)

## Joining, by = c("ngram", "token_id")

# remove documents with no terms remaining
corpus_dtm <- corpus_dtm[unique(corpus_dtm$i),]

corpus_lda12 <- LDA(corpus_dtm, k = 9, control = list(seed = 1234))

# A LDA_VEM topic model with 9 topics.

corpus_lda12_td <- tidy(corpus_lda12)

top_terms <- corpus_lda12_td %>%
  group_by(topic) %>%
  top_n(5, beta) %>%
  ungroup() %>%
  arrange(topic, -beta)

top_terms %>%
  mutate(topic = factor(topic),
         term = reorder_within(term, beta, topic))

# removing stop words characteristic of this topic

topical_stop_words <- data.frame(word = c("senhor", "deus", "igrejas", "igreja", "aleluia",
                                          "glória", "jesus", "verso"))
full_stop_words <- union(PT_stop_words, topical_stop_words)

# remove stop words or n-grams beginning or ending with stop word
corpus_full_stop_words <- corpus_tokens %>%
  # separate ngrams into separate columns
  separate(col = word,
           into = c("word1", "word2", "word3", "word4", "word5"),
           sep = " ") %>%
  # find last word
  mutate(last = if_else(ngram == 5, word5,
                        if_else(ngram == 4, word4,
                                if_else(ngram == 3, word3,
                                        if_else(ngram == 2, word2, word1))))) %>%
  # remove tokens where the first or last word is a stop word
  filter(word1 %in% full_stop_words$word |
           last %in% full_stop_words$word) %>%
  select(ngram, token_id)

# convert to dtm
corpus_filtered_dtm <- corpus_tokens %>%
  # remove stop word tokens
  anti_join(corpus_full_stop_words) %>%
  # get count of each token in each document
  count(id, word) %>%
  # create a document-term matrix with all features and tf weighting
  cast_dtm(document = id, term = word, value = n) %>%
  removeSparseTerms(sparse = .999)

## Joining, by = c("ngram", "token_id")

# remove documents with no terms remaining
corpus_filtered_dtm <- corpus_filtered_dtm[unique(corpus_filtered_dtm$i),]

corpus_filtered_lda12 <- LDA(corpus_filtered_dtm, k = 9, control = list(seed = 1234))

# A LDA_VEM topic model with 9 topics.

corpus_filtered_lda12_td <- tidy(corpus_filtered_lda12)

top_terms_filtered <- corpus_filtered_lda12_td %>%
  group_by(topic) %>%
  top_n(5, beta) %>%
  ungroup() %>%
  arrange(topic, -beta)

top_terms_filtered %>%
  mutate(topic = factor(topic),
         term = reorder_within(term, beta, topic))