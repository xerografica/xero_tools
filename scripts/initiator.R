# Approximate fiat dollar value of tezos acquisition
# Uses the Average Method for tax purposes
# No guarantees of usefulness, generally just for the author's purposes

# No guarantees provided
# Run all from main repo

# Clear working space
#rm(list = ls())

# Set working directory
## If using Rstudio, set working directory
current.path <- dirname(rstudioapi::getSourceEditorContext()$path)
current.path <- gsub(pattern = "\\/scripts", replacement = "", x = current.path) # take main directory
setwd(current.path)

# Load libraries
#install.packages(tidyr)
require(tidyr)

# Set user variables
input_convert.FN <- "input/Tezos CAD Historical Data.csv"
currency <- "CAD"
coin <- "XTZ"
year <- 2021
wallet_activity.FN <- "input/activity.csv"
username <- "xerografica"

# Set the initial per coin value (0 if no coin)
initial.value <- 0
# Set the initial per coin volume (0 if no coin)
initial.volume <- 0

# GO TO import_crypto_buys.R