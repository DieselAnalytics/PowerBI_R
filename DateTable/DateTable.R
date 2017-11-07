#Loads the necessary libraries
library(tidyverse)
library(lubridate)
library(rvest)
library(stringr)

# This function is used to create the "date table". The only arguments you pass in are the begin and end date
Create.Date.Table <- function(start.date, end.date) {

	#Base date table
	Dates <- seq(ymd(start.date), ymd(end.date), by = "days") # Creates a vector of dates starting with the start.date and ending with the end.date incrementing by a day
	FiscalYearEndMonth = 6

	# Creates a one column data frame based on the Dates vector created above
	DateTable <- data.frame(Dates)

	DateTable <- DateTable %>%
	# Uses the mutate verb and a few functions from the lubridate package to create date attribute fields for the "DateTables" data frame  
	mutate("DateKey" = format(Dates, "%Y%m%d") # Uses the format function to format the date in YYYYMMDD format so that it can be used as a key
			   , "Month Name" = format(Dates, "%b") # Uses the format function to return the proper abbreviated month name for the given date.
			   , "Weekday Name" = wday(Dates, label = TRUE) # Uses the wday function to return the proper abbreviated weekday name for the given date.
			   , "Weekday Key" = wday(Dates) # Uses the wday function to return the integer representation of the weekday for the given date.
			   , "Year" = year(Dates) # Uses the year function to return the year for the given date.
			   , "Fiscal Year" = Year + ifelse(month(Dates) > FiscalYearEndMonth, 1, 0) # Calculates the fiscal year using the FiscalYearEndMonth variable to determine the end of the fiscal year
			   , "Month Key" = month(Dates) # Uses the month function to return the integer representation of the month for the given date.
			   , "Month Day" = mday(Dates) # Uses the mday function to return the day of the month for the given date
			   , "Iso Year" = isoyear(Dates) # Uses the isoyear function to return the iso year for the given date
			   , "Week" = week(Dates) # Uses the week function to return the week of the year for the given date
			   , "Iso Week" = isoweek(Dates) # Uses the isoweek function to return the iso week of the year for the given date
			   , "Quarter" = quarter(Dates) # Uses the quarter function to return the quarter of the year for the given date
			   , "Quarter Day" = qday(Dates) # (looks like it is returning seconds) USes the qday function to return the day of the quarter for the given date
			   , "Year Day" = yday(Dates) # Uses the yday function to return the day of the year for the given date
			   , "Weekend" = ifelse(wday(Dates) %in% c(1, 7), TRUE, FALSE) # Determines if the given date occurs in the weekend based on the wkday function
		) %>%
	# The select verb below is used to reorder the fields in the data frame in a more logical order    
	select(`DateKey`, `Dates`, `Year`, `Fiscal Year`, `Iso Year`, `Year Day`, `Quarter`, `Quarter Day`, `Month Name`, `Month Key`,
			   `Month Day`, `Week`, `Iso Week`, `Weekday Name`, `Weekday Key`, `Weekend`
		)


	#Add holidays
	Dates <- as.Date(NA)
	Holidays <- as.character(NA)
	Holiday_Info <- tibble(Dates, Holidays)

	# Uses the rvest package to extract the federal holidays from the website for each year passed to it. Reads in the html from the website passed into it
	# and then identifies the nodes that it wants to extract based on what we identified using the selectorgadget or developer tools in Google Chrome. The value
	# of those nodes are returned back to us in the form of a character vector using the html_text function.
	url <- "https://www.opm.gov/policy-data-oversight/snow-dismissal-procedures/federal-holidays/#url=201"
	Holiday_Data <-
		read_html(url) %>%
		html_nodes(".DataTable") %>%
		html_text()

	items <- length(Holiday_Data)

	for (item in 1:5) {

		Holiday_Vector <- Holiday_Data[[item]] %>%
			str_split(pattern = "\r\n") %>%
			flatten_chr() %>%
			str_replace("DateHoliday", "") %>%
			str_replace("^[A-Za-z]+,\\s", "") %>%
			str_replace("\\*+", "")

		Holiday_Vector_Length <- length(Holiday_Vector) - 1
		year <- as.numeric(str_sub(Holiday_Vector[1], 1, 4))
		Holiday_Vector <- Holiday_Vector[2:Holiday_Vector_Length]

		Dates <- Holiday_Vector[seq(1, Holiday_Vector_Length, 2)] %>%
			na.omit() %>%
			paste(year, sep = " ") %>%
			mdy()

		Holidays <- Holiday_Vector[seq(2, Holiday_Vector_Length, 2)]

		Holiday_Year_Info <- tibble(Dates, Holidays)
		Holiday_Info <- rbind(Holiday_Year_Info, Holiday_Info)

	}

	Holiday_Info <- na.omit(Holiday_Info)

	# Adds a boolean field called "Federal Holiday" to the DateTable data frame. For each date in the DateTable dataframe it test whether
	# the date is one of the dates in the federal_holidays vector and if it is it returns TRUE otherwise it returns FALSE
	# DateTable$`Federal Holiday` <- DateTable$Dates %in% federal_holidays
	DateTable <- left_join(DateTable, Holiday_Info) %>%
		mutate(`Federal Holiday`=ifelse(is.na(Holidays),FALSE,TRUE))
	return(DateTable) # Returns a data frame of a date table based on the date parameters passed in.
}

My.Date.Table <- Create.Date.Table(start.date = "2016-01-01", end.date = "2020-12-31")
