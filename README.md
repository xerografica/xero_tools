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


### 01. Find your price of tezos, and track over transactions
Inputs:     
- tezos transactions from cryptocurrency exchange


