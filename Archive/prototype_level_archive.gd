extends Node2D

const player_scene = preload("res://Scenes/Player/player.tscn")

var camera: Camera2D  # Store the Camera2D reference
var player: Node2D  # Store the Player reference

# Variables for camera clamping
var SIDE: float = 0.0  # Width of the texture divided by two
var LNG: float = 0.0   # Full height (length) of the texture

func _ready() -> void:
	# Get the Sprite2D node named "Background"
	var background = get_node("Background") as Sprite2D
	
	if background and background.texture:
		# Get the dimensions of the texture
		var texture_size = background.texture.get_size()
		SIDE = texture_size.x / 2  # Assign to class variable (no `var`)
		LNG = texture_size.y      # Assign to class variable (no `var`)
	
	if player_scene:
		# Instance and add the player to the scene
		player = player_scene.instantiate()
		add_child(player)
		player.global_position = Vector2(0, 25)  # Set the initial position (adjust as needed)
	
		# Access the existing Camera2D on the player
		camera = player.get_node("Camera2D") as Camera2D
		if camera:
			# Modify the camera's limits
			camera.limit_left = -SIDE  
			camera.limit_right = SIDE  
			camera.limit_top = 0
			camera.limit_bottom = LNG
		else:
			print("Error! No camera detected")

func _process(delta: float) -> void:
	# Clamp the player's position to keep it within bounds
	if player:
		player.position.x = clamp(player.position.x, -SIDE + 10, SIDE - 10)  # Horizontal clamping
		player.position.y = clamp(player.position.y, 25, LNG - 25)      # Vertical clamping
