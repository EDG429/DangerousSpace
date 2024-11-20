extends Enemy

@onready var awaken_zone: Area2D = $AwakenZone

# Boss is asleep on spawn, only wakes up when the player enters its "zone"
var is_asleep: bool = true
var is_awakening: bool = false

func sleep() -> void:
	health_bar.visible = false
	collision_shape_2d.disabled = true
	animated_sprite.play("sleep")

func awaken() -> void:
	if is_awakening:
		return
	is_awakening = true

	animated_sprite.play("awakening")
	await get_tree().create_timer(3).timeout

	is_awakening = false
	is_asleep = false  # Boss is no longer asleep
	health_bar.visible = true
	collision_shape_2d.disabled = false

	animated_sprite.play("idle")
	initialize_bossfight()

func initialize_bossfight() -> void:
	health = MAX_HP
	if health_bar:
		health_bar.init_health(health)

	# Assign the player reference
	if not is_instance_valid(player):
		player = get_tree().get_root().get_node("prototype_level/Player")  # Adjust path if necessary

	if not player:
		print("Player not found. Boss won't move or attack.")
		return  # Exit if the player is not found

	# Start firing timer
	fire_timer.disconnect("timeout", Callable(self, "_on_FireTimer_timeout"))
	fire_timer.connect("timeout", Callable(self, "_on_FireTimer_timeout"))
	fire_timer.wait_time = FIRE_RATE
	fire_timer.start()

	# Start damage flickering timer
	damage_flicker_timer.disconnect("timeout", Callable(self, "_on_DamageFeedbackTimer_timeout"))
	damage_flicker_timer.connect("timeout", Callable(self, "_on_DamageFeedbackTimer_timeout"))
	fire_timer.wait_time = FIRE_RATE
	damage_flicker_timer.start()

func _ready() -> void:
	sleep()

func _on_awaken_zone_body_entered(body: Node2D) -> void:
	if body is Player and is_asleep:
		is_asleep = false
		awaken_zone.monitorable = false
		awaken_zone.queue_free()
		awaken()

func _process(delta: float) -> void:
	if is_dead or is_asleep or health <= 0:  # Add 'is_asleep' to the condition
		return

	if not is_instance_valid(player):
		return

	# Ensure the player instance is valid
	if is_instance_valid(player):
		# Follow the player
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * SPEED
		move_and_slide()

	# Flip sprite based on position
	animated_sprite.flip_v = global_position.y > player.global_position.y

func fire() -> void:
	if not is_instance_valid(player):
		return

	# Create and fire a bullet at the player
	var bullet = BULLET_SCENE.instantiate()
	get_parent().add_child(bullet)  # Add the bullet to the parent node
	bullet.global_position = global_position
	# Calculate bullet direction
	bullet.direction = (player.global_position - global_position).normalized()

	# Optional: Flip the bullet sprite for visual effects
	if bullet.has_node("Sprite2D"):
		var bullet_sprite = bullet.get_node("Sprite2D")
		bullet_sprite.flip_v = global_position.y > player.global_position.y

func _on_Boss_FireTimer_timeout() -> void:
	if not is_asleep and not is_dead and is_instance_valid(player):
		fire()
