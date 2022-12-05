# Oppose

# Welcome!
# This is an R script file, created by Simone
# Everything written after an hashtag is a comment
# Everything else is R code
# To activate the code, place the cursor on the corresponding line
# (or highlight multiple lines/pieces of code) 
# ...and press Ctrl+Enter (or Cmd+Enter for Mac)
# (the command will be automatically copy/pasted into the console)

# call the library
library(stylo)

# read the metadata
metadata <- read.csv("metadata.csv", stringsAsFactors = F)

# define the name of the author on which we want to work
my_author <- "Arnim, Bettina von"

# load the tokenized texts
load("resources/quanteda_texts_tokens_gg.Rdata")

# convert them into (lowercased) lists of tokens
texts_list <- as.list(quanteda_texts_tok)
texts_list <- lapply(texts_list, tolower)

# separate based on target author
primary_set <- texts_list[which(metadata$author.name == my_author)]
secondary_set <- texts_list[which(metadata$gender.cat != my_author)]

# reduce to just reference corpus to just 20 texts
# (necessary to avoid RAM issues!)
secondary_set <- secondary_set[1:20]

# run a basic Zeta analysis
oppose(primary.corpus = primary_set, secondary.corpus = secondary_set)


################
### Your turn!!
#############

# run the same analysis on a different author
# tip: you will have just to change the name of the author in line 19
# and then re-run the script from the beginning