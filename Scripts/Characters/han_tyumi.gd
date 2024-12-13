extends CharacterBody2D


const ACCELERATION = 750 # The acceleration that the player's movement receives
const FRICTION = 900 # The friction the player has in the world
const MAX_SPEED = 100 # The maximum speed the player can reach

enum {IDLE, WALK, DEAD, ATTACK} # All possible states
var state = IDLE # Instantiate the curret state to be the idle state

var last_direction = Vector2.ZERO  # Variable to store the last movement direction
var attack_in_progress = false  # Flag to track if an attack is in progress

@onready var animationTree = $AnimationTree
@onready var state_machine = animationTree["parameters/playback"]

var blend_position : Vector2 = Vector2.ZERO # The position in the blendspace 2D matrix for animations
var blen_pos_paths = [
	"parameters/Idle/Idle_BS2D/blend_position",
	"parameters/Walk/Walk_BS2D/blend_position",
	"parameters/Dead/Dead_BS2D/blend_position",
	"parameters/Attack/Attack_BS2D/blend_position",
]

var animationTree_state_keys = [
	"Idle",
	"Walk",
	"Dead",
	"Attack"
]

@onready var directionMarker = $DirectionMarker
@onready var actionableFinderArea2D = $DirectionMarker/ActionableFinderArea2D


func _ready():
	state = IDLE # Set the default animation to the idle animation


func _physics_process(delta: float) -> void:
	if !GameManager.inDialogue:
		if state == DEAD: # If the player is dead
			animate() # Update the animation tree variables and shiz
		else: # If the player is alive
			move(delta) # Move the player every physics frame based on input (or lack thereof)
			animate() # Update the animation tree variables and shiz
	else: # If the player IS in dialogue
		state = IDLE
		animate() # Update the animation tree variables and shiz


func move(delta):
	var input_vector = Input.get_vector("left", "right", "up", "down")
	
	var last_angle = last_direction.angle() # the last angle the player was facing
	directionMarker.rotation = last_angle - 190
	# NOTE: ATTACK HANDLING
	if Input.is_action_just_pressed("attack") and state != ATTACK and not attack_in_progress:  # Initiate attack if not already attacking
		state = ATTACK
		attack_in_progress = true  # Mark attack as in progress
	# NOTE: DIALOGUE HANDLING 
	elif Input.is_action_just_pressed("interact") and !GameManager.inDialogue:
		var actionables = actionableFinderArea2D.get_overlapping_areas()
		if actionables.size() > 0:
			actionables[0].action()
			GameManager.inDialogue = true
			return
	elif input_vector == Vector2.ZERO and state != ATTACK: # IDLE STATE
		state = IDLE
		apply_friction(FRICTION * delta)
	elif state != ATTACK and input_vector: # WALK STATE
		state = WALK
		apply_movement(input_vector * ACCELERATION * delta)
		blend_position = input_vector
		move_and_slide()
		last_direction = input_vector.normalized()  # Update last direction
	elif state == ATTACK: # ATTACK STATE
		apply_friction(FRICTION * delta)
		move_and_slide()
		
		# Check if an attack collider already exists
		if not attack_in_progress:
			return  # Skip if attack already in progress
		
		# Load and instantiate the attack collider
		var attack_collider = load("res://Scenes/Characters/HanTyumi/Attacks/han_tyumi_punch_attack.tscn")
		var new_attack_collider = attack_collider.instantiate()
		
		# Set initial position for the attack collider at Han's origin
		var attack_position = $Area2D.global_position
		
		# Check if the input vector is not zero to place the attack hitbox in the correct direction
		if input_vector != Vector2.ZERO:
			# Use the input vector if available
			var direction = input_vector.normalized()
			# Set an offset distance for the attack collider placement (adjust as necessary)
			var attack_offset = 10 * direction  # 10 units away in the direction of movement
			
			# Adjust the attack collider position to be on the side the player is facing
			attack_position += attack_offset
			
			# Set the new position of the attack collider
			new_attack_collider.set_position(attack_position)
			
			# Add the attack collider to the scene
			get_parent().add_child(new_attack_collider)
		else:
			# NOTE: If you're wondering why the same code is repeated in both the "if" and the "else",
			# its simply because Godot & GD Script in general is a retarded game engine and programming
			# language.
			
			# If no input, use the last known direction
			var direction = last_direction.normalized()
		
			# Set an offset distance for the attack collider placement (adjust as necessary)
			var attack_offset = 10 * direction  # 10 units away in the direction of movement
			
			# Adjust the attack collider position to be on the side the player is facing
			attack_position += attack_offset
			
			# Set the new position of the attack collider
			new_attack_collider.set_position(attack_position)
			
			# Add the attack collider to the scene
			get_parent().add_child(new_attack_collider)
		
		# Reset the attack_in_progress flag after the attack collider is instantiated
		attack_in_progress = false


func apply_friction(amount):
	if velocity.length() > amount:
		velocity -= velocity.normalized() * amount
	else:
		velocity = Vector2.ZERO


func apply_movement(amount):
	if GameManager.canMove: # if the player is allowed to move
		velocity += amount # Add amount to velocity
		velocity = velocity.limit_length(MAX_SPEED)
		# NOTE: Once RUN state's animation and shit has been implemented, ensure that this checks for if 
		# the player is running, and applies a higher velocity


func animate(): # Function that tells what node the animation tree should go to or be at
	state_machine.travel(animationTree_state_keys[state])
	animationTree.set(blen_pos_paths[state], blend_position)


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("Enemy"): # If an enemy of some kind's hitbox enters the player's hitbox
		print("An enemy entered HanTyumi's hitbox")
		SoundManager.playRandomHurtSoundFX() # play a randomized hurt sound effect
		flashRedWhiteRed() # Flash player red
		HealthManager.health -= 1
		print("Health is now: " + str(HealthManager.health))
		if HealthManager.health <= 0: # Change to dead state if health is <= 0
			SoundManager.playSoundFX(0, load("res://Assets/Sound/SFX/HanTyumi/Death/deathSound0.mp3"))
			state = DEAD

func go_to_death_screen():
	get_tree().change_scene_to_file("res://Scenes/UI/death_menu.tscn")


func changeToIdleState(): # Function that changes the current state to IDLE
	state = IDLE


func flashRedWhiteRed(): # NOTE: USES SHADER ON HAN'S ANIMATED SPRITE 2D NODE TO MAKE SPRITE CHANGE COLOR!!!
	# First flash: red
	$AnimatedSprite2D.material.set("shader_param/flash_color", Color(0.7, 0.2, 0.35, 0.5))
	$AnimatedSprite2D.material.set("shader_param/flash_strength", 1.0)
	await get_tree().create_timer(0.1).timeout
	
	# Second flash: white
	$AnimatedSprite2D.material.set("shader_param/flash_color", Color(1, 1, 1, 1))
	$AnimatedSprite2D.material.set("shader_param/flash_strength", 1.0)
	await get_tree().create_timer(0.1).timeout
	
	# Third flash: red again
	$AnimatedSprite2D.material.set("shader_param/flash_color", Color(0.7, 0.2, 0.35, 0.5))
	$AnimatedSprite2D.material.set("shader_param/flash_strength", 1.0)
	await get_tree().create_timer(0.1).timeout
	
	# Reset to normal
	$AnimatedSprite2D.material.set("shader_param/flash_strength", 0.0)
