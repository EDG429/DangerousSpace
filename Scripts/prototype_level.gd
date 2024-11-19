class_name WorldLevel
extends Node2D

const player_scene = preload("res://Scenes/Player/player.tscn")


@onready var supercharge_spawn_timer: Timer = $SuperchargeSpawn_Timer
@onready var background: Sprite2D = $Background
@onready var deadline: StaticBody2D = $Deadline

@export var SUPERCHARGE_BUFF_SPAWN_INTERVAL: float = 20.0
@export var SUPERCHARGE_BUFF_SPAWN_RADIUS: float = 300.0 # Maximum distance from the player to spawn the buff
@export var SUPERCHARGE_BUFF_SCENE = preload("res://Scenes/Environment/Supercharge_Buff.tscn")
@export var DEADLINE_MOVE_OFFSET: float = 50.0 # Pixels to move upwards

@export var asteroid_scene: PackedScene

var camera: Camera2D # Store the Camera2D reference
var player: Node2D # Store the Player reference
var asteroid: Node2D # Store asteroid reference

# Variables for camera clamping
var SIDE: float = 0.0 # Width of the texture divided by two
var LNG: float = 0.0 # Full height (length) of the texture

func _ready() -> void:
	# Get the Sprite2D node named "Background"
	var localBackground = get_node("Background") as Sprite2D
	
	if localBackground and localBackground.texture:
		# Get the dimensions of the texture
		var texture_size = localBackground.texture.get_size()
		SIDE = texture_size.x / 2 # Assign to class variable (no `var`)
		LNG = texture_size.y # Assign to class variable (no `var`)
	
	if player_scene:
		# Instance and add the player to the scene
		player = player_scene.instantiate()
		add_child(player)
		player.global_position = Vector2(0, 7400) # Set the initial position (adjust as needed)
	
		# Access the existing Camera2D on the player
		camera = player.get_node("Camera2D") as Camera2D
		if camera:
			# Modify the camera's limits
			camera.limit_left = -SIDE
			camera.limit_right = SIDE
			camera.limit_top = -LNG / 2
			camera.limit_bottom = LNG / 2
		else:
			print("Error! No camera detected")
	
	# Start the supercharge buff spawn timer
	supercharge_spawn_timer.wait_time = SUPERCHARGE_BUFF_SPAWN_INTERVAL
	supercharge_spawn_timer.start()
	
func _process(_delta: float) -> void:
	# Clamp the player's position to keep it within bounds
	if player:
		player.position.x = clamp(player.position.x, -SIDE + 15, SIDE - 15) # Horizontal clamping
		player.position.y = clamp(player.position.y, 25 - LNG / 2, LNG / 2 - 25) # Vertical clamping
	

# ---------------------- Buff Spawning Logic Start -------------------------------------- #
func spawn_supercharge_buff() -> void:
	if not player:
		return # Need player to spawn
	
	# Fetch the player's current position
	var player_current_position = player.global_position
	
	# Generate in a random position around the player
	var spawn_x = player_current_position.x + randf_range(-SUPERCHARGE_BUFF_SPAWN_RADIUS, SUPERCHARGE_BUFF_SPAWN_RADIUS)
	var spawn_y = -player_current_position.y + randf_range(-80, SUPERCHARGE_BUFF_SPAWN_RADIUS) # Always forward (Y increases)
	
	# Clamp the spawn position to ensure it remains within background bounds
	spawn_x = clamp(spawn_x, -SIDE, SIDE) # Clamp X to stay within left/right bounds
	spawn_y = clamp(spawn_y, player_current_position.y - 80, LNG / 2) # Clamp Y to stay forward and within bounds
	
	var spawn_position = Vector2(spawn_x, spawn_y)
	
	# Instance the Supercharge Buff and add it to the scene
	var supercharge_buff = SUPERCHARGE_BUFF_SCENE.instantiate()
	add_child(supercharge_buff)
	supercharge_buff.global_position = spawn_position

func _on_SuperchargeSpawn_Timer_timeout() -> void:
	spawn_supercharge_buff()

# ---------------------- Buff Spawning Logic End  -------------------------------------- #

# ---------------------- Deadline Moving Logic Start ----------------------------------- #
func _on_Deadline_Move_Timer_timeout() -> void:
	if deadline:
		deadline.position += Vector2(0, -DEADLINE_MOVE_OFFSET)


# spawn asteroids randomly at the top of the screen
func spawn_asteroids() -> void:
	print("Spawning asteroids...")
	
	if not player:
		return # Safeguard: Exit if the player node is not assigned.

	# Fetch the player's global position to determine where to spawn asteroids
	var player_position: Vector2 = player.global_position

	# Define spawning logic
	for i in range(5): # Spawn 5 asteroids
		var l_asteroid = asteroid.instance()
		add_child(l_asteroid)
		
		# Offset spawning positions around the player
		var offset = Vector2(randf() * 200 - 100, randf() * 200 - 100)
		l_asteroid.global_position = player_position + offset

		# Customize asteroid properties if needed
		l_asteroid.speed = randf() * 100 + 50 # Example property adjustment
		print("Spawning asteroid at: ", l_asteroid.global_position)

	
func _on_asteroid_spawn_timer_timeout() -> void:
	spawn_asteroids()
