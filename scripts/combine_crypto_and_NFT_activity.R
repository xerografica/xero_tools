# Uses outputs of import_crypto_buys.R, and import_NFT_activity.R
head(withdrawal.df)
head(activity.df)
head(convert.df)

# Set values in columns missing from activity.df
activity.df$type <- "NFT"
activity.df$coin <- "XTZ"
colnames(activity.df)[colnames(activity.df)=="Date"] <- "date"
head(activity.df)

# Set values in columns missing from activity.df
withdrawal.df$type <- "CRYPTO"
withdrawal.df$Token <- NA
withdrawal.df$Buyer <- username
withdrawal.df$Creator <- NA
withdrawal.df$Type <- "buy"
withdrawal.df$Ed. <- NA
withdrawal.df$Swap <- NA
withdrawal.df$Total <- NA

withdrawal.df <- withdrawal.df[,c("date", "Token", "Buyer", "Creator", "Type"
                 , "Ed.", "Swap", "Total", "type", "coin", "amount")]
head(withdrawal.df)
str(withdrawal.df)
withdrawal.df$date <- as.Date(x = withdrawal.df$date, tryFormats = c("%Y-%m-%d"))


head(activity.df)
activity.df$amount <- NA
str(activity.df)

#### SAVE POINT ####
# Simple rbind to join the crypto activity and the NFT activity
all.df <- rbind(withdrawal.df, activity.df)
str(all.df)

dim(all.df)
dim(withdrawal.df)
dim(activity.df)

# Now all are in the same dataframe, proceed. 
all.df <- all.df[order(all.df$date), ]

# Add columns to be filled through the calculations loop
# NOTE: may need to use as.numeric(rep(x = NA, times = nrow(all.df)))
all.df$gains.crypto <- NA
all.df$losses.crypto <- NA

all.df$gains.NFT <- NA
all.df$losses.NFT <- NA

all.df$fiat.val.of.NFT.indiv <- NA
all.df$fiat.val.of.NFT.all <- NA

all.df$current.crypto.val <- NA
all.df$current.crypto.vol <- NA

# Other cols needed
all.df$amt_spent_fiat     <- as.numeric(rep(x = NA, times = nrow(all.df))) # amount spent for crypto this trade
all.df$trade_vol          <- as.numeric(rep(x = NA, times = nrow(all.df))) # Volume this trade
all.df$trade_mean_price   <- as.numeric(rep(x = NA, times = nrow(all.df))) # Average price this trade

all.df$position <- c("initial", rep("subsequent", times = (nrow(all.df)-1) ))

head(all.df)

# WILL NEED THE POSITION PRIOR IF A SUBSEQUENT TRANSACTION

# GO TO calc_loop.R
