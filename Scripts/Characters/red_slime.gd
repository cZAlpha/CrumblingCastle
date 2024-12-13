extends CharacterBody2D


# Movement Variables
const ACCELERATION = 300 # The acceleration for the slime's movement
const MAX_SPEED = 30 # The maximum speed the slime can reach
const THRESHOLD_DISTANCE = 200 # Distance threshold for slime to start moving

# State Variables
enum {IDLE, DEAD} # All possible states
var state = IDLE # Instantiate the current state to be the idle state

# Animation Tree Variables
@onready var animationTree = $AnimationTree
@onready var state_machine = animationTree["parameters/playback"]
var blend_position : Vector2 = Vector2.ZERO # The position in the blendspace 2D matrix for animations
var blend_pos_paths = [
	"parameters/Idle/Idle_BS2D/blend_position",
	"parameters/Dead/Dead_BS2D/blend_position",
]
var animationTree_state_keys = [
	"Idle",
	"Dead"
]

# Health Variables
const MAX_HEALTH = 1 # Maximum health of the slime
var health = MAX_HEALTH # Current health of the slime

# Movement AI Variables
var player = null # Reference to the player, set to null until _ready() is called

# Gold Coin
var coin_scene: PackedScene

# Unique ID
@onready var id = generate_unique_id()

var quest: Quest


func _ready():
	# Assert coin scene's existence
	coin_scene = preload("res://Scenes/Items/GoldCoin/gold_coin.tscn")
	
	# Duplicate the shader used for red and white flash to ensure when ONE slime is hit,
	# not EVERY SINGLE SLIME flashes red and white
	if $AnimatedSprite2D.material:
		$AnimatedSprite2D.material = $AnimatedSprite2D.material.duplicate()
	
	# Assuming the player is already in the scene, get the reference
	var players = get_tree().get_nodes_in_group("Player")
	if players.size() > 0:
		player = players[0] # Assign the first player found to the variable
		#print("Player found: ", player)
	
	# Play the normal slime sound effect upon instantiation
	SoundManager.playSoundFX(id, load("res://Assets/Sound/SFX/Slime/slime-2-30099.mp3"))


func _physics_process(delta: float) -> void:
	# Check if the slime is dead and handle animation
	if state == DEAD:
		animate()
		$Area2D/Hitbox.disabled = true  # Disable the collision shape
		return
	else:
		$Area2D/Hitbox.disabled = false  # Disable the collision shape
		move(delta)
		animate()


func move(delta):
	if player: # Ensure the player reference is valid
		# Calculate the distance to the player
		var distance_to_player = global_position.distance_to(player.global_position)
		
		# Check if the player is within the threshold distance
		if distance_to_player < THRESHOLD_DISTANCE:
			# Calculate the direction to the player
			var direction_to_player = (player.global_position - global_position).normalized()
			
			# Update the blend position so animation depends on direction (IMPORTANT!)
			blend_position = direction_to_player
			
			# Apply movement towards the player
			velocity += direction_to_player * ACCELERATION * delta
			velocity = velocity.limit_length(MAX_SPEED) # Limit the velocity to MAX_SPEED
			
			# Update the position of the slime based on the velocity
			move_and_slide() # Move the slime while handling collisions
		# SOUND FX LOGIC
		if distance_to_player < (THRESHOLD_DISTANCE * 1.3):
			SoundManager.setSoundEffectVolume(id, -10)
		else:
			SoundManager.setSoundEffectVolume(id, SoundManager.getMinSoundFXVolume())


func animate():
	# Update the animation state based on the current state
	state_machine.travel(animationTree_state_keys[state])
	animationTree.set(blend_pos_paths[state], blend_position)


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("PlayerAttack") or area.is_in_group("Sword"): # Check for collision with the player's attacks
		if health == 1: # If the slime has no health left when attacked
			state = DEAD
		else: # Otherwise, decrement health variable
			health -= 1
		flashRedWhiteRed() # Flash red to indicate damage taken regardless of health status


func remove_slime():
	GameManager.finish_quest("Kill a Slime!")
	SoundManager.playRandomSlimeDeathSoundFX() # Plays a random slime death sound effect
	spawn_coins() # Spawns coins 
	queue_free() # Deletes the slime
	

func spawn_coins():
	var spawn_radius = 50
	var number_of_coins = randi() % 5 + 1
	
	for i in range(number_of_coins):
		var coin_instance = coin_scene.instantiate()
		var angle = randf() * TAU
		var distance = randf_range(0, spawn_radius)
		var final_offset = Vector2(cos(angle), sin(angle)) * distance

		# Set the initial position of the coin at the enemy's position
		coin_instance.position = position
		
		# Set the coin's target and initial velocity for outward arc
		coin_instance.final_position = position + final_offset
		coin_instance.initial_velocity = Vector2(cos(angle), sin(angle)) * randf_range(40, 80)
		
		# Set should_arc to true for animation
		coin_instance.should_arc = true

		# Add the coin to the scene
		get_tree().current_scene.add_child(coin_instance)


func flashRedWhiteRed(): # NOTE: USES SHADER ON ANIMATED SPRITE 2D NODE TO MAKE SPRITE CHANGE COLOR!!!
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


# Generate a unique ID based on ticks and randomness
func generate_unique_id() -> int:
	var time_based_id = Time.get_ticks_msec() # Current time in milliseconds
	var random_part = randi() % 10000  # Random part to ensure uniqueness
	return time_based_id + random_part
