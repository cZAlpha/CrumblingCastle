extends AnimatedSprite2D


@export var arc_duration := 0.5  # Time to reach final position
@export var arc_height := 20  # Maximum height the coin will arc up

var final_position: Vector2
var initial_velocity: Vector2
var time_elapsed := 0.0
var should_arc := false  # Determines if the coin should perform the arc animation


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


func _process(delta):
	# Only animate coin movement if should_arc is true
	if should_arc:
		time_elapsed += delta
		
		# Calculate normalized progress over the arc duration
		var progress = min(time_elapsed / arc_duration, 1.0)

		# Calculate the horizontal movement toward the final position
		var position_x = lerp(position.x, final_position.x, progress)
		
		# Calculate the arc height based on progress to create a smooth parabolic effect
		var height_factor = (1 - progress) * progress  # Creates a peak in the middle
		var position_y = lerp(position.y, final_position.y, progress) - arc_height * height_factor
		
		# Update the coin's position
		position = Vector2(position_x, position_y)

		# Stop moving once it reaches the target
		if progress >= 1.0:
			set_process(false)


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("Player"): # If the player collides with the gold coin
		GameManager.gold += 1 # increment the gold count of the player by 1
		SoundManager.playSoundFX(get_instance_id(), load("res://Assets/Sound/SFX/Coin/coins-sound-effect-1-241818.mp3")) # Play coin pickup sound
		queue_free() # Delete the coin
