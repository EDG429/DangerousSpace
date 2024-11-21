extends Area2D
class_name EnemyBullet
# PRIMARY FIRE BULLET
@export var SPEED: float = 450.0  # Projectile speed
@export var DAMAGE: int = 10     # Damage dealt to enemies
@export var MAX_DISTANCE: int = 500 # Maximum distance from the player before removal

var direction: Vector2 = Vector2.ZERO
var player: Node = null # Ref to player


func _ready() -> void:
	
	pass

func _physics_process(delta: float) -> void:
	# Move the projectile in the given directionda
	position += direction * SPEED * delta
	
	# Remove the projectile if it moves too far
	if player:
		# Calculate distance to player
		if global_position.distance_to(player.global_position) > MAX_DISTANCE:
			queue_free()

func _on_body_entered(body: Node) -> void:
	#print(self, " has collided with ",body.name )
	if body is Enemy:
		return
		
	# Handle collision with an enemy
	if body.has_method("take_damage") or body.name == "Player":
		body.take_damage(DAMAGE)
		queue_free()  # Destroy the projectile

	# Handle collision with an Asteroid object
	elif body is Asteroid:
		queue_free()

func set_damage(multiplier: float) -> void:
	DAMAGE *= multiplier
