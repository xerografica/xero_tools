#!/bin/bash
# Use api output (see README) to identify the tokens that were burned by the wallet
INPUT_FN="fmj_to_burn_2022-04-29.txt"
OUTPUT_FN="burned_tokens.txt"

grep 'token_id' ./input/$INPUT_FN | 
    
        # Keep only the column with the token_id
        awk '{ print $2 }' - | 

        # Remove commas and save out
        sed 's/"//g' > ./output/$OUTPUT_FN
