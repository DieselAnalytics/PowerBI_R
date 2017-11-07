library(readr)
library(dplyr)
library(tidyr)
library(lubridate)
library(RODBC)
library(car)

#Loads Functions used for feature engineering
source("Functions.R")

#Build connection string to MS SQL Server database
server.name = "DESKTOP-171P4OD"
db.name = "NBAPredictions"
connection.string = paste("driver={SQL Server}", ";", "server=", server.name, ";", "database=", db.name, ";", "trusted_connection=true", sep = "")

#Connect to Database
conn <- odbcDriverConnect(connection.string)

#Build SQL Statement
#***************************************************
#***************************************************
#***************************************************
#See if this query is good
sql.statement = "
	select
		 gd.game_date 
		,home_team = tih.team
		,away_team = tia.team
		,gd.home_team_win
		,away_team_win = IIF(gd.home_team_win = 1, 0, 1)
	FROM dbo.GameData_Model AS gd 
		INNER JOIN dbo.TeamInfo AS tih ON gd.home_team_id = tih.ID 
		INNER JOIN dbo.TeamInfo AS tia ON gd.away_team_id = tia.ID
"

#Get Data
raw.data <- sqlQuery(channel = conn, sql.statement) # To get data from SQL

#Close connection
odbcClose(conn)

#Remove unneeded variables from session
variables.to.remove <- c("conn", "connection.string", "db.name", "server.name", "sql.statement", "variables.to.remove")
rm(list = variables.to.remove)

# Makes some data type changes
raw.data <-
	raw.data %>%
	mutate(game_date = as.Date(game_date))

# Training data set
training.data <-
	raw.data %>%
	filter(game_date <= '2009-01-21')

# Testing data set (see if the data that we are predicting is in this data set)
testing.data <-
	raw.data %>%
	filter(game_date > '2009-01-21')

# This is the feature engineering step. First I will get the data in a "tidy" format then I will add the following
# features (day_type, home.team.record.level, away.team.record.level, home.team.overall.record.level, and 
# away.team.overall.record.level).

#*******************************************************************************************************************************************
#*******************************************************************************************************************************************
base.train.data <-
	training.data %>%
	mutate(day_type = as.factor(ifelse(wday(ymd(game_date)) %in% c(6, 7), "Weekend", "Weekday"))) %>%
	select(home_team, away_team, game_date, day_type, home_team_win, away_team_win)

base.test.data <-
	testing.data %>%
	mutate(day_type = as.factor(ifelse(wday(ymd(game_date)) %in% c(6, 7), "Weekend", "Weekday"))) %>%
	select(home_team, away_team, game_date, day_type, home_team_win, away_team_win)

#*******************************************************************************************************************************************
#*******************************************************************************************************************************************
# Home team performance
home.team.performance <-
	base.train.data %>%
	group_by(home_team) %>%
	summarize(total_wins = sum(home_team_win), times_played = n(), win_ratio = total_wins / times_played)
home.team.performance <-
	home.team.performance %>%
	mutate(tertiles = ntile(win_ratio, 3), home_team_record_level = Recode(tertiles, "1='bad_at_home';2='ok_at_home';3='good_at_home'"))

#*******************************************************************************************************************************************
#*******************************************************************************************************************************************
# Away team performance
away.team.performance <-
	base.train.data %>%
	group_by(away_team) %>%
	summarize(total_away_team_wins = sum(away_team_win), times_played = n(), win_ratio = total_away_team_wins / times_played) 

away.team.performance <-
	away.team.performance %>%
	mutate(tertiles = ntile(win_ratio, 3), away_team_record_level = Recode(tertiles, "1='bad_away';2='ok_away';3='good_away'"))

#*******************************************************************************************************************************************
#*******************************************************************************************************************************************
# Overall record

# Make data frame of all of the home teams with a field that shows whether they won or lost
home.team.records <- base.train.data[, c('home_team', 'home_team_win')]
home.team.records <- home.team.records %>% rename(team = home_team, win = home_team_win)
away.team.records <- base.train.data[, c('away_team', 'away_team_win')]
away.team.records <- away.team.records %>% rename(team = away_team, win = away_team_win)

# Combine home.team.records and away.team.records then group the data by team and add additional
# descriptive fields
team.records <-
	rbind(home.team.records, away.team.records) %>%
	group_by(team) %>%
	summarise(wins = sum(win), total.games = n(), losses = total.games - wins, win.ratio = wins / total.games) %>%
	select(team, wins, losses, total.games, win.ratio)

# Adds percentiles using a lambda function that leverages the ecdf function
team.records <-
	team.records %>%
	mutate(tertiles = ntile(win.ratio, 3), overall_record_level = Recode(tertiles, "1='inferior';2='neutral';3='superior'")) 

#*******************************************************************************************************************************************
#*******************************************************************************************************************************************
# Model training data
model.train.data <-
	base.train.data %>%
	inner_join(home.team.performance, by = c("home_team" = "home_team")) %>% #tell about behavior if you don't specify
inner_join(away.team.performance, by = c("away_team" = "away_team")) %>% #tell about behavior if you don't specify
inner_join(team.records, by = c("home_team" = "team")) %>% # explain about this being something like a key value pair or named vector
rename(home_team_overall_record_level = overall_record_level) %>%
	select(home_team, away_team, day_type, home_team_record_level, away_team_record_level, home_team_overall_record_level, home_team_win)

model.train.data <-
	model.train.data %>%
	inner_join(team.records, by = c("away_team" = "team")) %>% # explain about this being something like a key value pair or named vector
rename(away_team_overall_record_level = overall_record_level) %>%
	select(home_team, away_team, day_type, home_team_record_level, away_team_record_level, home_team_overall_record_level, away_team_overall_record_level, home_team_win) %>%
	mutate(home_team_record_level = as.factor(home_team_record_level), away_team_record_level = as.factor(away_team_record_level),
	   home_team_overall_record_level = as.factor(home_team_overall_record_level), away_team_overall_record_level = as.factor(away_team_overall_record_level)
	)

#*******************************************************************************************************************************************
#*******************************************************************************************************************************************
# Model testing data
model.test.data <-
	base.test.data %>%
	inner_join(home.team.performance, by = c("home_team" = "home_team")) %>% #tell about behavior if you don't specify
inner_join(away.team.performance, by = c("away_team" = "away_team")) %>% #tell about behavior if you don't specify
inner_join(team.records, by = c("home_team" = "team")) %>% # explain about this being something like a key value pair or named vector
rename(home_team_overall_record_level = overall_record_level) %>%
	select(home_team, away_team, day_type, home_team_record_level, away_team_record_level, home_team_overall_record_level, home_team_win)

model.test.data <-
	model.test.data %>%
	inner_join(team.records, by = c("away_team" = "team")) %>% # explain about this being something like a key value pair or named vector
rename(away_team_overall_record_level = overall_record_level) %>%
	select(home_team, away_team, day_type, home_team_record_level, away_team_record_level, home_team_overall_record_level, away_team_overall_record_level, home_team_win) %>%
	mutate(home_team_record_level = as.factor(home_team_record_level), away_team_record_level = as.factor(away_team_record_level),
	   home_team_overall_record_level = as.factor(home_team_overall_record_level), away_team_overall_record_level = as.factor(away_team_overall_record_level)
	)

# Model 1
team.formula.one <- as.formula("home_team_win ~ home_team_record_level")
model.one <- glm(team.formula.one, data = model.train.data, family = binomial(link = "logit"))

# Model 2
team.formula.two <- as.formula("home_team_win ~ away_team_record_level")
model.two <- glm(team.formula.two, data = model.train.data, family = binomial(link = "logit"))

# Model 3
team.formula.three <- as.formula("home_team_win ~ home_team_overall_record_level")
model.three <- glm(team.formula.three, data = model.train.data, family = binomial(link = "logit"))

# Model 4
team.formula.four <- as.formula("home_team_win ~ away_team_overall_record_level")
model.four <- glm(team.formula.four, data = model.train.data, family = binomial(link = "logit"))

# Model 5
team.formula.five <- as.formula("home_team_win ~ home_team_record_level + away_team_record_level")
model.five <- glm(team.formula.five, data = model.train.data, family = binomial(link = "logit"))

# Model 6
team.formula.six <- as.formula("home_team_win ~ home_team_overall_record_level + away_team_overall_record_level")
model.six <- glm(team.formula.six, data = model.train.data, family = binomial(link = "logit"))

# Model 7
team.formula.seven <- as.formula("home_team_win ~ home_team_record_level + away_team_record_level + home_team_overall_record_level + away_team_overall_record_level")
model.seven <- glm(team.formula.seven, data = model.train.data, family = binomial(link = "logit"))

# Print out the results of the AIC 
cat("model.one aic = ", model.one$aic[1], '\n')
cat("model.two aic = ", model.two$aic[1], '\n')
cat("model.three aic = ", model.three$aic[1], '\n')
cat("model.four aic = ", model.four$aic[1], '\n')
cat("model.five aic = ", model.five$aic[1], '\n')
cat("model.six aic = ", model.six$aic[1], '\n')
cat("model.seven aic = ", model.seven$aic[1], '\n')
