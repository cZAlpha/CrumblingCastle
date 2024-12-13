extends Control


# cZAlpha Iconography Variables
@onready var topChevron = $cZAlphaInroCanvasLayer/RedChevronTextureRect0
@onready var middleChevron = $cZAlphaInroCanvasLayer/RedChevronTextureRect1
@onready var bottomChevron = $cZAlphaInroCanvasLayer/RedChevronTextureRect2
@onready var chevronArray = [topChevron, middleChevron, bottomChevron]


var fade_speed = 0.8
var move_speed = 50.0
var hold_duration = 5.0
var distanceFromOrigin = 100
@export var state = "fade_in"  # Possible states: "fade_in", "hold", "fade_out", "final_fade", "finished"
var hold_timer = 0.0
var fade_progress = 0.0
var move_progress = 0.0

var top_initial_pos = Vector2()
var bottom_initial_pos = Vector2()
var middle_initial_pos = Vector2()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Store initial positions
	top_initial_pos = topChevron.position
	bottom_initial_pos = bottomChevron.position
	middle_initial_pos = middleChevron.position

	# Set initial transparency and position
	for chevron in chevronArray:
		chevron.modulate.a = 0.0

func _process(delta: float) -> void:
	match state:
		"fade_in":
			_handle_fade_in(delta)
		"hold":
			_handle_hold(delta)
		"fade_out":
			_handle_fade_out(delta)
		"final_fade":
			_handle_final_fade(delta)
		"finished":
			pass # Do nothing when finished

func _handle_fade_in(delta: float) -> void:
	# Animate and fade in chevrons
	fade_progress += fade_speed * delta
	move_progress += move_speed * delta

	# Middle chevron fades in without movement
	middleChevron.modulate.a = clamp(fade_progress, 0.0, 1.0)

	# Top chevron fades in and moves up
	topChevron.modulate.a = clamp(fade_progress, 0.0, 1.0)
	topChevron.position.y = lerp(top_initial_pos.y, top_initial_pos.y - distanceFromOrigin, fade_progress)

	# Bottom chevron fades in and moves down
	bottomChevron.modulate.a = clamp(fade_progress, 0.0, 1.0)
	bottomChevron.position.y = lerp(bottom_initial_pos.y, bottom_initial_pos.y + distanceFromOrigin, fade_progress)

	# Transition to "hold" state once all animations are complete
	if fade_progress >= 1.0:
		state = "hold"
		hold_timer = 0.0

func _handle_hold(delta: float) -> void:
	# Wait for the hold duration
	hold_timer += delta
	if hold_timer >= hold_duration:
		state = "fade_out"
		fade_progress = 0.0
		move_progress = 0.0

func _handle_fade_out(delta: float) -> void:
	# Animate and fade out chevrons, returning to original positions
	fade_progress += fade_speed * delta
	
	# Top chevron fades out and moves back down
	topChevron.modulate.a = clamp(1.0 - fade_progress, 0.0, 1.0)
	topChevron.position.y = lerp(top_initial_pos.y - distanceFromOrigin, top_initial_pos.y, fade_progress)
	
	# Bottom chevron fades out and moves back up
	bottomChevron.modulate.a = clamp(1.0 - fade_progress, 0.0, 1.0)
	bottomChevron.position.y = lerp(bottom_initial_pos.y + distanceFromOrigin, bottom_initial_pos.y, fade_progress)
	
	# Transition to "final_fade" state when fade out is complete
	if fade_progress >= 1.0:
		state = "final_fade" 
		fade_progress = 0.0 # Reset timer


func _handle_final_fade(delta: float) -> void:
	# Middle chevron fades out without movement
	if middleChevron.modulate.a > 0:
		# Increment the fade progress
		fade_progress += fade_speed * delta
		# Remove opacity of middle chevron using delta time
		middleChevron.modulate.a = clamp(1.0 - fade_progress, 0.0, 1.0)
	elif middleChevron.modulate.a <= 0:
		state = "finished"
