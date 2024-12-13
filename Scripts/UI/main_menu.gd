extends Control


@onready var nowPlayingLabel = $CanvasLayer/NowPlaying # The label that shows the current song


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$CanvasLayer/VBoxContainer/DemoButton.grab_focus() # Make the cursor focus on the first button
	$CanvasLayer/VBoxContainer/DemoButton.grab_click_focus()
	#print("The main menu has been instantiated")
	if !SoundManager.isMusicPlaying(): # If a song ain't currently playing
		#print("No song was playing, so the main menu played a random song")
		SoundManager.playRandomSong() # Play a random song 
	SoundManager.removeAllSoundEffects() # Stops all sound effects from playing


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	showCurrentSong() # Display that song


func showCurrentSong():
	if nowPlayingLabel: # If the now playing label variable was instantiated correctly
		nowPlayingLabel.visible = true
		var currentSongName = SoundManager.getCurrentSong()
		if currentSongName: # If there was no error getting the curent song name
			if currentSongName != "-1": # If there is a valid song name
				nowPlayingLabel.text = "♫: " + currentSongName
			else: # If the error case of "-1" for song name
				nowPlayingLabel.text = "♫:"
				SoundManager.playRandomSong() # Play a random song
	else:
		print("ERROR: NowPlaying label could not be found or instantiated")


# SIGNALS
func _on_demo_button_pressed() -> void:
	SoundManager.playRandomButtonClickSoundFX() # play the button click sound effect
	get_tree().change_scene_to_file("res://Scenes/Levels/overworld.tscn")


func _on_options_button_pressed() -> void:
	SoundManager.playRandomButtonClickSoundFX() # play the button click sound effect
	get_tree().change_scene_to_file("res://Scenes/UI/options_menu.tscn")


func _on_exit_button_pressed() -> void:
	SoundManager.playRandomButtonClickSoundFX() # play the button click sound effect
	get_tree().quit()


func _on_skip_button_pressed() -> void:
	SoundManager.playRandomButtonClickSoundFX() # play the button click sound effect
	SoundManager.playRandomSong() # Play a random song
