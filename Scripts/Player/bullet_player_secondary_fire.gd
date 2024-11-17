extends Bullet

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	# Move the projectile in the given direction
	position += direction * SPEED * delta
	
	# Remove the projectile if it moves too far
	if player:
		# Calculate distance to player
		if global_position.distance_to(player.global_position) > MAX_DISTANCE:
			queue_free()

func _on_body_entered(body: Node) -> void:
	# Handle collision with an enemy
	print("Bullet collided with: ", body.name)
	if body.has_method("take_damage") and body.name != "Player":
		body.take_damage(DAMAGE)
		queue_free()  # Destroy the projectile
		
	# Handle collision with an Asteroid object
	if body is Asteroid:
		queue_free()
