# xero_tools

This is an experimental repository specifically designed for the needs of the author(s) and comes with no guarantees for other uses.     


### 00. Setup
To use this repository, you will the following items:     
i) tezos-CAD or -USD daily conversion
Obtain from the following site:        
https://www.investing.com/indices/investing.com-xtz-cad-historical-data     
Use the 'Historical Data' option, select the entire year, and export to csv.    

ii) wallet activity         
Obtained from NFTbiker tools `https://nftbiker.xyz/`       

iii) Withdrawals of tezos from exchanges          
Note: this is currently assuming that the day that you purchase the tezos from the exchange you also withdrew the tezos. This will be improved with future iterations.        

*Important*: this must be titled in the following format:       
`<marketplace>_withdrawal_history_<YYYY-MM-DD>.csv`        

...and it must be built in the following way, in csv format:     
| coin | date | time | amount |
|------|------|------|--------|
| XTZ | 2021-01-27 | NA | 36.725725 |
| XRP | 2021-03-24 | NA | 25.02 |

You can have as many different withdrawals from different exchanges, as long as they are all in this format. They will all be imported and sorted by date.       

Copy these three items into the `inputs` folder.      


### 01. Initiate and Load inputs
Open `initiator.R` from Rstudio, set the following variables and launch:          
`input_convert.FN` ...is your crypto-fiat conversion table.       
`currency`     
`coin`     
`year`     
`wallet_activity.FN`      
`username`       
`initial.value` this is the value of your coin at the start of the year (how much each is worth).     
`initial.volume` this is the initial volume of your coin at the start of the year.       
If you had no tezos at the start of the year, set both as 0.    

Then run `import_crypto_buys.R` to create withdrawal.df, which contains the withdrawal details of your coin off the exchange, and assumes that the acquisition of the coin occurred on that day.         

Then run `import_NFT_activity.R` to import your wallet buy/ sell activity of NFTs.      

Then run `import_crypto_to_fiat.R` to bring in your crypto-fiat conversion table.      


### 02. Calculate gains and losses per transaction
Inputs are:     
`withdrawal.df`        
`activity.df`       
`convert.df`       


