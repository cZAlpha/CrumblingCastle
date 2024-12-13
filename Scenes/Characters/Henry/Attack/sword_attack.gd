extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Initially set the sword attack to invisible
	self.visible = false
	
	# Start the timer with a delay of 0.2 seconds
	$Timer.start(0.2)  # Assuming the Timer node is a direct child of the Area2D


# This function is called when the timer times out
func _on_Timer_timeout() -> void:
	# Make the sword attack visible for 0.8 seconds
	self.visible = true

	# Start the visibility timer to wait for 0.8 seconds
	$Timer.wait_time = 0.8
	$Timer.start()  # Restart the same Timer for visibility duration


func _on_timer_timeout() -> void:
	# Remove the sword attack from the scene
	queue_free()  # Remove the sword attack node
