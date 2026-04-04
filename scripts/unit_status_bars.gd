extends Control
class_name UnitStatusBars

const FRAME_ATLAS := preload("res://hp-shield-bar.png")
const FRAME_REGION := Rect2(187.0, 242.0, 1159.0, 466.0)
const HP_LANE_RECT := Rect2(264.0, 75.0, 786.0, 82.0)
const BLOCK_LANE_RECT := Rect2(264.0, 274.0, 778.0, 75.0)
const TWEEN_DURATION := 0.14

const HP_EMPTY_COLOR := Color(0.207843, 0.0705882, 0.0901961, 0.9)
const HP_FILL_COLOR := Color(0.901961, 0.278431, 0.298039, 0.96)
const BLOCK_EMPTY_COLOR := Color(0.0509804, 0.12549, 0.215686, 0.9)
const BLOCK_FILL_COLOR := Color(0.14902, 0.52549, 0.94902, 0.96)
const LABEL_COLOR := Color(0.988235, 0.964706, 0.905882, 1.0)
const LABEL_OUTLINE_COLOR := Color(0.0156863, 0.0196078, 0.0352941, 0.95)

@onready var hp_lane_background: ColorRect = %HPLaneBackground
@onready var hp_fill_clip: Control = %HPFillClip
@onready var hp_fill: ColorRect = %HPFill
@onready var hp_label: Label = %HPLabel
@onready var block_lane_background: ColorRect = %BlockLaneBackground
@onready var block_fill_clip: Control = %BlockFillClip
@onready var block_fill: ColorRect = %BlockFill
@onready var block_label: Label = %BlockLabel
@onready var frame_texture: TextureRect = %FrameTexture

var _frame_texture: AtlasTexture
var _fill_tween: Tween
var _current_hp: int = 0
var _max_hp: int = 1
var _current_block: int = 0
var _displayed_hp_ratio: float = 1.0
var _displayed_block_ratio: float = 0.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	_frame_texture = AtlasTexture.new()
	_frame_texture.atlas = FRAME_ATLAS
	_frame_texture.region = FRAME_REGION
	frame_texture.texture = _frame_texture

	hp_lane_background.color = HP_EMPTY_COLOR
	hp_fill.color = HP_FILL_COLOR
	block_lane_background.color = BLOCK_EMPTY_COLOR
	block_fill.color = BLOCK_FILL_COLOR

	_style_label(hp_label)
	_style_label(block_label)

	resized.connect(_refresh_layout)
	call_deferred("_refresh_layout")


func set_values(current_hp: int, max_hp: int, current_block: int, animate: bool = true) -> void:
	_current_hp = maxi(0, current_hp)
	_max_hp = maxi(1, max_hp)
	_current_block = maxi(0, current_block)

	hp_label.text = "%d / %d" % [_current_hp, _max_hp]
	block_label.text = str(_current_block)
	block_label.visible = _current_block > 0

	var hp_ratio: float = clampf(float(_current_hp) / float(_max_hp), 0.0, 1.0)
	var block_ratio: float = clampf(float(_current_block) / float(_max_hp), 0.0, 1.0)

	if _fill_tween:
		_fill_tween.kill()
		_fill_tween = null

	if animate and is_node_ready():
		_fill_tween = create_tween().set_parallel(true)
		_fill_tween.set_ease(Tween.EASE_OUT)
		_fill_tween.set_trans(Tween.TRANS_QUAD)
		_fill_tween.tween_method(_set_displayed_hp_ratio, _displayed_hp_ratio, hp_ratio, TWEEN_DURATION)
		_fill_tween.tween_method(_set_displayed_block_ratio, _displayed_block_ratio, block_ratio, TWEEN_DURATION)
	else:
		_set_displayed_hp_ratio(hp_ratio)
		_set_displayed_block_ratio(block_ratio)


func _style_label(label: Label) -> void:
	label.add_theme_color_override("font_color", LABEL_COLOR)
	label.add_theme_color_override("font_outline_color", LABEL_OUTLINE_COLOR)
	label.add_theme_constant_override("outline_size", 3)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE


func _set_displayed_hp_ratio(value: float) -> void:
	_displayed_hp_ratio = value
	_refresh_layout()


func _set_displayed_block_ratio(value: float) -> void:
	_displayed_block_ratio = value
	_refresh_layout()


func _refresh_layout() -> void:
	var frame_rect := _get_frame_rect()
	if frame_rect.size.x <= 0.0 or frame_rect.size.y <= 0.0:
		return

	frame_texture.position = frame_rect.position
	frame_texture.size = frame_rect.size

	var font_size := maxi(16, int(round(frame_rect.size.y * 0.12)))
	hp_label.add_theme_font_size_override("font_size", font_size)
	block_label.add_theme_font_size_override("font_size", font_size)

	_layout_lane(HP_LANE_RECT, hp_lane_background, hp_fill_clip, hp_fill, hp_label, _displayed_hp_ratio, frame_rect)
	_layout_lane(BLOCK_LANE_RECT, block_lane_background, block_fill_clip, block_fill, block_label, _displayed_block_ratio, frame_rect)


func _get_frame_rect() -> Rect2:
	var available_size := size
	if available_size.x <= 0.0 or available_size.y <= 0.0:
		available_size = custom_minimum_size
	if available_size.x <= 0.0 or available_size.y <= 0.0:
		return Rect2()

	var scale := minf(available_size.x / FRAME_REGION.size.x, available_size.y / FRAME_REGION.size.y)
	var scaled_size := FRAME_REGION.size * scale
	var offset := (available_size - scaled_size) * 0.5
	return Rect2(offset, scaled_size)


func _layout_lane(base_rect: Rect2, background: ColorRect, fill_clip: Control, fill_rect: ColorRect, label: Label, fill_ratio: float, frame_rect: Rect2) -> void:
	var scale := frame_rect.size / FRAME_REGION.size
	var lane_rect := Rect2(
		frame_rect.position + (base_rect.position * scale),
		base_rect.size * scale
	)

	background.position = lane_rect.position
	background.size = lane_rect.size

	fill_clip.position = lane_rect.position
	fill_clip.size = lane_rect.size
	fill_rect.position = Vector2.ZERO
	fill_rect.size = Vector2(lane_rect.size.x * fill_ratio, lane_rect.size.y)

	label.position = lane_rect.position
	label.size = lane_rect.size
