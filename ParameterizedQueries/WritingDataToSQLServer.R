library(readr)
library(RODBC)

StudentData  <- read_csv("./Data/Students.csv")

server.name = "DESKTOP-171P4OD"
db.name = "StudentDB"
connection.string = paste("driver={SQL Server}", ";", "server=", server.name, ";", "database=", db.name, ";", "trusted_connection=true", sep = "")

conn <- odbcDriverConnect(connection.string)
sqlSave(channel = conn, dat = df, tablename = StudentData)
odbcClose(conn)