extends Control

@onready var score_label: Label = $MarginContainer/VBoxContainer/Score
@onready var restart_button: Button = $MarginContainer/VBoxContainer/HBoxContainer/RestartGame
@onready var main_menu_button: Button = $MarginContainer/VBoxContainer/HBoxContainer/MainMenu
@onready var quit_button: Button = $MarginContainer/VBoxContainer/HBoxContainer/QuitGame


# Load scenes (replace paths with your actual scenes)
@export var main_menu_scene: String = "res://Scenes/UI/MainMenu.tscn" # Placeholder for a main menu scene
@export var game_scene: String = "res://Scenes/World/WorldLevel.tscn" # Placeholder for retrying from the beginning

func _ready() -> void:
	# Display the score from the score manager
	score_label.text = "Your Score: %d".format(ScoreManager.get_score())

	# Connect button signals
	restart_button.pressed.connect(_on_restart_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)

func _on_restart_pressed() -> void:
	# Reset the score and restart the game
	ScoreManager.reset_score()
	get_tree().change_scene(game_scene)

func _on_main_menu_pressed() -> void:
	# Reset the score and return to the main menu
	ScoreManager.reset_score()
	get_tree().change_scene(main_menu_scene)

func _on_quit_game_pressed() -> void:  # NEW FUNCTION
	print("Quitting game...")
	get_tree().quit()
