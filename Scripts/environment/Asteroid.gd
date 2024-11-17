class_name Asteroid
extends Sprite2D

@export var damage: int = 10  # Default damage the asteroid deals

func _on_Asteroid_body_entered(body: Node) -> void:
	# Check if the body is the player and has a `take_damage` method
	if body.has_method("take_damage"):
		body.take_damage(damage)

#func take_damage() -> void:
	#pass
