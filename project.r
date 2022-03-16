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

# loading in csv files 
files = list.files(pattern="*.csv")
# First apply read.csv, then rbind
myfiles = do.call(rbind, lapply(files, function(x) read.csv(x, sep=';', stringsAsFactors = FALSE)))
# dividing into different dfs for later processing
head = myfiles["HEAD"]
head$source <- "Junge Freiheit"
subhead = myfiles["SUBHEAD"]
text = myfiles["TEXT"]
# turning dfs into corpus objects
head_corpus <- corpus(head, text_field = "HEAD")
head_corpus


# making document feature matrix of headlines
meine.dfm.head <- dfm(head_corpus, dictionary = sentiment.lexikon.sentiws)
# weighing features (negative and positive)
meine.dfm.head.weight <- dfm_weight(meine.dfm.head)
topfeatures(meine.dfm.head.weight)
# converting dfm to dataframe to summarize total amounts of "emotional" words
total <- convert(meine.dfm.head.weight, "data.frame")
sum(total$negative)