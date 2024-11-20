class_name Enemy
extends CharacterBody2D

# Export Variables
@export var SPEED: float = 160.0  # Movement speed
@export var MAX_HP: int = 50     # Enemy health
@export var BOUNTY: int = 50     # Points awarded for destroying this enemy
@export var BULLET_SCENE: PackedScene = preload("res://Scenes/Enemies/enemy_bullet.tscn")  # Bullet scene for enemy fire
@export var FIRE_RATE: float = 0.5  # Fire rate in seconds
@export var SUPERCHARGE_MULTIPLIER: float = 2.0 # Multiplier for firing speed and damage

# OnReady Variables
@onready var supercharge_particles_1: CPUParticles2D = $Supercharge_Particles1
@onready var supercharge_particles_2: CPUParticles2D = $Supercharge_Particles1/Supercharge_Particles2
@onready var debuff_particles_1: CPUParticles2D = $Debuff_Particles1
@onready var debuff_particles_2: CPUParticles2D = $Debuff_Particles1/Debuff_Particles2
@onready var supercharge_timer: Timer = $Supercharge_Timer
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var fire_timer: Timer = $Fire_Timer
@onready var health_bar: ProgressBar = $Healthbar
@onready var damage_flicker_timer: Timer = $DamageFlicker_Timer
@onready var on_enemy_damage_sound: AudioStreamPlayer2D = $OnEnemyDamage_Sound
@onready var on_enemy_explosion_sound: AudioStreamPlayer2D = $OnEnemyExplosion_Sound
@onready var debuff_timer: Timer = $Debuff_Timer
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D



# General Variables
var player: Node2D = null  # Reference to the player
var health: int
var player_state = GameState.player

# Boolean flags:
var is_dead: bool = false
var is_shooting: bool = false
var is_taking_damage: bool = false
var is_supercharged: bool = false
var is_downcharged: bool = false


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
	
	if player_state == null:
		return
	
	if is_dead or health <= 0:
		return
	
	# Ensure the player instance is valid
	if is_instance_valid(player):
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
	

# ------------------------ Damage Processing Logic Start ---------------------------------- #

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
	
	# Disable collisionshape
	collision_shape_2d.disabled
	
	# Disable supercharged visuals
	supercharge_particles_1.emitting = false
	supercharge_particles_2.emitting = false
	
	# Disable debuff visuals
	debuff_particles_1.emitting = false
	debuff_particles_2.emitting = false
	
	# Disable health bar
	health_bar.visible = false
	
	on_enemy_damage_sound.play()
	on_enemy_explosion_sound.play()
	animated_sprite.play("death")
	print("Enemy destroyed!")
	ScoreManager.add_points(BOUNTY)  # Award points to the player
	await get_tree().create_timer(3).timeout
	queue_free()  # Remove the enemy from the scene
	
# ------------------------ Damage Processing Logic End ---------------------------------- #

# -------------------------- Firing Logic Start --------------------------- #
func fire() -> void:
	
	if is_dead or player_state == null:
		return
		
	# Create and fire a bullet at the player
	var bullet = BULLET_SCENE.instantiate()
	get_parent().add_child(bullet)  # Add the bullet to the parent node
	var bullet_sprite = bullet.get_node("Sprite2D")
	
	# Play firing SFX here
	#######################
	
	bullet.global_position = global_position + Vector2(0, 25) if animated_sprite.flip_v == false else global_position + Vector2(0, - 25)
	bullet.direction = (player.global_position - global_position).normalized()
	
	# Flip the bullet sprite vertically based on the firing direction
	bullet_sprite.flip_v = true if animated_sprite.flip_v == false else false
	
func _on_FireTimer_timeout() -> void:
	if player and not is_dead:
		fire()
# -------------------------- Firing Logic End --------------------------- #

# ------------------------------------- Buff or Debuff Logic Start --------------------------------------- #

func apply_supercharge_buff(duration: float) -> void:
	if is_supercharged:
		return # Avoid stacking the buff
	
	is_supercharged = true
	
	# Double firerate and damage
	FIRE_RATE /= SUPERCHARGE_MULTIPLIER
	fire_timer.wait_time = FIRE_RATE  # Update the timer with the new fire rate
	
	# Enable supercharged visuals
	supercharge_particles_1.emitting = true
	supercharge_particles_2.emitting = true
	
	# Start the buff timer
	supercharge_timer.start(duration)

func _on_Supercharge_Timer_Timeout() -> void:
	# Remove the buff after the timeout
	is_supercharged = false
	
	# Restore original fire rate values
	FIRE_RATE *= SUPERCHARGE_MULTIPLIER
	fire_timer.wait_time = FIRE_RATE  # Update the timer
	
	# Disable supercharged visuals
	supercharge_particles_1.emitting = false
	supercharge_particles_2.emitting = false

func apply_supercharge_debuff(duration: float) -> void:
	if is_downcharged:
		return # Avoid stacking the buff
	#
	is_downcharged = true
	#
	# Halve firerate and damage
	FIRE_RATE *= SUPERCHARGE_MULTIPLIER
	fire_timer.wait_time = FIRE_RATE  # Update the timer
	#
	# Enable supercharged visuals
	debuff_particles_1.emitting = true
	debuff_particles_2.emitting = true
	#
	# Start the buff timer
	debuff_timer.start(duration)
#
func _on_Debuff_Timer_Timeout() -> void:
	# Remove the debuff after the timeout
	is_downcharged = false
	#
	# Restore original firerate values
	FIRE_RATE /= SUPERCHARGE_MULTIPLIER
	fire_timer.wait_time = FIRE_RATE
	#
	# Disable supercharged visuals
	debuff_particles_1.emitting = false
	debuff_particles_2.emitting = false

func heal(heal_amount: int) -> void:
	if not health_bar or health <= 0:
		return
	
	health = clamp(health + heal_amount, 0, MAX_HP)
	if health_bar:
		health_bar.set_health(health)
## ------------------------------------- Buff or Debuff Logic End --------------------------------------- #
