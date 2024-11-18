extends Area2D

@export var speed: float = 700.0 # Projectile speed
@export var damage: int = 1 # Damage dealt to enemies

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# move the projectile up
	position += Vector2(0, -1) * speed * delta

	# Remove the projectile if it moves off screen
	if position.y < -10:
		queue_free()


func _on_area_entered(area: Area2D) -> void:
	# check for collison with an enemy
	if area.is_in_group("enemies"):
		area.take_damage(damage)
		queue_free()
