extends Camera2D

@onready var background: Sprite2D = get_parent().get_node("Background")

func _ready() -> void:
	if background and background.texture:
		# Get the size of the background sprite (adjusted for scaling)
		var sprite_size = background.texture.get_size() * background.scale
		
		# Calculate the bounds of the background
		var min_x = background.global_position.x - sprite_size.x / 2
		var max_x = background.global_position.x + sprite_size.x / 2
		var min_y = background.global_position.y - sprite_size.y / 2
		var max_y = background.global_position.y + sprite_size.y / 2
		
		# Set the camera's limits
		limit_left = int(min_x)
		limit_right = int(max_x)
		limit_top = int(min_y)
		limit_bottom = int(max_y)
