#### Wallet Activity ####
# Obtain the wallet activity for the year
activity.df <- read.delim(file = wallet_activity.FN, header = TRUE, sep = ",")
head(activity.df)
str(activity.df)

activity.df$Date.corr <- as.Date(x = activity.df$Date, tryFormats = c("%y-%m-%d %H"))

head(activity.df[c("Date", "Date.corr")])
tail(activity.df[c("Date", "Date.corr")])

activity.df <- activity.df[,c("Date.corr", "Token", "Buyer", "Creator", "Type", "Ed.", "Swap", "Total")]
colnames(activity.df)[1] <- "Date"

# TODO: Limit by year here
activity.df <- activity.df[grep(pattern = year, x = activity.df$Date), ]
head(activity.df)
tail(activity.df)

# TODO: Need to deal with ### OTCs (for now remove them)

# Remove OTC
activity.df <- activity.df[activity.df$Total!="OTC", ]
head(activity.df)

# GOTO: combine_crypto_and_NFT_activity.R