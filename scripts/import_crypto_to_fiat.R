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
convert.df$Date.corr <- as.Date(x = convert.df$Date, tryFormats = c("%b %d, %Y"))

# Confirm ok
head(convert.df[, c("Date.corr", "Date")])
tail(convert.df[, c("Date.corr", "Date")])

# Keep only needed cols
convert.df <- convert.df[, c("Date.corr", "Price")]
str(convert.df)


### Go to combine_crypto_and_NFT_activity.R

