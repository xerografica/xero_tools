# Imports the crypto buys based on withdrawals from exchanges
# NOTE: assumes that withdrawals in coin mean the coin was purchased that day

# Set filename as, for example: "kucoin_withdrawal_history_<date>.csv"
withdrawal.FN <- list.files(path = "input", pattern = "_withdrawal_history_", full.names = TRUE)

# Remove the dummy version from the list if it is not running the demo
if(demo.version == "no"){
  
  withdrawal.FN <- withdrawal.FN[-grep(pattern = "dummy", x = withdrawal.FN )]
  
}

# Import all withdrawal histories and create single storage object
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
print(paste0("You have chosen to only consider **", coin, "** transactions"))
withdrawal.df <- withdrawal.df[grep(pattern = coin, x = withdrawal.df$coin), ]

# Keep only year of interest
print(paste0("You have chosen to only consider **", year, "** dates"))
withdrawal.df <- withdrawal.df[grep(pattern = year, x = withdrawal.df$date), ]

# Here is the details of crypto coin acquisition
withdrawal.df

# GOTO: import_NFT_activity.R