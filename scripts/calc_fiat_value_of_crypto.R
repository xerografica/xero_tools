# PREP, obtaining relevant row
current.df <- all.df[1,]

#### Calculate the value of bought tezos for each day


# Loop over each transaction
date_of_withdrawal <- NULL; daily_coin_price <- NULL
for(i in 1:nrow(withdrawal.df)){
  
  # What was the date of the purchase? 
  date_of_withdrawal <- withdrawal.df[i,"date"]
  date_of_withdrawal
  
  # How much were tezos worth that day? 
  daily_coin_price <- convert.df[convert.df$Date.corr==date_of_withdrawal, "Price"]
  daily_coin_price
  
  # What is your total spend amount in fiat? 
  amt_spent_fiat <- withdrawal.df[i,"amount"] * daily_coin_price
  amt_spent_fiat
  
  # Include your spent fiat in the df
  withdrawal.df$amt_spent_fiat[i] <- amt_spent_fiat
  #str(withdrawal.df)
  #withdrawal.df$amt_spent_fiat <- as.numeric(withdrawal.df$amt_spent_fiat)
  
  # # What is your volume purchased? 
  withdrawal.df$trade_vol[i] <- withdrawal.df$amount[i]
  
  # What is your current total vol of tezos?
  # If it is the first record of the year, add the initial volume to the amount currently withdrawn
  if(i==1){
    
    withdrawal.df$current.crypto.vol[i] <- initial.volume + withdrawal.df$amount[i]
    
  # If it is not the first record of the year, add the current amount to the previous total
  }else if(i!=1){
    
    withdrawal.df$current.crypto.vol[i] <- withdrawal.df$current.crypto.vol[i-1] + withdrawal.df$amount[i]
    
  }
  
  withdrawal.df
  
  # Trade mean price
  withdrawal.df$trade_mean_price[i] <-  withdrawal.df$amt_spent_fiat[i] / withdrawal.df$amount[i]
  # TODO: THIS CAN BE REPLACED FROM THE TEZOS TABLE? 
  
  withdrawal.df
  
  
  # Overall mean price
  
  if(i==1){
    
    withdrawal.df$current.crypto.val[i] <- ((withdrawal.df$trade_mean_price[i] * withdrawal.df$trade_vol[i]) + (initial.value * initial.volume)) / withdrawal.df$current.crypto.vol[i]
    
  }else if(i!=1){
    
    withdrawal.df$current.crypto.val[i] <- ((withdrawal.df$trade_mean_price[i] * withdrawal.df$trade_vol[i]) + 
                                              (withdrawal.df$current.crypto.val[i-1] * withdrawal.df$current.crypto.vol[i-1])) / 
                                                                      withdrawal.df$current.crypto.vol[i]
    
  }
  
}

withdrawal.df



### Notes: 
# this currently assumes no spend of tezos for any NFT
# Next need to integrate sales/ buys (removes total vol of tez)



