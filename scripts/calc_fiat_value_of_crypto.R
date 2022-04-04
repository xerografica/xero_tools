# Operations on crypto buy (initial or subsequent)
# 2022-04-04
# crypto_buy <- function(df = all.df, position = "initial", current_crypto_vol = "NA", current_crypto_val = "NA"
#                        , transaction_index = "i"){
  # Position can be initial or subsequent
  
  if(all.df$type[i]=="CRYPTO"){
    
    #### Currently run on CRYPTO activities
    # Loop over each transaction (NOTE: THIS IS NOT WHERE THE LOOP SHOULD BE)
    date_of_withdrawal <- NULL; daily_coin_price <- NULL; completed_table.df <- NULL
    #for(i in 1:nrow(current.df)){
    
    # What was the date of the purchase? 
    date_of_withdrawal <- current.df[i,"date"]
    print(paste0("This transaction occurred on ", date_of_withdrawal))
    
    # What was the coin worth that day? 
    daily_coin_price <- convert.df[convert.df$Date.corr==date_of_withdrawal, "Price"]
    print(paste0("Today the fiat value per coin is: ", daily_coin_price, " ", currency))
    
    # What is your total spend amount in fiat? 
    amt_spent_fiat <- current.df[i,"amount"] * daily_coin_price
    print(paste0("On this transaction, you have spent: ", amt_spent_fiat, " ", currency))
    
    # Retain this info in the df
    print("Retain the spent amount and the volume purchased")
    current.df$amt_spent_fiat[i] <- amt_spent_fiat  # Retain activity spent fiat
    current.df$trade_vol[i] <- current.df$amount[i] # Retain volume purchased
    current.df$trade_mean_price[i] <- daily_coin_price # Trade mean price (amount paid per coin)
    
    
    # Consider this activity and those before, what is your current total vol of coin?
    # If it is the first record of the year (position = initial), add the initial volume to the amount currently withdrawn
    if(current.df[i, "position"]=="initial"){
      
      current.df$current.crypto.vol[i] <- initial.volume + current.df$amount[i]
      print(paste0("This is the initial transaction, adding initial volume to the current transaction amount"))
      print("Retaining this value")
      
      # Calculate your overall mean price of the coin to-date moving forward
      current.df$current.crypto.val[i] <- ((current.df$trade_mean_price[i] * current.df$trade_vol[i]) + (initial.value * initial.volume)) / current.df$current.crypto.vol[i]
      
      # If it is not the first record of the year, add the current amount to the previous total
    }else if(current.df[i, "position"]=="subsequent"){
      
      # #### TODO #####
      # current.vol <- all.df[(slice-1), "current.crypto.vol"]
      # current.val <- all.df[(slice-1), "current.crypto.val"]
      # 
      # current.df$current.crypto.vol[i] <- current.vol + current.df$amount[i]
      # 
      
      # Calculate your overall mean price of the coin to-date moving forward
      current.df$current.crypto.val[i] <- ((current.df$trade_mean_price[i] * current.df$trade_vol[i]) + 
                                             (current.df$current.crypto.val[i-1] * current.df$current.crypto.vol[i-1])) / 
        current.df$current.crypto.vol[i]
      
    }
    
    # Save this round into the new, completed df
    completed_table.df <- rbind(completed_table.df, current.df)
    
  }
  
  completed_table.df
  
  
  
  
  
#}



# PREP, obtaining relevant row
# # Initialize
# i <- 1

# # Second, a sale: 
i <- 2


slice <- i
current.df <- all.df[slice, ]

current.vol <- all.df[(slice-1), "current.crypto.vol"]
current.val <- all.df[(slice-1), "current.crypto.val"]

#### Calculate the value of bought tezos for each day


### Notes: 
# this currently assumes no spend of tezos for any NFT
# Next need to integrate sales/ buys (removes total vol of tez)



