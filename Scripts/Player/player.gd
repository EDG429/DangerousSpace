extends CharacterBody2D

@export var SPEED: float = 300.0  # Movement speed of the spaceship
@export var MAX_HP: int = 100    # Maximum hit points of the player
@export var DODGE_SPEED: float = 500.0  # Speed boost when dodging
@export var PRIMARY_SHOOTING_SPEED: float = 0.075 # Shooting cooldown in seconds
@export var SECONDARY_SHOOTING_SPEED: float = 0.2 # Shooting cooldown in seconds
@export var BULLET_PLAYER_PRIMARY_FIRE_scene: PackedScene = preload("res://Scenes/Player/bullet_player_primary_fire.tscn") # Getting the projectile scene for primary fire
@export var BULLET_PLAYER_SECONDARY_FIRE_scene: PackedScene = preload("res://Scenes/Player/bullet_player_secondary_fire.tscn") # Getting the projectile scene for secondary fire

@onready var primary_firing_sound: AudioStreamPlayer2D = $Primary_FiringSound
@onready var secondary_firing_sound: AudioStreamPlayer2D = $Secondary_FiringSound
@onready var primary_fire_timer: Timer = $PrimaryFire_Timer
@onready var secondary_fire_timer: Timer = $SecondaryFire_Timer
@onready var primary_muzzle_light: PointLight2D = $Primary_MuzzleLight
@onready var primary_fire_muzzle_flash_timer: Timer = $PrimaryFire_MuzzleFlash_Timer

var can_primary_fire: bool = true
var can_secondary_fire: bool = true

func _physics_process(_delta: float) -> void:
	# Initialize the movement direction vector
	var direction = Vector2.ZERO
	
	# Capture movement inputs for all directions
	direction.x = Input.get_axis("ui_left", "ui_right")
	direction.y = Input.get_axis("ui_up", "ui_down")
	
	# Normalize the direction vector to maintain consistent speed diagonally
	if direction != Vector2.ZERO:
		direction = direction.normalized()
	
	# Update the velocity with the input direction
	velocity = direction * SPEED
	
	# Apply the movement
	move_and_slide()
	# Check for player fire
	fire()

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
	primary_fire_projectile.global_position = global_position + Vector2(0, 25)
	primary_fire_projectile.direction = Vector2(0, 1)
	
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
	left_bullet.direction = Vector2(-0.5, 1).normalized()
	left_bullet.player = self
	
	# Create the right bullet and fire it diagonally
	var right_bullet = BULLET_PLAYER_SECONDARY_FIRE_scene.instantiate()
	get_parent().add_child(right_bullet)
	right_bullet.global_position = global_position + Vector2(10, 0)
	right_bullet.direction = Vector2(0.5, 1).normalized()
	right_bullet.player = self
	

	
	# Cooldown timer
	secondary_fire_timer.start(SECONDARY_SHOOTING_SPEED)
