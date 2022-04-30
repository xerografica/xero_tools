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
    daily_coin_price <- convert.df[convert.df$Date==date_of_withdrawal, "Price"]
    print(paste0("Today the fiat value per coin is: ", daily_coin_price, " ", currency))
    df[i , "daily_price_crypto"] <- daily_coin_price # retain this info in the df
    
    # What is the total spend amount in fiat? 
    amt_spent_fiat <- df[i,"amount"] * daily_coin_price # number coin x price
    print(paste0("On this transaction, ", amt_spent_fiat, " ", currency, " was spent"))
    df$amt_spent_fiat[i] <- amt_spent_fiat           # retain this info in the df
    
    # # What is the total spend amount in fiat in the wallet? 
    # wallet_spent_fiat <- df[i,"amount"] * df$current.crypto.val[i-1] # number coin x price
    # print(paste0("The wallet fiat price of this transaction: ", wallet_spent_fiat, " ", currency))
    # df$wallet_spent_fiat[i] <- wallet_spent_fiat           # retain this info in the df
    # 
    # What is the volume of crypto in this transaction? 
    df$trade_vol[i] <- df$amount[i]                  # retain this info in the df
    
    # What is the average price that was paid for each coin? 
    df$trade_mean_price[i] <- daily_coin_price       # retain this info in the df
    #TODO: is this redundant? I think it is, but is used below. 
    
    
    #### Coin balance ####
    # Consider this activity and those before, what is your current total vol of coin?
    # First transaction of the year? Add the initial volume to the amount currently withdrawn
    # NOTE: the first position MUST BE A BUY currently (#TODO#)
    if(df[i, "position"]=="initial"){
      
      # Calculate your new current coin volume
      df$current.crypto.vol[i] <- initial.volume + df$amount[i]
      print(paste0("This is the initial transaction, adding initial volume, (", initial.volume
                   , ") to the current transaction amount: ", df$current.crypto.vol[i]))
      
      # Calculate your new current average coin price (overall) moving forward
      df$current.crypto.val[i] <- ((df$trade_mean_price[i] * df$trade_vol[i]) + (initial.value * initial.volume)) / df$current.crypto.vol[i]
      
    # If it is not the first record of the year, add the current amount to the previous total
    }else if(df[i, "position"]=="subsequent" & df[i, "Type"]=="buy"){
      
      # Update the total volume of crypto after this buy
      df$current.crypto.vol[i] <- df[i-1, "current.crypto.vol"] + df$amount[i]
      
      # Reporting
      print(paste0("This is a subsequent crypto buy, adding the current transaction amount: "
                     , df$amount[i], " to the previous volume, (", df[i-1, "current.crypto.vol"], ")"
                    ))
      
      # Calculate your new current average coin price (overall) moving forward
      df$current.crypto.val[i] <- ((df$trade_mean_price[i] * df$trade_vol[i]) + (df[i-1, "current.crypto.val"] * df[i-1, "current.crypto.vol"])) / 
        df$current.crypto.vol[i]

    # If it is not the first record of the year, AND is a SELL
    }else if(df[i, "position"]=="subsequent" & df[i, "Type"]=="sell"){
      
      # Update the total volume of crypto after this transaction
      df$current.crypto.vol[i] <- df[i-1, "current.crypto.vol"] - df$amount[i]
      
      # Reporting
      print(paste0("This is a subsequent crypto sell, subtracting the current transaction amount: "
                   , df$amount[i], " from the previous volume, (", df[i-1, "current.crypto.vol"], ")"
      ))
      
      # Update your daily value of the crypto (this doesn't change from previous with a sell)
      df$current.crypto.val[i] <- df$current.crypto.val[i-1]
      
      # Calculate gains and put it in column 'gains.crypto'
      user.cost <- df$current.crypto.val[i] * df$amount[i] 
      market.cost <- df$daily_price_crypto[i] * df$amount[i]
      
      gains <- market.cost - user.cost
      
      df$gains.crypto[i] <- gains
      
      df$wallet_spent_fiat[i] <- user.cost           # retain this info in the df
      # TODO: note: this could be where the wallet price is added to the df
      
      print("No new average is calculated, as this was a sell")
      print("gains calculated and recorded")
      
    }
    
    assign(x = "all.df", value = df, envir = .GlobalEnv)
    
  }
  

### Notes: 
# this currently assumes no spend of tezos for any NFT
# Next need to integrate sales/ buys (removes total vol of tez)



