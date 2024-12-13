extends Node2D


# NOTE: isPaused is a local version of the global paused variable held within the GameManager (ik its horrible structure, but i simply do not care lmfao)
var isPaused = false

# References to entities
@onready var hanTyumi = $Entities/HanTyumi
@onready var MiraNPC = $Entities/NPCs/MiraNPC
@onready var merchantNPC = $Entities/Merchant
@onready var HeinrichNPC = $Entities/NPCs/Heinrich

# State variables
var fishing = false # State variable to track if the fishing for fishies minigame is currently active

# General NPC Variables
var playerToNPCQuestCompletionThresholdDistance = 30

# State variables for MiraNPC
var hasMetMira = false # State variable to track if the player has spoken with MiraNPC before
var miraNPCRudenessMeter = 0 # State variable to track if the player was rude in their dialogue with MiraNPC
var startedMiraNPCFireQuest = false # State variable to track if the player has started the find the fire quest from MiraNPC to ensure they can't do it more than once
var goalReachedMiraNPCFireQuest = false # State variable to track if the player has finished the goal of the find the fire quest from MiraNPC to ensure that there isn't console clutter from errors from the GameManager
var finishedMiraNPCFireQuest = false # State variable to track if the player has finished the find the fire quest from MiraNPC to ensure that there isn't console clutter from errors from the GameManager
var fireQuestMarkerDistanceThreshold = 80
@onready var fireQuestMarker0 = $Entities/NPCs/Markers/MiraNPCMarkers/MiraNPCQuestMarkers/MiraNPCFireQuestMarker0
@onready var fireQuestMarker1 = $Entities/NPCs/Markers/MiraNPCMarkers/MiraNPCQuestMarkers/MiraNPCFireQuestMarker1

# State variables for HeinrichNPC
var hasMetHeinrich = false
var heinrichNPCRudenessMeter = 0 # Mood meter for heinrichNPC
var startedHeinrichNPCFishingForFishiesQuest = false # Keeps track of the status of whether the player has started Heinrich's 'Fishing for Fishies' quest

# State variables for MerchantNPC
var merchantNPCRudenessMeter = 0
var hasMetMerchant = false

# Fishing for fishies minigame variables
@onready var minigame = load("res://Scenes/Minigames/fishing_for_fishies_minigame.tscn")
@onready var minigame_instance = minigame.instantiate()


func _ready() -> void:
	# NOTE: FOR TESTING ONLY print("Overworld | Pause state is: ", GameManager.isPaused, " upon instantiation.")
	pass


func _process(delta: float):
	# Pausing the game 
	if Input.is_action_just_pressed("settings"): # If the settings button was pressed
		swapPause()
		SoundManager.playSoundFX(0, load("res://Assets/Sound/SFX/UI/Interface/pauseAndUnpause.mp3")) # Play the pause/unpause sound effect
	setPause() # Sets the current pause state to the Game Manager's pause state
	
	handleMiraFireQuest() # Handles quest management for the Mira Fire Quest
	handleHeinrichFishingForFishiesQuest()


func setPause() -> void: # Sets the current pause state to the Game Manager's pause state
	isPaused = GameManager.isPaused
	if !isPaused: # if the game is currently paused
		get_tree().paused = false
		isPaused = false
	else: # if the game is not paused
		get_tree().paused = true
		isPaused = true


func swapPause():
	GameManager.togglePauseState() # Toggle the global pause state
	if isPaused: # if the game is currently paused
		get_tree().paused = false
		isPaused = false
	else: # if the game is not paused
		get_tree().paused = true
		isPaused = true


func _exit_tree() -> void:
	# Unpause the game when this node is deleted
	get_tree().paused = false
	GameManager.isPaused = false # Reset the global pause state variable to false, matching the world
	exit_fishing_minigame() # Exits the fishing for fishies minigame


# If an area enters the dock area
func _on_dock_area_2d_area_entered(area: Area2D) -> void:
	print("Overworld | Player has entered the dock area")
	# Checks if the player has the fishing for fishies quest active
	var hasFishingForFishiesQuest = false
	for quest in GameManager.get_quests():
		if quest.quest_name == "Fishing for Fishies":
			hasFishingForFishiesQuest = true
	
	if area.is_in_group("Player") and hasFishingForFishiesQuest and hanTyumi and !fishing: # if the player enters the dock area and has the fishing for fishies quest
		print("Overworld | Starting Fishing for Fishies minigame!")
		# Swap state to indicate that minigame is in progress
		fishing = true
		# Swap player's ability to move state
		GameManager.disablePlayerMovement()
		# Load and instantiate the fishing minigame
		var minigame_instance_position = hanTyumi.position
		minigame_instance.set_position(minigame_instance_position) # Sets the position of the minigame instance
		get_tree().root.add_child(minigame_instance) # Add the minigame as a child of the player


# If an area exits the dock area
func _on_dock_area_2d_area_exited(area: Area2D) -> void:
	if area.is_in_group("Player"): # If the player exits the dock
		GameManager.enablePlayerMovement() # Enable the player to move
		exit_fishing_minigame()


func exit_fishing_minigame() -> void:
	fishing = false # swap state variable for minigame
	if minigame_instance in get_tree().root.get_children(): # if the minigame exists in the tree
		get_tree().root.remove_child(minigame_instance) # remove the minigame


func handleMiraFireQuest() -> void: # Function that handles quest management for Mira's fire quest 
	if startedMiraNPCFireQuest and !goalReachedMiraNPCFireQuest and fireQuestMarker0 and fireQuestMarker1 and hanTyumi: # If the player has the fire quest from MiraNPC active
		# Calculate the distance between the marker and the player
		var current_distance0 = fireQuestMarker0.global_position.distance_to(hanTyumi.global_position)
		var current_distance1 = fireQuestMarker1.global_position.distance_to(hanTyumi.global_position)
		if current_distance0 <= fireQuestMarkerDistanceThreshold or current_distance1 <= fireQuestMarkerDistanceThreshold: # If the player is close to the fires, finish the quest
			GameManager.goal_reached("Find the Fires")
			goalReachedMiraNPCFireQuest = true
	if goalReachedMiraNPCFireQuest and !finishedMiraNPCFireQuest: # If the player has reached the goal of the fire quest from MiraNPC but HAS NOT FINISHED IT
		var current_distance_to_MiraNPC = hanTyumi.global_position.distance_to(MiraNPC.global_position)
		if current_distance_to_MiraNPC < playerToNPCQuestCompletionThresholdDistance:
			GameManager.finish_quest("Find the Fires")
			finishedMiraNPCFireQuest = true


func handleHeinrichFishingForFishiesQuest() -> void: # Function that handles quest management of Heinrich's Fishing for Fishies Quest
	if startedHeinrichNPCFishingForFishiesQuest and GameManager.get_quest_status("Fishing for Fishies") == Quest.QuestStatus.reached_goal: # If the player has caught the fish already
		var heinrichDistanceToPlayer = HeinrichNPC.global_position.distance_to(hanTyumi.global_position)
		if heinrichDistanceToPlayer <= playerToNPCQuestCompletionThresholdDistance:
			GameManager.finish_quest("Fishing for Fishies")




#
# DIALOGUE FUNCTIONS
#

func gameManagerSwapInDialogue() -> void: # Function that swaps the current state of the 'inDialogue' variable
	GameManager.inDialogue = !GameManager.inDialogue

# MIRANPC SPECIFIC DIALOGUE FUNCTIONS

func startMiraFireQuest():
	if !MiraNPC: # Error check to see if MiraNPC was found
		print("Overworld Error | startMiraQuest | MiraNPC not found! Check path.")
		return
	if !MiraNPC.quest: # Error check to see if MiraNPC has a quest
		print("Overworld Error | startMiraQuest | MiraNPC does not contain a quest!")
		return
	MiraNPC.quest.start_quest() # Start the quest that the MiraNPC contains
	startedMiraNPCFireQuest = true # Tracks the player's start of the quest


func metMira(): # Function that swaps the state of the hasMetMira state variable to indicate that the player has met MiraNPC
	hasMetMira = true


func incrementMiraNPCRudenessMeter(): # Function that increments the variable that keeps track of how many times you were rude to MiraNPC
	MiraNPC.incrementRudenessMeter()
	miraNPCRudenessMeter += 1


func decrementMiraNPCRudenessMeter(): # Function that dencrements the variable that keeps track of how many times you were rude to MiraNPC
	if miraNPCRudenessMeter <= 0:
		miraNPCRudenessMeter = 0 # Ensure that rudenss meter does not go below 0
		print("Overworld Error | incrementMiraNPCRudenessMeter | Cannot decrement miraNPCRudenessMeter below 0")
		return
	MiraNPC.decrementRudenessMeter()
	miraNPCRudenessMeter -= 1 # If no error, decrement the rudeness meter for MiraNPC


# HEINRICH NPC SPECIFIC DIALOGUE FUNCTIONS

func startHeinrichFishingForFishiesQuest():
	if !HeinrichNPC: # Error check to see if MiraNPC was found
		print("Overworld Error | startHeinrichFishingForFishiesQuest | HeinrichNPC not found! Check path.")
		return
	if !HeinrichNPC.quest: # Error check to see if MiraNPC has a quest
		print("Overworld Error | startHeinrichFishingForFishiesQuest | HeinrichNPC does not contain a quest!")
		return
	HeinrichNPC.quest.start_quest() # Start the quest that the HeinrichNPC contains
	startedHeinrichNPCFishingForFishiesQuest = true # Tracks the player's start of the quest


func metHeinrich(): # State variable changing function for when the player first meets Heinrich NPC
	hasMetHeinrich = true


func incrementHeinrichNPCRudenessMeter(): # Function that increments the variable that keeps track of how many times you were rude to MiraNPC
	HeinrichNPC.incrementRudenessMeter()
	heinrichNPCRudenessMeter += 1


func decrementHeinrichNPCRudenessMeter(): # Function that increments the variable that keeps track of how many times you were rude to Heinrich
	if heinrichNPCRudenessMeter <= 0:
		heinrichNPCRudenessMeter = 0 # Ensure that rudenss meter does not go below 0
		print("Overworld Error | incrementMiraNPCRudenessMeter | Cannot decrement miraNPCRudenessMeter below 0")
		return
	HeinrichNPC.decrementRudenessMeter()
	heinrichNPCRudenessMeter -= 1 # If no error, decrement the rudeness meter


# MERCHANT NPC SPECIFIC DIALOGUE FUNCTIONS

func toggleShopGUI(): # Function that toggles the visibility of the shop gui for the player (using the status of a state variable)
	GameManager.inShop = !GameManager.inShop
	print("Overworld | toggleShopGUI | Function has run, inShop = ", GameManager.inShop)


func metMerchant(): # Function that swaps the state of the hasMetMerchant state variable to indicate that the player has met the Merchant
	hasMetMerchant = true


func incrementMerchantNPCRudenessMeter(): # Function that increments the variable that keeps track of how many times you were rude to MiraNPC
	merchantNPC.incrementRudenessMeter()
	merchantNPC += 1


func decrementMerchantNPCRudenessMeter(): # Function that dencrements the variable that keeps track of how many times you were rude to MiraNPC
	if merchantNPC <= 0:
		merchantNPC = 0 # Ensure that rudenss meter does not go below 0
		print("Overworld Error | incrementMerchantNPCRudenessMeter | Cannot decrement merchantNPCRudenessMeter below 0")
		return
	merchantNPC.decrementRudenessMeter()
	merchantNPC -= 1 # If no error, decrement the rudeness meter for MiraNPC
