library(tidyverse)
library(lubridate)
library(rvest)
library(stringr)

dates <- as.Date(NA)
holidays <- as.character(NA)
holiday_info <- tibble(dates, holidays)

# Uses the rvest package to extract the federal holidays from the website for each year passed to it. Reads in the html from the website passed into it
# and then identifies the nodes that it wants to extract based on what we identified using the selectorgadget or developer tools in Google Chrome. The value
# of those nodes are returned back to us in the form of a character vector using the html_text function.
url <- "https://www.opm.gov/policy-data-oversight/snow-dismissal-procedures/federal-holidays/#url=201"
holiday_data <-
	read_html(url) %>%
	html_nodes(".DataTable") %>%
	html_text()

items <- length(holiday_data)

for (item in 1:5) {

	holiday_vector <- holiday_data[[item]] %>%
		str_split(pattern = "\r\n") %>%
		flatten_chr() %>%
		str_replace("DateHoliday", "") %>%
		str_replace("^[A-Za-z]+,\\s", "") %>%
		str_replace("\\*+", "")

	holiday_vector_length <- length(holiday_vector) - 1
	year <- as.numeric(str_sub(holiday_vector[1], 1, 4))
	holiday_vector <- holiday_vector[2:holiday_vector_length]

	dates <- holiday_vector[seq(1, holiday_vector_length, 2)] %>%
		na.omit() %>%
		paste(year, sep = " ") %>%
		mdy()

	holidays <- holiday_vector[seq(2, holiday_vector_length, 2)]

	holiday_year_info <- tibble(dates, holidays)
	holiday_info <- rbind(holiday_year_info,holiday_info)

}

holiday_info <- na.omit(holiday_info)