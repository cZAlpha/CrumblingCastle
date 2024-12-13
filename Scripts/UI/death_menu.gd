extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$CanvasLayer/VBoxContainer/RespawnButton.grab_focus() # Put the keyboard control focus on the respawn button by default
	SoundManager.removeAllSoundEffects() # Stops all sound effects from playing


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float):
	pass


func _on_respawn_button_pressed(): # If respawn is pressed, reload the overworld scene
	HealthManager.health = HealthManager.MAX_HEALTH 
	SoundManager.playRandomButtonClickSoundFX() # play a random button sound effect
	get_tree().change_scene_to_file("res://Scenes/Levels/overworld.tscn")


func _on_main_menu_button_pressed() -> void:
	SoundManager.playRandomButtonClickSoundFX() # play a random button sound effect
	get_tree().change_scene_to_file("res://Scenes/UI/main_menu.tscn")
