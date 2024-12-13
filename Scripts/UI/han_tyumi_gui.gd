extends Node2D


# Gameplay UI Reference
@onready var gameplayGUI = $"./GamePlayGUI"
# Gold UI References
@onready var goldLabel = $"./GamePlayGUI/GoldHBoxContainer/GoldLabel"
# Health UI References
@onready var heart0 = $"./GamePlayGUI/HeartHBoxContainer/Heart0"
@onready var heart1 = $"./GamePlayGUI/HeartHBoxContainer/Heart1"
@onready var heart2 = $"./GamePlayGUI/HeartHBoxContainer/Heart2"
@onready var heart3 = $"./GamePlayGUI/HeartHBoxContainer/Heart3"
@onready var heart4 = $"./GamePlayGUI/HeartHBoxContainer/Heart4"
# Quest UI References
@onready var questVBoxContainer = $"./GamePlayGUI/QuestVBoxContainer"
@onready var questTitleLabel = $"./GamePlayGUI/QuestVBoxContainer/QuestTitleLabel"
@onready var questDescriptionLabel = $"./GamePlayGUI/QuestVBoxContainer/QuestDescriptionLabel"

# Settings GUI Variables
@onready var settingsGUI = $"./SettingsGUI"
@onready var settingsBG = $"./SettingsGUI/SettingsBG"
@onready var musicVolumeLabel = $"./SettingsGUI/SettingsVBoxContainer/ButtonsVBoxContainer/MusicVolumeHBoxContainer/MusicVolumeLabel"
@onready var musicVolumeSlider = $"./SettingsGUI/SettingsVBoxContainer/ButtonsVBoxContainer/MusicVolumeHBoxContainer/MusicVolumeHSlider"
# Settings Menu Quest UI Elements
@onready var questTabContainer = $SettingsGUI/QuestListVBoxContainer/QuestTabContainer
@onready var activeQuestsLabel = $SettingsGUI/QuestListVBoxContainer/QuestTabContainer/Active/ActiveQuestsLabel
@onready var goalCompletedQuestLabel = $SettingsGUI/QuestListVBoxContainer/QuestTabContainer/Completed/GoalCompletedQuestsLabel
@onready var finishedQuestsLabel = $SettingsGUI/QuestListVBoxContainer/QuestTabContainer/Finished/FinishedQuestsLabel
# Reference to sound volume for UI element updates
var musicVolume = null
var masterVolume = null

# Shop GUI Variables
@onready var shopGUI = $ShopGUI
@onready var shopGoldLabel = $ShopGUI/ShopGUIBG/ShopGUIReferenceRect/PlayersideReferenceRect/PlayerGoldReferenceRect/GoldLabel


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	musicVolume = SoundManager.getMaxMusicVolume()
	if musicVolumeSlider and musicVolume: # If the references to needed elements are not NULL
		musicVolumeSlider.value = musicVolume
		SoundManager.setNewMaxVolumeForMusic(musicVolumeSlider.value)
	else:
		print("HanTyumi's GUI | Music Volume Slider Reference is NULL and/or incorrect")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Ensuring the correct visibility of the settings and shop menus
	toggleSettingsAndShopMenus()
	# Update the health UI hearts
	updateHearts()
	# Update the main quest UI elements (only the normal gameplay quest UI, NOT SETTINGS MENU)
	updateMainQuest()
	# Update the settings menu quest UI elements
	updateSettingsQuests()
	# Update Gold UI Element
	updateGold()
	if Input.is_action_just_pressed("settings") and GameManager.inShop: # If the player is in the shop and hits the settings buttons
		closeShopGUI()


func updateHearts() -> void: # Function that updates the hearts on the UI using the healthmanager
	# GUI Health Handling
	var health = HealthManager.health # Reference to the health of the player
	# Update hearts based on current health
	
	# Zero Health
	if health <= 0: # Turn all hearts inactive
		if heart0: heart0.play('inactive')
		if heart1: heart1.play('inactive')
		if heart2: heart2.play('inactive')
		if heart3: heart3.play('inactive')
		if heart4: heart4.play('inactive')

	# Health level 1: Turn only the first heart on
	if health == 1:
		if heart0: heart0.play('active')
		if heart1: heart1.play('inactive')
		if heart2: heart2.play('inactive')
		if heart3: heart3.play('inactive')
		if heart4: heart4.play('inactive')

	# Health level 2: Turn the first two hearts on
	if health == 2:
		if heart0: heart0.play('active')
		if heart1: heart1.play('active')
		if heart2: heart2.play('inactive')
		if heart3: heart3.play('inactive')
		if heart4: heart4.play('inactive')

	# Health level 3: Turn the first three hearts on
	if health == 3:
		if heart0: heart0.play('active')
		if heart1: heart1.play('active')
		if heart2: heart2.play('active')
		if heart3: heart3.play('inactive')
		if heart4: heart4.play('inactive')

	# Health level 4: Turn the first four hearts on
	if health == 4:
		if heart0: heart0.play('active')
		if heart1: heart1.play('active')
		if heart2: heart2.play('active')
		if heart3: heart3.play('active')
		if heart4: heart4.play('inactive')

	# Health level 5: Turn all hearts on
	if health == 5:
		if heart0: heart0.play('active')
		if heart1: heart1.play('active')
		if heart2: heart2.play('active')
		if heart3: heart3.play('active')
		if heart4: heart4.play('active')

	# Health overflow check
	if health > 5:
		print("GUI ERROR: HEALTH TOO HIGH!")


func updateGold() -> void: # Function that handles gold UI updates
	var gold = GameManager.gold # Reference to the current # of coins the player possesses
	if goldLabel: goldLabel.text = str(gold)
	if shopGoldLabel: shopGoldLabel.text = str(gold)


func updateMainQuest() -> void: # Function that updates the quest UI elements
	var currentQuest = null
	if GameManager.quests and len(GameManager.quests) > 0:
		currentQuest = GameManager.quests[0]
	else: # If there are no active quests
		questTitleLabel.text = "" # Blank out the labels
		questDescriptionLabel.text = ""
	if currentQuest: # If there is a quest currently undertaken by the player
		if currentQuest.quest_status == QuestManager.QuestStatus.started: # If the quest has been started but NOT completed
			questTitleLabel.text = str(currentQuest.quest_name)
			questDescriptionLabel.text = str(currentQuest.quest_description)
		if currentQuest.quest_status == QuestManager.QuestStatus.reached_goal: # If the quest has been completed but NOT finishes
			questTitleLabel.text = "Completed: " + str(currentQuest.quest_name)
			questDescriptionLabel.text = str(currentQuest.reached_goal_text)


func updateSettingsQuests() -> void:
	# Clear existing labels
	activeQuestsLabel.text = ""
	goalCompletedQuestLabel.text = ""
	finishedQuestsLabel.text = "" # Assuming you have a label for finished quests as well

	# Populate active quests and goal completed quests
	var hasActiveQuest = false
	var hasGoalCompletedQuest = false
	if GameManager.quests.size() > 0:
		for quest in GameManager.quests:
			if quest.quest_status == Quest.QuestStatus.started:
				hasActiveQuest = true # State that there has been an active quest found
				var questName = quest.quest_name
				var questDescription = quest.quest_description
				activeQuestsLabel.text += questName + "\n"
				activeQuestsLabel.text += "    " + questDescription + "\n"
				activeQuestsLabel.text += "-------------------------------------------------" + "\n"
				#print("Han's GUI | Active Quest: ", questName, " : ", questDescription)
			elif quest.quest_status == Quest.QuestStatus.reached_goal:
				hasGoalCompletedQuest = true # State that there has been a goal completed quest found
				var questName = quest.quest_name
				var questGoalCompletedText = quest.reached_goal_text
				goalCompletedQuestLabel.text += questName + "\n"
				goalCompletedQuestLabel.text += "    " + questGoalCompletedText + "\n"
				goalCompletedQuestLabel.text += "-------------------------------------------------" + "\n"
				#print("Han's GUI | Goal Completed Quest: ", questName, " : ", questGoalCompletedText)
		if !hasActiveQuest: # if the player does not have an active quest BUT DOES HAVE a quest in the quests array (from GameManager)
			activeQuestsLabel.text = "No active quests"
		if !hasGoalCompletedQuest: # if the player does not have a goal completed quest BUT DOES HAVE a quest in the quests array (from GameManager)
			goalCompletedQuestLabel.text = "No goal completed quests"
	else:
		activeQuestsLabel.text = "No active quests"
		goalCompletedQuestLabel.text = "No goal completed quests"
	
	# Populate finished quests
	if GameManager.finished_quests.size() > 0:
		for finishedQuest in GameManager.finished_quests:
			var finishedQuestName = finishedQuest.quest_name
			var finishedQuestDescription = finishedQuest.quest_description
			finishedQuestsLabel.text += finishedQuestName + "\n"
			finishedQuestsLabel.text += "    " + finishedQuestDescription + "\n"
			finishedQuestsLabel.text += "-------------------------------------------------" + "\n"
				
			#print("Han's GUI | Finished Quest: ", finishedQuest.quest_name)
	# If no quests are found, ensure labels are cleared
	else:
		finishedQuestsLabel.text = "No finished quests"


func toggleSettingsAndShopMenus() -> void: # Function that toggles the visibility of the shop menu
	var inShop = GameManager.inShop
	var isPaused = GameManager.isPaused
	if !inShop and !isPaused: # If the player is not in any menus
		if settingsGUI: settingsGUI.visible = false
		if gameplayGUI: gameplayGUI.visible = true
		if shopGUI: shopGUI.visible = false
		GameManager.canMove = true
	elif inShop and !isPaused: # If in the shop and not paused
		if settingsGUI: settingsGUI.visible = false
		if gameplayGUI: gameplayGUI.visible = false
		if shopGUI: shopGUI.visible = true
		GameManager.canMove = false # Disable player movement when in shop menu
	elif isPaused: # If paused (regardless of other status')
		if settingsGUI: settingsGUI.visible = true
		if gameplayGUI: gameplayGUI.visible = false
		if shopGUI: shopGUI.visible = false
		GameManager.canMove = false # Disable player movement when pausedGameManager.canMove = true


func closeShopGUI() -> void: # Function that closes the shop GUI
	GameManager.inShop = false # Forcefully ensure that the inShop state variable is false when closing the shop GUI
	var isPaused = GameManager.isPaused
	if isPaused: # If the game was paused
		if settingsGUI: settingsGUI.visible = true
		if gameplayGUI: gameplayGUI.visible = false
		if shopGUI: shopGUI.visible = false
		GameManager.canMove = true
	else: # If the game is not paused
		if settingsGUI: settingsGUI.visible = false
		if gameplayGUI: gameplayGUI.visible = true
		if shopGUI: shopGUI.visible = false
		GameManager.canMove = true


func _on_main_menu_button_pressed() -> void: # A function that goes to the main menu
	GameManager.togglePauseState() # Toggles the pause state
	SoundManager.playRandomButtonClickSoundFX() # play the button click sound effect
	get_tree().change_scene_to_file("res://Scenes/UI/main_menu.tscn") # Change current scene to main menu


func _on_music_volume_h_slider_value_changed(value: float) -> void:
		SoundManager.setNewMaxVolumeForMusic(value) # Sets the music track volume using the value from the slider


#
# Quest Related Functions
#


func setQuestTitle(questName: String) -> void: # Function that sets the label that represents the quest title
	if len(questName) > 3: # Length check (pause)
		if questTitleLabel: questTitleLabel.text = questName


func removeQuestTitle() -> void: # Function that removes the current quests' title
	if questTitleLabel: questTitleLabel.text = "" # Remove the text from it


func makeQuestVisible(isVisible: bool) -> void:
	if questVBoxContainer: questVBoxContainer.visible = isVisible


#
# Node Related Functions
#


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
