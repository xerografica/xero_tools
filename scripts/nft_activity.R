# Operations on NFT buy or sell
# 2022-04-04
nft_activity <- function(df = all.df, position = "NA", transaction_index = "NA"){
  # Position can be initial or subsequent
  
  i <- transaction_index
  print(i)
  
  # Date of transaction? 
  date_of_withdrawal <- df[i, "date"]
  print(paste0("This transaction occurred on ", date_of_withdrawal))
  ### TODO: Correct variable name ###
  
  # Coin's value on date of transaction? 
  daily_coin_price <- convert.df[convert.df$Date.corr==date_of_withdrawal, "Price"]
  print(paste0("Today the fiat value per coin is: ", daily_coin_price, " ", currency))
  #### TODO: Add this to the line info as well
  
  # What is the total spent amount in fiat? 
  amt_spent_fiat <- df[i,"Total"] * daily_coin_price
  print(paste0("On this transaction, ", amt_spent_fiat, " ", currency, " was spent"))
  
  # Retain this info in the df
  print("Retain the spent amount")
  df$amt_spent_fiat[i] <- amt_spent_fiat  # Retain activity spent fiat
  
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
    
  
  # If it is a secondary sale  
  }else if(df$Creator[i]!=username & df$Type[i]=="sale"){
    
    print("This is a secondary sale")
    
    # As this is a secondary sale, add this to the gains NFT row as a sale
    sold.objkt <- df$Token[i]
    
    ### CURRENTLY ACTING AS FIFO UNTIL AVG PRICE ADDED (TODO)###
    ### TODO: confirm the use of all.df is safe here rather than df, because referring to a previous round of data
    original.fiat.of.objkt <- abs(all.df[which(df$Token==sold.objkt)[1], "fiat.val.of.NFT.indiv"]) # Amount spent on the FIRST objkt
    
    ### TODO: ADD COLUMN WHETHER ASSET IS STILL IN WALLET
    
    # NFT gain
    gain_from_selling_NFT <- df[i,"amt_spent_fiat"] - original.fiat.of.objkt
    # Add to df
    df[i,"gains.NFT"] <- gain_from_selling_NFT
    
    # Affects current.crypto.val, and current.crypto.vol
    # Calculate your overall mean price of the coin to-date moving forward
    # Calculate weighted average
    
    # Total volume in wallet
    total_vol <- df$current.crypto.vol[i-1] + df[i,"Total"]
    
    # Weighted average: 
    df$current.crypto.val[i] <- (daily_coin_price * df[i,"Total"] + df$current.crypto.val[i-1] * df$current.crypto.vol[i-1]) / 
      total_vol
    df$current.crypto.vol[i] <- total_vol
    
    # Indicate that the sale occurred by removing the NFT from your collection
    df[which(df$Token==sold.objkt & df$inventory==1)[1], "inventory"] <- 0
    
  
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
