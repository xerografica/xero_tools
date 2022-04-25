# Operations on NFT buy or sell
# 2022-04-04
nft_activity <- function(df = all.df, position = "NA", transaction_index = "NA"){
  # Position can be initial or subsequent
  
  # Use the variable i instead of long form
  i <- transaction_index
  print(paste0("Operating on the transaction ", i))
  
  # Date of transaction? 
  date_of_withdrawal <- df[i, "date"]
  print(paste0("This transaction occurred on ", date_of_withdrawal))
  ### TODO: Correct variable name ###
  
  # Coin's value on date of transaction? 
  daily_coin_price <- convert.df[convert.df$Date.corr==date_of_withdrawal, "Price"]
  print(paste0("Today the fiat value per coin is: ", daily_coin_price, " ", currency))
  df[i , "daily_price_crypto"] <- daily_coin_price # retain this info in the df
  #### TODO: This constant formula should be done in the combine script, not here
  
  # What is the total fiat amount?  
  amt_spent_fiat <- df[i,"Total"] * daily_coin_price
  print(paste0("On this transaction, ", amt_spent_fiat, " ", currency, " was spent"))
  df$amt_spent_fiat[i] <- amt_spent_fiat           # retain this info in the df
  
  
  ##### Primary Sale #####
  # If this was a primary sale: 
  if(df$Creator[i]==username & df$Type[i]=="sale"){
    
    print("This was a primary sale")
    
    # As it was a primary sale, add this to the gains NFT row as a sale
    df$gains.NFT[i] <- df$amt_spent_fiat[i]
    
    # Also need to affect the total volume of coin and the total value of coin
    # affects current.crypto.val and current.crypto.vol
    # Calculate your overall mean price of the coin to-date moving forward
    
    # Total volume in wallet
    total_vol <- df$current.crypto.vol[i-1] + df[i,"Total"]
    df$current.crypto.vol[i] <- total_vol        # retain this info in the df
    #TODO: Note: this will break if your first transaction is buying an NFT, not buying crypto
    # solve with an if statement on subsequent or initial, then use the initial vol
    
    # Calculate weighted average price
    df$current.crypto.val[i] <- (daily_coin_price * df[i,"Total"] + df$current.crypto.val[i-1] * df$current.crypto.vol[i-1]) / 
                                    total_vol
    
    
  ##### Secondary Sale #####
  # If it is a secondary sale  
  }else if(df$Creator[i]!=username & df$Type[i]=="sale"){
    
    print("This is a secondary sale")
    
    # As this is a secondary sale, add this to the gains NFT row as a sale
    # What was the objkt name? 
    sold.objkt <- df$Token[i]
    sold.creator <- df$Creator[i]
    
    # Reporting
    paste0("Secondary sale of ", sold.objkt, " created by ", sold.creator)
    
    # How many and which rows involve this exact token? 
    indices <- which(df$Token==sold.objkt & df$Creator==sold.creator & df$Type=="buy")
    #TODO: ensure that the above indices are only BEFORE the sale
    
    # Obtain the average buy price of this objkt
    avg.buy.price    <-  mean(
                        abs(
                          df[ indices, "amt_spent_fiat"]
                          )
                          )
    
    # Update the table with this average buy price
    df[ indices, "fiat.val.of.NFT.all" ] <- avg.buy.price
    
    # Debugging
    df[ indices, ]
    
### TODO: ADD COLUMN WHETHER ASSET IS STILL IN WALLET
    
    # NFT gain
    gain_from_selling_NFT <- df[i,"amt_spent_fiat"] - avg.buy.price
    
    print(paste0("This sale brought ", gain_from_selling_NFT, " ", currency, " of new crypto"))
    
    # Add to df
    df[i,"gains.NFT"] <- gain_from_selling_NFT
    
    # The sold amount is used to buy crypto through the sale
    # What is the amount spent and volume for the transaction?  
    amt.spent.transaction <- daily_coin_price * df[i,"Total"]
    volume.transaction <- df[i,"Total"]
    
    # What is the amount spent and volume in the wallet? 
    amt.spent.on.wallet.crypto <- df$current.crypto.val[i-1] * df$current.crypto.vol[i-1]
    volume.wallet.crypto <- df$current.crypto.vol[i-1]
    
    # What is the new weighted mean of the crypto value? 
    # amount spent transaction + amount spent wallet / vol total
    new.crypto.val <- ( amt.spent.transaction + amt.spent.on.wallet.crypto ) / ( volume.transaction + volume.wallet.crypto )
    
    # Update wallet (current value)
    df$current.crypto.val[i] <- new.crypto.val
    
    # Update wallet (current volume)
    total_vol <- df$current.crypto.vol[i-1] + df[i,"Total"]
    df$current.crypto.vol[i] <- total_vol
    
    # Indicate that the sale occurred by removing the NFT from your collection
    ### TODO: 
    #df[which(df$Token==sold.objkt & df$inventory==1)[1], "inventory"] <- 0
    
  
  ##### Buy #####
  # If this was a buy  
  }else if(df$Buyer[i]==username & df$Type[i]=="buy"){
    
    print("This was a buy")
    
    # Buying means crypto is sold to acquire the NFT
    # How much fiat was needed to buy the NFT? 
    crypto.sale.amt  <- abs(df$Total[i]) * daily_coin_price # Total price of the NFT in fiat
    
    # How much does this amount of fiat go for in your current average price? 
    crypto.value.amt <- abs(df$Total[i]) * df$current.crypto.val[i-1] # What is the number of coin worth in your wallet? 
    
    # How much difference between when you bought the AMOUNT of crypto and when you sold it today to buy the NFT? 
    gains_from_selling_crypto_for_NFT <- crypto.sale.amt - crypto.value.amt # Amount in fiat
    
    # Add to the table
    df$gains.crypto[i] <- gains_from_selling_crypto_for_NFT
    
    # Remove the sold crypto from your total volume
    df$current.crypto.vol[i] <- df$current.crypto.vol[i-1] - abs(df$Total[i])
    
    # Also record the amount in fiat paid for the NFT so you can consider gains when you resale it
    df[i, "fiat.val.of.NFT.indiv"] <- abs(df[i, "amt_spent_fiat"])
    
    # There is no change to the average price paid per coin, only the total vol, and so carry forward the 'current.crypto.val'
    df$current.crypto.val[i] <- df$current.crypto.val[i-1]
    
    # Add indicator that this objkt is in your inventory
    all.df$inventory[i] <- 1
    
  
  ##### Buy back of a creator's NFT #####
  # If this was a buy of the creators own NFT 
  }else if(df$Buyer[i]=="creator" & df$Creator[i]==username & df$Type[i]=="buy"){
  
  print("This was a buy back of the NFT by the user")
  
  # Buying means crypto is sold to acquire the NFT
  # How much fiat was needed to buy the NFT? 
  crypto.sale.amt  <- abs(df$Total[i]) * daily_coin_price # Total price of the NFT in fiat
  
  # How much does this amount of fiat go for in your current average price? 
  crypto.value.amt <- abs(df$Total[i]) * df$current.crypto.val[i-1] # What is the number of coin worth in your wallet? 
  
  # How much difference between when you bought the AMOUNT of crypto and when you sold it today to buy the NFT? 
  gains_from_selling_crypto_for_NFT <- crypto.sale.amt - crypto.value.amt # Amount in fiat
  
  # Add to the table
  df$gains.crypto[i] <- gains_from_selling_crypto_for_NFT
  
  # Remove the sold crypto from your total volume
  df$current.crypto.vol[i] <- df$current.crypto.vol[i-1] - abs(df$Total[i])
  
  # Also record the amount in fiat paid for the NFT so you can consider gains when you resale it
  df[i, "fiat.val.of.NFT.indiv"] <- abs(df[i, "amt_spent_fiat"])
  
  # There is no change to the average price paid per coin, only the total vol, and so carry forward the 'current.crypto.val'
  df$current.crypto.val[i] <- df$current.crypto.val[i-1]
  
  # Add indicator that this objkt is in your inventory
  all.df$inventory[i] <- 1
  
  
}

  assign(x = "all.df", value = df, envir = .GlobalEnv)

}
