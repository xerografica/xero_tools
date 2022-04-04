# Calculate per transaction


# Broadly, per line
head(all.df)


# Loop
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
