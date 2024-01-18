# Library
# install.packages("acdcquery") # for the latest stable CRAN release

library(acdcquery)

# download the latest version of the database and connect to that
db_file <- "C:/Users/sven/Documents/Amsterdam/acdc-database/acdc.db"

conn <- connect_to_db(db_file)

arguments <- list() 
arguments <- add_argument(
  list = arguments,
  conn = conn,
  variable = "dataset_id",
  operator = "equal",
  values = 56
)

df <- query_db(conn, arguments, "default")

data.table::fwrite(df, file = "data/stroop_data.csv")
