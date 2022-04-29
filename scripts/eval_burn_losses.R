# Determine which NFTs were burned
# Requires that xero_tools/scripts/obtain_burn_list.sh was conducted

# Read in output results from the pipeline
all_results <- read.delim2(file = "output/all_results.txt"
                           , header = T, sep = "\t")
head(all_results)

# Which in the burned list are not in your results list? 
setdiff(x = burned.df$token_id, y = all_results$Token)

# Only keep non-NA tokens
all_results <- all_results[!is.na(all_results$Token), ]

# Remove objkts for which you are the creator
all_results <- all_results[all_results$Creator!=username, ]

# Read in the burned NFT list
burned.df <- read.delim2(file = "output/burned_tokens.txt"
                           , header = F, sep = "\t")
colnames(burned.df)[1] <- "token_id"
burned.df$token_id <- paste0("#", burned.df$token_id)
burned.df$burn <- rep("burned", times = nrow(burned.df))

setdiff(x = burned.df$token_id, y = all_results$Token)

dim(all_results)
all_results_burned.df <- merge(x = all_results, y = burned.df
                                , by.x = "Token", by.y = "token_id"
                                , all.x = T, sort = F
                               )
dim(all_results_burned.df)
write.table(x = all_results_burned.df, file = "output/all_results_burned.txt", row.names = F)

