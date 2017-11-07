library("RODBC")
library("tibble")
library("magrittr")
library("dplyr")

setwd("C:/Users/RWADE_HP/OneDrive - Diesel Analytics/Talks/PASS_Summit/RScripts/PredictGames")
pd <- readRDS("./Model/PredictGames")

server.name = "9tDESKTOP-171P4OD"
db.name = "NBAPredictions"
#connection.string = paste("driver={SQL Server}", ";", "server=", server.name, ";", "database=", db.name, ";", "trusted_connection=true", sep = "")
connection.string = paste0("driver={SQL Server}", ";", "server=", server.name, ";", "database=", db.name, ";", "trusted_connection=true")
conn <- odbcDriverConnect(connection.string)

sql.statement = "
	SELECT
	     gd.game_id
		,home_team_id
	    ,home_team = h.team
		,away_team = a.team
		,gd.[home_score]
		,gd.[visitor_score]
		,home_team_win = CASE WHEN gd.[home_score] > gd.[visitor_score] THEN 1 ELSE 0 END	
		,gd.game_date
		,sd.day_type
		,sd.home_team_record_level
		,sd.away_team_record_level
		,sd.home_team_overall_record_level
		,sd.away_team_overall_record_level
	FROM ScoreData sd
	INNER JOIN[dbo] .[GameData_FinalQuarterResults] gd
		ON sd.game_id = gd.game_id
	INNER JOIN[dbo] .[TeamInfo] h
		ON gd.home_team_id = h.ID
	INNER JOIN[dbo] .[TeamInfo] a
		ON gd.away_team_id = a.ID
	"

new.games <- sqlQuery(channel = conn, sql.statement) %>%
	as_tibble()

odbcClose(conn)

Score <- predict.glm(pd, newdata = new.games, family = binomial(link = "logit"), type = "response")
GamePredictions <- cbind(new.games, Score) %>%
		as_tibble() %>%
		mutate(predicted_home_team_win = ifelse(Score > 0.5, 1, 0), Score = 1) %>%
		select(game_id, home_team_id, game_date, home_team, away_team, game_date, home_score, visitor_score, home_team_win, predicted_home_team_win, Score)

