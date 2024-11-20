extends CharacterBody2D

# Export Variables
@export var SPEED: float = 150.0  # Movement speed
@export var MAX_HP: int = 50     # Enemy health
@export var BOUNTY: int = 50     # Points awarded for destroying this enemy
@export var BULLET_SCENE: PackedScene = preload("res://Scenes/Player/bullet_player_primary_fire.tscn")  # Bullet scene for enemy fire
@export var FIRE_RATE: float = 1.5  # Fire rate in seconds

# OnReady Variables
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var fire_timer: Timer = $Fire_Timer
@onready var health_bar: ProgressBar = $Healthbar
@onready var damage_flicker_timer: Timer = $DamageFlicker_Timer
@onready var on_enemy_damage_sound: AudioStreamPlayer2D = $OnEnemyDamage_Sound
@onready var on_enemy_explosion_sound: AudioStreamPlayer2D = $OnEnemyExplosion_Sound



# General Variables
var player: Node2D = null  # Reference to the player
var health: int

# Boolean flags:
var is_dead: bool = false
var is_shooting: bool = false
var is_taking_damage: bool = false

func _ready() -> void:
	health = MAX_HP
	if health_bar:
		health_bar.init_health(health)
	# Find the player in the scene tree
	player = get_tree().get_root().get_node("prototype_level/Player")  # Adjust path to match your scene setup
	if not player:
		print("Player not found. Enemy won't follow.")
	
	# Start firing timer
	fire_timer.wait_time = FIRE_RATE
	fire_timer.start()

func _process(delta: float) -> void:
	
	if is_dead or health <= 0:
		return
	
	if player:
		# Follow the player
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * SPEED
		move_and_slide()
	
	if global_position.y > player.global_position.y:
		# Enemy is below the player, flip sprite
		animated_sprite.flip_v = true
	else:
		# Enemy is above the player, reset sprite
		animated_sprite.flip_v = false
	

func take_damage(damage_amount: int) -> void:
	if is_dead or health <= 0:
		return
	
	health -= damage_amount
	health = clamp(health, 0, MAX_HP)
	
	if health_bar: 
		health_bar.visible = true  # Show the health bar when taking damage
		health_bar.set_health(health)  # Update the health bar
	
	if health <= 0:
		die()
	else:
		flicker_red()

func flicker_red() -> void:
	is_taking_damage = true
	on_enemy_damage_sound.play()
	animated_sprite.modulate = Color(1, 0, 0)  # Set sprite color to red
	damage_flicker_timer.start()  # Start the timer to reset the color

# Reset the sprite's color to normal when the timer times out
func _on_DamageFeedbackTimer_timeout() -> void:
	animated_sprite.modulate = Color(1, 1, 1)  # Revert the sprite color to normal
	is_taking_damage = false


func die() -> void:
	is_dead = true
	on_enemy_damage_sound.play()
	on_enemy_explosion_sound.play()
	animated_sprite.play("death")
	print("Enemy destroyed!")
	ScoreManager.add_points(BOUNTY)  # Award points to the player
	await get_tree().create_timer(3).timeout
	queue_free()  # Remove the enemy from the scene

func _on_FireTimer_timeout() -> void:
	if player:
		fire()

func fire() -> void:
	# Create and fire a bullet at the player
	var bullet = BULLET_SCENE.instantiate()
	get_parent().add_child(bullet)  # Add the bullet to the parent node
	bullet.global_position = global_position
	bullet.direction = (player.global_position - global_position).normalized()
