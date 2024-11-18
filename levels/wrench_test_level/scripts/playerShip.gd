extends Node2D # Now attached to the root PlayerShip node

# Movement speed
@export var speed: float = 200.0
@export var primary_fire_scene: PackedScene
@export var primary_fire_rate: float = 0.2 # Time between bullet shots
@export var secondary_fire_scene: PackedScene
@export var secondary_fire_rate: float = 0.5 # Time between bullet shots

# Track firing
var is_firing: bool = false

@onready var target_for_secondary_fire: Node2D = null

func _ready() -> void:
	# Position the ship at the center bottom of the screen
	position = Vector2(
		get_viewport_rect().size.x / 2,
		get_viewport_rect().size.y - $Sprite2D.region_rect.size.y / 2
	)

	# Connect Timer signal
	# $PrimaryFireTimer.timeout.connect(_on_fire_timer_timeout)

	# $SecondaryFireTimer.timeout.connect(_on_secondary_fire_timer_timeout)

	# find the target for secondary fire
	var enemies = get_tree().get_nodes_in_group("enemies")
	if enemies.size() > 0:
		target_for_secondary_fire = enemies[0]
		var closest_distance = global_position.distance_to(target_for_secondary_fire.global_position)
		for enemy in enemies:
			var distance = global_position.distance_to(enemy.global_position)
			if distance < closest_distance:
				target_for_secondary_fire = enemy
				closest_distance = distance

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Handle player movement
	_handle_movement(delta)

	# Check for firing input
	if Input.is_action_pressed("primary_fire"):
		if not is_firing:
			is_firing = true
			$PrimaryFireTimer.start()
	else:
		is_firing = false
		$PrimaryFireTimer.stop()

	if Input.is_action_pressed("secondary_fire"):
		$SecondaryFireTimer.start()
	else:
		$SecondaryFireTimer.stop()


func _handle_movement(delta: float) -> void:
	var input_vector = Vector2.ZERO

	# Read the input
	if Input.is_action_pressed("ui_right"):
		input_vector.x += 1
	if Input.is_action_pressed("ui_left"):
		input_vector.x -= 1
	if Input.is_action_pressed("ui_down"):
		input_vector.y += 1
	if Input.is_action_pressed("ui_up"):
		input_vector.y -= 1

	# Normalize the input vector to prevent faster diagonal movement
	input_vector = input_vector.normalized()

	# Move the player
	position += input_vector * speed * delta

	# Get viewport size
	var viewport_size = get_viewport_rect().size

	# Clamp the player position to the screen
	position.x = clamp(position.x, 0 + $Sprite2D.region_rect.size.x / 2, viewport_size.x - $Sprite2D.region_rect.size.x / 2)

	# Clamp vertical movement: Bottom of the screen to the middle
	var y_min = viewport_size.y - $Sprite2D.region_rect.size.y / 2 # Bottom edge
	var y_max = viewport_size.y / 2 # Middle of the screen
	position.y = clamp(position.y, y_max, y_min)

# Handle bullet firing
func _on_fire_timer_timeout() -> void:
	if primary_fire_scene:
		# Spawn and position the bullet
		var bullet = primary_fire_scene.instantiate()
		bullet.position = $PrimaryFireSpawn.global_position.snapped(Vector2(1, 1))
		get_parent().add_child(bullet)

		# play fire sound
		$PrimaryFireSound.play()


func _on_secondary_fire_timer_timeout() -> void:
	if secondary_fire_scene:
		var bullet = secondary_fire_scene.instantiate()
		bullet.position = $SecondaryFireSpawn.global_position.snapped(Vector2(1, 1))
		get_parent().add_child(bullet)
