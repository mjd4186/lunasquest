extends Control

const STARTING_HP := 28
const MONSTER_STARTING_HP := 40
const HAND_SIZE := 5
const COURAGE_PER_TURN := 3

const CARD_UI_SCENE := preload("res://scenes/card_ui.tscn")
const ICON_HEART := preload("res://assets/icons/lucide/heart.svg")
const ICON_SHIELD := preload("res://assets/icons/lucide/shield.svg")
const ICON_SPARKLES := preload("res://assets/icons/lucide/sparkles.svg")
const ICON_MOON_STAR := preload("res://assets/icons/lucide/moon-star.svg")
const COMPOSITION_SIZE := Vector2(1920, 1080)
const BASE_PREVIEW_CARD_SIZE := Vector2(280, 420)
const BASE_PILE_CARD_SIZE := Vector2(156, 234)
const BASE_HAND_CARD_SIZE := Vector2(208, 312)
const CARD_ART_DIRECTORY := "res://cardart"
const CARD_ART_EXTENSIONS := ["png", "jpg"]
const END_TURN_BUTTON_SIZE := Vector2(188, 64)
const HAND_SIDE_PADDING := 32.0
const HAND_CARD_OVERLAP := 0.72
const HAND_FAN_ROTATION := 11.0
const HAND_FAN_ARC := 48.0
const HAND_BASE_LIFT := 12.0

@onready var combat_canvas: Control = %CombatCanvas
@onready var title_label: Label = %TitleLabel
@onready var flavor_label: Label = %FlavorLabel
@onready var monster_name_label: Label = %MonsterName
@onready var preview_title_label: Label = %PreviewTitleLabel
@onready var preview_card_anchor: CenterContainer = %PreviewCardAnchor
@onready var draw_pile_card_anchor: CenterContainer = %DrawPileCardAnchor
@onready var discard_pile_card_anchor: CenterContainer = %DiscardPileCardAnchor
@onready var player_hp_label: Label = %PlayerHPLabel
@onready var player_courage_label: Label = %PlayerCourageLabel
@onready var player_block_label: Label = %PlayerBlockLabel
@onready var player_name_label: Label = %PlayerName
@onready var player_status_label: Label = %PlayerStatusLabel
@onready var player_buffs_label: Label = %PlayerBuffsLabel
@onready var monster_hp_label: Label = %MonsterHPLabel
@onready var monster_block_label: Label = %MonsterBlockLabel
@onready var monster_status_label: Label = %MonsterStatusLabel
@onready var monster_buffs_label: Label = %MonsterBuffsLabel
@onready var intent_label: Label = %IntentLabel
@onready var turn_label: Label = %TurnLabel
@onready var draw_pile_label: Label = %DrawPileLabel
@onready var discard_pile_label: Label = %DiscardPileLabel
@onready var play_area: PanelContainer = %PlayArea
@onready var play_instruction_label: Label = %PlayInstructionLabel
@onready var hand_area: Control = %HandArea
@onready var end_turn_button: Button = %EndTurnButton
@onready var log_label: RichTextLabel = %LogLabel
@onready var reset_button: Button = %ResetButton
@onready var pile_hover_panel: PanelContainer = %PileHoverPanel
@onready var pile_hover_label: Label = %PileHoverLabel
@onready var monster_stage_label: Label = %MonsterStageLabel
@onready var monster_emoji_label: Label = %MonsterEmojiLabel

@onready var title_panel: PanelContainer = %TitlePanel
@onready var monster_panel: PanelContainer = %MonsterPanel
@onready var intent_panel: PanelContainer = %IntentPanel
@onready var player_panel: PanelContainer = %PlayerPanel
@onready var log_panel: PanelContainer = %LogPanel
@onready var log_title_label: Label = get_node("CombatCanvas/RightColumn/LogPanel/LogMargin/LogVBox/LogTitle")

var rng := RandomNumberGenerator.new()

var player_hp := STARTING_HP
var player_courage := COURAGE_PER_TURN
var player_block := 0
var monster_hp := MONSTER_STARTING_HP
var monster_block := 0

var player_statuses := {
	"weak": 0,
	"frail": 0,
}

var monster_statuses := {
	"vulnerable": 0,
}

var draw_pile: Array[Dictionary] = []
var discard_pile: Array[Dictionary] = []
var hand: Array[Dictionary] = []
var player_buffs: Array[Dictionary] = []
var monster_buffs: Array[Dictionary] = []

var turn_number := 1
var current_turn := "player"
var pending_intent: Dictionary = {}
var battle_over := false

var hand_card_views: Array[CardUI] = []
var preview_card_view: CardUI
var draw_pile_card_view: CardUI
var discard_pile_card_view: CardUI

var hand_signature := ""
var hovered_card_index := -1
var pinned_preview_card: Dictionary = {}
var pinned_preview_title := "Hover a card"
var play_area_idle_style: StyleBoxFlat
var play_area_hover_style: StyleBoxFlat
var play_area_valid_style: StyleBoxFlat
var layout_scale := 1.0
var preview_card_size := BASE_PREVIEW_CARD_SIZE
var pile_card_size := BASE_PILE_CARD_SIZE
var hand_card_size := BASE_HAND_CARD_SIZE
var hovered_pile := ""
var card_art_textures: Dictionary = {}


func _ready() -> void:
	rng.randomize()
	combat_canvas.size = COMPOSITION_SIZE
	get_viewport().size_changed.connect(_on_viewport_size_changed)
	hand_area.resized.connect(_on_hand_area_resized)
	end_turn_button.pressed.connect(_on_end_turn_pressed)
	reset_button.pressed.connect(_on_reset_button_pressed)

	_create_static_card_views()
	_apply_visual_theme()
	_install_lucide_icons()
	_apply_fixed_layout_metrics()
	_update_canvas_transform()
	_start_battle()
	call_deferred("_update_canvas_transform")


func _start_battle() -> void:
	player_hp = STARTING_HP
	player_courage = COURAGE_PER_TURN
	player_block = 0
	monster_hp = MONSTER_STARTING_HP
	monster_block = 0
	player_statuses = {"weak": 0, "frail": 0}
	monster_statuses = {"vulnerable": 0}
	player_buffs = _build_starting_player_buffs()
	monster_buffs = _build_starting_monster_buffs()
	turn_number = 1
	current_turn = "player"
	battle_over = false
	hand_signature = ""
	hovered_card_index = -1
	hovered_pile = ""
	pinned_preview_card.clear()
	pinned_preview_title = "Hover a card"
	pile_hover_panel.visible = false
	log_label.clear()
	title_label.text = "Scared Little Dog vs. The Dark Hallway"
	flavor_label.text = "Every creak sounds enormous. Every shadow looks hungry."
	monster_name_label.text = "The Dark Hallway"
	player_name_label.text = "The Little Dog"
	monster_stage_label.text = "The Dark Hallway"

	draw_pile = _build_starting_deck()
	discard_pile.clear()
	hand.clear()
	_shuffle(draw_pile)
	roll_monster_intent()
	add_log("The little dog pads into the hallway. The dark stares back.")
	start_player_turn()


func _build_starting_deck() -> Array[Dictionary]:
	var deck: Array[Dictionary] = []
	var yip: Dictionary = {
		"name": "Yip!",
		"type": "attack",
		"cost": 1,
		"damage": 6,
		"text": "Deal 6 damage.",
	}
	var cower: Dictionary = {
		"name": "Cower",
		"type": "block",
		"cost": 1,
		"block": 5,
		"text": "Gain 5 block.",
	}
	var peek_around_corner: Dictionary = {
		"name": "Peek Around Corner",
		"type": "skill",
		"cost": 2,
		"damage": 7,
		"block": 7,
		"text": "Deal 7 damage and gain 7 block.",
	}
	var find_courage: Dictionary = {
		"name": "Find Courage",
		"type": "skill",
		"cost": 0,
		"draw": 2,
		"block": 2,
		"text": "Gain 2 block. Draw 2 cards.",
	}
	var favorite_sweater: Dictionary = {
		"name": "Favorite Sweater",
		"type": "buff",
		"cost": 2,
		"text": "Fight buff: At the start of your turn, gain 2 block.",
		"buff_data": {
			"name": "Favorite Sweater",
			"text": "At the start of your turn, gain 2 block.",
			"block_on_turn_start": 2,
		},
	}
	var calming_drops: Dictionary = {
		"name": "Calming Drops",
		"type": "buff",
		"cost": 1,
		"text": "Fight buff: At the start of your turn, gain 1 courage.",
		"buff_data": {
			"name": "Calming Drops",
			"text": "At the start of your turn, gain 1 courage.",
			"courage_on_turn_start": 1,
		},
	}
	var squeaky_hedgehog: Dictionary = {
		"name": "Squeaky Hedgehog",
		"type": "buff",
		"cost": 2,
		"text": "Fight buff: Your attacks deal 1 extra damage.",
		"buff_data": {
			"name": "Squeaky Hedgehog",
			"text": "Your attacks deal 1 extra damage.",
			"attack_bonus": 1,
		},
	}
	var card_templates: Array[Dictionary] = [
		yip,
		cower,
		peek_around_corner,
		find_courage,
		favorite_sweater,
		calming_drops,
		squeaky_hedgehog,
	]
	_ensure_card_art_library(card_templates)
	deck.append_array(_make_copies(yip, 5))
	deck.append_array(_make_copies(cower, 4))
	deck.append_array(_make_copies(peek_around_corner, 2))
	deck.append_array(_make_copies(find_courage, 1))
	deck.append_array(_make_copies(favorite_sweater, 1))
	deck.append_array(_make_copies(calming_drops, 1))
	deck.append_array(_make_copies(squeaky_hedgehog, 1))
	return deck


func _build_starting_player_buffs() -> Array[Dictionary]:
	return []


func _build_starting_monster_buffs() -> Array[Dictionary]:
	return [
		{
			"name": "Shadow Teeth",
			"text": "Its attacks deal 2 extra damage.",
			"attack_bonus": 2,
		},
		{
			"name": "Cold Draft",
			"text": "At the start of its turn, strip 3 block from the little dog.",
			"shred_block_on_turn_start": 3,
		},
	]


func _make_copies(card: Dictionary, amount: int) -> Array[Dictionary]:
	var copies: Array[Dictionary] = []
	for i in amount:
		copies.append(_decorate_card(card))
	return copies


func _ensure_card_art_library(card_templates: Array[Dictionary]) -> void:
	_load_card_art_textures(card_templates)


func _card_slug_for(card: Dictionary) -> String:
	var explicit_slug := String(card.get("art_slug", "")).strip_edges()
	if not explicit_slug.is_empty():
		return explicit_slug.to_lower()

	var source_name := String(card.get("name", "")).to_lower()
	var slug := ""
	var last_was_separator := false
	for i in source_name.length():
		var character := source_name.substr(i, 1)
		var code := source_name.unicode_at(i)
		var is_ascii_letter := code >= 97 and code <= 122
		var is_digit := code >= 48 and code <= 57
		if is_ascii_letter or is_digit:
			slug += character
			last_was_separator = false
		elif not slug.is_empty() and not last_was_separator:
			slug += "-"
			last_was_separator = true

	return slug.trim_suffix("-") if not slug.is_empty() else "card"


func _card_art_resource_path(slug: String, extension: String) -> String:
	return "%s/%s.%s" % [CARD_ART_DIRECTORY, slug, extension]


func _find_existing_card_art_path(slug: String) -> String:
	for extension_variant in CARD_ART_EXTENSIONS:
		var extension: String = String(extension_variant)
		var resource_path: String = _card_art_resource_path(slug, extension)
		if ResourceLoader.exists(resource_path, "Texture2D"):
			return resource_path
	return ""


func _decorate_card(card: Dictionary) -> Dictionary:
	var decorated := card.duplicate(true)
	var slug := _card_slug_for(decorated)
	decorated["art_slug"] = slug
	if card_art_textures.has(slug):
		decorated["art_texture"] = card_art_textures[slug]
	return decorated


func _load_card_art_textures(card_templates: Array[Dictionary]) -> void:
	card_art_textures.clear()
	var seen_slugs: Dictionary = {}
	for card in card_templates:
		var slug: String = _card_slug_for(card)
		if seen_slugs.has(slug):
			continue
		seen_slugs[slug] = true
		var resource_path: String = _find_existing_card_art_path(slug)
		if resource_path.is_empty():
			continue
		var texture: Texture2D = _load_card_art_texture(resource_path)
		if texture != null:
			card_art_textures[slug] = texture


func _load_card_art_texture(resource_path: String) -> Texture2D:
	return load(resource_path) as Texture2D


func _shuffle(cards: Array[Dictionary]) -> void:
	for i in range(cards.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var temp: Dictionary = cards[i]
		cards[i] = cards[j]
		cards[j] = temp


func start_player_turn() -> void:
	current_turn = "player"
	player_courage = COURAGE_PER_TURN
	player_block = 0
	_apply_turn_start_buffs("player")
	_draw_up_to(HAND_SIZE)
	add_log("[b]Turn %d:[/b] The little dog braces herself." % turn_number)
	update_ui()


func _draw_up_to(target_hand_size: int) -> void:
	while hand.size() < target_hand_size:
		if draw_pile.is_empty():
			if discard_pile.is_empty():
				break
			draw_pile = discard_pile.duplicate(true)
			discard_pile.clear()
			_shuffle(draw_pile)
			add_log("She gathers her nerve and reshuffles her options.")
		hand.append(draw_pile.pop_back())


func _attempt_play_card(index: int) -> bool:
	if battle_over or current_turn != "player":
		return false
	if index < 0 or index >= hand.size():
		return false

	var card := hand[index]
	var card_cost: int = card.get("cost", 0)
	if player_courage < card_cost:
		add_log("She wants to play [b]%s[/b], but doesn't have enough courage." % card["name"])
		update_ui()
		return false

	player_courage -= card_cost
	var should_discard := _resolve_card(card)
	if should_discard:
		discard_pile.append(card)
	hand.remove_at(index)
	_set_pinned_preview(card, "Last played")

	if _check_battle_end():
		update_ui()
		return true

	update_ui()
	return true


func _resolve_card(card: Dictionary) -> bool:
	add_log("She plays [b]%s[/b]." % card["name"])

	if card.get("type", "") == "buff":
		_gain_fight_buff(card["buff_data"])
		return false

	if card.has("damage"):
		var amount := _modified_attack_damage(card["damage"], "player")
		_deal_damage_to_monster(amount)

	if card.has("block"):
		var block_amount: int = card["block"]
		if player_statuses.frail > 0:
			block_amount = maxi(1, int(floor(block_amount * 0.75)))
		player_block += block_amount
		add_log("She gains %d block." % block_amount)

	if card.has("draw"):
		var draw_amount: int = card["draw"]
		for i in draw_amount:
			_draw_up_to(hand.size() + 1)
		add_log("She finds a little courage and draws %d card(s)." % draw_amount)

	return true


func _deal_damage_to_monster(amount: int) -> void:
	var blocked := mini(monster_block, amount)
	monster_block -= blocked
	var damage_taken := amount - blocked
	monster_hp -= damage_taken
	add_log("The Dark Hallway takes %d damage." % damage_taken)
	if blocked > 0:
		add_log("Its shadows soak up %d with block." % blocked)


func _deal_damage_to_player(amount: int) -> void:
	var blocked := mini(player_block, amount)
	player_block -= blocked
	var damage_taken := amount - blocked
	player_hp -= damage_taken
	add_log("The little dog takes %d damage." % damage_taken)
	if blocked > 0:
		add_log("Her courage absorbs %d with block." % blocked)


func _on_end_turn_pressed() -> void:
	if battle_over or current_turn != "player":
		return
	if not hand.is_empty():
		discard_pile.append_array(hand)
		hand.clear()
	end_turn_button.disabled = true
	_tick_down_player_statuses()
	current_turn = "monster"
	update_ui()
	_run_monster_turn()


func _run_monster_turn() -> void:
	monster_block = 0
	_apply_turn_start_buffs("monster")
	add_log("[b]The Dark Hallway acts:[/b] %s" % pending_intent["name"])

	match pending_intent["kind"]:
		"attack":
			_deal_damage_to_player(_modified_attack_damage(pending_intent["damage"], "monster"))
		"attack_debuff":
			_deal_damage_to_player(_modified_attack_damage(pending_intent["damage"], "monster"))
			player_statuses[pending_intent["status"]] += pending_intent["amount"]
			add_log("She is afflicted with %s for %d turn(s)." % [String(pending_intent["status"]).capitalize(), pending_intent["amount"]])
		"block":
			monster_block += pending_intent["block"]
			add_log("The hallway gathers %d block." % pending_intent["block"])
		"block_debuff":
			monster_block += pending_intent["block"]
			player_statuses[pending_intent["status"]] += pending_intent["amount"]
			add_log("The hallway gathers %d block." % pending_intent["block"])
			add_log("She is afflicted with %s for %d turn(s)." % [String(pending_intent["status"]).capitalize(), pending_intent["amount"]])

	if _check_battle_end():
		update_ui()
		return

	roll_monster_intent()
	turn_number += 1
	start_player_turn()


func roll_monster_intent() -> void:
	var intents: Array[Dictionary] = [
		{
			"name": "A sudden shape lunges from the dark",
			"kind": "attack",
			"damage": 8,
			"preview": "Attack for 8 (+ buffs)",
		},
		{
			"name": "The hallway closes in",
			"kind": "block",
			"block": 8,
			"preview": "Gain 8 block",
		},
		{
			"name": "A growl echoes off the walls",
			"kind": "attack_debuff",
			"damage": 5,
			"status": "weak",
			"amount": 2,
			"preview": "Attack for 5 (+ buffs) and apply Weak 2",
		},
		{
			"name": "The shadows stretch longer",
			"kind": "block_debuff",
			"block": 5,
			"status": "frail",
			"amount": 2,
			"preview": "Gain 5 block and apply Frail 2",
		},
	]
	pending_intent = intents[rng.randi_range(0, intents.size() - 1)].duplicate(true)
	update_ui()


func _apply_turn_start_buffs(owner: String) -> void:
	var buffs := player_buffs if owner == "player" else monster_buffs
	for buff in buffs:
		if buff.has("block_on_turn_start"):
			var block_amount: int = buff["block_on_turn_start"]
			if owner == "player":
				player_block += block_amount
				add_log("%s grants %d block." % [buff["name"], block_amount])
			else:
				monster_block += block_amount
				add_log("%s grants the hallway %d block." % [buff["name"], block_amount])

		if buff.has("courage_on_turn_start") and owner == "player":
			var courage_amount: int = buff["courage_on_turn_start"]
			player_courage += courage_amount
			add_log("%s grants %d courage." % [buff["name"], courage_amount])

		if buff.has("shred_block_on_turn_start"):
			var shred_amount: int = buff["shred_block_on_turn_start"]
			if owner == "monster":
				var removed := mini(player_block, shred_amount)
				player_block -= removed
				if removed > 0:
					add_log("%s tears away %d of the little dog's block." % [buff["name"], removed])
			else:
				var removed_from_monster := mini(monster_block, shred_amount)
				monster_block -= removed_from_monster
				if removed_from_monster > 0:
					add_log("%s tears away %d of the hallway's block." % [buff["name"], removed_from_monster])


func _gain_fight_buff(buff_data: Dictionary) -> void:
	for buff in player_buffs:
		if buff["name"] == buff_data["name"]:
			add_log("She already has %s." % buff_data["name"])
			return

	player_buffs.append(buff_data.duplicate(true))
	add_log("%s comforts her for this fight." % buff_data["name"])


func _modified_attack_damage(base_damage: int, attacker: String) -> int:
	var total_damage := base_damage
	var buffs := player_buffs if attacker == "player" else monster_buffs

	for buff in buffs:
		if buff.has("attack_bonus"):
			total_damage += buff["attack_bonus"]

	if attacker == "player" and player_statuses.weak > 0:
		total_damage = maxi(1, int(floor(total_damage * 0.75)))
	if attacker == "player" and monster_statuses.vulnerable > 0:
		total_damage = int(ceil(total_damage * 1.5))

	return total_damage


func _tick_down_player_statuses() -> void:
	for key in player_statuses.keys():
		player_statuses[key] = maxi(player_statuses[key] - 1, 0)


func _check_battle_end() -> bool:
	if monster_hp <= 0:
		monster_hp = 0
		battle_over = true
		add_log("[b]Victory.[/b] The little dog makes it through the dark.")
		return true
	if player_hp <= 0:
		player_hp = 0
		battle_over = true
		add_log("[b]Defeat.[/b] The fear becomes too much this time.")
		return true
	return false


func update_ui() -> void:
	player_hp_label.text = "HP %d / %d" % [player_hp, STARTING_HP]
	player_courage_label.text = "Courage %d / %d" % [player_courage, COURAGE_PER_TURN]
	player_block_label.text = "Block %d" % player_block
	player_status_label.text = _format_statuses(player_statuses, "Steady tail. No debuffs.")
	player_buffs_label.text = _format_buffs(player_buffs, "No comfort items yet.")
	monster_hp_label.text = "HP %d / %d" % [monster_hp, MONSTER_STARTING_HP]
	monster_block_label.text = "Block %d" % monster_block
	monster_status_label.text = _format_statuses(monster_statuses, "Only restless shadows.")
	monster_buffs_label.text = _format_buffs(monster_buffs, "No dark traits.")

	if monster_hp <= 0:
		turn_label.text = "Encounter Won"
	elif player_hp <= 0:
		turn_label.text = "Encounter Lost"
	else:
		turn_label.text = "Turn %d - %s" % [turn_number, "Player" if current_turn == "player" else "Monster"]

	intent_label.text = _build_intent_text()
	draw_pile_label.text = str(draw_pile.size())
	discard_pile_label.text = str(discard_pile.size())
	end_turn_button.disabled = battle_over or current_turn != "player"
	reset_button.visible = battle_over

	_sync_pile_views()
	_sync_hand_views()
	_refresh_preview()
	_refresh_play_area_hint(false, false)


func _format_statuses(statuses: Dictionary, empty_text: String) -> String:
	var parts: Array[String] = []
	for key in statuses.keys():
		if statuses[key] > 0:
			parts.append("%s %d" % [key.capitalize(), statuses[key]])
	if parts.is_empty():
		return empty_text
	return "Statuses: %s" % ", ".join(parts)


func _format_buffs(buffs: Array[Dictionary], empty_text: String) -> String:
	if buffs.is_empty():
		return empty_text

	var parts: Array[String] = []
	for buff in buffs:
		parts.append("%s: %s" % [buff["name"], buff["text"]])
	return "Buffs: %s" % " | ".join(parts)


func _build_intent_text() -> String:
	if monster_hp <= 0:
		return "Victory. The hallway falls quiet."
	if player_hp <= 0:
		return "Defeat. The hallway looms overhead."
	if pending_intent.is_empty():
		return "The dark is gathering itself."

	var summary := ""
	match pending_intent.get("kind", ""):
		"attack":
			summary = "Attack for %d" % _modified_attack_damage(pending_intent["damage"], "monster")
		"block":
			summary = "Gain %d block" % pending_intent["block"]
		"attack_debuff":
			summary = "Attack for %d and %s %d" % [
				_modified_attack_damage(pending_intent["damage"], "monster"),
				String(pending_intent["status"]).capitalize(),
				pending_intent["amount"],
			]
		"block_debuff":
			summary = "Gain %d block and %s %d" % [
				pending_intent["block"],
				String(pending_intent["status"]).capitalize(),
				pending_intent["amount"],
			]
		_:
			summary = "Unknown intent"

	return "%s\n%s" % [summary, pending_intent.get("name", "")]


func _create_static_card_views() -> void:
	preview_card_view = CARD_UI_SCENE.instantiate()
	preview_card_anchor.add_child(preview_card_view)
	preview_card_view.set_display_size(preview_card_size)
	preview_card_view.mouse_filter = Control.MOUSE_FILTER_IGNORE
	preview_card_view.draggable = false
	preview_card_view.set_hover_enabled(false)
	preview_card_view.visible = false

	draw_pile_card_view = CARD_UI_SCENE.instantiate()
	draw_pile_card_anchor.add_child(draw_pile_card_view)
	draw_pile_card_view.set_display_size(pile_card_size)
	draw_pile_card_view.mouse_filter = Control.MOUSE_FILTER_STOP
	draw_pile_card_view.draggable = false
	draw_pile_card_view.set_hover_enabled(false)
	draw_pile_card_view.set_face_down(true)
	draw_pile_card_view.rotation_degrees = -8.0
	draw_pile_card_view.mouse_entered.connect(_on_draw_pile_mouse_entered)
	draw_pile_card_view.mouse_exited.connect(_on_pile_mouse_exited)

	discard_pile_card_view = CARD_UI_SCENE.instantiate()
	discard_pile_card_anchor.add_child(discard_pile_card_view)
	discard_pile_card_view.set_display_size(pile_card_size)
	discard_pile_card_view.mouse_filter = Control.MOUSE_FILTER_STOP
	discard_pile_card_view.draggable = false
	discard_pile_card_view.set_hover_enabled(false)
	discard_pile_card_view.set_face_down(true)
	discard_pile_card_view.rotation_degrees = 8.0
	discard_pile_card_view.mouse_entered.connect(_on_discard_pile_mouse_entered)
	discard_pile_card_view.mouse_exited.connect(_on_pile_mouse_exited)


func _install_lucide_icons() -> void:
	_attach_icon_before_label(player_hp_label, ICON_HEART, Vector2(26, 26), 8)
	_attach_icon_before_label(player_block_label, ICON_SHIELD, Vector2(26, 26), 8)
	_attach_icon_before_label(player_courage_label, ICON_SPARKLES, Vector2(26, 26), 8)
	_attach_icon_before_label(monster_hp_label, ICON_HEART, Vector2(18, 18), 6)
	_attach_icon_before_label(monster_block_label, ICON_SHIELD, Vector2(18, 18), 6)
	_replace_stage_emoji_with_icon()


func _attach_icon_before_label(label: Label, icon_texture: Texture2D, icon_size: Vector2, separation: int) -> void:
	var parent := label.get_parent()
	if parent == null:
		return
	if parent is HBoxContainer and String(parent.name).begins_with("IconRow"):
		return

	var child_index := label.get_index()
	parent.remove_child(label)

	var row := HBoxContainer.new()
	row.name = "IconRow%s" % label.name
	row.theme_override_constants.separation = separation
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.size_flags_horizontal = label.size_flags_horizontal
	row.size_flags_vertical = label.size_flags_vertical
	parent.add_child(row)
	parent.move_child(row, child_index)

	var icon := TextureRect.new()
	icon.name = "%sIcon" % label.name
	icon.texture = icon_texture
	icon.custom_minimum_size = icon_size
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(icon)
	row.add_child(label)


func _replace_stage_emoji_with_icon() -> void:
	var parent := monster_emoji_label.get_parent()
	if parent == null:
		return
	if parent.has_node("MonsterStageIcon"):
		monster_emoji_label.visible = false
		return

	var icon := TextureRect.new()
	icon.name = "MonsterStageIcon"
	icon.texture = ICON_MOON_STAR
	icon.custom_minimum_size = Vector2(84, 84)
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE

	parent.add_child(icon)
	parent.move_child(icon, monster_emoji_label.get_index())
	monster_emoji_label.visible = false


func _apply_visual_theme() -> void:
	play_area_idle_style = _make_panel_style(Color(0, 0, 0, 0.0), Color(1.0, 0.847059, 0.588235, 0.0), 44, 0, 0)
	play_area_hover_style = _make_panel_style(Color(0.0509804, 0.0784314, 0.117647, 0.12), Color(1.0, 0.847059, 0.588235, 0.34), 44, 3, 22)
	play_area_valid_style = _make_panel_style(Color(0.0980392, 0.145098, 0.0901961, 0.18), Color(0.976471, 0.866667, 0.466667, 0.72), 44, 4, 26)

	title_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.0235294, 0.0313726, 0.054902, 0.54), Color(1.0, 0.839216, 0.596078, 0.16), 26, 2, 18))
	monster_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.0313726, 0.0392157, 0.0666667, 0.58), Color(1.0, 0.839216, 0.596078, 0.2), 30, 2, 20))
	intent_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.105882, 0.0745098, 0.0392157, 0.66), Color(0.996078, 0.854902, 0.556863, 0.32), 28, 2, 18))
	play_area.add_theme_stylebox_override("panel", play_area_idle_style)
	player_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.0352941, 0.0431373, 0.0705882, 0.52), Color(1.0, 0.839216, 0.596078, 0.16), 24, 2, 16))
	log_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.0196078, 0.027451, 0.0470588, 0.56), Color(1.0, 0.839216, 0.596078, 0.14), 22, 2, 16))
	var pile_hover_style := _make_panel_style(Color(0.0156863, 0.027451, 0.0470588, 0.92), Color(1.0, 0.839216, 0.596078, 0.26), 18, 2, 12)
	pile_hover_style.content_margin_left = 14
	pile_hover_style.content_margin_top = 10
	pile_hover_style.content_margin_right = 14
	pile_hover_style.content_margin_bottom = 10
	pile_hover_panel.add_theme_stylebox_override("panel", pile_hover_style)

	_apply_button_theme(end_turn_button, Color(0.239216, 0.337255, 0.454902, 0.96), Color(0.956863, 0.835294, 0.560784, 1.0), Color(0.294118, 0.403922, 0.545098, 1.0))
	_apply_button_theme(reset_button, Color(0.321569, 0.188235, 0.117647, 0.96), Color(0.956863, 0.835294, 0.560784, 1.0), Color(0.403922, 0.239216, 0.14902, 1.0))

	_apply_fixed_typography()

	monster_stage_label.add_theme_color_override("font_color", Color(0.980392, 0.937255, 0.811765, 1.0))
	monster_stage_label.add_theme_color_override("font_outline_color", Color(0.0313726, 0.0392157, 0.0666667, 1.0))
	monster_stage_label.add_theme_constant_override("outline_size", 4)
	monster_emoji_label.add_theme_color_override("font_outline_color", Color(0.0313726, 0.0392157, 0.0666667, 0.95))
	monster_emoji_label.add_theme_constant_override("outline_size", 4)

	for label in [player_hp_label, player_block_label, player_courage_label, player_status_label, player_buffs_label, monster_hp_label, monster_block_label, monster_status_label, monster_buffs_label, draw_pile_label, discard_pile_label]:
		label.add_theme_color_override("font_color", Color(0.968627, 0.941176, 0.854902, 1.0))
		label.add_theme_color_override("font_outline_color", Color(0.0196078, 0.027451, 0.0470588, 0.92))
		label.add_theme_constant_override("outline_size", 2)

	log_label.add_theme_color_override("default_color", Color(0.964706, 0.937255, 0.870588, 1.0))
	log_label.add_theme_font_size_override("normal_font_size", 17)
	log_label.add_theme_font_size_override("bold_font_size", 18)
	log_label.add_theme_font_size_override("italics_font_size", 17)
	pile_hover_label.add_theme_color_override("font_color", Color(0.980392, 0.94902, 0.870588, 1.0))
	pile_hover_label.add_theme_color_override("font_outline_color", Color(0.0235294, 0.027451, 0.0431373, 0.95))
	pile_hover_label.add_theme_constant_override("outline_size", 2)


func _apply_button_theme(button: Button, fill: Color, border: Color, hover_fill: Color) -> void:
	var normal := _make_panel_style(fill, border, 28, 3, 14)
	var hover := _make_panel_style(hover_fill, border, 28, 3, 16)
	var pressed := _make_panel_style(fill.darkened(0.14), border, 28, 3, 10)
	var disabled := _make_panel_style(fill.darkened(0.35), Color(border.r, border.g, border.b, 0.45), 28, 2, 8)
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_stylebox_override("disabled", disabled)
	button.add_theme_color_override("font_color", Color(0.980392, 0.94902, 0.870588, 1.0))
	button.add_theme_color_override("font_hover_color", Color.WHITE)
	button.add_theme_color_override("font_pressed_color", Color(0.980392, 0.94902, 0.870588, 1.0))
	button.add_theme_color_override("font_disabled_color", Color(0.85, 0.82, 0.74, 0.76))
	button.add_theme_font_size_override("font_size", 24)


func _apply_fixed_typography() -> void:
	_style_header(title_label, 28)
	_style_support_text(flavor_label, 16)
	_style_header(monster_name_label, 24)
	_style_header(player_name_label, 22)
	_style_header(turn_label, 22)
	_style_header(intent_label, 20)
	_style_header(preview_title_label, 18)
	_style_support_text(play_instruction_label, 18)
	_style_header(log_title_label, 21)
	pile_hover_label.add_theme_font_size_override("font_size", 18)
	draw_pile_label.add_theme_font_size_override("font_size", 24)
	discard_pile_label.add_theme_font_size_override("font_size", 24)
	monster_stage_label.add_theme_font_size_override("font_size", 54)
	monster_emoji_label.add_theme_font_size_override("font_size", 84)
	for label in [player_hp_label, player_block_label, player_courage_label]:
		label.add_theme_font_size_override("font_size", 24)
	for label in [player_status_label, player_buffs_label, monster_hp_label, monster_block_label, monster_status_label, monster_buffs_label]:
		_style_support_text(label, 17)


func _apply_fixed_layout_metrics() -> void:
	preview_card_size = BASE_PREVIEW_CARD_SIZE
	pile_card_size = BASE_PILE_CARD_SIZE
	hand_card_size = BASE_HAND_CARD_SIZE
	preview_card_anchor.custom_minimum_size = preview_card_size
	draw_pile_card_anchor.custom_minimum_size = pile_card_size
	discard_pile_card_anchor.custom_minimum_size = pile_card_size
	end_turn_button.custom_minimum_size = END_TURN_BUTTON_SIZE
	reset_button.custom_minimum_size = END_TURN_BUTTON_SIZE

	if preview_card_view:
		preview_card_view.set_display_size(preview_card_size)
	if draw_pile_card_view:
		draw_pile_card_view.set_display_size(pile_card_size)
	if discard_pile_card_view:
		discard_pile_card_view.set_display_size(pile_card_size)
	for card_view in hand_card_views:
		card_view.set_display_size(hand_card_size)


func _update_canvas_transform() -> void:
	var viewport_size := get_viewport_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return

	layout_scale = minf(viewport_size.x / COMPOSITION_SIZE.x, viewport_size.y / COMPOSITION_SIZE.y)
	combat_canvas.scale = Vector2.ONE * layout_scale
	combat_canvas.position = (viewport_size - (COMPOSITION_SIZE * layout_scale)) * 0.5
	_update_hovered_pile_tooltip()


func _on_viewport_size_changed() -> void:
	_update_canvas_transform()


func _make_panel_style(background: Color, border: Color, radius: int, border_width := 2, shadow_size := 10) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border
	style.set_border_width_all(border_width)
	style.set_corner_radius_all(radius)
	style.shadow_color = Color(0, 0, 0, 0.26)
	style.shadow_size = shadow_size
	return style


func _style_header(label: Label, font_size: int) -> void:
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", Color(0.980392, 0.945098, 0.858824, 1.0))
	label.add_theme_color_override("font_outline_color", Color(0.0196078, 0.027451, 0.0470588, 0.95))
	label.add_theme_constant_override("outline_size", 3)


func _style_support_text(label: Label, font_size: int) -> void:
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", Color(0.894118, 0.839216, 0.705882, 1.0))
	label.add_theme_color_override("font_outline_color", Color(0.0196078, 0.027451, 0.0470588, 0.92))
	label.add_theme_constant_override("outline_size", 2)


func _sync_pile_views() -> void:
	draw_pile_card_view.set_face_down(true)
	draw_pile_card_view.modulate = Color(1, 1, 1, 1.0) if draw_pile.size() > 0 else Color(0.65, 0.65, 0.65, 0.7)

	if discard_pile.is_empty():
		discard_pile_card_view.set_face_down(true)
		discard_pile_card_view.modulate = Color(0.72, 0.72, 0.72, 0.55)
	else:
		discard_pile_card_view.set_face_down(false)
		discard_pile_card_view.set_card_data(discard_pile.back())
		discard_pile_card_view.modulate = Color.WHITE
	_update_hovered_pile_tooltip()


func _show_pile_hover(pile_name: String, count: int, anchor: Control) -> void:
	hovered_pile = pile_name
	pile_hover_label.text = "%s\n%d" % [pile_name, count]
	pile_hover_panel.custom_minimum_size = Vector2.ZERO
	pile_hover_panel.size = pile_hover_panel.get_combined_minimum_size()
	pile_hover_panel.visible = true
	var anchor_rect: Rect2 = anchor.get_global_rect()
	var tooltip_size: Vector2 = pile_hover_panel.size * layout_scale
	var desired_position := Vector2(
		anchor_rect.get_center().x - (tooltip_size.x * 0.5),
		anchor_rect.position.y - tooltip_size.y - 14.0
	)
	var viewport_size := get_viewport_rect().size
	pile_hover_panel.global_position = Vector2(
		clampf(desired_position.x, 12.0, viewport_size.x - tooltip_size.x - 12.0),
		clampf(desired_position.y, 12.0, viewport_size.y - tooltip_size.y - 12.0)
	)


func _hide_pile_hover() -> void:
	hovered_pile = ""
	pile_hover_panel.visible = false


func _update_hovered_pile_tooltip() -> void:
	if not pile_hover_panel.visible:
		return
	match hovered_pile:
		"Draw Pile":
			_show_pile_hover("Draw Pile", draw_pile.size(), draw_pile_card_anchor)
		"Discard Pile":
			_show_pile_hover("Discard Pile", discard_pile.size(), discard_pile_card_anchor)


func _on_draw_pile_mouse_entered() -> void:
	_show_pile_hover("Draw Pile", draw_pile.size(), draw_pile_card_anchor)


func _on_discard_pile_mouse_entered() -> void:
	_show_pile_hover("Discard Pile", discard_pile.size(), discard_pile_card_anchor)


func _on_pile_mouse_exited() -> void:
	_hide_pile_hover()


func _sync_hand_views() -> void:
	var new_signature := _build_hand_signature()
	var should_rebuild := new_signature != hand_signature or hand_card_views.size() != hand.size()

	if should_rebuild:
		_rebuild_hand_views()
		hand_signature = new_signature
	else:
		for i in hand_card_views.size():
			hand_card_views[i].card_index = i
			hand_card_views[i].set_disabled(_is_card_disabled(hand[i]))

	_layout_hand_cards(false)


func _build_hand_signature() -> String:
	var parts: Array[String] = []
	for card in hand:
		parts.append("%s|%s|%s|%s|%s|%s|%s" % [
			card.get("name", ""),
			card.get("type", ""),
			card.get("cost", 0),
			card.get("damage", -1),
			card.get("block", -1),
			card.get("draw", -1),
			card.get("text", ""),
		])
	return "||".join(parts)


func _rebuild_hand_views() -> void:
	for child in hand_area.get_children():
		child.queue_free()
	hand_card_views.clear()
	hovered_card_index = -1

	for i in hand.size():
		var card_view: CardUI = CARD_UI_SCENE.instantiate()
		card_view.drag_started.connect(_on_hand_card_drag_started)
		card_view.drag_moved.connect(_on_hand_card_drag_moved)
		card_view.drag_ended.connect(_on_hand_card_drag_ended)
		card_view.hover_changed.connect(_on_hand_card_hover_changed)
		hand_area.add_child(card_view)
		card_view.set_display_size(hand_card_size)
		card_view.set_card_data(hand[i])
		card_view.card_index = i
		card_view.set_disabled(_is_card_disabled(hand[i]))
		hand_card_views.append(card_view)


func _is_card_disabled(card: Dictionary) -> bool:
	return battle_over or current_turn != "player" or card.get("cost", 0) > player_courage


func _layout_hand_cards(animated := true) -> void:
	if hand_card_views.is_empty():
		return
	if hand_area.size.x <= 0.0:
		call_deferred("_layout_hand_cards", animated)
		return

	var card_width: float = hand_card_size.x
	var card_height: float = hand_card_size.y
	var count: int = hand_card_views.size()
	var side_padding: float = HAND_SIDE_PADDING
	var usable_width: float = maxf(0.0, hand_area.size.x - (side_padding * 2.0) - card_width)
	var step: float = 0.0

	if count > 1:
		step = minf(card_width * HAND_CARD_OVERLAP, usable_width / float(count - 1))

	var total_width: float = card_width + (step * float(maxi(count - 1, 0)))
	var start_x: float = maxf(side_padding, (hand_area.size.x - total_width) * 0.5)
	var base_y: float = hand_area.size.y - card_height - HAND_BASE_LIFT

	for i in count:
		var card_view: CardUI = hand_card_views[i]
		var t := 0.5 if count == 1 else float(i) / float(count - 1)
		var normalized: float = 0.0 if count == 1 else (t * 2.0) - 1.0
		var arc_offset: float = pow(absf(normalized), 1.35) * HAND_FAN_ARC
		var target_position: Vector2 = Vector2(start_x + (step * i), base_y + arc_offset)
		var rotation: float = 0.0 if count == 1 else lerpf(-HAND_FAN_ROTATION, HAND_FAN_ROTATION, t)
		card_view.set_rest_transform(target_position, rotation, 20 + i, animated)


func _set_pinned_preview(card: Dictionary, title: String) -> void:
	pinned_preview_card = card.duplicate(true)
	pinned_preview_title = title


func _refresh_preview() -> void:
	if hovered_card_index >= 0 and hovered_card_index < hand.size():
		preview_title_label.text = "Card Preview"
		preview_card_view.visible = true
		preview_card_view.set_face_down(false)
		preview_card_view.set_card_data(hand[hovered_card_index])
		return

	if not pinned_preview_card.is_empty():
		preview_title_label.text = pinned_preview_title
		preview_card_view.visible = true
		preview_card_view.set_face_down(false)
		preview_card_view.set_card_data(pinned_preview_card)
		return

	preview_title_label.text = "Hover a card"
	preview_card_view.visible = false


func _refresh_play_area_hint(is_dragging: bool, is_valid_drop: bool) -> void:
	if battle_over:
		play_area.add_theme_stylebox_override("panel", play_area_idle_style)
		play_instruction_label.text = "The encounter is over. Use Try Again to reset."
		return

	if current_turn != "player":
		play_area.add_theme_stylebox_override("panel", play_area_idle_style)
		play_instruction_label.text = "The hallway is acting. Hold your nerve."
		return

	if not is_dragging:
		play_area.add_theme_stylebox_override("panel", play_area_idle_style)
		play_instruction_label.text = "Drag a card onto the hallway rug to play it."
		return

	if is_valid_drop:
		play_area.add_theme_stylebox_override("panel", play_area_valid_style)
		play_instruction_label.text = "Release to play this card."
	else:
		play_area.add_theme_stylebox_override("panel", play_area_hover_style)
		play_instruction_label.text = "Drag higher onto the hallway rug to play."


func _drop_position_is_valid(drop_position: Vector2) -> bool:
	if battle_over or current_turn != "player":
		return false
	return play_area.get_global_rect().has_point(drop_position)


func _on_hand_card_drag_started(card_view: CardUI) -> void:
	_hide_pile_hover()
	hovered_card_index = card_view.card_index
	_refresh_preview()
	_refresh_play_area_hint(true, false)


func _on_hand_card_drag_moved(card_view: CardUI, mouse_position: Vector2) -> void:
	_refresh_play_area_hint(true, _drop_position_is_valid(mouse_position))


func _on_hand_card_drag_ended(card_view: CardUI, mouse_position: Vector2) -> void:
	var can_play := _drop_position_is_valid(mouse_position)
	hovered_card_index = card_view.card_index if card_view.card_index < hand.size() else -1
	_refresh_play_area_hint(false, false)

	if can_play:
		if _attempt_play_card(card_view.card_index):
			return

	_layout_hand_cards(true)
	_refresh_preview()


func _on_hand_card_hover_changed(card_view: CardUI, is_hovering: bool) -> void:
	if is_hovering:
		hovered_card_index = card_view.card_index
	else:
		if hovered_card_index == card_view.card_index:
			hovered_card_index = -1
	_refresh_preview()


func _on_hand_area_resized() -> void:
	_layout_hand_cards(false)


func add_log(message: String) -> void:
	log_label.append_text("%s\n" % message)
	log_label.scroll_to_line(log_label.get_line_count())


func _on_reset_button_pressed() -> void:
	_hide_pile_hover()
	_start_battle()
