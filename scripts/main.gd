extends Control

const STARTING_HP := 28
const MONSTER_STARTING_HP := 40
const HAND_SIZE := 5
const COURAGE_PER_TURN := 3

@onready var title_label: Label = %TitleLabel
@onready var flavor_label: Label = %FlavorLabel
@onready var player_hp_label: Label = %PlayerHPLabel
@onready var player_courage_label: Label = %PlayerCourageLabel
@onready var player_block_label: Label = %PlayerBlockLabel
@onready var player_status_label: Label = %PlayerStatusLabel
@onready var monster_hp_label: Label = %MonsterHPLabel
@onready var monster_block_label: Label = %MonsterBlockLabel
@onready var monster_status_label: Label = %MonsterStatusLabel
@onready var intent_label: Label = %IntentLabel
@onready var turn_label: Label = %TurnLabel
@onready var draw_pile_label: Label = %DrawPileLabel
@onready var discard_pile_label: Label = %DiscardPileLabel
@onready var hand_container: HBoxContainer = %HandContainer
@onready var end_turn_button: Button = %EndTurnButton
@onready var log_label: RichTextLabel = %LogLabel
@onready var reset_button: Button = %ResetButton

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

var turn_number := 1
var current_turn := "player"
var pending_intent: Dictionary = {}
var battle_over := false


func _ready() -> void:
	rng.randomize()
	end_turn_button.pressed.connect(_on_end_turn_pressed)
	reset_button.pressed.connect(_on_reset_button_pressed)
	_start_battle()


func _start_battle() -> void:
	player_hp = STARTING_HP
	player_courage = COURAGE_PER_TURN
	player_block = 0
	monster_hp = MONSTER_STARTING_HP
	monster_block = 0
	player_statuses = {"weak": 0, "frail": 0}
	monster_statuses = {"vulnerable": 0}
	turn_number = 1
	current_turn = "player"
	battle_over = false
	log_label.clear()
	title_label.text = "Scared Little Dog vs. The Dark Hallway"
	flavor_label.text = "Every creak sounds enormous. Every shadow looks hungry."

	draw_pile = _build_starting_deck()
	discard_pile.clear()
	hand.clear()
	_shuffle(draw_pile)
	roll_monster_intent()
	add_log("The little dog pads into the hallway. The dark stares back.")
	start_player_turn()


func _build_starting_deck() -> Array[Dictionary]:
	var deck: Array[Dictionary] = []
	deck.append_array(_make_copies({
		"name": "Yip!",
		"type": "attack",
		"cost": 1,
		"damage": 6,
		"text": "Deal 6 damage.",
	}, 5))
	deck.append_array(_make_copies({
		"name": "Cower",
		"type": "block",
		"cost": 1,
		"block": 5,
		"text": "Gain 5 block.",
	}, 5))
	deck.append_array(_make_copies({
		"name": "Peek Around Corner",
		"type": "skill",
		"cost": 1,
		"damage": 4,
		"block": 4,
		"text": "Deal 4 damage and gain 4 block.",
	}, 2))
	deck.append_array(_make_copies({
		"name": "Find Courage",
		"type": "skill",
		"cost": 1,
		"draw": 2,
		"block": 3,
		"text": "Gain 3 block. Draw 2 cards.",
	}, 1))
	return deck


func _make_copies(card: Dictionary, amount: int) -> Array[Dictionary]:
	var copies: Array[Dictionary] = []
	for i in amount:
		copies.append(card.duplicate(true))
	return copies


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


func _on_card_pressed(index: int) -> void:
	if battle_over or current_turn != "player":
		return
	if index < 0 or index >= hand.size():
		return

	var card := hand[index]
	var card_cost: int = card.get("cost", 0)
	if player_courage < card_cost:
		add_log("She wants to play [b]%s[/b], but doesn't have enough courage." % card["name"])
		update_ui()
		return

	player_courage -= card_cost
	_resolve_card(card)
	discard_pile.append(card)
	hand.remove_at(index)

	if _check_battle_end():
		update_ui()
		return

	update_ui()


func _resolve_card(card: Dictionary) -> void:
	add_log("She plays [b]%s[/b]." % card["name"])

	if card.has("damage"):
		var amount: int = card["damage"]
		if player_statuses.weak > 0:
			amount = maxi(1, int(floor(amount * 0.75)))
		if monster_statuses.vulnerable > 0:
			amount = int(ceil(amount * 1.5))
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
	add_log("[b]The Dark Hallway acts:[/b] %s" % pending_intent["name"])

	match pending_intent["kind"]:
		"attack":
			_deal_damage_to_player(pending_intent["damage"])
		"attack_debuff":
			_deal_damage_to_player(pending_intent["damage"])
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
			"damage": 7,
			"preview": "Attack for 7",
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
			"damage": 4,
			"status": "weak",
			"amount": 2,
			"preview": "Attack for 4 and apply Weak 2",
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


func _tick_down_player_statuses() -> void:
	for key in player_statuses.keys():
		player_statuses[key] = maxi(player_statuses[key] - 1, 0)


func _check_battle_end() -> bool:
	if monster_hp <= 0:
		monster_hp = 0
		battle_over = true
		intent_label.text = "The hallway falls quiet."
		add_log("[b]Victory.[/b] The little dog makes it through the dark.")
		return true
	if player_hp <= 0:
		player_hp = 0
		battle_over = true
		intent_label.text = "The hallway looms overhead."
		add_log("[b]Defeat.[/b] The fear becomes too much this time.")
		return true
	return false


func update_ui() -> void:
	player_hp_label.text = "HP: %d / %d" % [player_hp, STARTING_HP]
	player_courage_label.text = "Courage: %d / %d" % [player_courage, COURAGE_PER_TURN]
	player_block_label.text = "Block: %d" % player_block
	player_status_label.text = _format_statuses(player_statuses, "Steady tail. No debuffs.")
	monster_hp_label.text = "HP: %d / %d" % [monster_hp, MONSTER_STARTING_HP]
	monster_block_label.text = "Block: %d" % monster_block
	monster_status_label.text = _format_statuses(monster_statuses, "Only restless shadows.")
	intent_label.text = "Intent: %s" % pending_intent.get("preview", "Unknown")
	turn_label.text = "Turn %d - %s" % [turn_number, "Player" if current_turn == "player" else "Monster"]
	draw_pile_label.text = "Draw pile: %d" % draw_pile.size()
	discard_pile_label.text = "Discard: %d" % discard_pile.size()
	end_turn_button.disabled = battle_over or current_turn != "player"
	reset_button.visible = battle_over
	_rebuild_hand()


func _format_statuses(statuses: Dictionary, empty_text: String) -> String:
	var parts: Array[String] = []
	for key in statuses.keys():
		if statuses[key] > 0:
			parts.append("%s %d" % [key.capitalize(), statuses[key]])
	if parts.is_empty():
		return empty_text
	return "Statuses: %s" % ", ".join(parts)


func _rebuild_hand() -> void:
	for child in hand_container.get_children():
		child.queue_free()

	for i in hand.size():
		var card: Dictionary = hand[i]
		var card_cost: int = card.get("cost", 0)
		var button := Button.new()
		button.custom_minimum_size = Vector2(150, 180)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		button.text = "%s (%d)\n\n%s" % [card["name"], card_cost, card["text"]]
		button.disabled = battle_over or current_turn != "player" or card_cost > player_courage
		button.pressed.connect(_on_card_pressed.bind(i))
		hand_container.add_child(button)


func add_log(message: String) -> void:
	log_label.append_text("%s\n" % message)
	log_label.scroll_to_line(log_label.get_line_count())


func _on_reset_button_pressed() -> void:
	_start_battle()
