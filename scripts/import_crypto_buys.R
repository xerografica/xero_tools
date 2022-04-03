# Imports the crypto buys based on withdrawals from exchanges
# NOTE: assumes that withdrawals in xtz mean the xtz was purchased that day

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

withdrawal.df

# This df will then be merged with NFT activity log

# GOTO: import_NFT_activity.R