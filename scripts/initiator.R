# Approximate fiat dollar value of crypto acquisition
# Uses the Average Method (tax term)
# No guarantees of usefulness, generally just for the author's purposes
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
wallet_activity.FN <- "input/activity_tz1SNTGS7rHpCqnGbwTjjnndaE1bzbbMTfmJ.csv"
username <- "xerografica"
demo.version <- "no"
#demo.version <- "yes"

# Set the initial per coin value (0 if no coin)
initial.value <- 0
# Set the initial per coin volume (0 if no coin)
initial.volume <- 0

# Update wallet activity FN for demo version
if(demo.version=="yes"){
  
  wallet_activity.FN <- "input/demo_activity.csv"
  
}

# Source functions applied by program
source("scripts/crypto_buy.R")
source("scripts/nft_activity.R")

# Run steps
source("scripts/import_crypto_buys.R")
source("scripts/import_crypto_sells.R") # if relevant
source("scripts/import_NFT_activity.R")
source("scripts/import_crypto_to_fiat.R")
source("scripts/combine_crypto_and_NFT_activity.R")
source("scripts/calc_loop.R")
