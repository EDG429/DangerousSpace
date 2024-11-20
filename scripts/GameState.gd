extends Node

signal game_over

# References to key nodes (set during runtime)
var player: Node = null
var deadline: Node = null
var finish_line: Node = null

# Background bounds
@export var LNG: float = 15000.0  # The total height of the background

# Initialize the GameState

func _ready() -> void:
	print("GameState initialized.")
	player = null
	deadline = null
	finish_line = null
	
	# If the FinishLine node exists, connect its signal
	if finish_line and finish_line.has_signal("body_entered"):
		finish_line.connect("body_entered", Callable(self, "_on_finish_line_entered"))
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# Check game over conditionswww
func check_game_over() -> void:
	
	# Condition 1: Player emits its death signal
	if player and player.is_dead and not player.is_connected("player_death_complete",  Callable(self, "_on_player_death_complete")):
		player.connect("player_death_complete", Callable(self, "_on_player_death_complete"))
		print("Connected to player_death_complete signal.")
		_on_player_death_complete()
		return
		
	# Condition 2: Deadline's Y position is out of bounds
	if deadline and deadline.global_position.y <= - LNG:
		emit_signal("game_over", "Deadline reached the top of the screen.")  # Correctly emit the signal
		get_tree().change_scene_to_file("res://Scenes/GameOver/game_over.tscn")
		return
		

func _on_finish_line_entered(body: Node) -> void:
	if body == player:
		print("Player crossed the finish line!")
		emit_signal("game_over", "Congratulations! You've reached the finish line.")
		# Transport to the Game Over screen
		get_tree().change_scene_to_file("res://Scenes/GameOver/game_over.tscn")
	
	
	
 
		
func _on_player_death_complete() -> void:
	print("Player death complete. Game Over triggered.")
	emit_signal("game_over", "Player death animation finished.")
	
	# Transport to the Game Over scene
	get_tree().change_scene_to_file("res://Scenes/GameOver/game_over.tscn")

func clear_references() -> void:
	player = null
	deadline = null
	finish_line = null
	print("GameState references cleared.")
