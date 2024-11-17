class_name Player
extends CharacterBody2D

# Export vars
@export var SPEED: float = 300.0  # Movement speed of the spaceship
@export var MAX_HP: int = 100    # Maximum hit points of the player
@export var DODGE_SPEED: float = 500.0  # Speed boost when dodging
@export var DODGE_DISTANCE: float = 10.0  # Distanced traveled while dodging
@export var DODGE_TIME: float = 0.25  # Duration of dodge in seconds
@export var DODGE_COOLDOWN: float = 2.0  # Cooldown duration in seconds
@export var PRIMARY_SHOOTING_SPEED: float = 0.075 # Shooting cooldown in seconds
@export var SECONDARY_SHOOTING_SPEED: float = 0.2 # Shooting cooldown in seconds
@export var BULLET_PLAYER_PRIMARY_FIRE_scene: PackedScene = preload("res://Scenes/Player/bullet_player_primary_fire.tscn") # Getting the projectile scene for primary fire
@export var BULLET_PLAYER_SECONDARY_FIRE_scene: PackedScene = preload("res://Scenes/Player/bullet_player_secondary_fire.tscn") # Getting the projectile scene for secondary fire
@export var SUPERCHARGE_MULTIPLIER: float = 2.0 # Multiplier for firing speed and damage


# OnReady vars
@onready var health_bar: ProgressBar = $Healthbar
@onready var primary_firing_sound: AudioStreamPlayer2D = $Primary_FiringSound
@onready var secondary_firing_sound: AudioStreamPlayer2D = $Secondary_FiringSound
@onready var primary_fire_timer: Timer = $PrimaryFire_Timer
@onready var secondary_fire_timer: Timer = $SecondaryFire_Timer
@onready var dodge_timer: Timer = $Dodge_Timer
@onready var dodge_cooldown_timer: Timer = $DodgeCooldown_Timer
@onready var supercharge_timer: Timer = $Supercharge_Timer

@onready var primary_muzzle_light: PointLight2D = $Primary_MuzzleLight
@onready var primary_fire_muzzle_flash_timer: Timer = $PrimaryFire_MuzzleFlash_Timer
@onready var supercharge_particles_1: CPUParticles2D = $Supercharge_Particles1
@onready var supercharge_particles_2: CPUParticles2D = $Supercharge_Particles1/Supercharge_Particles2




# Boolean flags
var can_fire: bool = true
var can_primary_fire: bool = true
var can_secondary_fire: bool = true
var is_dead: bool = false # <= future implementation of a death mechanic (only needs a death animation now)
var is_dodging: bool = false # Track dodge state
var is_supercharged: bool = false # Track the supercharged state

# Key Player Variables
var health: int
var last_direction: Vector2 = Vector2.UP  # Default direction (forward)

func _ready() -> void:
	health = MAX_HP
	if health_bar:
		health_bar.init_health(health)

func _physics_process(_delta: float) -> void:
	# If the player is dead prevent any update
	if is_dead:
		return
	
	if is_dodging:
		move_and_slide()
		return
	
	# Initialize the movement direction vector
	var direction = Vector2.ZERO	
	# Capture movement inputs for all directions
	direction.x = Input.get_axis("ui_left", "ui_right")
	direction.y = Input.get_axis("ui_up", "ui_down")
	
	# Normalize the direction vector to maintain consistent speed diagonally
	if direction != Vector2.ZERO:
		last_direction = direction.normalized()
	
	# Update the velocity with the input direction
	velocity = direction * SPEED	
	# Apply the movement
	move_and_slide()
	
	# Check for player fire
	if can_fire:
		fire()

	# Check for dodge
	if Input.is_action_just_pressed("dodge"):
		dodge()

#----------------------------- Firing Logic Start ---------------------------------------#

func fire() -> void:
	if Input.is_action_pressed("primary_fire") and can_primary_fire: # Spawn a new projectile and add it to the scene
		Primary_Fire()
		
	if Input.is_action_pressed("secondary_fire") and can_secondary_fire:
		Secondary_Fire()

func _on_timer_timeout_PrimaryFire() -> void:
	can_primary_fire = true

func _on_timer_timeout_SecondaryFire() -> void:
	can_secondary_fire = true

func _on_PrimaryFire_MuzzleFlashTimer_timeout() -> void:
	# Disable the muzzle light when the timer times out
	primary_muzzle_light.visible = false

func Primary_Fire() -> void:
	can_primary_fire = false
	print("shots fired! Primary Fire")
	# Enable Muzzle Light
	primary_muzzle_light.global_position = global_position + Vector2(0, 24)
	primary_muzzle_light.visible = true
	primary_fire_muzzle_flash_timer.start()
	
	# Create the bullet and attach it to the player as a child node
	var primary_fire_projectile = BULLET_PLAYER_PRIMARY_FIRE_scene.instantiate()
	get_parent().add_child(primary_fire_projectile)
	
	# Play SFX
	primary_firing_sound.play()
	
	# Set position and direction
	primary_fire_projectile.global_position = global_position + Vector2(0, - 26)
	primary_fire_projectile.direction = Vector2(0, - 1)
	primary_fire_projectile.set_damage(SUPERCHARGE_MULTIPLIER if is_supercharged else 1.0)
	
	# Pass the player reference
	primary_fire_projectile.player = self  # Pass 'self' as the player reference
	
	# Cooldown timer
	primary_fire_timer.start(PRIMARY_SHOOTING_SPEED)

func Secondary_Fire() -> void:
	can_secondary_fire = false
	print("shots fired! Secondary Fire")
	
	# Code for muzzle light will go here
	# XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
	
	# Code for secondary fire logic
	
	# Play SFX
	secondary_firing_sound.play()
	
	# Create the left bullet and fire it diagonally
	var left_bullet = BULLET_PLAYER_SECONDARY_FIRE_scene.instantiate()
	get_parent().add_child(left_bullet)
	left_bullet.global_position = global_position + Vector2(-10, 0)
	left_bullet.direction = Vector2(-0.5, -1).normalized()
	left_bullet.set_damage(SUPERCHARGE_MULTIPLIER if is_supercharged else 1.0)
	left_bullet.player = self
	
	# Create the right bullet and fire it diagonally
	var right_bullet = BULLET_PLAYER_SECONDARY_FIRE_scene.instantiate()
	get_parent().add_child(right_bullet)
	right_bullet.global_position = global_position + Vector2(10, 0)
	right_bullet.direction = Vector2(0.5, -1).normalized()
	right_bullet.set_damage(SUPERCHARGE_MULTIPLIER if is_supercharged else 1.0)
	right_bullet.player = self
	

	
	# Cooldown timer
	secondary_fire_timer.start(SECONDARY_SHOOTING_SPEED)

#----------------------------- Firing Logic End -----------------------------------------#

#----------------------- Damage Processing Logic Start ----------------------------------#

# Damage the player
func take_damage(damage_amount: int):
	
	if is_dead:
		return  # Ignore damage if dead
	
	health -= damage_amount
	health = clamp(health, 0, MAX_HP)
	#
	if health_bar: 
		health_bar.visible = true  # Show the health bar when taking damage
		health_bar.set_health(health)  # Update the health bar
	#
	if health <= 0:
		die()

# Kill the player
func die() -> void:
	is_dead = true
	#ap.play("death") <= future implementation of a death animation when the proper sprites are collected

# -------------------------------------- Dodge Logic Start ---------------------------------------------- #

func dodge() -> void:
	if is_dodging or is_dead:
		return  # Ignore if already dodging or dead
	
	if dodge_timer.is_stopped() and dodge_cooldown_timer.is_stopped():
		is_dodging = true  # Start dodge
		can_fire = false  # Disable firing
		velocity = last_direction * DODGE_SPEED  # Apply dodge velocity
		make_invulnerable(true)  # Enable invulnerability
		dodge_timer.start(DODGE_TIME)  # Start dodge duration timer
	
		# Start the dodge cooldown timer
		dodge_timer.start(DODGE_TIME)
		
		 # Start the cooldown timer
		dodge_cooldown_timer.start(DODGE_COOLDOWN)
	
	else:
		print("Dodge on cooldown!")

func _on_Dodge_Timer_timeout() -> void:
	is_dodging = false
	can_fire = true
	make_invulnerable(false)

func _on_DodgeCooldown_Timer_timeout() -> void:
	# Logic to re-enable dodge will go here
	pass

func make_invulnerable(enabled: bool) -> void:
	set_collision_layer(0 if enabled else 1)


# ------------------------------------- Dodge Logic End -------------------------------------------------- #

# ------------------------------------- Buff or Debuff Logic Start --------------------------------------- #

func apply_supercharge_buff(duration: float) -> void:
	if is_supercharged:
		return # Avoid stacking the buff
	
	is_supercharged = true
	
	# Double firerate and damage
	PRIMARY_SHOOTING_SPEED /= SUPERCHARGE_MULTIPLIER
	SECONDARY_SHOOTING_SPEED /= SUPERCHARGE_MULTIPLIER	
	
	# Enable supercharged visuals
	supercharge_particles_1.emitting = true
	supercharge_particles_2.emitting = true
	
	# Start the buff timer
	supercharge_timer.start(duration)

func _on_supercharge_timer_Timeout() -> void:
	# Remove the buff after the timeout
	is_supercharged = false
	
	# Restore original damage values
	PRIMARY_SHOOTING_SPEED *= SUPERCHARGE_MULTIPLIER
	SECONDARY_SHOOTING_SPEED *= SUPERCHARGE_MULTIPLIER

	
	# Disable supercharged visuals
	supercharge_particles_1.emitting = false
	supercharge_particles_2.emitting = false
