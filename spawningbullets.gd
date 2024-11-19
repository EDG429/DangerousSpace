extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Spawning.spawn(
	{"position": Vector2(353,393), "rotation":15},
	"one",
	"first"
	)
