extends Enemy
class_name Boss

@export var BOSS_BULLET_SCENE: PackedScene = preload("res://Scenes/Enemies/Boss_bullet.tscn")
@export var BOSS_MISSILE_SCENE: PackedScene = preload("res://Scenes/Enemies/BossMissile.tscn")
@export var BOSS_SECONDARY_BULLET_SCENE: PackedScene = preload("res://BulletSpawner/BulletSpawner.tscn")
@export var secondary_bullet_rate = 5
@export var MISSILE_FIRE_RATE = 3

@onready var awaken_zone: Area2D = $AwakenZone
@onready var awakening_sound: AudioStreamPlayer2D = $AwakeningSound
@onready var shutdown_sound: AudioStreamPlayer2D = $ShutdownSound
@onready var boss_explosion_sound: AudioStreamPlayer2D = $BossExplosionSound
@onready var secondary_timer: Timer = $secondaryTimer
@onready var missile_timer: Timer = $MissileTimer


# Boss is asleep on spawn, only wakes up when the player enters its "zone"
var is_asleep: bool = true
var is_awakening: bool = false

func sleep() -> void:
	health_bar.visible = false
	collision_shape_2d.disabled = true
	animated_sprite.play("sleep")

func awaken() -> void:
	if is_awakening:
		return
	is_awakening = true

	animated_sprite.play("awakening")
	awakening_sound.play()
	await get_tree().create_timer(3).timeout

	is_awakening = false
	is_asleep = false # Boss is no longer asleep
	collision_shape_2d.disabled = false

	animated_sprite.play("idle")
	initialize_bossfight()

func initialize_bossfight() -> void:
	health = MAX_HP
	if health_bar:
		health_bar.init_health(health)

	# Assign the player reference
	if not is_instance_valid(player):
		player = get_tree().get_root().get_node("prototype_level/Player") # Adjust path if necessary

	if not player:
		print("Player not found. Boss won't move or attack.")
		return # Exit if the player is not found

	# Start firing timer
	
	fire_timer.connect("timeout", Callable(self, "_on_FireTimer_timeout"))
	fire_timer.wait_time = FIRE_RATE
	fire_timer.start()
	
	secondary_timer.connect("secondary_fire_timeout", Callable(self, "_on_secondary_timer_timeout"))
	secondary_timer.wait_time = secondary_bullet_rate
	secondary_timer.start()
	
	missile_timer.connect("missile_timeout", Callable(self, "_on_Missile_Timer_Timeout"))
	missile_timer.wait_time = MISSILE_FIRE_RATE
	missile_timer.start()

	# Start damage flickering timer	
	damage_flicker_timer.connect("timeout", Callable(self, "_on_DamageFeedbackTimer_timeout"))
	fire_timer.wait_time = FIRE_RATE
	damage_flicker_timer.start()

func _ready() -> void:
	sleep()

func _on_awaken_zone_body_entered(body: Node2D) -> void:
	if body is Player and is_asleep:
		is_asleep = false
		awaken_zone.set_deferred("monitorable", false)
		awaken_zone.queue_free()
		awaken()

func _process(_delta: float) -> void:
	if is_dead or is_asleep or health <= 0 or player_dead: # Add 'is_asleep' to the condition
		return

	if not is_instance_valid(player):
		return

	# Ensure the player instance is valid
	if is_instance_valid(player):
		# Follow the player
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * SPEED
		move_and_slide()

	# Flip sprite based on position
	animated_sprite.flip_v = global_position.y > player.global_position.y

func fire() -> void:
	if not is_instance_valid(player):
		return

	# Create and fire a bullet at the player
	var bullet = BOSS_BULLET_SCENE.instantiate()
	get_parent().add_child(bullet) # Add the bullet to the parent node
	bullet.global_position = global_position
	# Calculate bullet direction
	bullet.direction = (player.global_position - global_position).normalized()

	# Flip the bullet sprite for visual effects
	if bullet.has_node("Sprite2D"):
		var bullet_sprite = bullet.get_node("Sprite2D")
		bullet_sprite.flip_v = global_position.y > player.global_position.y


func fire_missile() -> void:
	if not is_instance_valid(player):
		return

	# Create and fire a missile at the player
	var missile = BOSS_MISSILE_SCENE.instantiate()
	get_parent().add_child(missile) # Add the missile to the parent node
	missile.global_position = global_position

	# Pass the player reference to the missile so it can rotate toward the player
	missile.player = player

	# Ensure the missile rotates and sets its direction towards the player
	missile.rotate_towards_player()

func secondary_fire() -> void:
	if not is_instance_valid(player):
		return

	var bullet = BOSS_SECONDARY_BULLET_SCENE.instantiate()
	get_parent().add_child(bullet)
	bullet.global_position = global_position

	var timer = Timer.new()
	timer.one_shot = true
	timer.wait_time = 3
	bullet.add_child(timer)
	timer.start()

	timer.connect("timeout", Callable(bullet, "queue_free"))

func _on_Boss_FireTimer_timeout() -> void:
	if not is_asleep and not is_dead and is_instance_valid(player):
		fire()

func die() -> void:
	is_dead = true
	
	# Disable collisions
	self.set_collision_layer(0)
	self.set_collision_mask(0)
	
	# Disable supercharged visuals
	supercharge_particles_1.emitting = false
	supercharge_particles_2.emitting = false
	
	# Disable debuff visuals
	debuff_particles_1.emitting = false
	debuff_particles_2.emitting = false
	
	# Disable health bar
	health_bar.visible = false
	
	shutdown_sound.play()
	await get_tree().create_timer(1.5).timeout
	boss_explosion_sound.play()
	animated_sprite.play("death")
	print("Enemy destroyed!")
	ScoreManager.add_points(BOUNTY) # Award points to the player
	await get_tree().create_timer(3).timeout
	queue_free() # Remove the enemy from the scene


func _on_player_died() -> void:
	player_dead = true
	fire_timer.stop()

func _on_secondary_timer_timeout() -> void:
	if not is_asleep and not is_dead and is_instance_valid(player):
		secondary_fire()

func _on_Missile_Timer_Timeout() -> void:
	if not is_asleep and not is_dead and is_instance_valid(player):
		fire_missile()
