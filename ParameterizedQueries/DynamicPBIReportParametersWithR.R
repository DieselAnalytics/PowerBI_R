library(RODBC)
library(readr)
library(magrittr)
library(tibble)

# Read in the student ids and combines them into a string that separates them with a "|"
students <- read_csv("C:/Users/RWADE_HP/OneDrive - Diesel Analytics/Talks/PASS_Summit/RScripts/ParameterizedQueries/Data/StudentList.csv")
student_ids <- paste0("'",paste(students$StudentAK, collapse = "|"), "'")

# Builds the connection string and sql statement that calls the dbo.DynamicReportParameters 
# stored procedure that uses "student_ids" as a parameter 
server.name = "DESKTOP-171P4OD"
db.name = "StudentDB"
sql.statement = paste("EXEC dbo.DynamicReportParameters", student_ids, sep = " ")
connection.string = paste("driver={SQL Server}", ";", "server=", server.name, ";", "database=", db.name, ";", "trusted_connection=true", sep = "")

# Opens a connection to SQL Server and executes the query and stores the results of it to 
# a R dataframe then closes the connection
conn <- odbcDriverConnect(connection.string)
FilteredData <- sqlQuery(channel = conn, sql.statement) %>% as_tibble() 
odbcClose(conn)


# DECLARE@MyString AS VARCHAR(15) = 'one|two|three'
# SELECT value
# FROM string_split(@MyString, '|')
