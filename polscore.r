### Lea Wetzke, BSc Computerlinguistik, WiSe 21/22

### requirements installation ###
install.packages("quanteda")
install.packages("tidyverse")
install.packages("readtext")
install.packages("tm")
# this portion only has to be ran once to ensure the mandatory packages are 
# installed.
### installation end ###

### this R project reads in a csv corpus consisting of headlines, subheadlines
### and text of articles published by Junge Freiheit and Tagesschau in order
### to calculate a 'polarization' score and compare said scores in a graphical
### manner. The score is mainly calculated via SentiWS scores.
### The .Rdata-version of SentiWS was compiled by Cornelius Puschmann
### https://github.com/cbpuschmann/inhaltsanalyse-mit-r.de

### package set up ###
require(readtext)
require("quanteda")
require("tm")
library("quanteda")
library(readtext) 
library(tidyverse)
# this portion has to be run every time!

### read in of corpus and setup ###
# loading SentiWS file
load("lexika/sentiWS.RData")
sentiment.lexikon.sentiws <- dictionary(list(positive = positive.woerter.senti,
                                             negative = negative.woerter.senti))

# loading in Junge Freiheit csv files 
jf_files = list.files(pattern="jf-[0-9][0-9]?.csv", recursive = TRUE)
# loading in Tagesschau csv files
ts_files = list.files(pattern="ts-[0-9][0-9]?.csv", recursive = TRUE)
# First apply read.csv, then rbind

# function to make corpus out of df of csv names
make_corp <- function(df_name, col_name) {
  # arguments: 
  #     df_name (str): name of the df containing the extracted article data
  #     col_name (str): name of column ("HEAD" for headlines, "SUBHEAD" for
  #                                     subheadlines, "TEXT" for paragraphs)
  # returns:
  #     column_corpus: quanteda corpus object derived from column data
  df_column <- df_name[col_name]
  column_corpus <- corpus(df_column, text_field = col_name)
  return(column_corpus)
}

jf_dfs = do.call(rbind, lapply(jf_files, function(x) read.csv(x, sep=';', 
                                                     stringsAsFactors = FALSE)))
# read in data from csv

# turning dfs into corpus objects, dividing them for later comparison
jf_head_corpus <- make_corp(jf_dfs, "HEAD")
jf_subhead_corpus <- make_corp(jf_dfs, "SUBHEAD")
jf_text_corpus <- make_corp(jf_dfs, "TEXT")

ts_dfs = do.call(rbind, lapply(ts_files, function(x) read.csv(x, sep=';', 
                                                     stringsAsFactors = FALSE)))
# turning dfs into corpus objects, tagesschau this time
ts_head_corpus <- make_corp(ts_dfs, "HEAD")
ts_subhead_corpus <- make_corp(ts_dfs, "SUBHEAD")
ts_text_corpus <- make_corp(ts_dfs, "TEXT")

### functions used for score calculations ###

# function for calculating total occurrences of 'emotional' words in a corpus
# emotional words = words with sentiws entry, nevermind if pos or neg
make_sentiws_weights <- function(corpus_name) {
  # arguments: 
  #     corpus_name (str): variable name of the corpus
  # returns:
  #     pol_sum (int): summarized occurrences of polarizing words
  corpus_dfm <- tokens(corpus_name) %>% 
    dfm() %>% 
    dfm_lookup(dictionary = sentiment.lexikon.sentiws)
  # make document feature matrix with sentiws 
  corpus_weight <- dfm_weight(corpus_dfm)
  dfm_converted <- convert(corpus_weight, "data.frame") 
  pol_sum <- sum(dfm_converted$negative) + sum(dfm_converted$positive)
  # convert dfm to data frame and summarize occurrences of negative and 
  # positive words
  return(pol_sum)
}

# function for calculating occurrences of a certain punctuation in a corpus
search_punct <- function(punct, corpus) {
  # arguments: 
  #     punct (str): string with punctuation (like "!")
  # returns:
  #     length of the keyword column: equivalent to amount of occurrences
  corp_tokens <- tokens(corpus)
  keyword <- c(punct)
  kw_df <- as.data.frame(kwic(corp_tokens, keyword, window = 0))
  # use kwic to make dataframe with occurences of the chosen punctuation 
  return(length(kw_df$keyword))
}

# function for calculating polarity score of a single corpus
calc_score <- function(corpus_name) {
  # arguments: 
  #     corpus_name (corpus): variable name of the corpus
  # returns:
  #     float produced by applying pol score formula
  sentiwords = make_sentiws_weights(corpus_name)
  # calculate SentiWS weights
  excl = search_punct("!", corpus_name)
  qs = search_punct("?", corpus_name)
  # calculate punctuation scores
  total = sum(quanteda::ntoken(corpus_name))
  # calculate total amount of tokens
  return((sentiwords + (excl*2) + (qs*0.4))/total)
  # apply formula to calculate score
}

# function for calculating combined polarity score of two corpora
calc_score_sum <- function(corpus_name_1, corpus_name_2) {
  # arguments: 
  #     corpus_name_1 (corpus): variable name of the first corpus
  #     corpus_name_2 (corpus): variable name of the first corpus
  # returns:
  #     float calculated by applying polarity score formula
  sentiwords_1 = make_sentiws_weights(corpus_name_1)
  sentiwords_2 = make_sentiws_weights(corpus_name_2)
  # calculate SentiWS weights
  excl_1 = search_punct("!", corpus_name_1)
  excl_2 = search_punct("!", corpus_name_2)
  qs_1 = search_punct("?", corpus_name_1)
  qs_2 = search_punct("?", corpus_name_2)
  # calculate punctuation scores
  total_1 = sum(quanteda::ntoken(corpus_name_1))
  total_2 = sum(quanteda::ntoken(corpus_name_2))
  # calculate total amount of tokens
  return(((sentiwords_1 + sentiwords_2) + ((excl_1 + excl_2)*2) + 
          ((qs_1 + qs_2)*0.4))/(total_1 + total_2))
  # apply formula to calculate score
}

### score calculations ###
calc_score_jf_head <- calc_score(jf_head_corpus)
calc_score_jf_subhead <- calc_score(jf_subhead_corpus)
calc_score_jf_text <- calc_score(jf_text_corpus)

calc_score_ts_head <- calc_score(ts_head_corpus)
calc_score_ts_subhead <- calc_score(ts_subhead_corpus)
calc_score_ts_text <- calc_score(ts_text_corpus)
# calculate scores for each category

scores <- c(calc_score_jf_head, calc_score_jf_subhead, calc_score_jf_text, 
            calc_score_ts_head, calc_score_ts_subhead, calc_score_ts_text)
names <- c("JF head", "JF subhead", "JF text", 
            "TS head", "TS subhead", "TS text")
final_data <- data.frame(names, scores)
write.csv(final_data,'results.csv')
# compile final data to df and export to csv
data_tibble <- as_tibble(final_data)
# make df of scores + labels for bars in later graph and convert it to a tibble

### make secondary barplots ###

final_plot <- data_tibble %>% 
  ggplot(aes(names,scores))+
  geom_col() +
  labs(title="polarization-score")
final_plot + theme_grey(base_size = 19)
ggsave("final_barplot.png")
# make bar plot

scores_sum <- c(calc_score_jf_head, calc_score_sum(jf_subhead_corpus, 
                                                    jf_text_corpus), 
              calc_score_ts_head, calc_score_sum(ts_subhead_corpus, 
                                                 ts_text_corpus))  
names_sum <- c("JF head", "JF subhead + JF text", 
               "TS head", "TS subhead + TS text")

# make barplot for version where subhead and head are summarized
final_sum_data <- data.frame(names_sum, scores_sum)
data_tibble_sum <- as_tibble(final_sum_data)

sum_plot <- data_tibble_sum %>% 
  ggplot(aes(names_sum,scores_sum))+
  geom_col() +
  labs(title="polarization-score")
sum_plot + theme_grey(base_size = 16)
ggsave("sum_barplot.png")
# make bar plot