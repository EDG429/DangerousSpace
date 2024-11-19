extends Label

func _ready() -> void:
	# Connect to the score_changed signal from ScoreManager
	ScoreManager.connect("score_changed", Callable(self, "_update_score"))
	_update_score(ScoreManager.get_score())  # Initialize with the current score	

func _update_score(new_score: int) -> void:
	# Update the text of the label when the score changes
	text = "Score: " + str(new_score)
