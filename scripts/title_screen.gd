extends Control

const COMPOSITION_SIZE := Vector2(1920, 1080)
const MAIN_SCENE_PATH := "res://scenes/main.tscn"
const PROXIMITY_RADIUS := 210.0
const IDLE_BOUNCE_AMPLITUDE := 6.0
const IDLE_BOUNCE_SPEED := 1.1
const PROXIMITY_LIFT := 16.0
const MAX_PROXIMITY_SCALE := 1.14
const MAX_PROXIMITY_ROTATION := 1.5
const IDLE_DIM_ALPHA := 0.7
const IDLE_DIM_COLOR := 0.82

@onready var title_canvas: Control = %TitleCanvas
@onready var play_now_button: TextureButton = %PlayNowButton
@onready var bark_button: TextureButton = %BarkButton
@onready var bark_player: AudioStreamPlayer = %BarkPlayer

var _button_base_positions: Dictionary[String, Vector2] = {}
var _button_phase_offsets: Dictionary[String, float] = {}


func _ready() -> void:
	title_canvas.size = COMPOSITION_SIZE
	get_viewport().size_changed.connect(_on_viewport_size_changed)
	play_now_button.pressed.connect(_on_play_now_pressed)
	bark_button.pressed.connect(_on_bark_pressed)
	_store_button_defaults()
	_update_canvas_transform()


func _on_play_now_pressed() -> void:
	get_tree().change_scene_to_file(MAIN_SCENE_PATH)


func _on_bark_pressed() -> void:
	if bark_player.playing:
		bark_player.stop()
	bark_player.play()


func _process(_delta: float) -> void:
	_update_button_feedback(Time.get_ticks_msec() * 0.001)


func _update_canvas_transform() -> void:
	var viewport_size := get_viewport_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return

	var layout_scale := minf(
		viewport_size.x / COMPOSITION_SIZE.x,
		viewport_size.y / COMPOSITION_SIZE.y
	)
	title_canvas.scale = Vector2.ONE * layout_scale
	title_canvas.position = (viewport_size - (COMPOSITION_SIZE * layout_scale)) * 0.5


func _on_viewport_size_changed() -> void:
	_update_canvas_transform()


func _store_button_defaults() -> void:
	_button_base_positions[play_now_button.name] = play_now_button.position
	_button_base_positions[bark_button.name] = bark_button.position
	_button_phase_offsets[play_now_button.name] = 0.0
	_button_phase_offsets[bark_button.name] = 0.9
	play_now_button.pivot_offset = play_now_button.size * 0.5
	bark_button.pivot_offset = bark_button.size * 0.5


func _update_button_feedback(time_seconds: float) -> void:
	var canvas_mouse_position := title_canvas.get_local_mouse_position()
	_update_single_button(play_now_button, canvas_mouse_position, time_seconds)
	_update_single_button(bark_button, canvas_mouse_position, time_seconds)


func _update_single_button(button: TextureButton, canvas_mouse_position: Vector2, time_seconds: float) -> void:
	var base_position: Vector2 = _button_base_positions.get(button.name, button.position)
	var button_center := base_position + (button.size * 0.5)
	var distance_to_mouse := canvas_mouse_position.distance_to(button_center)
	var proximity := clampf(1.0 - (distance_to_mouse / PROXIMITY_RADIUS), 0.0, 1.0)
	if button.get_rect().has_point(button.get_local_mouse_position()):
		proximity = 1.0

	var phase_offset: float = _button_phase_offsets.get(button.name, 0.0)
	var bounce_wave := sin((time_seconds * TAU * IDLE_BOUNCE_SPEED) + phase_offset)
	var bounce_offset := bounce_wave * (IDLE_BOUNCE_AMPLITUDE + (proximity * 2.0))
	var lift_offset := proximity * PROXIMITY_LIFT
	button.position = base_position + Vector2(0.0, bounce_offset - lift_offset)

	var target_scale := lerpf(1.0, MAX_PROXIMITY_SCALE, proximity)
	button.scale = Vector2.ONE * target_scale

	var direction := signf(canvas_mouse_position.x - button_center.x)
	button.rotation_degrees = bounce_wave * 0.7 + (direction * proximity * MAX_PROXIMITY_ROTATION)
	var brightness := lerpf(IDLE_DIM_COLOR, 1.0, proximity)
	var alpha := lerpf(IDLE_DIM_ALPHA, 1.0, proximity)
	button.modulate = Color(brightness, brightness, brightness, alpha)
