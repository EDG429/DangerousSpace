class_name WorldLevel
extends Node2D

const player_scene = preload("res://Scenes/Player/player.tscn")
const enemy_scene = preload("res://Scenes/Enemies/main_enemy.tscn")
const boss_scene = preload("res://Scenes/Enemies/boss.tscn")
const MIN_SCALE = 0.5  # Minimum scale of the asteroid
const MAX_SCALE = 1.5  # Maximum scale of the asteroid

@onready var supercharge_spawn_timer: Timer = $SuperchargeSpawn_Timer
@onready var asteroid_spawn_timer: Timer = $AsteroidSpawn_Timer
@onready var background: Sprite2D = $Background
@onready var deadline: StaticBody2D = $Deadline

@export var SUPERCHARGE_BUFF_SPAWN_INTERVAL: float = 7.0
@export var SUPERCHARGE_BUFF_SPAWN_RADIUS: float = 300.0  # Maximum distance from the player to spawn the buff
@export var ASTEROID_SPAWN_INTERVAL: float = 5.0
@export var ASTEROID_SPAWN_RADIUS: float = 700.0  # Maximum distance from the player to spawn the buff
@export var SUPERCHARGE_BUFF_SCENE = preload("res://Scenes/Environment/Supercharge_Buff.tscn")
@export var DEBUFF_SCENE = preload("res://Scenes/Environment/Supercharge_Debuff.tscn")
@export var ASTEROID_SCENE = preload("res://Scenes/Environment/destructible_asteroid.tscn")
@export var DEADLINE_MOVE_OFFSET: float = 75.0  # Pixels to move upwards
@export var ENEMY_SCENE: PackedScene = preload("res://Scenes/Enemies/main_enemy.tscn")  # Path to the Enemy scene
@export var SPAWN_RADIUS: float = 500.0  # Radius around the player where enemies will spawn
@export var MIN_ENEMIES: int = 2  # Minimum number of enemies to spawn per wave
@export var MAX_ENEMIES: int = 3   # Maximum number of enemies to spawn per wave
@export var SPAWN_INTERVAL_MIN: float = 7.0  # Minimum time interval between waves
@export var SPAWN_INTERVAL_MAX: float = 10.0  # Maximum time interval between waves
@export var MIN_DISTANCE_BETWEEN_ENEMIES: float = 60.0  # Minimum distance between spawned enemies

var camera: Camera2D  # Store the Camera2D reference
var player: Node2D  # Store the Player reference
var enemy: Node2D
var asteroid: Node2D # Store asteroid reference
var buff_spawn_position: Vector2
var last_asteroid_count = -1
var spawned_positions = [] # List to keep track of spawned asteroid positions
var active_enemies: Array = []  # Keep track of spawned enemies

const MIN_DISTANCE_BETWEEN_ASTEROIDS = 50.0 # Minimum distance to avoid overlap
const ASTEROID_SPEED = 200.0 # Speed of the asteroid moving towards the player

# Boss boolean flags
var boss_spawned: bool = false  # Track if the boss has already spawned

# Variables for camera clamping
var SIDE: float = 0.0  # Width of the texture divided by two
var LNG: float = 0.0   # Full height (length) of the texture

func _ready() -> void:
	# Get the Sprite2D node named "Background"
	background = get_node("Background") as Sprite2D
	
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
	
	if boss_scene:
		spawn_boss()
	
	start_spawn_timer() # Immediately start the spawn timer
	
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
	
# ----------------------------- Enemy Spawn Logic Start ---------------------------------- #

func start_spawn_timer() -> void:
	
	while Player:
		var random_interval = randf_range(SPAWN_INTERVAL_MIN, SPAWN_INTERVAL_MAX)
		await get_tree().create_timer(random_interval).timeout
		spawn_wave()

func spawn_wave() -> void:
	if not player or player.global_position.y < -7400:
		print("Player not found. Cannot spawn enemies.")
		return
	
	# Randomize the number of enemies for this wave
	var num_enemies = randi_range(MIN_ENEMIES, MAX_ENEMIES)
	var spawn_positions: Array = []
	
	for i in range(num_enemies):
		var position = get_valid_spawn_position(spawn_positions)
		if position != null:
			spawn_enemy(position)
			spawn_positions.append(position)

func spawn_enemy(position: Vector2) -> void:
	var enemy_instance = ENEMY_SCENE.instantiate()
	get_parent().add_child(enemy_instance)  # Add enemy to the parent node
	enemy_instance.global_position = position
	active_enemies.append(enemy_instance)  # Keep track of the spawned enemy
	enemy_instance.add_to_group("enemies")

func get_valid_spawn_position(existing_positions: Array) -> Vector2:
	var attempts:int = 10  # Limit the number of attempts to avoid infinite loops
	while attempts > 0:
		var random_angle = randf() * TAU  # Random angle in radians
		var offset = Vector2(cos(random_angle), sin(random_angle)) * SPAWN_RADIUS
		var spawn_position = player.global_position + offset
		
		 # Check if the position is valid (not overlapping with existing enemies)
		var is_valid = true
		for existing_pos in existing_positions:
			if spawn_position.distance_to(existing_pos) < MIN_DISTANCE_BETWEEN_ENEMIES:
				is_valid = false
				break
		
		if is_valid:
			return spawn_position
		
		attempts -= 1
	
	return Vector2.ZERO
	
# ----------------------------- Enemy Spawn Logic End  ---------------------------------- #

func _process(_delta: float) -> void:
	
	# Check for game over conditions
	GameState.check_game_over()
	
	# Clamp the player's position to keep it within bounds
	if player:
		player.position.x = clamp(player.position.x, -SIDE + 15, SIDE - 15)  # Horizontal clamping
		player.position.y = clamp(player.position.y, 25 -LNG/2, LNG/2 - 25)      # Vertical clamping
	

# ---------------------- Buff and Debuff Spawning Logic Start -------------------------------------- #
func spawn_supercharge_buff() -> Vector2:
	if not player:
		Vector2.ZERO # Need player to spawn
	
	if player.global_position.x <= -440 or player.global_position.x >= 440:
		var supercharge_buff = SUPERCHARGE_BUFF_SCENE.instantiate()
		add_child(supercharge_buff)
		supercharge_buff.global_position = Vector2(0,player.global_position.y - 150)
		buff_spawn_position = supercharge_buff.global_position
		return buff_spawn_position
	
	# Fetch the player's current position
	var player_current_position = player.global_position
	
	# Generate in a random position around the player
	var spawn_x = player_current_position.x + randf_range(-SUPERCHARGE_BUFF_SPAWN_RADIUS, SUPERCHARGE_BUFF_SPAWN_RADIUS)
	var spawn_y = - player_current_position.y + randf_range(- 150, SUPERCHARGE_BUFF_SPAWN_RADIUS)  # Always forward (Y increases)
	
	# Clamp the spawn position to ensure it remains within background bounds
	spawn_x = clamp(spawn_x, -SIDE + 30, SIDE - 30)  # Clamp X to stay within left/right bounds
	spawn_y = clamp(spawn_y, abs(player_current_position.y - 150), player_current_position.y + SUPERCHARGE_BUFF_SPAWN_RADIUS) if player_current_position.y > 0 else clamp(spawn_y, abs(player_current_position.y - 150), player_current_position.y - SUPERCHARGE_BUFF_SPAWN_RADIUS)  # Clamp Y to stay forward and within bounds
	
	var buff_spawn_position = Vector2(spawn_x, spawn_y)
	
	# Instance the Supercharge Buff and add it to the scene
	var supercharge_buff = SUPERCHARGE_BUFF_SCENE.instantiate()
	add_child(supercharge_buff)
	supercharge_buff.global_position = buff_spawn_position
	supercharge_buff.z_index = 1
	
	return buff_spawn_position
	
	
func spawn_supercharge_debuff(buff_spawn_position: Vector2) -> void:
	if not player:
		return
	
	# Fetch the player's current position
	var player_current_position = player.global_position
	var debuff_spawn_position: Vector2
	var is_valid_position: bool = false
	
	while not is_valid_position:
		
		# Generate a random position for the debuff
		var spawn_x = player_current_position.x + randf_range(-SUPERCHARGE_BUFF_SPAWN_RADIUS, SUPERCHARGE_BUFF_SPAWN_RADIUS)
		var spawn_y = - player_current_position.y + randf_range(- 150, SUPERCHARGE_BUFF_SPAWN_RADIUS)  # Always forward (Y increases)
		debuff_spawn_position = Vector2(spawn_x, spawn_y)
		
		# Clamp the spawn position to remain within the background bounds
		debuff_spawn_position.x = clamp(debuff_spawn_position.x, -SIDE + 30, SIDE - 30)
		debuff_spawn_position.y = clamp(debuff_spawn_position.y, abs(player_current_position.y - 150), player_current_position.y + SUPERCHARGE_BUFF_SPAWN_RADIUS) if player_current_position.y > 0 else clamp(debuff_spawn_position.y, abs(player_current_position.y - 150), player_current_position.y - SUPERCHARGE_BUFF_SPAWN_RADIUS)
		
		# Check if the position is valid (distance from the buff)
		if buff_spawn_position.distance_to(debuff_spawn_position) >= 35:
			is_valid_position = true
			
	if is_valid_position:
		# Instance the Supercharge Buff and add it to the scene
		var supercharge_debuff = DEBUFF_SCENE.instantiate()
		add_child(supercharge_debuff)
		supercharge_debuff.global_position = debuff_spawn_position
		supercharge_debuff.z_index = 1

func _on_SuperchargeSpawn_Timer_timeout() -> void:
	spawn_supercharge_buff()
	spawn_supercharge_debuff(buff_spawn_position)

# ---------------------- Buff and Debuff Spawning Logic End  -------------------------------------- #

# ---------------------- Asteroid Spawning Logic Start  -------------------------------------- #
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
		var distance = randf_range(500, ASTEROID_SPAWN_RADIUS) # Random distance within a safe range

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
		var random_scale = randf_range(MIN_SCALE, MAX_SCALE)
		spawned_asteroid.scale = Vector2(random_scale, random_scale)
		spawned_asteroid.rotation = randf() * TAU

		# Calculate direction towards the player
		var direction = (player.global_position - spawn_position).normalized()

		# Assign velocity to the asteroid (requires a `velocity` property in the asteroid script)
		if spawned_asteroid.has_method("set_velocity"):
			spawned_asteroid.call("set_velocity", direction * ASTEROID_SPEED)

		# Add the position to the list of spawned positions
		spawned_positions.append(spawn_position)
		
		# Start cleanup coroutine for the asteroid
		remove_asteroid_after_delay(spawned_asteroid, 20.0)

func remove_asteroid_after_delay(asteroid_removed: Node, delay: float) -> void:
	await get_tree().create_timer(delay).timeout
	
	# Ensure the asteroid is still valid before freeing it
	if is_instance_valid(asteroid_removed):
		# Remove position from the spawned positions list
		for pos in spawned_positions:
			if asteroid_removed.global_position.distance_to(position) < 1.0:  # Match positions
				spawned_positions.erase(position)
				break
		asteroid_removed.queue_free()

	
func _on_AsteroidSpawn_Timer_timeout() -> void:
	var asteroid_count = last_asteroid_count

	while asteroid_count == last_asteroid_count:
		asteroid_count = randi_range(2, 6)

	last_asteroid_count = asteroid_count

	for i in range(asteroid_count): # Spawn three asteroids
		spawn_asteroid()
	
# ---------------------- Asteroid Spawning Logic End  -------------------------------------- #
# ---------------------- Deadline Moving Logic Start ----------------------------------- #
func _on_Deadline_Move_Timer_timeout() -> void:
	if deadline:
		deadline.position += Vector2(0, -DEADLINE_MOVE_OFFSET)
		
# ---------------------- Deadline Moving Logic End ----------------------------------- #

# ---------------------- Game Over Logic Start --------------------------------------- #
func _on_game_over(_reason: String) -> void:
	active_enemies.clear()
	
	if not get_tree():
		return
	
	var enemies = get_tree().get_nodes_in_group("enemies") 
	
	for i in enemies:
		if is_instance_valid(enemy):
			enemy.queue_free()
	
# ---------------------- Level Cleaning Logic End ------------------------------------------- #

# ---------------------- Boss Handling Logic Start ------------------------------------------ #
func spawn_boss() -> void:
	# Ensure that the boss is spawned only once
	if boss_spawned:
		return
	
	boss_spawned = true
	
	# Instance and add the boss to the scene
	var boss_instance = boss_scene.instantiate()
	add_child(boss_instance)
	
	# Setting the boss position
	var boss_position = Vector2(0, -6834)  
	boss_instance.global_position = boss_position
