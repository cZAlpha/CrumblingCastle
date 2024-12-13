extends Control


# JDCIV Iconography Variables
@onready var IVTextureRect = $JDCIVCanvasLayer/IVTextureRect
@onready var topColorRect = $JDCIVCanvasLayer/TopColorRect
@onready var bottomColorRect = $JDCIVCanvasLayer/BottomColorRect

# Animation properties
var fade_duration = 3.0 # Duration for fading in and out
var hold_duration = 2.0 # Duration for holding the IVTextureRect fully visible
var elapsed_time = 0.0 # Tracks the elapsed time
var state = "fade_in" # Animation state: fade_in, hold, fade_out
var interpolationTravelDistance = 200 # Distance that the linear interpolation of the color rects will move in pixels


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Ensure initial states of the elements
	IVTextureRect.modulate.a = 0 # Fully transparent
	topColorRect.position.x = 0
	topColorRect.position.y = 0
	bottomColorRect.position.x = 0
	bottomColorRect.position.y = 540


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	match state:
		"fade_in":
			_fade_in(delta)
		"hold":
			_hold(delta)
		"fade_out":
			_fade_out(delta)
		"finished":
			pass


func _fade_in(delta: float) -> void:
	elapsed_time += delta
	if elapsed_time <= fade_duration:
		IVTextureRect.modulate.a = elapsed_time / fade_duration
		topColorRect.position.y = lerp(0, -interpolationTravelDistance, elapsed_time / fade_duration)
		bottomColorRect.position.y = lerp(540, 540+interpolationTravelDistance, elapsed_time / fade_duration)
	else:
		elapsed_time = 0.0
		state = "hold"


func _hold(delta: float) -> void:
	elapsed_time += delta
	if elapsed_time <= hold_duration:
		IVTextureRect.modulate.a = 1
	else:
		elapsed_time = 0.0
		state = "fade_out"


func _fade_out(delta: float) -> void:
	elapsed_time += delta
	if elapsed_time <= fade_duration:
		IVTextureRect.modulate.a = 1 - (elapsed_time / fade_duration)
	else:
		state = "finished"
