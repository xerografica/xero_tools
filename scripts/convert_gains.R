# Convert gains from tezos to fiat
# No guarantees provided

# Clear working space
#rm(list = ls())

# Set working directory

# Load libraries
#install.packages(tidyr)
require(tidyr)

# Set user variables
input_convert.FN <- "input/Tezos CAD Historical Data.csv"
wallet_activity.FN <- "input/activity.csv"
username <- "xerografica"
currency <- "CAD"


#### Currency conversion ####
# Obtain the conversion for the year
convert.df <- read.delim2(file = input_convert.FN, header = TRUE, sep = ","
                          #, quote = TRUE
                          )
head(convert.df)
str(convert.df) # note: all are character values

# Convert date to correct format
convert.df$Date.corr <- as.Date(x = convert.df$Date, tryFormats = c("%b %d, %Y"))

# Confirm ok
head(convert.df[, c("Date.corr", "Date")])
tail(convert.df[, c("Date.corr", "Date")])

# Keep only needed cols
convert.df <- convert.df[, c("Date.corr", "Price")]
colnames(convert.df) <- c("date", "price.tezos")

head(convert.df)

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

# TODO: Need to deal with ### OTCs (for now remove them)

# Remove OTC
activity.df <- activity.df[activity.df$Total!="OTC", ]
head(activity.df)

# Add the daily average value of tezos
activity.df <- merge(x = activity.df, y = convert.df, by.x = "Date", by.y = "date")
head(activity.df)

# Separate swap column into the actual sale price
activity.df <- separate(data = activity.df, col = Swap, into = c("quant", "sale.price.tez"), sep = "x", remove = TRUE)
head(activity.df)
str(activity.df)
# TODO: here should I remove the 'tz' and switch to numeric? OR are we not using this column?

# Make specific columns numeric values
activity.df$Total <- as.numeric(activity.df$Total)
activity.df$quant <- as.numeric(activity.df$quant)
activity.df$price.tezos <- as.numeric(activity.df$price.tezos)

# Determine what was the total paid in fiat for the NFT
activity.df$Total.fiat <- (activity.df$Total * activity.df$price.tezos)
head(activity.df)


#activity_sales_primary.df (later)
head(activity.df)

# Note: each objkt transaction has its own line item in the wallet

# TODO: Need a solution for instances where more than one item is bought, and one or more is sold
# THIS WILL PROBABLY DEPEND ON COUNTRY, FIFO or AVERAGE

##### Separate Buys from Sales for calculations #####
#### Buys ####
activity_buys.df <- activity.df[activity.df$Type=="buy", ]
head(activity_buys.df)

# Total spent on NFT in fiat this year
total_spent_fiat <- sum(activity_buys.df$Total.fiat)
total_spent_fiat

# Calculate average price paid per token
activity_buys.df$ID_token_creator <- paste0(activity_buys.df$Token, "__", activity_buys.df$Creator)
head(activity_buys.df)

unique_element <- table(activity_buys.df$ID_token_creator)

# These are the objkts that you bought more than one: 
names(unique_element[unique_element > 1])

# Example of how to calculate mean costs per objkt in fiat
row_of_note <- activity_buys.df[activity_buys.df$ID_token_creator=="#370712__Cryptofangs", ]
mean_buy_val <- mean(row_of_note$Total.fiat)
activity_buys.df$mean.total.fiat[activity_buys.df$ID_token_creator=="#370712__Cryptofangs"] <- mean_buy_val

# Do for all entries
objkt_of_note <- NULL; row_of_note <- NULL; mean_buy_val <- NULL; number_bought <- NULL
activity_buys.df$mean.total.fiat <- rep("NA", times = nrow(activity_buys.df))

for(i in 1:nrow(activity_buys.df)){
  
    # define objkt
    objkt_of_note <- activity_buys.df$ID_token_creator[i]
    
    # Get all buy rows with this entry 
    row_of_note <- activity_buys.df[activity_buys.df$ID_token_creator==objkt_of_note, ]
    
    # How many were bought of this objkt? (just for info)
    number_bought <- nrow(row_of_note)
    
    # Calculate the average amount spent on this token
    mean_buy_val <- mean(row_of_note$Total.fiat)
    
    # Assign the average amount spent on this token to the relevant rows
    activity_buys.df$mean.total.fiat[activity_buys.df$ID_token_creator==objkt_of_note] <- mean_buy_val
    
    # Assign the number bought to the relevant rows
    activity_buys.df$number_bought[activity_buys.df$ID_token_creator==objkt_of_note] <- number_bought
    
    # Reporting...
    activity_buys.df[activity_buys.df$ID_token_creator==objkt_of_note, ]
    
}

head(activity_buys.df)
tail(activity_buys.df)

# Reorder cols
# TODO?
#activity_buys.df[,c("ID_token_creator", )]

write.csv(x = activity_buys.df, file = "output/activity_buys_with_mean_fiat.csv", row.names = F)


##### Sales #####
activity_sales.df <- activity.df[activity.df$Type=="sale", ]

##### Primary Sales ######
# Primary sales (keep only those created by user)
activity_sales_primary.df <- activity_sales.df[activity_sales.df$Creator==username, ]
dim(activity_sales_primary.df)
head(activity_sales_primary.df)

tail(activity_sales_primary.df)

# Total earned on created NFT in fiat this year
total_earned_primary <- sum(activity_sales_primary.df$Total.fiat)
total_earned_primary
# TAX OBJECT

# Number of created objkts sold this year
number_objkts_sold_primary <- nrow(activity_sales_primary.df)
number_objkts_sold_primary

write.csv(x = activity_sales_primary.df, file = "output/activity_sales_with_fiat_out.csv", row.names = F)


####### Secondary Sales #######
activity_sales_secondary.df <- activity_sales.df[activity_sales.df$Creator!=username, ]
dim(activity_sales_secondary.df)
head(activity_sales_secondary.df)

## TODO: this should be done earlier, on the initial dataframe
# Create unique ID
activity_sales_secondary.df$ID_token_creator <- paste0(activity_sales_secondary.df$Token
                                                       , "__"
                                                       , activity_sales_secondary.df$Creator
                                                       )
head(activity_sales_secondary.df)

# Find the average purchase price of the sold item and add to the df
# First determine if the number of sales is more than one per objkt, if so, does not support

if( isTRUE(table(activity_sales_secondary.df$ID_token_creator) > 1) == TRUE ){
  
  print("This function not yet supported")
  
}else if(isTRUE(table(activity_sales_secondary.df$ID_token_creator) > 1) == FALSE){
  
  print("OK to proceed, only a single objkt was sold for each unique ID")
  
}

# Example for one
activity_buys.df[activity_buys.df$ID_token_creator=="#175130__x3r0ne", "mean.total.fiat"]
cost_for_NFT <- as.numeric(activity_buys.df[activity_buys.df$ID_token_creator=="#175130__x3r0ne", "mean.total.fiat"][1])
gains <- activity_sales_secondary.df[activity_sales_secondary.df$ID_token_creator=="#175130__x3r0ne", "Total.fiat"] - -(cost_for_NFT)
  
# put into a loop # TODO




## TODO: There must be a way to remove a line item once it has been accounted (sold), then carry forward what remains


### Code skeletons ####
# # Only consider the buys that have been sold
# secondary_details.df <- merge(x = activity_sales_secondary.df, y = activity_buys.df, by = "Token"
#                               #, all.x = TRUE
#                               )
# head(secondary_details.df)
# 
# # Hacky approach
# secondary_details.df <- secondary_details.df[!duplicated(secondary_details.df$Token), ]
# secondary_details.df
# 
# secondary_details.df$gains <- secondary_details.df$Total.fiat.x + secondary_details.df$Total.fiat.y
# total_earned_secondary <- sum(secondary_details.df$gains)
# total_earned_secondary
# 
# number_objkts_sold_secondary <- nrow(secondary_details.df)
# number_objkts_sold_secondary
# 


#summarize
print(paste0("In the present year, the user sold..."))
print(paste0("on primary: ", number_objkts_sold_primary, " objkts, for a total of ", round(total_earned_primary, digits = 2), " ", currency))
print(paste0("on secondary: ", number_objkts_sold_secondary, " objkts, for a total of ", round(total_earned_secondary, digits = 2), " ", currency, " (in gains)"))


