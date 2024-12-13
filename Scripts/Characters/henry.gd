extends CharacterBody2D


const ACCELERATION = 1000 # The acceleration that the player's movement receives
const FRICTION = 800 # The friction the player has in the world
const MAX_SPEED = 120 # The maximum speed the player can reach

enum {IDLE, WALK, RUN, ATTACK, DEAD} # All possible states
var state = IDLE # Instantiate the curret state to be the idle state

@onready var animationTree = $AnimationTree
@onready var state_machine = animationTree["parameters/playback"]

var blend_position : Vector2 = Vector2.ZERO # The position in the blendspace 2D matrix for animations
var blen_pos_paths = [
	"parameters/Idle/Idle_BS2D/blend_position",
	"parameters/Walk/Walk_BS2D/blend_position",
	"parameters/Run/Run_BS2D/blend_position",
	"parameters/Attack/Attack_BS2D/blend_position",
	"parameters/Dead/Dead_BS2D/blend_position"
]

var animationTree_state_keys = [
	"Idle",
	"Walk",
	"Run",
	"Attack",
	"Dead"
]


func _ready():
	state = IDLE


func _physics_process(delta: float) -> void:
	if HealthManager.health <= 0: # If the player's health is totally diminished
		state = DEAD
	
	if state != DEAD: # If the player ain't dead
		move(delta) # Move the player every physics frame based on input (or lack thereof)
		animate() # Update the animation tree variables and shiz
	elif state == DEAD: # If the player is dead
		animate() # Update the animation tree variables and shiz


func move(delta):
	var input_vector = Input.get_vector("left", "right", "up", "down")
	
	if Input.is_action_just_pressed("attack"):
		# Load and instantiate the attack collider
		var attack_collider = load("res://Scenes/Characters/Henry/Attack/sword_attack.tscn")
		var new_attack_collider = attack_collider.instantiate()
		
		# Set initial position for the attack collider at Henry's origin
		var attack_position = $Area2D.global_position
		
		# Check if the input vector is not zero to place the attack hitbox in the correct direction
		if input_vector != Vector2.ZERO:
			# Normalize the input vector to get the direction the player is facing
			var direction = input_vector.normalized()
			
			# Set an offset distance for the attack collider placement (adjust as necessary)
			var attack_offset = 10 * direction  # 10 units away in the direction of movement
			
			# Adjust the attack collider position to be on the side the player is facing
			attack_position += attack_offset
		
		# Set the new position of the attack collider
		new_attack_collider.set_position(attack_position)
		
		# Add the attack collider to the scene
		get_parent().add_child(new_attack_collider)
	
	
	if Input.is_action_pressed("attack"): # If the player is attacking
		state = ATTACK
	elif input_vector == Vector2.ZERO: # If not moving
		state = IDLE # Set state to idle since you aren't moving
		apply_friction(FRICTION * delta) # Slow the player to a stop slowly using friction when they stop moving
	else: # If moving
		if Input.is_action_pressed("run"): # If the player is pressing the run button
			state = RUN # Set state to run
		else: # If the player is walking
			state = WALK # Set default move state to walk
		apply_movement(input_vector * ACCELERATION * delta)
		blend_position = input_vector # Set the blend position to the input vector ONLY IF MOVING
	move_and_slide()


func apply_friction(amount):
	if velocity.length() > amount:
		velocity -= velocity.normalized() * amount
	else:
		velocity = Vector2.ZERO


func apply_movement(amount):
	if GameManager.canMove: # if the player is allowed to move
		velocity += amount # Add amount to velocity
		if state == RUN: # If the player is running
			velocity = velocity.limit_length(MAX_SPEED * 1.5)
		else:
			velocity = velocity.limit_length(MAX_SPEED)


func animate(): # Function that tells what node the animation tree should go to or be at
	state_machine.travel(animationTree_state_keys[state])
	animationTree.set(blen_pos_paths[state], blend_position)


func _on_area_2d_area_entered(area: Area2D): # The function that handles when something enters the player's hitbox
	if area.is_in_group("Enemy"): # If an enemy of some kind's hitbox enters the player's hitbox
		print("An enemy entered the player's hitbox")
		HealthManager.health -= 1
		print("Health is now: " + str(HealthManager.health))
	else:
		print("Something entered the player's hitbox")


func go_to_death_screen():
	print("DeathScreen")
	get_tree().change_scene_to_file("res://Scenes/UI/death_menu.tscn")
