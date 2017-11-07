library(data.table)
library(purrr)
library(magrittr)
library(tibble)

setwd("C:/Users/RWADE_HP/OneDrive - Diesel Analytics/Talks/PASS_Summit/RScripts/CombiningMultipleFiles/BLS")

#Get a list of files in the BLS folder
bls_files <- list.files(path = ".")

#Remove files that begins with "la.data.0.Current*" and other non-state files using negative look behinds
grep("la\\.data\\.\\d+\\.(?!((Current.*)|(All.*)|(Region.*)|(County)|(Micro)|(City)|(Combined)|(Metro)))", bls_files, value = T, perl = T)

#Stores the files in a character vector and concatenates the beginning part of the file path to each file 
bls_files <- grep("la\\.data\\.\\d+\\.(?!((Current.*)|(All.*)|(Region.*)|(County)|(Micro)|(City)|(Combined)|(Metro)))", bls_files, value = T, perl = T)

#Combines all of the files that represents a state into a list 
cc <- c("character", "character", "character", "character", "character")
bls_data <- map(bls_files, fread, colClasses = cc) %>%
	rbindlist() %>%
	as_tibble()
