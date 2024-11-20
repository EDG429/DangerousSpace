class_name WorldLevel
extends Node2D

const player_scene = preload("res://Scenes/Player/player.tscn")
const enemy_scene = preload("res://Scenes/Enemies/main_enemy.tscn")


@onready var supercharge_spawn_timer: Timer = $SuperchargeSpawn_Timer
@onready var asteroid_spawn_timer: Timer = $AsteroidSpawn_Timer
@onready var background: Sprite2D = $Background
@onready var deadline: StaticBody2D = $Deadline

@export var SUPERCHARGE_BUFF_SPAWN_INTERVAL: float = 20.0
@export var SUPERCHARGE_BUFF_SPAWN_RADIUS: float = 300.0 # Maximum distance from the player to spawn the buff
@export var ASTEROID_SPAWN_INTERVAL: float = 5.0
@export var ASTEROID_SPAWN_RADIUS: float = 300.0 # Maximum distance from the player to spawn the buff
@export var SUPERCHARGE_BUFF_SCENE = preload("res://Scenes/Environment/Supercharge_Buff.tscn")
@export var DEBUFF_SCENE = preload("res://Scenes/Environment/Supercharge_Debuff.tscn")
@export var ASTEROID_SCENE = preload("res://Scenes/Environment/destructible_asteroid.tscn")
@export var DEADLINE_MOVE_OFFSET: float = 75.0 # Pixels to move upwards

var camera: Camera2D # Store the Camera2D reference
var player: Node2D # Store the Player reference
var enemy: Node2D
var asteroid: Node2D # Store asteroid reference

# Variables for camera clamping
var SIDE: int = 0.0 # Width of the texture divided by two
var LNG: int = 0.0 # Full height (length) of the texture

func _ready() -> void:
	# Get the Sprite2D node named "Background"
	var background = get_node("Background") as Sprite2D
	
	if background and background.texture:
		# Get the dimensions of the texture
		var texture_size = background.texture.get_size()
		SIDE = texture_size.x / 2 # Assign to class variable (no `var`)
		LNG = texture_size.y # Assign to class variable (no `var`)
	
	if player_scene and enemy_scene:
		# Instance and add the player to the scene
		player = player_scene.instantiate()
		add_child(player)
		player.global_position = Vector2(0, 7400) # Set the initial position (adjust as needed)
		await get_tree().create_timer(3).timeout
		enemy = enemy_scene.instantiate()
		add_child(enemy)
		enemy.global_position = Vector2(0, 7100)
	
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
	
	asteroid_spawn_timer.wait_time = ASTEROID_SPAWN_INTERVAL
	asteroid_spawn_timer.start()
	
	# Register player and deadline with the GameState singleton
	GameState.player = player
	GameState.deadline = deadline
	GameState.LNG = LNG
	# Connect the game_over signal to handle game over logic
	GameState.connect("game_over", Callable(self, "_on_game_over"))
	
func _process(_delta: float) -> void:
	
	# Check for game over conditions
	GameState.check_game_over()
	
	# Clamp the player's position to keep it within bounds
	if player:
		player.position.x = clamp(player.position.x, -SIDE + 15, SIDE - 15) # Horizontal clamping
		player.position.y = clamp(player.position.y, 25 - LNG / 2, LNG / 2 - 25) # Vertical clamping
	

# ---------------------- Buff and Debuff Spawning Logic Start -------------------------------------- #
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

func spawn_supercharge_debuff() -> void:
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
	var supercharge_debuff = DEBUFF_SCENE.instantiate()
	add_child(supercharge_debuff)
	supercharge_debuff.global_position = spawn_position

func _on_SuperchargeSpawn_Timer_timeout() -> void:
	spawn_supercharge_buff()
	spawn_supercharge_debuff()

# ---------------------- Buff and Debuff Spawning Logic End  -------------------------------------- #

# ---------------------- Asteroid Spawning Logic Start  -------------------------------------- #
# func spawn_asteroid() -> void:
# 	if not player:
# 		return # Need player to spawn
	
# 	# Fetch the player's current position
# 	var player_current_position = player.global_position
	
# 	# Generate in a random position around the player
# 	var spawn_x = player_current_position.x + randf_range(-ASTEROID_SPAWN_RADIUS, ASTEROID_SPAWN_RADIUS)
# 	var spawn_y = - player_current_position.y + randf_range(- 250, ASTEROID_SPAWN_RADIUS)  # Always forward (Y increases)
	
# 	# Clamp the spawn position to ensure it remains within background bounds
# 	spawn_x = clamp(spawn_x, -SIDE, SIDE)  # Clamp X to stay within left/right bounds
# 	spawn_y = clamp(spawn_y, player_current_position.y - 250, LNG / 2)  # Clamp Y to stay forward and within bounds
	
# 	var spawn_position = Vector2(spawn_x, spawn_y)
	
# 	# Instance the Supercharge Buff and add it to the scene
# 	var spawned_asteroid = ASTEROID_SCENE.instantiate()
# 	add_child(spawned_asteroid)
# 	spawned_asteroid.global_position = spawn_position
	
# func _on_AsteroidSpawn_Timer_timeout() -> void:
# 	spawn_asteroid()
# 	spawn_asteroid()
# 	spawn_asteroid()

# func spawn_asteroid() -> void:
# 	if not player:
# 		return # Player is needed to spawn asteroids

# 	# Fetch the player's current position
# 	var player_current_position = player.global_position

# 	# Generate a random angle and distance within the radius
# 	var angle = randf() * TAU # Random angle (0 to 2 * PI)
# 	var distance = randf_range(100, ASTEROID_SPAWN_RADIUS) # Random distance within a safe range

# 	# Calculate spawn position using polar coordinates
# 	var spawn_position = player_current_position + Vector2(cos(angle), sin(angle)) * distance

# 	# Clamp spawn position to ensure it remains within the background bounds
# 	spawn_position.x = clamp(spawn_position.x, -SIDE, SIDE)
# 	spawn_position.y = clamp(spawn_position.y, player_current_position.y - 250, LNG / 2)

# 	# Instance the asteroid and set its position
# 	var spawned_asteroid = ASTEROID_SCENE.instantiate()
# 	add_child(spawned_asteroid)
# 	spawned_asteroid.global_position = spawn_position

# func _on_AsteroidSpawn_Timer_timeout() -> void:
# 	for i in range(3): # Spawn three asteroids
# 		spawn_asteroid()

# var spawned_positions = [] # List to keep track of spawned asteroid positions
# const MIN_DISTANCE_BETWEEN_ASTEROIDS = 50.0 # Minimum distance to avoid overlap

# func spawn_asteroid() -> void:
# 	if not player:
# 		return # Player is needed to spawn asteroids

# 	var spawn_position: Vector2
# 	var attempts = 0
# 	var is_valid_position = false

# 	while not is_valid_position and attempts < 10:
# 		# Fetch the player's current position
# 		var player_current_position = player.global_position

# 		# Generate a random angle and distance within the radius
# 		var angle = randf() * TAU # Random angle (0 to 2 * PI)
# 		var distance = randf_range(100, ASTEROID_SPAWN_RADIUS) # Random distance within a safe range

# 		# Calculate spawn position using polar coordinates
# 		spawn_position = player_current_position + Vector2(cos(angle), sin(angle)) * distance

# 		# Clamp spawn position to ensure it remains within the background bounds
# 		spawn_position.x = clamp(spawn_position.x, -SIDE, SIDE)
# 		spawn_position.y = clamp(spawn_position.y, player_current_position.y - 250, LNG / 2)

# 		# Check against existing positions to avoid overlap
# 		is_valid_position = true
# 		for existing_position in spawned_positions:
# 			if spawn_position.distance_to(existing_position) < MIN_DISTANCE_BETWEEN_ASTEROIDS:
# 				is_valid_position = false
# 				break

# 		attempts += 1

# 	# If a valid position is found within allowed attempts
# 	if is_valid_position:
# 		# Instance the asteroid and set its position
# 		var spawned_asteroid = ASTEROID_SCENE.instantiate()
# 		add_child(spawned_asteroid)
# 		spawned_asteroid.global_position = spawn_position

# 		# Add the position to the list of spawned positions
# 		spawned_positions.append(spawn_position)

# func _on_AsteroidSpawn_Timer_timeout() -> void:
# 	for i in range(3): # Spawn three asteroids
# 		spawn_asteroid()


var spawned_positions = [] # List to keep track of spawned asteroid positions
const MIN_DISTANCE_BETWEEN_ASTEROIDS = 50.0 # Minimum distance to avoid overlap
const ASTEROID_SPEED = 200.0 # Speed of the asteroid moving towards the player

func spawn_asteroid() -> void:
	if not player:
		return # Player is needed to spawn asteroids

	var spawn_position: Vector2
	var attempts = 0
	var is_valid_position = false

	while not is_valid_position and attempts < 10:
		# Fetch the player's current position
		var player_current_position = player.global_position

		# Generate a random angle and distance within the radius
		var angle = randf() * TAU # Random angle (0 to 2 * PI)
		var distance = randf_range(100, ASTEROID_SPAWN_RADIUS) # Random distance within a safe range

		# Calculate spawn position using polar coordinates
		spawn_position = player_current_position + Vector2(cos(angle), sin(angle)) * distance

		# Clamp spawn position to ensure it remains within the background bounds
		spawn_position.x = clamp(spawn_position.x, -SIDE, SIDE)
		spawn_position.y = clamp(spawn_position.y, player_current_position.y - 250, LNG / 2)

		# Check against existing positions to avoid overlap
		is_valid_position = true
		for existing_position in spawned_positions:
			if spawn_position.distance_to(existing_position) < MIN_DISTANCE_BETWEEN_ASTEROIDS:
				is_valid_position = false
				break

		attempts += 1

	# If a valid position is found within allowed attempts
	if is_valid_position:
		# Instance the asteroid and set its position
		var spawned_asteroid = ASTEROID_SCENE.instantiate()
		add_child(spawned_asteroid)
		spawned_asteroid.global_position = spawn_position

		# Calculate direction towards the player
		var direction = (player.global_position - spawn_position).normalized()

		# Assign velocity to the asteroid (requires a `velocity` property in the asteroid script)
		if spawned_asteroid.has_method("set_velocity"):
			spawned_asteroid.call("set_velocity", direction * ASTEROID_SPEED)

		# Add the position to the list of spawned positions
		spawned_positions.append(spawn_position)

func _on_AsteroidSpawn_Timer_timeout() -> void:
	for i in randi_range(1, 5): # Spawn three asteroids
		spawn_asteroid()

	# Optional: Clear the positions if they shouldn't persist
	# spawned_positions.clear()  # Uncomment if new batches should ignore old positions


	# Optional: Clear the positions if they shouldn't persist
	# spawned_positions.clear()  # Uncomment if new batches should ignore old positions


# ---------------------- Asteroid Spawning Logic End  -------------------------------------- #
# ---------------------- Deadline Moving Logic Start ----------------------------------- #
func _on_Deadline_Move_Timer_timeout() -> void:
	if deadline:
		deadline.position += Vector2(0, -DEADLINE_MOVE_OFFSET)
		
# ---------------------- Deadline Moving Logic End ----------------------------------- #

# ---------------------- Game Over Logic Start --------------------------------------- #
func _on_game_over(reason: String) -> void:
	print("Game Over triggered! Reason: ", reason)
