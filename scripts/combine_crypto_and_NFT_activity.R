# Uses outputs of import_crypto_buys.R, and import_NFT_activity.R
head(withdrawal.df)
head(activity.df)
head(convert.df)

activity.df$type <- "NFT"
activity.df$coin <- "XTZ"
head(activity.df)
colnames(activity.df)[colnames(activity.df)=="Date"] <- "date"

withdrawal.df$type <- "CRYPTO"

withdrawal.df$Token <- NA
withdrawal.df$Buyer <- username
withdrawal.df$Creator <- NA
withdrawal.df$Type <- "buy"
withdrawal.df$Ed. <- NA
withdrawal.df$Swap <- NA
withdrawal.df$Total <- NA

withdrawal.df <- withdrawal.df[,c("date", "Token", "Buyer", "Creator", "Type"
                 , "Ed.", "Swap", "Total", "type", "coin", "amount")]
head(withdrawal.df)
str(withdrawal.df)
withdrawal.df$date <- as.Date(x = withdrawal.df$date, tryFormats = c("%Y-%m-%d"))


head(activity.df)
activity.df$amount <- NA
str(activity.df)

all.df <- rbind(withdrawal.df, activity.df)
str(all.df)

dim(all.df)
dim(withdrawal.df)
dim(activity.df)

# Now all are in the same dataframe, proceed. 
all.df <- all.df[order(all.df$date), ]

all.df$gains.crypto <- NA
all.df$losses.crypto <- NA
all.df$gains.NFT <- NA
all.df$losses.NFT <- NA
all.df$current.crypto.val <- NA
all.df$current.crypto.vol <- NA



# Broadly, per line
head(all.df)

for(r in 1:nrow(all.df)){
  
  # If the record is a crypto buy
  if(all.df[r,"type"]=="CRYPTO"){
    
    # Run calc_fiat_value_of_crypto
    # Will produce a value into current.crypto.val and current.crypto.vol
  
  }else if(all.df[r,"type"]=="NFT" && all.df[r,"Type"]=="buy"){
    
    # Run convert_gains.R
    # Will affect current.crypto.vol (decrease)
    # Selling crypto, so compare the daily value vs. current.crypto.val and add to gains.crypto or losses.crypto
    # Add column, fiat value paid for the NFT
    
  }else if(all.df[r,"type"]=="NFT" && all.df[r,"Type"]=="sale"){
    
    # Run convert_gains.R
    # Will affect current.crypto.vol (increase)
    # Buying crypto, so adjust current.crypto.val based on current vs. daily
    # THERE WILL ALSO BE A FIAT SALE AMOUNT, that is then used to buy crypto - THIS IS A GAIN

  }
  
  
  
}

