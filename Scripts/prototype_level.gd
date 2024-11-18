extends Node2D

const player_scene = preload("res://Scenes/Player/player.tscn")


@onready var supercharge_spawn_timer: Timer = $SuperchargeSpawn_Timer

@export var SUPERCHARGE_BUFF_SPAWN_INTERVAL: float = 20.0
@export var SUPERCHARGE_BUFF_SPAWN_RADIUS: float = 300.0  # Maximum distance from the player to spawn the buff
@export var SUPERCHARGE_BUFF_SCENE = preload("res://Scenes/Environment/Supercharge_Buff.tscn")

@onready var background: Sprite2D = $Background


var camera: Camera2D  # Store the Camera2D reference
var player: Node2D  # Store the Player reference
var asteroid: Node2D # Store asteroid reference

# Variables for camera clamping
var SIDE: int = 0.0  # Width of the texture divided by two
var LNG: int = 0.0   # Full height (length) of the texture

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
		player.global_position = Vector2(0, 7400)  # Set the initial position (adjust as needed)
	
		# Access the existing Camera2D on the player
		camera = player.get_node("Camera2D") as Camera2D
		if camera:
			# Modify the camera's limits
			camera.limit_left = -SIDE  
			camera.limit_right = SIDE  
			camera.limit_top = -LNG/2
			camera.limit_bottom = LNG/2
		else:
			print("Error! No camera detected")
	
	# Start the supercharge buff spawn timer
	supercharge_spawn_timer.wait_time = SUPERCHARGE_BUFF_SPAWN_INTERVAL
	supercharge_spawn_timer.start()
	
func _process(_delta: float) -> void:
	# Clamp the player's position to keep it within bounds
	if player:
		player.position.x = clamp(player.position.x, -SIDE + 15, SIDE - 15)  # Horizontal clamping
		player.position.y = clamp(player.position.y, 25 -LNG/2, LNG/2 - 25)      # Vertical clamping
	

# ---------------------- Buff Spawning Logic Start -------------------------------------- #
func spawn_supercharge_buff() -> void:
	if not player:
		return # Need player to spawn
	
	# Generate in a random position around the player
	var spawn_position = player.global_position + Vector2(
		randf_range(-SUPERCHARGE_BUFF_SPAWN_RADIUS, SUPERCHARGE_BUFF_SPAWN_RADIUS),
		randf_range(-SUPERCHARGE_BUFF_SPAWN_RADIUS, SUPERCHARGE_BUFF_SPAWN_RADIUS)
	)
	
	 # Clamp the spawn position to the background's dimensions
	spawn_position.x = clamp(spawn_position.x, -SIDE, SIDE)
	spawn_position.y = clamp(spawn_position.y, -LNG / 2, LNG / 2)
	
	 # Instance the Supercharge Buff and add it to the scene
	var supercharge_buff = SUPERCHARGE_BUFF_SCENE.instantiate()
	add_child(supercharge_buff)
	supercharge_buff.global_position = spawn_position

func _on_SuperchargeSpawn_Timer_timeout() -> void:
	spawn_supercharge_buff()

# ---------------------- Buff Spawning Logic End  -------------------------------------- #
