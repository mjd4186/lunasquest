extends Control
class_name CardUI

signal drag_started(card: CardUI)
signal drag_moved(card: CardUI, mouse_position: Vector2)
signal drag_ended(card: CardUI, mouse_position: Vector2)
signal hover_changed(card: CardUI, is_hovering: bool)

const CARD_FRONT_TEXTURE := preload("res://card-front.png")
const CARD_BACK_TEXTURE := preload("res://card-back.png")
const DEFAULT_CARD_SIZE := Vector2(240, 360)
const DRAG_THRESHOLD := 10.0

@onready var shadow: ColorRect = %Shadow
@onready var frame_texture: TextureRect = %FrameTexture
@onready var art_texture_rect: TextureRect = %ArtTexture
@onready var cost_badge: PanelContainer = %CostBadge
@onready var cost_label: Label = %CostLabel
@onready var description_label: RichTextLabel = %DescriptionLabel
@onready var name_label: Label = %NameLabel

var card_data: Dictionary = {}
var card_index := -1
var face_down := false
var disabled := false
var draggable := true
var dragging := false
var hover_enabled := true

var _pressing := false
var _mouse_inside := false
var _press_origin := Vector2.ZERO
var _drag_offset := Vector2.ZERO
var _rest_position := Vector2.ZERO
var _rest_rotation := 0.0
var _rest_z_index := 0
var _move_tween: Tween


func _ready() -> void:
	resized.connect(_on_resized)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	if custom_minimum_size == Vector2.ZERO and size == Vector2.ZERO:
		set_display_size(DEFAULT_CARD_SIZE)
	else:
		if custom_minimum_size == Vector2.ZERO:
			custom_minimum_size = size
		if size == Vector2.ZERO:
			size = custom_minimum_size
		_on_resized()
	frame_texture.stretch_mode = TextureRect.STRETCH_SCALE
	art_texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	_apply_card_theme()
	_refresh()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and _can_drag():
		_pressing = true
		_press_origin = get_global_mouse_position()
		_drag_offset = _press_origin - global_position
		accept_event()


func _input(event: InputEvent) -> void:
	if _pressing and not dragging and event is InputEventMouseMotion:
		if get_global_mouse_position().distance_to(_press_origin) >= DRAG_THRESHOLD:
			_begin_drag()

	if dragging and event is InputEventMouseMotion:
		global_position = get_global_mouse_position() - _drag_offset
		drag_moved.emit(self, get_global_mouse_position())

	if (dragging or _pressing) and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		if dragging:
			_finish_drag()
		_pressing = false


func set_card_data(data: Dictionary) -> void:
	card_data = data.duplicate(true)
	if is_node_ready():
		_refresh()


func set_display_size(new_size: Vector2) -> void:
	custom_minimum_size = new_size
	size = new_size
	if is_node_ready():
		_on_resized()


func set_face_down(value: bool) -> void:
	face_down = value
	if is_node_ready():
		_refresh()


func set_disabled(value: bool) -> void:
	disabled = value
	if is_node_ready():
		_apply_enabled_state()


func set_hover_enabled(value: bool) -> void:
	hover_enabled = value


func set_rest_transform(new_position: Vector2, new_rotation: float, new_z_index: int, animated := true, delay := 0.0, duration := 0.18) -> void:
	_rest_position = new_position
	_rest_rotation = new_rotation
	_rest_z_index = new_z_index
	if is_node_ready():
		_apply_rest_transform(animated, delay, duration)


func is_dragging() -> bool:
	return dragging


func _begin_drag() -> void:
	_pressing = false
	dragging = true
	_kill_tween()
	z_index = 200
	rotation_degrees = 0.0
	scale = Vector2.ONE * 1.2
	drag_started.emit(self)
	drag_moved.emit(self, get_global_mouse_position())


func _finish_drag() -> void:
	dragging = false
	scale = Vector2.ONE
	drag_ended.emit(self, get_global_mouse_position())


func _can_drag() -> bool:
	return draggable and not disabled and not face_down


func _on_resized() -> void:
	if not is_node_ready():
		return
	pivot_offset = size * 0.5
	shadow.position = Vector2(10, 14)
	shadow.size = Vector2(maxf(0.0, size.x - 12.0), maxf(0.0, size.y - 18.0))
	_update_text_scale()


func _on_mouse_entered() -> void:
	if face_down or dragging or not hover_enabled:
		return
	_mouse_inside = true
	hover_changed.emit(self, true)
	_apply_rest_transform(true)


func _on_mouse_exited() -> void:
	if face_down or dragging or not hover_enabled:
		return
	_mouse_inside = false
	hover_changed.emit(self, false)
	if not dragging:
		_apply_rest_transform(true)


func _apply_card_theme() -> void:
	var badge_style := StyleBoxFlat.new()
	badge_style.bg_color = Color(0.109804, 0.07451, 0.0352941, 0.92)
	badge_style.border_color = Color(0.972549, 0.796078, 0.294118, 1.0)
	badge_style.set_border_width_all(2)
	badge_style.set_corner_radius_all(16)
	badge_style.shadow_color = Color(0, 0, 0, 0.35)
	badge_style.shadow_size = 6
	cost_badge.add_theme_stylebox_override("panel", badge_style)

	_style_text(description_label, 15, Color(0.956863, 0.917647, 0.784314, 1.0), Color(0, 0, 0, 1.0), 4)
	_style_text(name_label, 17, Color(0.278431, 0.172549, 0.0470588, 1.0), Color(1.0, 0.972549, 0.882353, 0.95), 2)
	_style_text(cost_label, 20, Color(1.0, 0.952941, 0.815686, 1.0), Color(0.160784, 0.0901961, 0.0235294, 1.0), 3)
	description_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.85))
	description_label.add_theme_constant_override("shadow_offset_x", 0)
	description_label.add_theme_constant_override("shadow_offset_y", 3)

	shadow.color = Color(0, 0, 0, 0.34)


func _style_text(label: Control, font_size: int, font_color: Color, outline_color: Color, outline_size: int) -> void:
	if label is RichTextLabel:
		var rich_label := label as RichTextLabel
		rich_label.add_theme_font_size_override("normal_font_size", font_size)
		rich_label.add_theme_font_size_override("bold_font_size", font_size)
		rich_label.add_theme_font_size_override("italics_font_size", font_size)
		rich_label.add_theme_color_override("default_color", font_color)
		rich_label.add_theme_color_override("font_outline_color", outline_color)
		rich_label.add_theme_constant_override("outline_size", outline_size)
		return

	var plain_label := label as Label
	plain_label.add_theme_font_size_override("font_size", font_size)
	plain_label.add_theme_color_override("font_color", font_color)
	plain_label.add_theme_color_override("font_outline_color", outline_color)
	plain_label.add_theme_constant_override("outline_size", outline_size)


func _update_text_scale() -> void:
	var scale_factor: float = clampf(size.y / DEFAULT_CARD_SIZE.y, 0.5, 1.2)
	var description_font_size := maxi(11, roundi(16 * scale_factor))
	description_label.add_theme_font_size_override("normal_font_size", description_font_size)
	description_label.add_theme_font_size_override("bold_font_size", description_font_size)
	description_label.add_theme_font_size_override("italics_font_size", description_font_size)
	name_label.add_theme_font_size_override("font_size", maxi(12, roundi(18 * scale_factor)))
	cost_label.add_theme_font_size_override("font_size", maxi(12, roundi(20 * scale_factor)))
	description_label.add_theme_constant_override("outline_size", maxi(3, roundi(4 * scale_factor)))
	description_label.add_theme_constant_override("shadow_offset_y", maxi(2, roundi(3 * scale_factor)))
	name_label.add_theme_constant_override("outline_size", maxi(1, roundi(2 * scale_factor)))
	cost_label.add_theme_constant_override("outline_size", maxi(1, roundi(3 * scale_factor)))


func _refresh() -> void:
	frame_texture.texture = CARD_BACK_TEXTURE if face_down else CARD_FRONT_TEXTURE

	var show_front_content := not face_down and not card_data.is_empty()
	var art_texture: Texture2D = card_data.get("art_texture", null)
	art_texture_rect.visible = show_front_content and art_texture != null
	art_texture_rect.texture = art_texture
	cost_badge.visible = show_front_content
	description_label.visible = show_front_content
	name_label.visible = show_front_content

	if not show_front_content:
		_apply_enabled_state()
		return

	cost_label.text = str(card_data.get("cost_label", card_data.get("cost", 0)))
	name_label.text = card_data.get("name", "")
	description_label.text = card_data.get("rich_text", card_data.get("text", ""))
	_apply_enabled_state()


func _apply_enabled_state() -> void:
	var fade := 0.65 if disabled else 1.0
	modulate = Color(fade, fade, fade, 1.0)

	if disabled:
		cost_label.add_theme_color_override("font_color", Color(1.0, 0.8, 0.8, 1.0))
	else:
		cost_label.add_theme_color_override("font_color", Color(1.0, 0.952941, 0.815686, 1.0))


func fly_to(target_pos: Vector2, target_rot: float, target_scl: Vector2, duration: float, delay := 0.0, callback: Callable = Callable()) -> void:
	draggable = false
	hover_enabled = false
	_kill_tween()
	_move_tween = create_tween().set_parallel(true)
	_move_tween.set_ease(Tween.EASE_IN_OUT)
	_move_tween.set_trans(Tween.TRANS_QUAD)
	_move_tween.tween_property(self, "position", target_pos, duration).set_delay(delay)
	_move_tween.tween_property(self, "rotation_degrees", target_rot, duration).set_delay(delay)
	_move_tween.tween_property(self, "scale", target_scl, duration).set_delay(delay)
	if callback.is_valid():
		_move_tween.finished.connect(callback)


func _apply_rest_transform(animated: bool, delay := 0.0, duration := 0.18) -> void:
	if dragging:
		return

	var target_position := _rest_position
	var target_rotation := _rest_rotation
	var target_scale := Vector2.ONE

	if _mouse_inside:
		target_position -= Vector2(0, 24)
		target_rotation = lerpf(_rest_rotation, 0.0, 0.5)
		target_scale = Vector2.ONE * 1.2
		z_index = maxi(_rest_z_index, 100)
	else:
		z_index = _rest_z_index

	if not animated:
		position = target_position
		rotation_degrees = target_rotation
		scale = target_scale
		return

	_kill_tween()
	_move_tween = create_tween().set_parallel(true)
	_move_tween.set_ease(Tween.EASE_OUT)
	_move_tween.set_trans(Tween.TRANS_BACK)
	_move_tween.tween_property(self, "position", target_position, duration).set_delay(delay)
	_move_tween.tween_property(self, "rotation_degrees", target_rotation, duration).set_delay(delay)
	_move_tween.tween_property(self, "scale", target_scale, duration).set_delay(delay)


func _kill_tween() -> void:
	if _move_tween and _move_tween.is_running():
		_move_tween.kill()
