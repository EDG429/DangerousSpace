class_name Enemy
extends CharacterBody2D

# The base enemy class should be 


@export var SPEED: float = 300.0  # Movement speed of the enemy spaceship
@export var MAX_HP: int = 100     # Maximum hit points of the enemy
@export var bounty: int = 50      # Bounty points awarded to the player on death

@onready var health_bar: ProgressBar = $Healthbar

var is_dead: bool = false
var health: int


func _ready() -> void:
	health = MAX_HP
	if health_bar:
		health_bar.init_health(health)

func take_damage(damage_amount: int):
	
	if is_dead:
		return  # Ignore damage if dead
	
	
	health -= damage_amount
	health = clamp(health, 0, MAX_HP)
	#
	if health_bar: 
		health_bar.visible = health < MAX_HP  # Show health bar only after taking damage so health bars don't clutter the screen
		health_bar.set_health(health)  # Update the health bar
	#
	if health <= 0:
		die()

# Kill the player
func die() -> void:
	is_dead = true
	award_points(bounty)
	queue_free()

func award_points(bounty: int):
	ScoreManager.add_points(bounty)  # Award points to the player
