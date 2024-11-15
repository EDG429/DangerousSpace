extends Area2D

@export var SPEED: float = 600.0  # Projectile speed
@export var DAMAGE: int = 10     # Damage dealt to enemies

var direction: Vector2 = Vector2.ZERO

func _physics_process(delta: float) -> void:
	# Move the projectile in the given direction
	position += direction * SPEED * delta
	
	# Remove the projectile if it moves too far
	if not get_viewport_rect().has_point(global_position):
		queue_free()

func _on_body_entered(body: Node) -> void:
	# Handle collision with an enemy
	if body.has_method("take_damage"):
		body.take_damage(DAMAGE)
		queue_free()  # Destroy the projectile
