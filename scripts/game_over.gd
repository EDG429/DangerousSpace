extends Control

@onready var score_label: Label = $MarginContainer/VBoxContainer/Score
@onready var restart_button: Button = $MarginContainer/VBoxContainer/HBoxContainer/RestartGame
@onready var main_menu_button: Button = $MarginContainer/VBoxContainer/HBoxContainer/MainMenu
@onready var quit_button: Button = $MarginContainer/VBoxContainer/HBoxContainer/QuitGame


# Load scenes (replace paths with your actual scenes)
@export var main_menu_scene: String = "res://Scenes/main_menu.tscn" # Placeholder for a main menu scene
@export var game_scene: String = "res://Scenes/prototype_level.tscn" # Placeholder for retrying from the beginning

func _ready() -> void:
	
	# Disconnect existing signals 
	if restart_button.is_connected("pressed", Callable(self, "_on_restart_pressed")):
		restart_button.disconnect("pressed", Callable(self, "_on_restart_pressed"))
	
	if main_menu_button.is_connected("pressed", Callable(self, "_on_main_menu_pressed")):
		main_menu_button.disconnect("pressed", Callable(self, "_on_main_menu_pressed"))
	
	# Reconnect them - This avoids crashing when pre connected signals aren't disconnected properly
	restart_button.connect("pressed", Callable(self, "_on_restart_pressed"))
	main_menu_button.connect("pressed", Callable(self, "_on_main_menu_pressed"))
	
	# Display the score from the score manager
	var score = str(ScoreManager.get_score())
	score_label.text = "Your Score: " + score


func _on_restart_pressed() -> void:
	# Clear gamestate references before restarting
	GameState.clear_references()
	
	# Reset the score and restart the game
	ScoreManager.reset_score()
	
	#get_tree().change_scene_to_file(game_scene)
	OS.shell_open(OS.get_executable_path())
	await get_tree().create_timer(0.05).timeout
	get_tree().quit()

func _on_main_menu_pressed() -> void:
	# Reset the score and return to the main menu
	ScoreManager.reset_score()
	get_tree().change_scene_to_file(main_menu_scene)

func _on_quit_game_pressed() -> void:  # NEW FUNCTION
	print("Quitting game...")
	get_tree().quit()
