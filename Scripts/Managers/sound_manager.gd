extends Node

 
# References to all shit pertaining to the playing of music through the sound manager
var music
@export var musicVolumeDB = -40 # The default volume of the music
@export var fadeSpeed = 5
@onready var dummy_player = AudioStreamPlayer.new() # Instantiate a new audio player
var isFading = false # Var used to keep track of if the audio player is fading
var MUSIC_MAX_VOLUME_DB = -40 # The maximum volume that any audiostreamplayer can play at, this value is what is changed through the options menu
var MUSIC_MIN_VOLUME_DB = -80
var rng = RandomNumberGenerator.new() # Instantiate a new random number generator
# Also shit for the music player
var song_paths = [
	"res://Assets/Sound/Music/Bootlegs/King Gizz - Tezeta.mp3",
	"res://Assets/Sound/Music/Bootlegs/King Gizz - BIT BIT BIT BIT BIT.mp3",
	"res://Assets/Sound/Music/Bootlegs/King Gizz - Horology.mp3",
	"res://Assets/Sound/Music/Bootlegs/King Gizz - Moses.mp3",
	"res://Assets/Sound/Music/Bootlegs/King Gizz - Most of What I Like.mp3",
	"res://Assets/Sound/Music/Bootlegs/King Gizz - Music To Think Existentially To.mp3",
	"res://Assets/Sound/Music/Bootlegs/King Gizz - Scared of Christmas.mp3",
	"res://Assets/Sound/Music/Polygondwanaland/King Gizz - Crumbling Castle.mp3",
	"res://Assets/Sound/Music/Polygondwanaland/King Gizz - Loyalty.mp3",
	"res://Assets/Sound/Music/Polygondwanaland/King Gizz - Searching.mp3",
	"res://Assets/Sound/Music/Polygondwanaland/King Gizz - Tetrachromacy.mp3"
]

# References for sound FX audio player stuff
var sound_fx_players = {}
@export var soundFXVolumeDB = -30 # The default volume of the music
var SOUNDFX_MAX_VOLUME_DB = -30 # The maximum volume that any audiostreamplayer can play at, this value is what is changed through the options menu
var SOUNDFX_MIN_VOLUME_DB = -80
# All slime death sound effects
var slime_death_soundFX_list = [
	"res://Assets/Sound/SFX/Slime/Death/slime-splatter-7-220269.mp3",
	"res://Assets/Sound/SFX/Slime/Death/slime-squish-4-218568.mp3",
	"res://Assets/Sound/SFX/Slime/Death/slime-squish-5-218569.mp3"
]
# All button click sound effects
var button_click_soundFX_list = [
	"res://Assets/Sound/SFX/UI/Buttons/buttonClick0.mp3",
	"res://Assets/Sound/SFX/UI/Buttons/buttonClick1.mp3"
]
# All hurt sound effects
var hurt_soundFX_list = [
	"res://Assets/Sound/SFX/HanTyumi/Hurt/hurtSound0.mp3",
	"res://Assets/Sound/SFX/HanTyumi/Hurt/hurtSound1.mp3"
]
# Quest Sound effects lists
	# Quest Started Sound FX List
var quest_started_soundFX_list = [
	"res://Assets/Sound/SFX/UI/questSoundFX/questStartSoundFX0.mp3"
]
	# Quest Goal Reached Sound FX List
var quest_goal_reached_soundFX_list = [
	"res://Assets/Sound/SFX/UI/questSoundFX/questGoalReachedSoundFX0.mp3"
]
	# Quest Finished Sound FX List
var quest_finished_soundFX_list = [
	"res://Assets/Sound/SFX/UI/questSoundFX/questFinishedSoundFX0.mp3"
]


func _ready():
	#print("Sound Manager Startup...")
	music = $"/root/SoundManager"/Music  # Reference to the music audio stream player node
	if !music:
		print("Error: Music node not found in _ready()")
		return
	if musicVolumeDB < MUSIC_MIN_VOLUME_DB or musicVolumeDB > MUSIC_MAX_VOLUME_DB:  # Volume must be between -80 and 0 dB
		print("Error: Invalid musicVolumeDB amount.")
		return
	music.volume_db = musicVolumeDB
	add_child(dummy_player) # Add the dummy player to the parent node
	dummy_player.volume_db = MUSIC_MIN_VOLUME_DB # Set the dummy player's volume to low
	
	# NOTE: For testing only
	#print("Initial Volume: ", music.volume_db)
	#playRandomSong() # Play a random song on startup
	#printSoundEffectDictionary()
	#print("Sound Manager Startup Complete")


func _process(delta: float):
	# DEBUGGING PRINT STATEMENT ONLY
	# print("Main Track VolDB: ", music.volume_db, " Aux Vol: ", dummy_player.volume_db)
	# printSoundEffectDictionary()
	
	if isFading: # If the player is fading
		music.volume_db -= fadeSpeed * delta # Fade out the current sound's volume
		dummy_player.volume_db += fadeSpeed * delta # Fade in the new sound's volume
		if dummy_player.volume_db >= MUSIC_MAX_VOLUME_DB: # if the dummy player is playing
			music.stream = dummy_player.stream # Set the curr song to the new song on the music player
			music.volume_db = floori(dummy_player.volume_db) # Set the curr song volume db to the volume db of the dummy player
			music.play(dummy_player.get_playback_position()) # Play the song from the dummmy player at the exact same position
			dummy_player.volume_db = MUSIC_MIN_VOLUME_DB # Mute the dummy player
			dummy_player.stop() # Stop the dummy player
			isFading = false # Set the fading state to false
	else: # If not currently fading tracks
		music.volume_db = MUSIC_MAX_VOLUME_DB # Ensure that the main track is playing at max volume
		dummy_player.volume_db = MUSIC_MIN_VOLUME_DB # Set the dummy player volume to zero if not fading


func playSong(stream: AudioStream):
	# This function will play a given song and if a song is currently playing 
	# and the function is called again, it will smoothly crossfade in the new song
	if music.stream: # If the player is currently playing something
		print("SoundManager | playSong | Playing song: ", stream.resource_path)
		isFading = true # Switch the state to make the cross fade start
		dummy_player.stream = stream # Set the wanted song 
		dummy_player.volume_db = MUSIC_MIN_VOLUME_DB # Set the volume to be low
		dummy_player.play() # Play the dummy player
	else: # If there is no song playing, play a song like normal
		if music:
			music.stream = stream
			music.volume_db = musicVolumeDB
			music.play()
			if stream.resource_path:
				print("SoundManager | Playing song: ", stream.resource_path)
		else:
			print("SoundManager Error | playSong | Music node not found when trying to play")


func getCurrentSong() -> String: # Returns the filename of the current song playing, otherwise -1 for error
	if music.is_playing(): # If there is a song currently playing
		var full_filename = music.stream.resource_path.get_file()
		var dot_index = full_filename.rfind(".") # Find the index of the last "." in the name
		if dot_index != -1:
			return full_filename.substr(0, dot_index)  # Return the substring before the last dot
		else:
			return full_filename    
	else:
		return "-1"


func get_song_length(audio_player: AudioStreamPlayer) -> float: # Returns the length of the song currently playing
	if music.is_playing(): # if there is a song currently playing
		return audio_player.stream.get_length()
	return -1.0  # Return -1 if there's no stream or it's not a valid AudioStream


func get_current_song_position(audio_player: AudioStreamPlayer) -> float: # Returns the current position in seconds that the audioplayer is at
	return music.get_playback_position()


func playRandomSong() -> void: # Plays a random song from the song_paths array
	var randomIndex = rng.randf_range(0, (len(song_paths)-1))
	playSong(load(song_paths[randomIndex]))


func setNewMaxVolumeForMusic(newVolumeDB) -> void: # Sets the current volume and the max volume for music tracks
	if not isFading: # If not currently fading music tracks
		music.volume_db = newVolumeDB # Main track volume 
		MUSIC_MAX_VOLUME_DB = newVolumeDB # Set the max volume


func getMusicVolume() -> int: # Returns the current music volume in decibels
	return musicVolumeDB


func getMaxMusicVolume() -> int: # Returns the current maxiumum volume for the music player in decibels
	return MUSIC_MAX_VOLUME_DB


func getMinMusicVolume() -> int: # Returns the current minimum volume for the music player in decibels
	return MUSIC_MIN_VOLUME_DB


func isMusicPlaying() -> bool: # Returns true if music is currently playing on the music player, false if not
	if music.stream:
		return true
	else:
		return false


#====================================================================================================================================
# SOUND FX FUNCTIONS
#====================================================================================================================================

func playSoundFX(id: int, stream: AudioStream) -> void:
	if stream == null:
		print("SoundManager Error | ID: ", id, " | Sound effect stream is null.")
		return
	
	if id == 0:  # Check for id == 0 and randomize id if it is 0
		id = generate_unique_id()  # Generates a random and unique ID
		var max_retries = 100  # Limit the number of retries to avoid potential infinite loops
		var retries = 0
		
		# Repeatedly make a new unique id if it's already in the dictionary
		while id in sound_fx_players.keys() and retries < max_retries:
			id = generate_unique_id()
			retries += 1
			
		if retries == max_retries:
			print("SoundManager Warning | Reached maximum retries for generating a unique ID")
	
	# Check if a player with this ID already exists and remove it
	if sound_fx_players.has(id):
		print("SoundManager Error | CONFLICTING ID, REMOVING ID: ", id)
		sound_fx_players[id].queue_free()
		sound_fx_players.erase(id)
	
	# Create a new AudioStreamPlayer instance for the sound effect
	var sfx_player = AudioStreamPlayer.new()
	sfx_player.stream = stream
	sfx_player.volume_db = soundFXVolumeDB
	add_child(sfx_player)
	
	# Store the player in the dictionary with the ID as the key
	sound_fx_players[id] = sfx_player
	sfx_player.play()
	
	# Remove after playback
	var timer = Timer.new()
	timer.wait_time = sfx_player.stream.get_length()
	timer.one_shot = true
	add_child(timer)
	timer.timeout.connect(Callable(sfx_player.queue_free))
	timer.connect("timeout", Callable(self, "_remove_sound_effect_player").bind(id))
	timer.start()



func _on_sound_fx_finished(id: int) -> void:
	if sound_fx_players.has(id):
		sound_fx_players[id].queue_free()  # Free the AudioStreamPlayer instance
		sound_fx_players.erase(id)  # Remove from dictionary


func setSoundEffectVolume(id: int, volumeDB: int) -> void:
	if sound_fx_players.has(id):
		var sfx_player = sound_fx_players[id]
		
		# Check if the player is still valid (not freed)
		if is_instance_valid(sfx_player):
			sfx_player.volume_db = volumeDB
		else:
			pass
			#print("Error: Sound effect player with ID ", id, " is no longer valid (it may have been freed).")
	else:
		pass
		#print("Error: Sound effect with ID: ", id, " not found.")


func getSoundFXVolume() -> int: # Returns the current sound fx volume in decibels
	return soundFXVolumeDB


func getMaxSoundFXVolume() -> int: # Returns the current sound fx max volume in decibels
	return SOUNDFX_MAX_VOLUME_DB


func getMinSoundFXVolume() -> int: # Returns the current sound fx minimum volume in decibels
	return SOUNDFX_MIN_VOLUME_DB


func playRandomSlimeDeathSoundFX() -> void: # Plays a random slime death sound effect
	var randomIndex = rng.randf_range(0, (len(slime_death_soundFX_list)-1))
	playSoundFX(0, load(slime_death_soundFX_list[randomIndex]))


func playRandomButtonClickSoundFX() -> void: # Plays a random button click sound effect
	var randomIndex = rng.randf_range(0, (len(button_click_soundFX_list)-1))
	playSoundFX(0, load(button_click_soundFX_list[randomIndex]))


func playRandomHurtSoundFX() -> void: # Plays a random hurt sound effect
	var randomIndex = rng.randf_range(0, (len(hurt_soundFX_list)-1))
	playSoundFX(0, load(hurt_soundFX_list[randomIndex]))


func playRandomQuestStartedSoundFX() -> void: # Plays a random quest started sound FX 
	var randomIndex = rng.randf_range(0, (len(quest_started_soundFX_list)-1))
	playSoundFX(0, load(quest_started_soundFX_list[randomIndex]))


func playRandomQuestGoalReachedSoundFX() -> void: # Plays a random quest goal reached sound FX
	var randomIndex = rng.randf_range(0, (len(quest_goal_reached_soundFX_list)-1))
	playSoundFX(0, load(quest_goal_reached_soundFX_list[randomIndex]))


func playRandomQuestFinishedSoundFX() -> void: # Plays a random quest finished sound FX
	var randomIndex = rng.randf_range(0, (len(quest_finished_soundFX_list)-1))
	playSoundFX(0, load(quest_finished_soundFX_list[randomIndex]))


# Generate a unique ID based on ticks and randomness
func generate_unique_id() -> int:
	var time_based_id = Time.get_ticks_msec() # Current time in milliseconds
	var random_part = randi() % 10000  # Random part to ensure uniqueness
	return time_based_id + random_part


func printSoundEffectDictionary(): # Prints the entire sound effects dictionary contents
	print("=========================================")
	print("SoundManager | printSoundEffectDictionary")
	if len(sound_fx_players.keys()) > 0: # if there are any active sound effects
		print("Sound Effect Dict Start")
		for soundEffect in sound_fx_players.keys():
			print(soundEffect)
		print("Sound Effect Dict End")
	else:
		print("There are no sound effects currently playing")
	print("=========================================")


func removeAllSoundEffects():
	# Iterate through all currently playing sound effects and stop them
	for player in sound_fx_players.values():
		if is_instance_valid(player):  # Check if the player instance is valid
			if player.is_playing():  # Check if the player is currently playing sound
				player.stop()  # Stop the sound effect if it's playing
		else:
			print("SoundManager Warning | removeAllSoundEffects | A sound player is no longer valid.")
	
	# Clear the dictionary to remove all references to the sound effects
	sound_fx_players.clear()
