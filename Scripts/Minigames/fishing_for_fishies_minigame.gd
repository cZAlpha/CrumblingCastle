extends Node2D


# References to game UI elements
@onready var fish = $Game/Fish
@onready var hook = $Game/Hook
@onready var fishingProgressBar = $Game/FishingProgressBar

# "Gravity" variables
@export var fishSpeed = 1400 # Pixels per delta
@export var hookSpeed = 4000 # Pixels per delta

# Game logic variables
var gameComplete = false # The state variable that dictates if the game has been finished
var onHook = false # Hold the state of if the fish is on the hook or not
var progressMultiplier = 20 # The multiplier for progress per delta frame of the progress bar


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if fish and hook and fishingProgressBar:
		#print("Fishing For Fishies Minigame | All elements are loaded correctly")
		pass
	else:
		#print("Fishing For Fishies Minigame | ERROR: At least one element was not loaded correctly")
		pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !gameComplete:
		# Check if the player has won
		if fishingProgressBar.value >= fishingProgressBar.max_value: # if the progress bar has been maxed out
			gameComplete = true # Swap the game completion state variable
			GameManager.enablePlayerMovement() # Swap player's ability to move state
			GameManager.goal_reached("Fishing for Fishies") # Set the state of the Fishing for Fishies! quest to be goal_reached
			queue_free() # Delete the minigame when you win
		
		# Handle hook movement using velocity
		hook.velocity = Vector2(0, hookSpeed * delta)  # Default downward movement
		if Input.is_action_pressed("space"): # If the space bar was pressed
			hook.velocity.y = -hookSpeed * delta  # Move the hook up when space is pressed
		# Apply movement with collision handling
		hook.move_and_slide()
		
		# Move the fish
		fish.velocity.y = fishSpeed * delta  # Apply gravity to velocity
		var fishCollision = fish.move_and_slide()  # Move fish with collision
		if fishCollision: # Check for fish collision with boundaries, reverse direction of the fish if collision occurs
			fishSpeed = -fishSpeed  # Reverse gravity to make fish bounce back
		
		# Increase the progress of the completion bar if the fish is on the hook
		if fishingProgressBar.value <= fishingProgressBar.max_value and fishingProgressBar.value >= fishingProgressBar.min_value:
			if onHook:
				fishingProgressBar.value += progressMultiplier * delta 
				#print("Fishing for Fishies Minigame | Incrementing progress to: ", fishingProgressBar.value)
			else:
				fishingProgressBar.value -= (progressMultiplier / 3) * delta
				#print("Fishing for Fishies Minigame | Decrementing progress to: ", fishingProgressBar.value)
	else: # If the game has been completed
		GameManager.goal_reached("Fishing For Fishies") # Game manager checks if the Fishing for Fishies quest is active, and goal completes it if so


# When the fish enters the hook area
func _on_hook_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("Fish"):
		#print("Fishing for Fishies Minigame | Fish on!")
		onHook = true


# When the fish exits teh hook area
func _on_hook_area_2d_area_exited(area: Area2D) -> void:
	if area.is_in_group("Fish"):
		#print("Fishing for Fishies Minigame | Fish off")
		onHook = false
