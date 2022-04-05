# Operations on NFT buy or sell
# 2022-04-04
nft_activity <- function(df = all.df, position = "NA", transaction_index = "NA"){
  # Position can be initial or subsequent
  
  # Use the variable i instead of long form
  i <- transaction_index
  
  # For debugging
  print(i)
  
  # Date of transaction? 
  date_of_withdrawal <- df[i, "date"]
  print(paste0("This transaction occurred on ", date_of_withdrawal))
  ### TODO: Correct variable name ###
  
  # Coin's value on date of transaction? 
  daily_coin_price <- convert.df[convert.df$Date.corr==date_of_withdrawal, "Price"]
  print(paste0("Today the fiat value per coin is: ", daily_coin_price, " ", currency))
  #### TODO: Add this to the line info as well
  #### TODO: This constant formula should be done in the combine script, not here
  
  # What is the total fiat amount?  
  amt_spent_fiat <- df[i,"Total"] * daily_coin_price
  print(paste0("This transaction involves, ", amt_spent_fiat, " ", currency, " (note: recording this amount)"))
  
  # Keep this info in the df
  df$amt_spent_fiat[i] <- amt_spent_fiat  # Retain activity spent fiat
  
  
  ##### Primary Sale #####
  # If this was a primary sale: 
  if(df$Creator[i]==username & df$Type[i]=="sale"){
    
    print("This was a primary sale")
    
    ### NOTE: DOES NOT WORK IF INITIAL IS NFT ##### #TODO
    
    # As it was a primary sale, add this to the gains NFT row as a sale
    df$gains.NFT[i] <- df$amt_spent_fiat[i]
    
    # Also need to affect the total volume of coin and the total value of coin
    # affects current.crypto.val and current.crypto.vol
    # Calculate your overall mean price of the coin to-date moving forward
    
    # Calculate weighted average
    # Total volume in wallet
    total_vol <- df$current.crypto.vol[i-1] + df[i,"Total"]
    
    
    df$current.crypto.val[i] <- (daily_coin_price * df[i,"Total"] + df$current.crypto.val[i-1] * df$current.crypto.vol[i-1]) / 
                                    total_vol
    df$current.crypto.vol[i] <- total_vol
    
  ##### Secondary Sale #####
  # If it is a secondary sale  
  }else if(df$Creator[i]!=username & df$Type[i]=="sale"){
    
    print("This is a secondary sale")
    
    # As this is a secondary sale, add this to the gains NFT row as a sale
    # What was the objkt name? 
    sold.objkt <- df$Token[i]
    sold.creator <- df$Creator[i]
    
    paste0("Secondary sale of ", sold.objkt, " created by ", sold.creator)
    
    indices <- which(df$Token==sold.objkt & df$Creator==sold.creator & df$Type=="buy")
    
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
    
    print(paste0("This sale brought ", gain_from_selling_NFT, " ", currency))
    
    # Add to df
    df[i,"gains.NFT"] <- gain_from_selling_NFT
    
#### TODO: REMOVE losses.NFT and losses.crypto cols, only use gains col with + or -
    
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
    # How much crypto was sold? 
    crypto.sale.amt  <- abs(df$Total[i]) * daily_coin_price
    crypto.value.amt <- abs(df$Total[i]) * df$current.crypto.val[i-1]
    gains_from_selling_crypto_for_NFT <- crypto.sale.amt - crypto.value.amt
    
    # Add to the table
    df$gains.crypto[i] <- gains_from_selling_crypto_for_NFT
    
    # Remove the sold crypto from your total volume
    df$current.crypto.vol[i] <- df$current.crypto.vol[i-1] - abs(df$Total[i])
    
    # Also add the amount in fiat paid for the NFT
    df[i, "fiat.val.of.NFT.indiv"] <- abs(df[i, "amt_spent_fiat"])
    
    # There is no change to the average price paid per coin, only the total vol, so carry forward the 'current.crypto.val'
    df$current.crypto.val[i] <- df$current.crypto.val[i-1]
    
    # Add indicator this objkt is in your inventory
    all.df$inventory[i] <- 1
    
  
  } 

  assign(x = "all.df", value = df, envir = .GlobalEnv)

}
