extends Area2D

@export var game_end_message: String = "Congratulations! You've finished the game."


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Connect the body_entered signal
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body: Node) -> void:
	# Check if the body is the player
	if body is Player:
		print("Player has crossed the finish line!")
		get_tree().change_scene_to_file("res://Scenes/GameOver/game_over.tscn")
		GameState.emit_signal("game_over", game_end_message)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
