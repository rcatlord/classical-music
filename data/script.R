# Building a Library database (1999-2024)
# Source: BBC Radio 3 
# URL: https://www.bbc.co.uk/programmes/b06w2121

library(tidyverse) ; library(httr) ; library(readxl) ; library(janitor) ; library(htmltools)

url <- "https://downloads.bbc.co.uk/radio3/building_a_library/BAL_1999-2024_V2.xlsx"
GET(url, write_disk(tmp <- tempfile(fileext = ".xlsx")))

df <- read_xlsx(tmp, sheet = 1) |> 
  clean_names() |>  
  select(-x10) |> 
  select(composer, piece, top_recommendation, starts_with("also_recommended"), date, reviewer, podcast = podcast_link_if_available) |> 
  pivot_longer(-c(composer, piece, top_recommendation, date, reviewer, podcast), values_to = "also_recommended") |> 
  select(composer, piece, top_recommendation, also_recommended, date, reviewer, podcast) |> 
  mutate_at(vars(top_recommendation, date, reviewer, podcast), funs(replace(., duplicated(.), NA))) |> 
  filter_at(vars(top_recommendation, also_recommended), any_vars(!is.na(.))) |> 
  arrange(desc(date)) |> 
  select(composer, piece, top_recommendation, date, reviewer, podcast) |> 
  filter(!is.na(top_recommendation))

write_csv(df, "building_a_library_database.csv")
