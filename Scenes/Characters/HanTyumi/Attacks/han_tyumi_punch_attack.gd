extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Initially set the sword attack to invisible
	self.visible = true
	SoundManager.playSoundFX(0, load("res://Assets/Sound/SFX/HanTyumi/Attack/Punch/punchSound0.mp3"))
	$Timer.start(0.1)  # Assuming the Timer node is a direct child of the Area2D


# This function is called when the timer times out
func _on_timer_timeout() -> void:
	# Remove the sword attack from the scene
	queue_free()  # Remove the sword attack node
