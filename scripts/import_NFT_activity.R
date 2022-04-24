#### Wallet Activity ####
# Obtain the wallet activity for the year
activity.df <- read.delim(file = wallet_activity.FN, header = TRUE, sep = ",")
head(activity.df)
str(activity.df)

# Correct date to YYYY-MM-DD
activity.df$Date.corr <- as.Date(x = activity.df$Date, tryFormats = c("%y-%m-%d %H"))

## Confirming date formatting worked correctly 
# head(activity.df[c("Date", "Date.corr")])
# tail(activity.df[c("Date", "Date.corr")])

# Temporary fix for the renamed 'Token' to now 'Objkt' in the readout
colnames(activity.df)[which(colnames(activity.df)=="Objkt")] <- "Token"

# Keep specific columns
activity.df <- activity.df[,c("Date.corr", "Token", "Buyer", "Creator", "Type", "Ed.", "Swap", "Total")]
colnames(activity.df)[1] <- "Date"

# Limit by year
print(paste0("You have chosen to only consider **", year, "** NFT activity"))
activity.df <- activity.df[grep(pattern = year, x = activity.df$Date), ]
head(activity.df)
tail(activity.df)

# Remove OTC
print("Warning: free transfer NFTs are not yet considered in this pipeline, removing OTC")
activity.df <- activity.df[activity.df$Total!="OTC", ]
head(activity.df)
#TODO: Need to deal with ### OTCs (for now remove them)

# GOTO: combine_crypto_and_NFT_activity.R