class_name Quest extends QuestManager


# When the player starts the quest
func start_quest() -> void:
	if quest_status == QuestManager.QuestStatus.available: # Check if the quest is available
		quest_status = QuestManager.QuestStatus.started # Update the quest's status
		SoundManager.playRandomQuestStartedSoundFX()
		GameManager.add_quest(self) # Add the current quest to the quest list


# When the player reaches the goal of the quest
func goal_reached() -> void: 
	if quest_status == QuestManager.QuestStatus.started: # Make sure the quest has been started
		SoundManager.playRandomQuestGoalReachedSoundFX()
		quest_status = QuestManager.QuestStatus.reached_goal # Updates the quest's status 


# When the player finishes the quest
func finish_quest() -> void:
	if quest_status == QuestManager.QuestStatus.started or quest_status == QuestManager.QuestStatus.reached_goal: # Makes sure that the quest has been completed
		SoundManager.playRandomQuestFinishedSoundFX()
		GameManager.remove_quest(self) # Delete the current quest out of the quest list after completion
		GameManager.gold += reward_amount # Give the player gold for completing the quest
		print("Questing | ", reward_amount, " gold has been rewarded")


# =========================
# NODE FINDING FUNCTIONS
# =========================

func find_node(root: Node, target_name: String) -> Node:
	# Check if the current root node is the target node
	if root.name == target_name:
		return root
	
	# Loop through each child of the root node
	for child in root.get_children():
		# Recursively search within each child node
		var result = find_node(child, target_name)
		if result != null:
			return result
	
	# Return null if the node is not found in this branch
	return null


func is_node_in_tree(root: Node, target_name: String) -> bool:
	# Check if the root node itself matches the target name
	if root.name == target_name:
		return true
	
	# Iterate over all children of the root node
	for child in root.get_children():
		# Recursively check each child node
		if is_node_in_tree(child, target_name):
			return true
	
	# If no match was found in this branch, return false
	return false

# Function to print each child node of the root and list all sub-nodes of each child
func print_child_nodes_with_sub_nodes(root: Node) -> void:
	# Loop through each child of the root node
	for child in root.get_children():
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
