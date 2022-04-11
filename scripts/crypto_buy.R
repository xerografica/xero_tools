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
    df[i , "daily_price_crypto"] <- daily_coin_price # retain this info in the df
    
    # What is your total spend amount in fiat? 
    amt_spent_fiat <- df[i,"amount"] * daily_coin_price # number coin x price
    print(paste0("On this transaction, ", amt_spent_fiat, " ", currency, " was spent"))
    df$amt_spent_fiat[i] <- amt_spent_fiat           # retain this info in the df
    
    # What is the volume of crypto in this transaction? 
    df$trade_vol[i] <- df$amount[i]                  # retain this info in the df
    
    # What is the average price you paid for each coin? 
    df$trade_mean_price[i] <- daily_coin_price       # retain this info in the df
    #TODO: is this redundant? 
    
    #### Coin balance ####
    # Consider this activity and those before, what is your current total vol of coin?
    # First transaction of the year? Add the initial volume to the amount currently withdrawn
    if(df[i, "position"]=="initial"){
      
      # Calculate your new current coin volume
      df$current.crypto.vol[i] <- initial.volume + df$amount[i]
      print(paste0("This is the initial transaction, adding initial volume, (", initial.volume
                   , ") to the current transaction amount: ", df$current.crypto.vol[i]))
      
      # Calculate your new current average coin price (overall) moving forward
      df$current.crypto.val[i] <- ((df$trade_mean_price[i] * df$trade_vol[i]) + (initial.value * initial.volume)) / df$current.crypto.vol[i]
      
    # If it is not the first record of the year, add the current amount to the previous total
    }else if(df[i, "position"]=="subsequent"){
      
      # Update the total volume of crypto after this buy
      df$current.crypto.vol[i] <- df[i-1, "current.crypto.vol"] + df$amount[i]
      
      # Reporting
      print(paste0("This is a subsequent crypto buy, adding the current transaction amount: "
                     , df$amount[i], " to the previous volume, (", df[i-1, "current.crypto.vol"], ")"
                    ))
      
      # Calculate your new current average coin price (overall) moving forward
      df$current.crypto.val[i] <- ((df$trade_mean_price[i] * df$trade_vol[i]) + (df[i-1, "current.crypto.val"] * df[i-1, "current.crypto.vol"])) / 
        df$current.crypto.vol[i]

    }
    
    assign(x = "all.df", value = df, envir = .GlobalEnv)
    
  }
  

### Notes: 
# this currently assumes no spend of tezos for any NFT
# Next need to integrate sales/ buys (removes total vol of tez)



