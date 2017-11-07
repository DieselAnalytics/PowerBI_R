opp.type <- function(win.ratio) {
	win.ratio = round(win.ratio, 2)
	lower.mid = 0.4
	upper.mid = 0.6
	criteria <- paste("0:", lower.mid - 0.01, " = 'superior'; ", lower.mid, ":", upper.mid - 0.01, " = 'nuetral'; ", upper.mid, ":", 1, " = 'inferior'", sep = "")
	category <- Recode(win.ratio, criteria)

	return(category)
}

record_level <- function(win.ratio, low.mid, upper.mid) {
	
	category <-
		ifelse(win.ratio < low.mid, "bad_record",
		ifelse(win.ratio >= low.mid & win.ratio <= upper.mid, "ok_record",
		ifelse(win.ratio > upper.mid, "good_record", 
		"error")))
	
	return(category)

}

home_performance_level <- function(win.ratio, low.mid, upper.mid) {
	
	category <-
		ifelse(win.ratio < low.mid, "bad_at_home",
		ifelse(win.ratio >= low.mid & win.ratio <= upper.mid, "ok_at_home",
		ifelse(win.ratio > upper.mid, "good_at_home", 
		"error")))
	
	return(category)

}

away_performance_level <- function(win.ratio, low.mid, upper.mid) {
	
	category <-
		ifelse(win.ratio < low.mid, "bad_away",
		ifelse(win.ratio >= low.mid & win.ratio <= upper.mid, "ok_away",
		ifelse(win.ratio > upper.mid, "good_away", 
		"error")))
	
	return(category)

}