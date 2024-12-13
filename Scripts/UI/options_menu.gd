extends Control


# References to UI elements
@onready var musicVolumeLabel = $CanvasLayer/MusicVolumeHBox/MusicVolumeLabel
@onready var masterVolumeLabel = $CanvasLayer/MasterVolumeHBox/MasterVolumeLabel
@onready var musicVolumeSlider = $CanvasLayer/MusicVolumeHBox/MusicVolumeSlider
@onready var masterVolumeSlider = $CanvasLayer/MasterVolumeHBox/MasterVolumeSlider

# Reference to sound volume for UI element updates
var musicVolume = null
var masterVolume = null


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	musicVolume = SoundManager.getMaxMusicVolume()
	musicVolumeSlider.value = musicVolume
	SoundManager.setNewMaxVolumeForMusic(musicVolumeSlider.value)
	#print("Options menu opening, volume should be: ", musicVolume)
	#print("Slider value after setting: ", musicVolumeSlider.value)
	# masterVolume = SoundManager.getMasterVolume() # NOTE: Not implemented yet


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_back_button_pressed() -> void:
	SoundManager.playRandomButtonClickSoundFX() # play the button click sound effect
	get_tree().change_scene_to_file("res://Scenes/UI/main_menu.tscn")


# When the music volume slider value is changed by the user
func _on_music_volume_slider_value_changed(value: float) -> void:
	SoundManager.setNewMaxVolumeForMusic(value) # Sets the music track volume using the value from the slider


# When the music volume slider has stopped being dragged
func _on_music_volume_slider_drag_ended(value_changed: bool) -> void:
	SoundManager.playRandomButtonClickSoundFX() # play a random button sound effect
