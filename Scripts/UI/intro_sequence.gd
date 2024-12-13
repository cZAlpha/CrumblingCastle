extends Control


# Intro sequence - Sub sequence Variables
	# Preloads
var studioSequence = preload("res://Scenes/UI/studio_sequence.tscn")
var jdcivSequence = preload("res://Scenes/UI/jdciv_sequence.tscn")
var creditsSequence = preload("res://Scenes/UI/credits_sequence.tscn")
	# Local State Variables
var studioStateLocal
var jdcivStateLocal
var creditsStateLocal
	# Instances
var studioSequenceInstance
var jdcivSequenceInstance
var creditsSequenceInstance

# Main menu variables
var mainMenu = preload("res://Scenes/UI/main_menu.tscn")
var mainMenuInstance


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Instantiate the sequence scenes and main menu scene
	studioSequenceInstance = studioSequence.instantiate()
	jdcivSequenceInstance = jdcivSequence.instantiate()
	creditsSequenceInstance = creditsSequence.instantiate()
	mainMenuInstance = mainMenu.instantiate()
	
	# Set local state variables on startup
	studioStateLocal = studioSequenceInstance.state
	jdcivStateLocal = jdcivSequenceInstance.state
	creditsStateLocal = creditsSequenceInstance.state
	
	# Ensure position is at origin
	studioSequenceInstance.position = Vector2.ZERO 
	jdcivSequenceInstance.position = Vector2.ZERO
	creditsSequenceInstance.position = Vector2.ZERO 
	
	# Add studio sequence as a child node immediately to start intro process
	add_child(studioSequenceInstance)


func _process(delta: float) -> void:
	# Update local state variables
	studioStateLocal = studioSequenceInstance.state
	jdcivStateLocal = jdcivSequenceInstance.state 
	creditsStateLocal = creditsSequenceInstance.state
	
	# Control flow
	if studioStateLocal == "finished": # If studio sequence has finished, remove it from tree and add credits sequence
		remove_child(studioSequenceInstance)
		add_child(jdcivSequenceInstance) 
	if studioStateLocal == "finished" and jdcivStateLocal == "finished":
		remove_child(jdcivSequenceInstance)
		add_child(creditsSequenceInstance) 
	if studioStateLocal == "finished" and jdcivStateLocal == "finished" and creditsStateLocal == "finished": # If both sub-sequences have finished
		remove_child(creditsSequenceInstance) # Remove the credits seqeuence
		get_tree().change_scene_to_file("res://Scenes/UI/main_menu.tscn")
	
	# USER INPUT HANDLING FOR SKIPPING INTRO SEQUENCE
	if Input.is_action_pressed("settings") or Input.is_action_just_pressed("attack") or Input.is_action_just_pressed("interact"):
		remove_child(creditsSequenceInstance) 
		remove_child(creditsSequenceInstance)
		print("IntroSequenece | Skip Button Has Been Pressed")
		get_tree().change_scene_to_file("res://Scenes/UI/main_menu.tscn")
