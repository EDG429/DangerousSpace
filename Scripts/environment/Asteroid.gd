class_name Asteroid

extends Sprite2D

@export var damage: int = 25 # Default damage the asteroid deals
@export var MAX_HP: int = 50 # Maximum hit points of the asteroid

var health: int
var is_dead: bool

func _ready() -> void:
	health = MAX_HP

func _on_Asteroid_body_entered(body: Node) -> void:
	# Check if the body is the player and has a `take_damage` method
	if body.has_method("take_damage"):
		print("Collided with asteroid")
		body.take_damage(damage)
	if body.is_in_group("PlayerBullets"):
		# take_damage(damage) <= we can decide if we want the asteroid to be an indestructible or destructible
		body.queue_free()

func take_damage(damage_amount: int):
	
	if is_dead:
		return # Ignore damage if dead
	
	health -= damage_amount
	health = clamp(health, 0, MAX_HP)
	
	if health <= 0:
		explode()

func explode() -> void:
	is_dead = true
	queue_free()
