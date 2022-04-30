#### Currency conversion ####
# Obtain the conversion for the year
convert.df <- read.delim2(file = input_convert.FN, header = TRUE, sep = ","
                          #, quote = TRUE
)
head(convert.df)
str(convert.df) # note: all are character values

# Convert price to numeric
convert.df$Price <- as.numeric(x = convert.df$Price)
str(convert.df)

# Convert date to correct format
convert.df$Date <- as.Date(x = convert.df$Date, tryFormats = c("%b %d, %Y"))
#colnames(convert.df)[which(colnames(convert.df)=="Date.corr")] <- "Date" # I think this is done earlier now
head(convert.df)

# Keep only needed cols
convert.df <- convert.df[, c("Date", "Price")]
str(convert.df)
head(convert.df)

### Go to combine_crypto_and_NFT_activity.R
