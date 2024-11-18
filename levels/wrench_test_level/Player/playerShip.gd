extends Sprite2D

# Movement speed
@export var speed: float = 200.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# position at center on x axis and bottom on y axis
	position = Vector2(get_viewport_rect().size.x / 2, get_viewport_rect().size.y - region_rect.size.y / 2)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
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

	# get viewport size
	var viewport_size = get_viewport_rect().size

	# Clamp the player position to the screen
	position.x = clamp(position.x, 0 + region_rect.size.x / 2, viewport_size.x - region_rect.size.x / 2)

	# Clamp vertical movement: Bottom of the screen to the middle
	var y_min = viewport_size.y - region_rect.size.y / 2 # Bottom edge
	var y_max = viewport_size.y / 2 # Middle of the screen
	position.y = clamp(position.y, y_max, y_min)
