# Keyness analysis

# Welcome!
# This is an R script file, created by Simone
# Everything written after an hashtag is a comment
# Everything else is R code
# To activate the code, place the cursor on the corresponding line
# (or highlight multiple lines/pieces of code) 
# ...and press Ctrl+Enter (or Cmd+Enter for Mac)
# (the command will be automatically copy/pasted into the console)

# call the packages
library(quanteda)
library(quanteda.textstats)
library(quanteda.textplots)

# read the metadata
metadata <- read.csv("metadata.csv", stringsAsFactors = F)

# watch the metadata
View(metadata)

# define the name of the author on which we want to work
my_author <- "Arnim, Bettina von"

# load the tokenized texts
load("resources/Quanteda_texts.RData")

# separate target and reference corpus
my_selection <- rep("Other", length(quanteda_texts))
my_selection[which(metadata$author.name == my_author)] <- "My author"
quanteda_texts <- tokens_group(quanteda_texts, groups = my_selection)

# transform the corpus into a document-feature matrix
document_feature_matrix <- dfm(quanteda_texts)
# note that the "grouping" is based on the names of the corpus, i.e. "My author" and "Others"

# calculate the keyness for each word
# choosing as a target the documents with the "My author" name
# and using as a measure the "log-likelihood ratio" method ("lr")
keyness_results <- textstat_keyness(document_feature_matrix, target = "My author", measure = "lr")

# plot the results!
textplot_keyness(keyness_results, n = 20)

################
### Your turn!!
#############

# define the name of the author on which we want to work
my_author <- "..."

# (re-)load the tokenized texts
load("resources/Quanteda_texts.RData")

# separate target and reference corpus
my_selection <- rep("Other", length(quanteda_texts))
my_selection[which(metadata$author.name == my_author)] <- "My author"
quanteda_texts <- tokens_group(quanteda_texts, groups = my_selection)

# transform the corpus into a document-feature matrix
document_feature_matrix <- dfm(quanteda_texts)
# note that the "grouping" is based on the names of the corpus, i.e. "My author" and "Others"

# calculate the keyness for each word
# choosing as a target the documents with the "My author" name
# and using as a measure the "log-likelihood ratio" method ("lr")
keyness_results <- textstat_keyness(document_feature_matrix, target = "My author", measure = "lr")

# plot the results!
textplot_keyness(keyness_results, n = 20)

# Appendix

# here are the scripts to create the tokenized texts
# do not work on Posit Cloud (free): not enough RAM!

# my_texts <- lapply(metadata$filename, readLines)
# my_texts <- sapply(my_texts, function(x) paste(x, collapse = "\n"))
# names(my_texts) <- metadata$filename
# quanteda_texts <- tokens(my_texts, remove_punct = T)
