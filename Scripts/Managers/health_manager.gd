extends Node


const MAX_HEALTH = 5
var health


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health = MAX_HEALTH # Set the default health to max


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
