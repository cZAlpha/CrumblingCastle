class_name QuestManager extends Node


@export_group("Quest Settings")
@export var quest_name: String # The name for the quest
@export var quest_description: String # The main description for the quest
@export var reached_goal_text: String # The text displayed for the quest after the goal of the quest has been achieved

enum QuestStatus { # Enum object called QuestStatus that holds all possible quest status'
	available,
	started,
	reached_goal,
	finished
}

# Quest status
@export var quest_status: QuestStatus = QuestStatus.available

@export_group("Quest Reward Settings")
@export var reward_amount: int # The amount of gold you get from completing the quest



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
