# Approximate fiat dollar value of crypto acquisition
# Uses the Average Method (tax term)
# No guarantees of usefulness, generally just for the author's purposes
# Run all from main repo

# Clear working space
#rm(list = ls())

options(scipen = 9999999)

# Set working directory
## If using Rstudio, set working directory
current.path <- dirname(rstudioapi::getSourceEditorContext()$path)
current.path <- gsub(pattern = "\\/scripts", replacement = "", x = current.path) # take main directory
setwd(current.path)

# Load libraries
#install.packages(tidyr)
require(tidyr)

# Set user variables
up_to_year <- 2022
target_year <- 2021
currency <- "CAD"

# input_convert.FN <- "input/Tezos CAD Historical Data.csv"

# coin <- "XTZ"
# year <- 2021
# wallet_activity.FN <- "input/activity.csv"
# username <- "xerografica"
# demo.version <- "no"
#demo.version <- "yes"



# Read in conversion tables
conversions.FN <- list.files(path = "input/", pattern = "Historical")

# Read in all conversions
all_conversions.df <- NULL; temp <- NULL; coin <- NULL
for(i in 1:length(conversions.FN)){
  
  coin <- gsub(pattern = "\\_.*", replacement = "", x = conversions.FN[i])
  
  if(i == 1){
    
    all_conversions.df <- read.csv2(file = paste0("input/", conversions.FN[i]), sep = ",")
    all_conversions.df$coin <- rep(coin, times = nrow(all_conversions.df))
    
  }else if(i != 1){
    
    temp <- read.csv2(file = paste0("input/", conversions.FN[i]), sep = ",")
    temp$coin <- rep(coin, times = nrow(temp))
    all_conversions.df <- rbind(all_conversions.df, temp)
    
  }
  
}

head(all_conversions.df)

# Clean up data
# Remove commas
all_conversions.df$Date <- gsub(pattern = ",", replacement = "", x = all_conversions.df$Date)
all_conversions.df$Price <- gsub(pattern = ",", replacement = "", x = all_conversions.df$Price)
head(all_conversions.df)

# Fix date
all_conversions.df$date.corr <- as.Date(x = all_conversions.df$Date, tryFormats = c("%b %d %Y"))
head(all_conversions.df)

# Sort by date
all_conversions.df <- all_conversions.df[order(all_conversions.df$date.corr, decreasing = F),]
head(all_conversions.df)

all_conversions.df <- all_conversions.df[,c("date.corr", "coin",  "Price")]
head(all_conversions.df)
colnames(all_conversions.df)[which(colnames(all_conversions.df)=="date.corr")] <- "date"
all_conversions.df$Price <- as.numeric(all_conversions.df$Price)
head(all_conversions.df)


#### Read in transactions ####
transactions.FN <- list.files(path = "input/", pattern = "transactions_Ledger")
transactions.FN <- transactions.FN[grep(pattern = ".csv", x = transactions.FN)] #only keep CSV
transactions.FN

# Read in all transactions
all_data.df <- NULL; temp <- NULL
for(i in 1:length(transactions.FN)){
  
  if(i == 1){
    
    all_data.df <- read.csv2(file = paste0("input/", transactions.FN[i]), sep = ",")
    
  }else if(i != 1){
    
    temp <- read.csv2(file = paste0("input/", transactions.FN[i]), sep = ",")
    all_data.df <- rbind(all_data.df, temp)
    
  }
  
}

head(all_data.df)
dim(all_data.df)
tail(all_data.df)

# Clean data
# Fix date
all_data.df$date.corr <- as.Date(x = all_data.df$date, tryFormats = c("%d-%m-%y"))
head(all_data.df)

# Sort by date
all_data.df <- all_data.df[order(all_data.df$date.corr, decreasing = F),]
head(all_data.df)

# Remove commas
all_data.df$to_amount <- as.numeric(gsub(pattern = ",", replacement = "", x = all_data.df$to_amount))
all_data.df$from_amount <- as.numeric(gsub(pattern = ",", replacement = "", x = all_data.df$from_amount))

# Remove duplicate rows (these occur because of redundant records from each type of transaction file)
all_data.df <- all_data.df[!duplicated(all_data.df), ]

# Remove anything after the deadline (up_to_year)
all_data.df <- all_data.df[grep(pattern = up_to_year, x = all_data.df$date.corr, invert = T), ]
all_data.df <- all_data.df[,c("date.corr", "from_currency", "from_amount", "to_currency", "to_amount")]

all_data.df
colnames(all_data.df)[which(colnames(all_data.df)=="date.corr")] <- "date"

head(all_data.df)
all_data.df

#### Only keep the target year
all_data.df <- all_data.df[grep(pattern = target_year, x = all_data.df$date), ]




#### CALCULATING GAINS AND LOSSES FOR BUYS AND SELLS ####
coin.tracking <- list()
crypto_in_play <- unique(c(all_data.df$from_currency, all_data.df$to_currency))
crypto_in_play <- crypto_in_play[grep(pattern = currency, x = crypto_in_play, invert = T)]

# Create empty list
for(i in 1:length(crypto_in_play)){
  
  # Create variable for the FIAT DOLLAR PER COIN
  coin.tracking[[crypto_in_play[i]]]$val <- 0
  
  coin.tracking[[crypto_in_play[i]]]$vol <- 0
  
}

coin.tracking

# Add values for input that are not 0 at the start of the year
coin.tracking[["DOGE"]]$val <- 0.0145732 # FIAT PER COIN
coin.tracking[["DOGE"]]$vol <- 1468.924
coin.tracking[["LTC"]]$val  <- 349.0248
coin.tracking[["LTC"]]$vol  <- 0.1189307
coin.tracking[["BTC"]]$val  <- 17387.86
coin.tracking[["BTC"]]$vol  <- 0.02798176
coin.tracking[["ETH"]]$val  <- 1175.878
coin.tracking[["ETH"]]$vol  <- 0.2235153

str(coin.tracking)

# BACKUP
all_data.df.bck <- all_data.df
#all_data.df <- all_data.df.bck

# Add necessary cols to fill
all_data.df$sold_coin_daily_val <- rep(NA, times = nrow(all_data.df))
all_data.df$cash_out_fiat <- rep(NA, times = nrow(all_data.df))
all_data.df$original_spend_fiat <- rep(NA, times = nrow(all_data.df))
all_data.df$gains_crypto <- rep(NA, times = nrow(all_data.df))
all_data.df$sold_coin_new_vol <- rep(NA, times = nrow(all_data.df))
all_data.df$sold_coin_new_val <- rep(NA, times = nrow(all_data.df))

all_data.df$bought_coin_daily_val <- rep(NA, times = nrow(all_data.df))
all_data.df$bought_coin_new_vol <- rep(NA, times = nrow(all_data.df))
all_data.df$bought_coin_new_val <- rep(NA, times = nrow(all_data.df))
all_data.df$transaction_spend_fiat <- rep(NA, times = nrow(all_data.df)) 
all_data.df$total_fiat_invested_bought <- rep(NA, times = nrow(all_data.df)) 


#### Function to track gains/ losses
bought_coin <- NULL; bought_amt <- NULL
for(i in 1:nrow(all_data.df)){
  
  print(i)
  
  # Buying side is dealt with first
  # Obtain variables for easy-use
  bought_coin <- all_data.df$to_currency[i]
  bought_amt <-  all_data.df$to_amount[i]
  
  # Reporting
  print(paste0("You have bought ", bought_amt, " ", bought_coin))
  
  # What is the daily value of the bought coin? (FIAT PER COIN)
  all_data.df$bought_coin_daily_val[i] <- all_conversions.df[all_conversions.df$coin==bought_coin &
                                                               all_conversions.df$date==all_data.df$date[i], "Price"]
  print(paste0("Your ", bought_coin, " is worth ", all_data.df$bought_coin_daily_val[i], " fiat today (", all_data.df$date[i], ")"))
  
  # Adjust average 
  print("Adjusting average value based on your holdings and new acquisition")
  # (FIAT per COIN x vol COIN) + (FIAT per COIN x vol COIN) = TOTAL FIAT INVESTED
  # TOTAL FIAT INVESTED / TOTAL COIN = AVERAGE COST
  total.fiat.invested <- (coin.tracking[[bought_coin]]$val * coin.tracking[[bought_coin]]$vol) + (all_data.df$bought_coin_daily_val[i] * all_data.df$to_amount[i])
  print(paste0("You have invested in total ", round(total.fiat.invested, digits = 2), " fiat in ", bought_coin))
  all_data.df$total_fiat_invested_bought[i] <- total.fiat.invested
  
  total.vol.holding   <- (coin.tracking[[bought_coin]]$vol + all_data.df$to_amount[i])
  print(paste0("You are holding ", round(total.vol.holding, digits = 4), " in ", bought_coin))
  
  new.fiat.per.coin   <- total.fiat.invested / total.vol.holding
  new.fiat.per.coin
  print(paste0("Your new average value of ", bought_coin, " is ", round(new.fiat.per.coin, digits = 3), " fiat per coin"))
  
  # Update current value and volume
  coin.tracking[[bought_coin]]$val <- new.fiat.per.coin
  coin.tracking[[bought_coin]]$vol <- total.vol.holding
  # Also update df for transparency
  all_data.df$bought_coin_new_vol[i] <- total.vol.holding
  all_data.df$bought_coin_new_val[i] <- new.fiat.per.coin
  
  all_data.df$transaction_spend_fiat[i] <- (all_data.df$bought_coin_daily_val[i] * all_data.df$to_amount[i])
  
  
  ## Selling crypto to get crypto
  # Buy from fiat? 
  if(all_data.df$from_currency[i]==currency){
    
    # Deal with adjusting reserves if selling another crypto? 
    print("This is a buy from fiat, so don't need to tap into reserves")
    
  # Buy from crypto?   
  }else if(all_data.df$from_currency[i]!=currency){
    
    print("This is a buy from crypto, need to tap into reserves, and calc gains/ losses")
    
    spend_crypto_coin        <- all_data.df$from_currency[i]
    spend_crypto_amt         <- all_data.df$from_amount[i]
    print(paste0("You are spending ", spend_crypto_amt, " of ", spend_crypto_coin))
    
    # What is the daily value of the coin in fiat? (FIAT PER COIN)
    spend_crypto_daily_price <- all_conversions.df[all_conversions.df$coin==spend_crypto_coin &
                                                     all_conversions.df$date==all_data.df$date[i], "Price"]
    all_data.df$daily_coin_val[i] <- spend_crypto_daily_price # add to df
    
    # How much did you make when you spent this crypto? 
    daily_fiat_cashed_out <- spend_crypto_amt * spend_crypto_daily_price
    print(paste0("By spending  ", round(spend_crypto_amt, digits = 2), " ", spend_crypto_coin, " today you obtained ", round(daily_fiat_cashed_out, digits = 2), " fiat"))
    all_data.df$cash_out_fiat[i] <- daily_fiat_cashed_out
    
    # How much did you originally spend to get this amount of this crypto? (based on average)
    orig.fiat.of.this.vol <- spend_crypto_amt * coin.tracking[[spend_crypto_coin]]$val
    print(paste0("You originally spent ", round(orig.fiat.of.this.vol, digits = 2), " fiat to get this amount"))
    all_data.df$original_spend_fiat[i] <- orig.fiat.of.this.vol
    
    # Add gains to the spreadsheet
    all_data.df$gains_crypto[i] <- daily_fiat_cashed_out - orig.fiat.of.this.vol
    
    # Adjust current averages
    # Remove the spent crypto volume from your current total volume
    coin.tracking[[spend_crypto_coin]]$vol <- coin.tracking[[spend_crypto_coin]]$vol - spend_crypto_amt
    all_data.df$sold_coin_new_vol[i]       <- coin.tracking[[spend_crypto_coin]]$vol - spend_crypto_amt
    
    # The value has not changed, only the volume
    all_data.df$sold_coin_new_val[i]       <- coin.tracking[[spend_crypto_coin]]$val
    
  }
}


write.table(x = all_data.df, file = "output/crypto_gains.txt", sep = "\t", col.names = T, row.names = F, quote = F)







