extends Node

var score: int = 0  # Initial score

func add_points(points: int) -> void:
	score += points
	print("Points added: ", points, " | Current Score: ", score)

func reset_score() -> void:
	score = 0
	print("Score reset. Current Score: ", score)

func get_score() -> int:
	return score
