extends Node

signal score_changed(new_score: int)

var score: int = 0  # Initial score

func add_points(points: int) -> void:
	score += points
	print("Points added: ", points, " | Current Score: ", score)
	emit_signal("score_changed", score)

func substract_points(points: int) -> void:
	score -= points
	print("Points substracted: ", points, " | Current Score: ", score)
	emit_signal("score_changed", score)

func reset_score() -> void:
	score = 0
	print("Score reset. Current Score: ", score)
	emit_signal("score_changed", score)

func get_score() -> int:
	return score
