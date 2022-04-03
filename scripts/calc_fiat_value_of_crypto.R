# Approximate fiat dollar value of tezos acquisition
# Uses the Average Method for tax purposes
# No guarantees of usefulness, generally just for the author's purposes

# Clear working space
#rm(list = ls())

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

# Set the initial per coin value (0 if no coin)
initial.value <- 0
# Set the initial per coin volume (0 if no coin)
initial.volume <- 0

# Assumes that withdrawals in xtz mean the xtz was purchased that day
# Set filename as, for example: "kucoin_withdrawal_history_<date>.csv"
withdrawal.FN <- list.files(path = "input", pattern = "_withdrawal_history_", full.names = TRUE)

markets.list <- list(); shortname <- NULL; withdrawal.df <- NULL
for(i in 1:length(withdrawal.FN)){
  
  # Find the shortname of the dataset
  shortname <- gsub(pattern = "input\\/", replacement = "", x = withdrawal.FN[i])
  shortname <- gsub(pattern = "\\_.*", replacement = "", x = shortname)
  shortname
  
  markets.list[[shortname]] <- read.csv(file = withdrawal.FN[i])
  
  df.temp <- markets.list[[shortname]]
  df.temp <- as.data.frame(df.temp)
  
  withdrawal.df <- rbind(withdrawal.df, df.temp)
   
}

markets.list # Contains your data, still separated by the market
withdrawal.df # contains a continuous dataframe

# Sort by date
withdrawal.df <- withdrawal.df[order(withdrawal.df$date), ]

# Keep only the rows for the coin of interest
coin
withdrawal.df <- withdrawal.df[grep(pattern = coin, x = withdrawal.df$coin), ]

# TEMP # Keep only year of interest
withdrawal.df <- withdrawal.df[grep(pattern = year, x = withdrawal.df$date), ]




##### TAKEN FROM CONVERT_GAINS.R REDUNDANT! #####
#### Currency conversion ####
# Obtain the conversion for the year
convert.df <- read.delim2(file = input_convert.FN, header = TRUE, sep = ","
                          #, quote = TRUE
)
head(convert.df)
str(convert.df) # note: all are character values

# Convert price to numeric
convert.df$Price <- as.numeric(x = convert.df$Price)
str(convert.df)

# Convert date to correct format
convert.df$Date.corr <- as.Date(x = convert.df$Date, tryFormats = c("%b %d, %Y"))

# Confirm ok
head(convert.df[, c("Date.corr", "Date")])
tail(convert.df[, c("Date.corr", "Date")])

# Keep only needed cols
convert.df <- convert.df[, c("Date.corr", "Price")]
str(convert.df)

##### /END/ TAKEN FROM CONVERT_GAINS.R REDUNDANT! EDITED THOUGH #####

withdrawal.df.bck <- withdrawal.df
#withdrawal.df <- withdrawal.df.bck


#### Calculate the value of bought tezos for each day

# Create dummy cols
withdrawal.df$amt_spent_fiat     <- as.numeric(rep(x = NA, times = nrow(withdrawal.df)))
withdrawal.df$trade_vol          <- as.numeric(rep(x = NA, times = nrow(withdrawal.df)))
withdrawal.df$trade_mean_price   <- as.numeric(rep(x = NA, times = nrow(withdrawal.df)))

withdrawal.df$overall_total_vol  <- as.numeric(rep(x = NA, times = nrow(withdrawal.df)))
withdrawal.df$overall_mean_price <- as.numeric(rep(x = NA, times = nrow(withdrawal.df)))

withdrawal.df


# Loop over each transaction
date_of_withdrawal <- NULL; daily_coin_price <- NULL
for(i in 1:nrow(withdrawal.df)){
  
  # What was the date of the purchase? 
  date_of_withdrawal <- withdrawal.df[i,"date"]
  date_of_withdrawal
  
  # How much were tezos worth that day? 
  daily_coin_price <- convert.df[convert.df$Date.corr==date_of_withdrawal, "Price"]
  daily_coin_price
  
  # What is your total spend amount in fiat? 
  amt_spent_fiat <- withdrawal.df[i,"amount"] * daily_coin_price
  amt_spent_fiat
  
  # Include your spent fiat in the df
  withdrawal.df$amt_spent_fiat[i] <- amt_spent_fiat
  #str(withdrawal.df)
  #withdrawal.df$amt_spent_fiat <- as.numeric(withdrawal.df$amt_spent_fiat)
  
  # # What is your volume purchased? 
  withdrawal.df$trade_vol[i] <- withdrawal.df$amount[i]
  
  # What is your current total vol of tezos?
  # If it is the first record of the year, add the initial volume to the amount currently withdrawn
  if(i==1){
    
    withdrawal.df$overall_total_vol[i] <- initial.volume + withdrawal.df$amount[i]
    
  # If it is not the first record of the year, add the current amount to the previous total
  }else if(i!=1){
    
    withdrawal.df$overall_total_vol[i] <- withdrawal.df$overall_total_vol[i-1] + withdrawal.df$amount[i]
    
  }
  
  withdrawal.df
  
  # Trade mean price
  withdrawal.df$trade_mean_price[i] <-  withdrawal.df$amt_spent_fiat[i] / withdrawal.df$amount[i]
  # TODO: THIS CAN BE REPLACED FROM THE TEZOS TABLE? 
  
  withdrawal.df
  
  
  # Overall mean price
  
  if(i==1){
    
    withdrawal.df$overall_mean_price[i] <- ((withdrawal.df$trade_mean_price[i] * withdrawal.df$trade_vol[i]) + (initial.value * initial.volume)) / withdrawal.df$overall_total_vol[i]
    
  }else if(i!=1){
    
    withdrawal.df$overall_mean_price[i] <- ((withdrawal.df$trade_mean_price[i] * withdrawal.df$trade_vol[i]) + 
                                              (withdrawal.df$overall_mean_price[i-1] * withdrawal.df$overall_total_vol[i-1])) / 
                                                                      withdrawal.df$overall_total_vol[i]
    
  }
  
}

withdrawal.df



### Notes: 
# this currently assumes no spend of tezos for any NFT
# Next need to integrate sales/ buys (removes total vol of tez)



