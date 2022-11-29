# call the library
library(stylo)

# read the metadata
metadata <- read.csv("metadata.csv", stringsAsFactors = F)

# load the tokenized texts
load("resources/Quanteda_texts.RData")

# convert them into (lowercased) lists of tokens
p <- as.list(quanteda_texts)
p <- lapply(p, tolower)

# separate based on gender
primary_set <- p[which(metadata$gender.cat == "f")]
secondary_set <- p[which(metadata$gender.cat == "m")]

# reduce to just 20 texts
# (necessary to avoid RAM issues!)
primary_set <- primary_set[1:10]
secondary_set <- secondary_set[1:10]

# run a basic Zeta analysis
oppose(primary.corpus = primary_set, secondary.corpus = secondary_set)
