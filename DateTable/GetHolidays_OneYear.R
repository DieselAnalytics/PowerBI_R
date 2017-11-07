library(lubridate)
library(rvest)
library(stringr)
library(purrr)
library(tibble)

url <- "https://www.opm.gov/policy-data-oversight/snow-dismissal-procedures/federal-holidays/"
selector.gadget  <- "http://selectorgadget.com/"

holiday_data <-
	read_html(url) %>%
	html_nodes(".DataTable") %>%
	html_text()

holiday_vector <- holiday_data[[1]] %>%
		str_split(pattern = "\r\n") %>%
		flatten_chr() %>%
		str_replace("DateHoliday", "") %>%
		str_replace("^[A-Z][a-z]+,\\s", "") %>%
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

