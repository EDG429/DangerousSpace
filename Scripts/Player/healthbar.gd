extends ProgressBar

@onready var damage_bar = $Damagebar
@onready var timer = $Timer

var health: int = 0
var max_hp: int = 0

# Setter for health that updates the health bar and handles damage
func set_health(new_health: int):
	var prev_health = health

	# Ensure new_health doesn't exceed max_hp
	if new_health > max_hp:
		new_health = max_hp
	
	health = new_health
	value = health
	
	if health <= 0: # death
		queue_free()
	elif health < prev_health: # taking damage
		timer.start()
	elif health > prev_health: # healing
		damage_bar.value = prev_health # Set the damage bar to the previous health before healing

# Initialize the health bar
func init_health(_health: int):
	max_hp = _health
	health = max_hp
	value = health
	max_value = max_hp  # Set max_value for the health bar
	damage_bar.max_value = max_hp  # Set max_value for the damage bar
	damage_bar.value = health

# Update damage bar when the timer times out
func _on_timer_timeout():
	damage_bar.value = health
