extends Control
var main_menu = "res://Scenes/main_menu.tscn"

# Called when the node enters the scene tree for the first time.
func _ready():
	$TabContainer/Sound.grab_focus()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_quit_to_menu_pressed():
	get_tree().change_scene_to_file(main_menu)
