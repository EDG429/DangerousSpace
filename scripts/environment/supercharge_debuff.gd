extends Area2D

@export var duration: float = 20.0  # Debuff duration in seconds
@export var heal_amount: int = -25

@onready var pickup_sound: AudioStreamPlayer2D = $PickupSound
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var cpu_particles_2d_2: CPUParticles2D = $CPUParticles2D2
@onready var cpu_particles_2d: CPUParticles2D = $CPUParticles2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_body_entered(body: Node) -> void:
	if body is Player and sprite_2d.visible:
		body.apply_supercharge_debuff(duration)  # Apply the buff to the player
		body.heal(heal_amount)
		pickup_sound.play()
		ScoreManager.substract_points(50)
		sprite_2d.visible = false
		cpu_particles_2d_2.emitting = false
		cpu_particles_2d.emitting = false
		collision_shape_2d.disabled
		await pickup_sound.finished
		queue_free()  # Remove the pickup object
		
	if body is Enemy and sprite_2d.visible:
		body.apply_supercharge_debuff(duration)  # Apply the buff to the player		
		pickup_sound.play()
		ScoreManager.add_points(50)
		sprite_2d.visible = false
		cpu_particles_2d_2.emitting = false
		cpu_particles_2d.emitting = false
		collision_shape_2d.disabled
		await pickup_sound.finished
		queue_free()  # Remove the pickup object
