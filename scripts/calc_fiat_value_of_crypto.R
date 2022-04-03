# BACKUP
#withdrawal.df.bck <- withdrawal.df
#withdrawal.df <- withdrawal.df.bck

#### Calculate the value of bought tezos for each day
# Create dummy cols
withdrawal.df$amt_spent_fiat     <- as.numeric(rep(x = NA, times = nrow(withdrawal.df)))
withdrawal.df$trade_vol          <- as.numeric(rep(x = NA, times = nrow(withdrawal.df)))
withdrawal.df$trade_mean_price   <- as.numeric(rep(x = NA, times = nrow(withdrawal.df)))

withdrawal.df$overall_total_vol  <- as.numeric(rep(x = NA, times = nrow(withdrawal.df)))
withdrawal.df$overall_mean_price <- as.numeric(rep(x = NA, times = nrow(withdrawal.df)))

withdrawal.df


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
    
    withdrawal.df$overall_total_vol[i] <- initial.volume + withdrawal.df$amount[i]
    
  # If it is not the first record of the year, add the current amount to the previous total
  }else if(i!=1){
    
    withdrawal.df$overall_total_vol[i] <- withdrawal.df$overall_total_vol[i-1] + withdrawal.df$amount[i]
    
  }
  
  withdrawal.df
  
  # Trade mean price
  withdrawal.df$trade_mean_price[i] <-  withdrawal.df$amt_spent_fiat[i] / withdrawal.df$amount[i]
  # TODO: THIS CAN BE REPLACED FROM THE TEZOS TABLE? 
  
  withdrawal.df
  
  
  # Overall mean price
  
  if(i==1){
    
    withdrawal.df$overall_mean_price[i] <- ((withdrawal.df$trade_mean_price[i] * withdrawal.df$trade_vol[i]) + (initial.value * initial.volume)) / withdrawal.df$overall_total_vol[i]
    
  }else if(i!=1){
    
    withdrawal.df$overall_mean_price[i] <- ((withdrawal.df$trade_mean_price[i] * withdrawal.df$trade_vol[i]) + 
                                              (withdrawal.df$overall_mean_price[i-1] * withdrawal.df$overall_total_vol[i-1])) / 
                                                                      withdrawal.df$overall_total_vol[i]
    
  }
  
}

withdrawal.df



### Notes: 
# this currently assumes no spend of tezos for any NFT
# Next need to integrate sales/ buys (removes total vol of tez)



