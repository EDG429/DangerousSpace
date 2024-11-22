extends Node2D

@export var hover_time: float = 2.5  # Time to hover before acting
@export var max_range: float = 500  # Maximum travel range in pixels
@export var speed: float = 300  # Missile speed
@export var impact_damage: int = 600  # Damage dealt on impact
@export var explosion_damage: int = 300  # Damage dealt during explosion
@export var explosion_radius: float = 200  # Explosion radius
@export var scan_radius: float = 350  # Scan radius

@onready var scan_area: Area2D = $ScanArea
@onready var explosion_area: Area2D = $ExplosionArea
@onready var impact_area: Area2D = $MissileImpact
@onready var missile_sprite: AnimatedSprite2D = $MissileSprite

var target: Node2D = null  # Target for homing
var start_position: Vector2  # Initial position of the missile
var is_homing: bool = false  # Indicates if homing is active

signal exploded

func _ready() -> void:
	start_position = global_position
	explosion_area.monitorable = false  # Disable explosion detection initially
	scan_area.monitorable = true  # Enable scanning
	await get_tree().create_timer(hover_time).timeout  # Wait for hover time
	scan_area.monitorable = false  # Disable scanning
	is_homing = target != null  # Enable homing if a target was found

func _process(delta: float) -> void:
	if is_homing and is_instance_valid(target):
		# Homing movement towards the target
		var direction = (target.global_position - global_position).normalized()
		global_position += direction * speed * delta
	else:
		# Straightforward movement
		global_position.y -= speed * delta

	# Check if the missile exceeded its range
	if global_position.distance_to(start_position) > max_range:
		explode()

func _on_ScanArea_body_entered(body: Node2D) -> void:
	if body is Enemy or body is Boss:
		target = body

func _on_MissileImpact_body_entered(body: Node2D) -> void:
	if body is Enemy or body is Boss:
		body.take_damage(impact_damage)
		explode()

func explode() -> void:
	# Enable the explosion detection
	explosion_area.monitorable = true

	# Delay briefly to allow explosion damage
	await get_tree().create_timer(0.1).timeout
	explosion_area.monitorable = false
	queue_free()  # Remove the missile after exploding

	emit_signal("exploded")  # Notify listeners

func _on_ExplosionArea_body_entered(body: Node2D) -> void:
	if body is Enemy or body is Boss:
		body.take_damage(explosion_damage)
