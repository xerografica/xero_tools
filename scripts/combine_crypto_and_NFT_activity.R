# Run after running import_crypto_buys.R, import_NFT_activity.R, and import_crypto_to_fiat.R
head(withdrawal.df) # from import_crypto_buys.R 
head(activity.df)   # from import_NFT_activity.R
head(convert.df)    # from_crypto_to_fiat.R


#### Add columns and missing values ####
# Add values in missing columns (withdrawal.df)
withdrawal.df$Buyer   <- username
withdrawal.df$type    <- "CRYPTO"
withdrawal.df$Type    <- "buy"
withdrawal.df$Token   <- NA
withdrawal.df$Creator <- NA
withdrawal.df$Ed.     <- NA
withdrawal.df$Swap    <- NA
withdrawal.df$Total   <- NA

# Order the columns (withdrawal.df)
withdrawal.df <- withdrawal.df[,c("date", "Token", "Buyer", "Creator", "Type"
                 , "Ed.", "Swap", "Total", "type", "coin", "amount")]
withdrawal.df$date <- as.Date(x = withdrawal.df$date, tryFormats = c("%Y-%m-%d"))
head(withdrawal.df)

# Add values in missing columns (activity.df)
activity.df$coin <- coin
activity.df$type <- "NFT"
colnames(activity.df)[colnames(activity.df)=="Date"] <- "date"
activity.df$amount <- NA
head(activity.df)

# Order the columns (activity.df)
activity.df <- activity.df[, c("date", "Token", "Buyer", "Creator", "Type"
                , "Ed.", "Swap", "Total", "type", "coin", "amount")]


#### Combine the dataframes ####
# Simple rbind to join the crypto activity and the NFT activity
all.df <- rbind(withdrawal.df, activity.df)
str(all.df)

# Confirm the size is correct
dim(withdrawal.df)
dim(activity.df)
dim(all.df)

# All are in the same dataframe, order by date and then type (crypto then NFT)
all.df <- all.df[order(all.df$date, all.df$Type), ]

#### Add columns to be filled with loop ####
# NOTE: may need to use as.numeric(rep(x = NA, times = nrow(all.df)))
all.df$gains.crypto <- NA
#all.df$losses.crypto <- NA # TODO: delete, as only using one column for this, based on (-) or (+)

all.df$gains.NFT <- NA
#all.df$losses.NFT <- NA    # TODO: delete, as only using one column for this, based on (-) or (+)

all.df$fiat.val.of.NFT.indiv <- NA # fiat value of the purchased NFT
all.df$fiat.val.of.NFT.all <- NA   # fiat value of all of the NFTs if there are multiple copies bought

all.df$current.crypto.val <- NA    # constantly updating value of the crypto
all.df$current.crypto.vol <- NA    # constantly updating volume of the crypto

# Other cols needed
all.df$amt_spent_fiat     <- as.numeric(rep(x = NA, times = nrow(all.df))) # amount spent for crypto this trade
all.df$trade_vol          <- as.numeric(rep(x = NA, times = nrow(all.df))) # Volume this trade
all.df$trade_mean_price   <- as.numeric(rep(x = NA, times = nrow(all.df))) # Average price this trade
all.df$Total <- as.numeric(all.df$Total)
all.df$inventory <- NA
all.df$daily_price_crypto <- as.numeric(rep(x = NA, times = nrow(all.df))) # Retained from crypto table

# Create a vector that indicates whether the transaction is the initial or a subsequent
all.df$position <- c("initial", rep("subsequent", times = (nrow(all.df)-1) ))
head(all.df)

# Create a backup
all.df.bck <- all.df
#all.df <- all.df.bck # RESTORE POINT

# GOTO calc_loop.R
