extends EnemyBullet

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

# Rotation offset to align the sprite tip (adjust based on your sprite's default orientation)
const SPRITE_ROTATION_OFFSET: float = - PI / 2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Ensure that the missile is facing the player
	rotate_towards_player()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if !animated_sprite_2d.is_playing():
		animated_sprite_2d.play("idle")
	
	# Move the projectile in the given directionda
	position += direction * SPEED * delta
	
	# Remove the projectile if it moves too far
	if player:
		# Calculate distance to player
		if global_position.distance_to(player.global_position) > MAX_DISTANCE:
			queue_free()

func rotate_towards_player() -> void:
	if player:
		# Calculate the direction vector from the bullet to the player
		var to_player: Vector2 = (player.global_position - global_position).normalized()
		direction = to_player
		
		# Rotate the missile
		rotation = direction.angle() + SPRITE_ROTATION_OFFSET
