extends Node


# Gold Tracking Variable
var gold = 0 # The amount of gold the player has 
# Pause State Tracking Variable
var isPaused = false # State tracking variable for if the game is currently paused
# State variable that tells the player if they are able to move (for minigames, cutscenes, ui, diaglogue, etc.)
var canMove = true
# State variable that tells the game if the player is currently in some dialogue
var inDialogue = false
# State variable that dictates if the shop GUI for the player should be displayed
var inShop = false
# Array to store Quest instances
var quests: Array = []
# Array to store Finished Quests
var finished_quests: Array = []



func _process(delta: float) -> void: # NOTE: DEBUG USE ONLY
	#print_child_nodes_with_sub_nodes()
	pass


# Toggles the global pause state variable (IMPORTANT)
func togglePauseState() -> void: 
	isPaused = !isPaused
	#print("GameManager | Toggle Pause State To: ", isPaused)


# Add a quest (creating a copy of the quest object)
func add_quest(quest: Quest) -> void:
	#print("Questing | Starting: ", quest.quest_name)
	var quest_copy = quest.duplicate()  # Create a copy of the quest
	quests.append(quest_copy)  # Store the copied quest in the array
	#print("Questing | Added quest: ", quest_copy.quest_name)


# Remove a quest from the array
func remove_quest(quest: Quest) -> void:
	if quests.has(quest):
		quests.erase(quest)  # Remove the quest from the array
		#print("Questing | Removed quest: ", quest.quest_name)
	else:
		#print("Questing | Quest not found when trying to remove it from quest list: ", quest.quest_name)
		pass


# Get the quest array/list
func get_quests() -> Array:
	return quests


func get_quest_status(quest_name: String): # Function that returns the status of a given quest instance
	if len(quests) > 0: # if there are any active quests
		var index = null
		var counter = 0
		for quest in quests: # iterate over the quests
			if quest_name in quest.quest_name:  # Ensure correct property name
				index = counter
				break
			counter += 1
		if index != null: # Check if index was found
			return quests[index].quest_status
		else:
			#print("Questing | Quest not found: ", quest_name)
			pass
	else:
		#print("Questing | No active quests to complete.")
		pass


# Finishes the given quest and removes it from the quests array
func finish_quest(quest_name: String) -> void:
	if len(quests) > 0: # if there are any active quests
		var index = null
		var counter = 0
		for quest in quests: # iterate over the quests
			if quest_name in quest.quest_name:  # Ensure correct property name
				index = counter
				break
			counter += 1
		if index != null: # Check if index was found
			if quests[index].has_method("finish_quest"):  # Ensure method exists
				finished_quests.append(quests[index]) # Append the finished quest to the finished_quests Array
				quests[index].finish_quest()  # Call the finish method (which will remove the quest from the global quests array)
			quests.erase(index) # Erase the quest at that index
			#print("Questing | ", quest_name, " Has Been Completed.")
		else:
			#print("Questing | Quest not found: ", quest_name)
			pass
	else:
		#print("Questing | No active quests to complete.")
		pass


# Completes the quest (goal reached state), DOES NOT remove the quest, DOES NOT finish the quest
func goal_reached(quest_name: String) -> void: 
	if len(quests) > 0: # if there are any active quests
		var index = null
		var counter = 0
		for quest in quests: # iterate over the quests
			if quest_name in quest.quest_name:  # Ensure correct property name
				index = counter
				break
			counter += 1
		if index != null: # Check if index was found
			if quests[index].has_method("finish_quest"):  # Ensure method exists
				quests[index].goal_reached()  # Call the finish method if it exists
			#print("Questing | ", quest_name, " Quest's Goal Has Been Reached.")
		else:
			#print("Questing | Quest not found: ", quest_name)
			pass
	else:
		#print("Questing | No active quests to complete.")
		pass

#
# Player movement Functions
#

func enablePlayerMovement() -> void: # Function that enables the player movement state variable
	#print("GameManager | Enabling Player Movement...")
	canMove = true

func disablePlayerMovement() -> void: # Function that enables the player movement state variable
	#print("GameManager | Disabling Player Movement...")
	canMove = false

#
# Node Functions
#
func print_node_tree() -> void:
	print("=================================")
	# Loop through each child of the root node
	for child in get_tree().root.get_children():
		# Print the name of the direct child node
		print("Child Node: ", child.name)


# Function to print each child node of the root and list all sub-nodes of each child
func print_child_nodes_with_sub_nodes() -> void:
	# Loop through each child of the root node
	for child in get_tree().root.get_children():
		# Print the name of the direct child node
		print("Child Node: ", child.name)
		
		# Check if this child has any sub-nodes
		if child.get_child_count() > 0:
			print("  Sub-nodes of ", child.name, ":")
			
			# Loop through each sub-node of the current child and print its name
			for sub_node in child.get_children():
				print("    ", sub_node.name)
		else:
			print("  No sub-nodes for ", child.name)
