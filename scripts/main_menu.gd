extends Control
var GameWorld = "res://Scenes/prototype_level.tscn"
var options_scene = "res://Scenes/options.tscn"

# Called when the node enters the scene tree for the first time.
func _ready():
	$MarginContainer/VBoxContainer/Start.grab_focus()


# Called every frame. 'delta' is the elapsed time since the previous frame.



func _on_start_pressed():
	get_tree().change_scene_to_file(GameWorld)

func _on_quit_pressed():
	get_tree().quit()
	

func _on_options_pressed():
	get_tree().change_scene_to_file(options_scene)
