# Stylometry

# Welcome!
# This is an R script file, created by Simone
# Everything written after an hashtag is a comment
# Everything else is R code
# To activate the code, place the cursor on the corresponding line
# (or highlight multiple lines/pieces of code) 
# ...and press Ctrl+Enter (or Cmd+Enter for Mac)
# (the command will be automatically copy/pasted into the console)

# Important note:
# If your RAM in Posit Cloud is full (red icon on the top right)
# Click on "Session" -> "Clear Workspace"
# ...and then "Session" -> "Restart R"

# Call the packages
library(stylo)
# ...you'll have to do it each time you re-start the project

# Important note:
# Stylo will work by default with the files in the "corpus" folder

# First analysis (authorship attribution)
stylo(corpus.format="plain",
      corpus.lang="German", 
      mfw.min=100, 
      mfw.max=100,
      mfw.incr=0,
      distance.measure="dist.delta",
      analysis.type="CA",
      write.jpg.file=T,
      plot.custom.height=16,
      plot.custom.width=9)
# for an explanation of this command, see the appendix below

# note that the analysis has generated a few files, including a table w/ frequencies
processed_texts <- read.csv("table_with_frequencies.txt", sep = " ")

# let's take a look
View(processed_texts)

# we can isolate the gender information from the metadata
metadata <- read.csv("metadata.csv")
View(metadata)
table(metadata$gender.cat)

# ...and use it to change the names of the texts
colnames(processed_texts) <- paste(metadata$gender.cat, colnames(processed_texts), sep = "_")
processed_texts <- processed_texts[,order(colnames(processed_texts))]
write.table(processed_texts, "gender_table_with_frequencies.txt", sep = " ")

# Second analysis (gender)
stylo(corpus.format="plain",
      corpus.lang="German", 
      mfw.min=100, 
      mfw.max=100,
      mfw.incr=0,
      distance.measure="dist.delta",
      analysis.type="CA",
      write.jpg.file=T,
      plot.custom.height=16,
      plot.custom.width=9,
      frequencies="gender_table_with_frequencies.txt")
# here files are not actually read from the "corpus" folder
# as word frequencies are already provided in "gender_table_with_frequencies.txt" file

# Appendix

# Here is an overview of the options to put between the brackets
# 
# # Type of the corpus
# 
# corpus.format = ...
# - you can choose between "plain", "xml", "xml.drama", "html", and many others
# [Example]
# stylo(corpus.format = "plain")
#
# # Language of the corpus
# 
# corpus.lang = ...
# - you can choose between "English", "German", "Italian", "Latin", and many others
# [Example]
# stylo(corpus.format = "plain", corpus.lang = "Italian")
# 
# # Most frequent words
# 
# mfw.min = ...
# - any integer number
# mfw.max = ...
# - any integer number
# mfw.incr = ...
# - any integer number
# 
# [Example]
# stylo(corpus.format = "plain", corpus.lang = "Italian", mfw.min = 100, mfw.max = 1000, mfw.incr = 100)
# - (this will perform 10 analyses with 100, 200, 300, etc. MFW)
# 
# # Distance measures 
# 
# distance.measure = "..."
# - you can choose between the following:
#   - "dist.delta"
#   - "dist.euclidean"
#   - "dist.manhattan"
#   - "dist.argamon"
#   - "dist.eder"
#   - "dist.simple"
#   - "dist.canberra"
#   - "dist.cosine"
#   - "dist.wurzburg"
#   - "dist.minmax"
# 
# [Example]
# stylo(corpus.format = "plain", corpus.lang = "Italian", mfw.min = 100, mfw.max = 1000, mfw.incr = 100, distance.measure = "dist.wurzburg")
# - (this will perform 10 analyses with 100, 200, 300, etc. MFW, using the Wurzburg distance, i.e., Cosine Delta)
# 
# # Analysis type (i.e. visualization)
# 
# analysis.type = 
# - you can choose between the following:
#   - "CA"
#     - (that is cluster analysis, i.e. dendrograms)
#   - "BCT"
#     - (that is bootstrap consensus tree)
# 
# [Example]
# stylo(corpus.format = "plain", corpus.lang = "Italian", mfw.min = 100, mfw.max = 1000, mfw.incr = 100, distance.measure = "dist.wurzburg", analysis.type = "BCT")
# - (this will perform 10 analyses with 100, 200, 300, etc. MFW, using the Wurzburg distance, i.e., Cosine Delta, and will use them to generate a single consensus tree)
# 
# Much more details are available here: https://github.com/computationalstylistics/stylo_howto/blob/master/stylo_howto.pdf
# Note that if you will install Rstudio in your laptop, stylo will also have a graphical interface to set up these features

################
### Your turn!!
#############

# Option 1
# repeat the analysis with different features
# do you get any distinction in term of gender?
# suggestion: just copy-paste here below lines 49-59 and modify them a bit



# Option 2
# try to extract another information from the metadata, such as the period
# and repeat the analysis by looking at it instead of gender
# suggestion: just copy-paste here below lines 32-59 and modify them a bit

