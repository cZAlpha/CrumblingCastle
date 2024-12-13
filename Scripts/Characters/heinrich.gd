extends CharacterBody2D

const ACCELERATION = 400
const MAX_SPEED = 60

# Define states for the NPC
enum {IDLE, WALK}
var state = IDLE

@onready var animationTree = $AnimationTree
@onready var state_machine = animationTree["parameters/playback"]

var blend_position : Vector2 = Vector2.ZERO
var blend_pos_paths = [
	"parameters/Idle/Idle_BS2D/blend_position",
	"parameters/Walk/Walk_BS2D/blend_position"
]

var animationTree_state_keys = [
	"Idle",
	"Walk"
]

# Player reference and distance threshold
var player = null
var threshold_distance = 30

# Quest and movement marker variables
@export var quest: Quest 
@export var homeMarker: Marker2D
@export var marker0: Marker2D
@export var marker1: Marker2D
@onready var markers = [homeMarker, marker0, marker1]
var current_marker_index = 0

# Dialogue stuff
var rudenessMeter = 0
@onready var dialogueIndicator = $DialogueIndicator

# Idle timer for random delay at each marker
var idle_timer = 0.0
var idle_duration = 0.0
@export var idle_min_duration = 5
@export var idle_max_duration = 15


func _ready():
	# Assuming the player is already in the scene, get the reference
	var players = get_tree().get_nodes_in_group("Player")
	if players.size() > 0:
		player = players[0]
	else:
		print("NPC Error | Player not found")
	# Ensure that the dialogue indicator is disabled on start
	#dialogueIndicator.visible = false
	set_idle_duration()
	state = WALK  # Start with walking state


func _physics_process(delta: float) -> void:
	var current_position = position  # Use the current local position instead of global position
	var target_position = markers[current_marker_index].position
	var closeToPlayer = current_position.distance_to(player.position) < threshold_distance
	if rudenessMeter == 0: # If the player is nuetral or good with MiraNPC
		dialogueIndicator.play("default")
	if rudenessMeter == 1: # If the player has annoyed MiraNPC
		dialogueIndicator.play("annoyed")
	if rudenessMeter > 1: # If the player has pissed MiraNPC off
		dialogueIndicator.play("angry")
	if player and !closeToPlayer: 
		dialogueIndicator.visible = false
	if player and closeToPlayer:
		dialogueIndicator.visible = true
		face_player()
		state = IDLE
	elif ensure_markers_exist(): # if all markers exist, proceed with movement AI stuff
		# If currently idling, increase the idle timer and set the NPC to walk after idle duration expires
		if state == IDLE:
			idle_timer += delta
			if idle_timer >= idle_duration:
				state = WALK
		elif state == WALK:
			move_to_next_marker(delta)
	else:
		print("NPC Error | Major movement error!")
	animate()


func move_to_next_marker(delta):
	# Get current local position and target marker's local position
	var current_position = position
	var target_position = markers[current_marker_index].position
	
	# Calculate direction towards the target
	var direction = (target_position - current_position).normalized()
	update_blend_position(-direction)  # Ensure NPC faces the direction of the next marker
	
	# Set velocity directly towards the target direction
	velocity = direction * MAX_SPEED
	move_and_slide()  # Move the NPC with the velocity
	
	# Check if NPC has reached the target marker
	if current_position.distance_to(target_position) < 5:  # Use a smaller threshold to stop close to the marker
		#print("NPC | THRESHOLD REACHED")
		velocity = Vector2.ZERO  # Stop movement
		state = IDLE
		set_idle_duration()
		idle_timer = 0.0
		# Move to the next marker in sequence
		current_marker_index = (current_marker_index + 1) % markers.size()
	else:
		#print("NPC | Moving to:", markers[current_marker_index], "marker, distance:", current_position.distance_to(target_position))
		pass


func set_idle_duration():
	# Set a random idle duration between the min and max settings for the NPC
	idle_duration = randi_range(idle_min_duration, idle_max_duration)


func face_player():
	# Update blend_position to face the player when idling
	var direction_to_player = (player.position - position).normalized()
	update_blend_position(direction_to_player)



func ensure_markers_exist():
	# If all markers and the array to hold them exist
	if homeMarker and marker0 and marker1 and (len(markers) > 0):
		return true
	else:
		return false


# Updates the blend_position to ensure the NPC faces the correct direction
func update_blend_position(new_direction: Vector2):
	blend_position = new_direction
	animationTree.set(blend_pos_paths[state], blend_position)


func animate():
	state_machine.travel(animationTree_state_keys[state])
	animationTree.set(blend_pos_paths[state], blend_position)


# Rounds a Vector2 position to avoid floating point precision issues
func round_position(position: Vector2) -> Vector2:
	return Vector2(roundi(position.x), roundi(position.y))


# Calculate the distance between two Vector2 points with rounding
func calculate_distance(point_a: Vector2, point_b: Vector2) -> float:
	var rounded_a = round_position(point_a)
	var rounded_b = round_position(point_b)
	
	var dx = rounded_b.x - rounded_a.x
	var dy = rounded_b.y - rounded_a.y
	return sqrt(dx * dx + dy * dy)



#
# Dialogue Related Functions
#

func incrementRudenessMeter(): # Function that increments the variable that keeps track of how many times you were rude to MiraNPC
	rudenessMeter += 1


func decrementRudenessMeter(): # Function that dencrements the variable that keeps track of how many times you were rude to MiraNPC
	if rudenessMeter <= 0:
		rudenessMeter = 0 # Ensure that rudenss meter does not go below 0
		print("HeinrichNPC Error | decrementRudenessMeter | Cannot decrement rudenessMeter below 0")
		return
	rudenessMeter -= 1 # If no error, decrement the rudeness meter for MiraNPC
