if(!require("quanteda")) {install.packages("quanteda"); library("quanteda")}
if(!require("readtext")) {install.packages("readtext"); library("readtext")}
if(!require("tidyverse")) {install.packages("tidyverse"); library("tidyverse")}
if(!require("RColorBrewer")) {install.packages("RColorBrewer"); library("RColorBrewer")}
install.packages("readtext")
install.packages("tm")
require(readtext)
library(readtext) 
library(tidyverse)
require("quanteda")
require("tm")
# loading SentiWS file
load("lexika/sentiWS.RData")
sentiment.lexikon.sentiws <- dictionary(list(positive = positive.woerter.senti, negative = negative.woerter.senti))

# loading in Junge Freiheit csv files 
jf_files = list.files(pattern="jf-[0-9][0-9]?.csv")
# loading in Tagesschau csv files
ts_files = list.files(pattern="ts-[0-9][0-9]?.csv")
# First apply read.csv, then rbind

make_corp <- function(df_name, col_name) {
  df_column <- df_name[col_name]
  column_corpus <- corpus(df_column, text_field = col_name)
  return(column_corpus)
}

jf_dfs = do.call(rbind, lapply(jf_files, function(x) read.csv(x, sep=';', stringsAsFactors = FALSE)))
# dividing into different dfs for later processing
# jf_head$source <- "Junge Freiheit"
# jf_subhead$source <- "Junge Freiheit"
# jf_text$source <- "Junge Freiheit"
# turning dfs into corpus objects
jf_head_corpus <- make_corp(jf_dfs, "HEAD")
jf_subhead_corpus <- make_corp(jf_dfs, "SUBHEAD")
jf_text_corpus <- make_corp(jf_dfs, "TEXT")

ts_dfs = do.call(rbind, lapply(jf_files, function(x) read.csv(x, sep=';', stringsAsFactors = FALSE)))
# dividing into different dfs for later processing
# jf_head$source <- "Junge Freiheit"
# jf_subhead$source <- "Junge Freiheit"
# jf_text$source <- "Junge Freiheit"
# turning dfs into corpus objects
ts_head_corpus <- make_corp(ts_dfs, "HEAD")
ts_subhead_corpus <- make_corp(ts_dfs, "SUBHEAD")
ts_text_corpus <- make_corp(ts_dfs, "TEXT")

# function for calculating total amount of 'emotional' words in a corpus
make_sentiws_weights <- function(corpus_name) {
  corpus_dfm <- dfm(corpus_name, dictionary = sentiment.lexikon.sentiws)
  # make document feature matrix with sentiws 
  corpus_weight <- dfm_weight(corpus_dfm)
  dfm_converted <- convert(corpus_weight, "data.frame")
  emwords_sum <- sum(dfm_converted$negative) + sum(dfm_converted$positive)
  # convert dfm to data frame and summarize occurrences of negative and positive words
  return(emwords_sum)
}

emwords_head <- make_sentiws_weights(jf_head_corpus)
emwords_subheads <- make_sentiws_weights(jf_subhead_corpus)
emwords_text <- make_sentiws_weights(jf_text_corpus)

total_tokens <- sum(quanteda::ntoken(jf_text_corpus))


