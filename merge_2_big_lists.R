##Splits a large file into smaller chunks and matches it to another based on the haversine calculation for geodistance

#Load your libraries
library(dplyr)
library(fuzzyjoin)
library(readr)

#Load your dataframes
df1 <- read_csv(FILEPATH)
df2 <- read_csv(FILEPATH)

#Sort your dataframes on lat descending (so there's some order when split/to optimizie matching)
df1 <- df1 %>% 
  arrange(desc(latitude))

df2 <- df2 %>%
  arrange(desc(latitude))

#Break the primary df into chunks (can be bigger depending on how large the set) and store those chunks in a list of arrays
df_length <- nrow(df1)
df_chunk <- 1000
split_it <- rep(1:ceiling(df_length/df_chunk), each = df_chunk)[1:df_length]
rep_split <- split(df1, split_it)

#Loop through the list of arrays/each chunk to match to the reference df
output <- lapply(rep_split, function(x) {
  geo_inner_join(x, df2, by = c('latitude','longitude'), max_dist = 0.03, unit = c('km'), method = c('haversine'), distance_col = 'Geo_Dist')
})

#Output all the matches into a primary df for further processing
output_df <- bind_rows(output, .id = "column_label")

