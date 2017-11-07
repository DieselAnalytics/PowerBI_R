library(tidyverse)
library(lubridate)
library(rvest)
library(stringr)

Create.Date.Table <- function(start.date, end.date) {

	Dates <- seq(ymd(start.date), ymd(end.date), by = "days") 
	FiscalYearEndMonth = 6
	DateTable <- data.frame(Dates)

	DateTable <- DateTable %>%
	mutate("DateKey" = format(Dates, "%Y%m%d") 
			   , "Month Name" = format(Dates, "%b") 
			   , "Weekday Name" = wday(Dates, label = TRUE) 
			   , "Weekday Key" = wday(Dates) 
			   , "Year" = year(Dates) 
			   , "Fiscal Year" = Year + ifelse(month(Dates) > FiscalYearEndMonth, 1, 0) 
			   , "Month Key" = month(Dates) 
			   , "Month Day" = mday(Dates) 
			   , "Iso Year" = isoyear(Dates) 
			   , "Week" = week(Dates) 
			   , "Iso Week" = isoweek(Dates) 
			   , "Quarter" = quarter(Dates) 
			   , "Quarter Day" = qday(Dates) 
			   , "Year Day" = yday(Dates) 
			   , "Weekend" = ifelse(wday(Dates) %in% c(1, 7), TRUE, FALSE) 
		)

	Dates <- as.Date(NA)
	Holidays <- as.character(NA)
	Holiday_Info <- tibble(Dates, Holidays)

	url <- "https://www.opm.gov/policy-data-oversight/snow-dismissal-procedures/federal-holidays/"
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

	DateTable <- left_join(DateTable, Holiday_Info) %>%
		mutate(`Federal Holiday` = ifelse(is.na(Holidays), FALSE, TRUE)) %>%
		select(`DateKey`, `Dates`, `Year`, `Fiscal Year`, `Iso Year`, `Year Day`,
			   `Quarter`, `Quarter Day`, `Month Name`, `Month Key`, `Month Day`,
			   `Week`, `Iso Week`, `Weekday Name`, `Weekday Key`, `Weekend`,
			   `Federal Holiday`, `Holidays`)

	return(DateTable)

}

DateTable <- Create.Date.Table(start.date = "2016-01-01", end.date = "2020-12-31")
