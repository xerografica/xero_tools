# Operations on crypto buy (initial or subsequent)
# 2022-04-04
crypto_buy <- function(df = all.df, position = "NA", transaction_index = "NA"){
  # Position can be initial or subsequent
  
    i <- transaction_index
    print(paste0("Operating on the transaction ", i))
  
    date_of_withdrawal <- NULL; daily_coin_price <- NULL; 
    
    # What was the date of the purchase? 
    date_of_withdrawal <- df[i, "date"]
    print(paste0("This transaction occurred on ", date_of_withdrawal))
    
    # What was the coin worth that day? 
    daily_coin_price <- convert.df[convert.df$Date.corr==date_of_withdrawal, "Price"]
    print(paste0("Today the fiat value per coin is: ", daily_coin_price, " ", currency))
    df[r , "daily_price_crypto"] <- daily_coin_price
    
    # What is your total spend amount in fiat? 
    amt_spent_fiat <- df[i,"amount"] * daily_coin_price
    print(paste0("On this transaction, you have spent: ", amt_spent_fiat, " ", currency))
    
    # Retain this info in the df
    print("Retain the spent amount and the volume purchased")
    df$amt_spent_fiat[i] <- amt_spent_fiat  # Retain activity spent fiat
    df$trade_vol[i] <- df$amount[i] # Retain volume purchased
    df$trade_mean_price[i] <- daily_coin_price # Trade mean price (amount paid per coin)
    
    # Consider this activity and those before, what is your current total vol of coin?
    # If it is the first record of the year (position = initial), add the initial volume to the amount currently withdrawn
    if(df[i, "position"]=="initial"){
      
      df$current.crypto.vol[i] <- initial.volume + df$amount[i]
      print(paste0("This is the initial transaction, adding initial volume to the current transaction amount"))
      print("Retaining this value")
      
      # Calculate your overall mean price of the coin to-date moving forward
      df$current.crypto.val[i] <- ((df$trade_mean_price[i] * df$trade_vol[i]) + (initial.value * initial.volume)) / df$current.crypto.vol[i]
      
      # If it is not the first record of the year, add the current amount to the previous total
    }else if(df[i, "position"]=="subsequent"){
      
      # #### TODO #####
      # current.vol <- all.df[(slice-1), "current.crypto.vol"]
      # current.val <- all.df[(slice-1), "current.crypto.val"]
      # 
      # df$current.crypto.vol[i] <- current.vol + df$amount[i]
      # 
      
      # Calculate your overall mean price of the coin to-date moving forward
      df$current.crypto.val[i] <- ((df$trade_mean_price[i] * df$trade_vol[i]) + 
                                             (df$current.crypto.val[i-1] * df$current.crypto.vol[i-1])) / 
        df$current.crypto.vol[i]
      
    }
    
    # Not using this method anymore, writing into the actual df
    # # Save this round into the new, completed df
    # completed_table.df <- rbind(completed_table.df, df[i,])
    # 
    # completed_table.df
    # 
    # assign(x = "completed_table.df", value = completed_table.df, envir = .GlobalEnv)
    # /END/ Not using this method anymore, writing into the actual df

    
    assign(x = "all.df", value = df, envir = .GlobalEnv)
    
  }
  

### Notes: 
# this currently assumes no spend of tezos for any NFT
# Next need to integrate sales/ buys (removes total vol of tez)



