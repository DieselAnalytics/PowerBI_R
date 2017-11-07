library(ROCR)
library(readr)

GamePredictions <- read_csv("./Data/GamePredictions.csv")

perf.data <- prediction(GamePredictions$predicted_home_team_win, GamePredictions$home_team_win)
plot.data <- performance(perf.data, "tpr", "fpr")
plot(plot.data, main = "NBA Home Team Win Predictions")
abline(a = 0, b = 1)
