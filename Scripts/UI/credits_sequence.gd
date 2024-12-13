extends Control

# Title
@onready var musicTitle = $CanvasLayer/MusicCreditTitleLabel

# Music Covers
@onready var demo5and6 = $"CanvasLayer/MusicCoverImagesHBox/Demo5&6TextureRect"
@onready var official_bootlegger = $"CanvasLayer/MusicCoverImagesHBox/OfficialBootleggerTextureRect"
@onready var polygonwanaland = $"CanvasLayer/MusicCoverImagesHBox/PolygonwanalandCoverTextureRect"

# Music Labels
@onready var demo5and6_label = $"CanvasLayer/Demo5&6Label"
@onready var official_bootlegger_label = $CanvasLayer/OfficialBootleggerLabel
@onready var polygonwanaland_label = $CanvasLayer/Polygonwanaland


var fade_in_order = []
var fade_out_order = []
var fade_in_progress = 0.0
var fade_out_progress = 0.0
var current_fade_index = 0
var fade_speed = 0.7  # Adjust fade speed as desired
@export var state = "fade_in"  # States: "fade_in", "hold", "fade_out", "finished"
var hold_timer = 0.0
var hold_duration = 3.0 # Duration, in seconds, for the holding of 100% opacity during fade in and out sequence


func _ready() -> void:
	# Set initial transparency
	musicTitle.modulate.a = 0.0
	demo5and6.modulate.a = 0.0
	official_bootlegger.modulate.a = 0.0
	polygonwanaland.modulate.a = 0.0
	demo5and6_label.modulate.a = 0.0
	official_bootlegger_label.modulate.a = 0.0
	polygonwanaland_label.modulate.a = 0.0

	# Define the fade-in order
	fade_in_order = [musicTitle, demo5and6, demo5and6_label, official_bootlegger, official_bootlegger_label, polygonwanaland, polygonwanaland_label]
	# Fade out order is the same as the fade in order
	fade_out_order = fade_in_order

	# Ensure only the first texture starts fading in
	current_fade_index = 0

func _process(delta: float) -> void:
	if state == "fade_in":
		_handle_fade_in(delta)
	elif state == "hold":
		_handle_hold(delta)
	elif state == "fade_out":
		_handle_fade_out(delta)
	elif state == "finished":
		pass # Do nothing when finished

func _handle_fade_in(delta: float) -> void:
	if current_fade_index < fade_in_order.size():
		# Get the current texture to fade in
		var texture = fade_in_order[current_fade_index]
		fade_in_progress += fade_speed * delta
		texture.modulate.a = clamp(fade_in_progress, 0.0, 1.0)

		# If fully faded in, move to the next texture
		if fade_in_progress >= 1.0:
			fade_in_progress = 0.0
			current_fade_index += 1

	# If all textures are faded in, transition to "hold" state
	if current_fade_index >= fade_in_order.size():
		state = "hold"
		hold_timer = 0.0

func _handle_hold(delta: float) -> void:
	hold_timer += delta
	if hold_timer >= hold_duration:
		state = "fade_out"
		current_fade_index = 0
		fade_out_progress = 0.0

func _handle_fade_out(delta: float) -> void:
	if current_fade_index < fade_out_order.size():
		# Get the current texture to fade out
		var texture = fade_out_order[current_fade_index]
		fade_out_progress += fade_speed * delta
		texture.modulate.a = clamp(1.0 - fade_out_progress, 0.0, 1.0)

		# If fully faded out, move to the next texture
		if fade_out_progress >= 1.0:
			fade_out_progress = 0.0
			current_fade_index += 1

	# If all textures are faded out, stop the process
	if current_fade_index >= fade_out_order.size():
		state = "finished"
