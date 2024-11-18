extends Asteroid

@export var SPEED: float = 200.0  # Falling speed in pixels per second

func _process(delta: float) -> void:
	# Move the asteroid downwards
	position.y += SPEED * delta
	# Remove the asteroid if it goes off-screen
	if global_position.y > get_viewport_rect().size.y:
		queue_free()
