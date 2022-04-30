# Imports crypto sells
# NOTE: assumes that withdrawals in coin mean the coin was purchased that day

# Import sales
input.FN <- "tezos_sales.csv"
sells.df <- read.csv(file = paste0("input/", input.FN))

# Ensure coin is capitals
sells.df$coin <- toupper(sells.df$coin)

# Keep only year of interest
print(paste0("You have chosen to only consider **", year, "** dates"))
sells.df <- sells.df[grep(pattern = year, x = sells.df$date), ]

# Keep only cols of interset
sells.df <- sells.df[, c("coin", "date", "amount")]

# Here is the details of crypto coin acquisition
print("Your custom sells are available in sells.df")
sells.df

# GOTO: import_NFT_activity.R
