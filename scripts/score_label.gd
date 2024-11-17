extends Label


func _process(delta: float) -> void:
	# Update the text of the label with the current score
	text = "Score: " + str(ScoreManager.get_score())
