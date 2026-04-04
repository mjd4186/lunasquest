class_name CombatState
extends RefCounted

const PLAYER_SIDE := "player"
const MONSTER_SIDE := "monster"

var player_hp: int = 0
var player_courage: int = 0
var player_block: int = 0
var monster_hp: int = 0
var monster_block: int = 0

var player_statuses: Dictionary = {"weak": 0, "frail": 0}
var monster_statuses: Dictionary = {"vulnerable": 0}

var draw_pile: Array[Dictionary] = []
var discard_pile: Array[Dictionary] = []
var hand: Array[Dictionary] = []
var player_buffs: Array[Dictionary] = []
var monster_buffs: Array[Dictionary] = []

var turn_number: int = 1
var current_turn: String = PLAYER_SIDE
var pending_intent: Dictionary = {}
var battle_over: bool = false

var player_bonus_courage_next_turn: int = 0
var player_strength_this_turn: int = 0


func reset_for_battle(
	starting_hp: int,
	monster_starting_hp: int,
	courage_per_turn: int,
	starting_player_buffs: Array[Dictionary],
	starting_monster_buffs: Array[Dictionary]
) -> void:
	player_hp = starting_hp
	player_courage = courage_per_turn
	player_block = 0
	monster_hp = monster_starting_hp
	monster_block = 0
	player_statuses = {"weak": 0, "frail": 0}
	monster_statuses = {"vulnerable": 0}
	draw_pile.clear()
	discard_pile.clear()
	hand.clear()
	player_buffs = _duplicate_dictionary_array(starting_player_buffs)
	monster_buffs = _duplicate_dictionary_array(starting_monster_buffs)
	turn_number = 1
	current_turn = PLAYER_SIDE
	pending_intent = {}
	battle_over = false
	player_bonus_courage_next_turn = 0
	player_strength_this_turn = 0


func set_starting_deck(deck: Array[Dictionary]) -> void:
	draw_pile = _duplicate_dictionary_array(deck)
	discard_pile.clear()
	hand.clear()


func refill_draw_pile_from_discard() -> void:
	draw_pile = _duplicate_dictionary_array(discard_pile)
	discard_pile.clear()


func shuffle_draw_pile(rng: RandomNumberGenerator) -> void:
	for i in range(draw_pile.size() - 1, 0, -1):
		var j: int = rng.randi_range(0, i)
		var temp: Dictionary = draw_pile[i]
		draw_pile[i] = draw_pile[j]
		draw_pile[j] = temp


func roll_monster_intent(rng: RandomNumberGenerator) -> void:
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


func is_player_turn() -> bool:
	return current_turn == PLAYER_SIDE


func card_properties(card: Dictionary) -> Dictionary:
	var raw_properties: Variant = card.get("properties", {})
	if typeof(raw_properties) == TYPE_DICTIONARY:
		return raw_properties
	return {}


func base_card_cost(card: Dictionary) -> int:
	return int(card.get("cost", 0))


func current_card_cost(card: Dictionary) -> int:
	if card_properties(card).get("x_cost", false):
		return player_courage
	return base_card_cost(card)


func can_play_card(index: int) -> bool:
	if battle_over or not is_player_turn():
		return false
	if index < 0 or index >= hand.size():
		return false
	return player_courage >= current_card_cost(hand[index])


func modified_block_amount(base_block: int) -> int:
	if int(player_statuses.get("frail", 0)) > 0:
		return maxi(1, int(floor(base_block * 0.75)))
	return base_block


func modified_heal_amount(base_heal: int) -> int:
	return base_heal


func card_should_discard(card: Dictionary) -> bool:
	if card.get("type", "") == "buff":
		return false
	return not bool(card_properties(card).get("exile", false))


func build_fight_buff_from_card(card: Dictionary) -> Dictionary:
	var properties: Dictionary = card_properties(card)
	var buff: Dictionary = {
		"id": String(card.get("id", "")),
		"name": String(card.get("name", "")),
		"text": buff_summary_text(String(card.get("text", ""))),
	}
	for property_name in ["block_every_turn", "draw_every_turn", "energy_every_turn", "strength_every_turn", "shred_block_every_turn"]:
		if properties.has(property_name):
			buff[property_name] = properties[property_name]
	return buff


func buff_summary_text(card_text: String) -> String:
	return card_text.trim_prefix("Exile. ").strip_edges()


func try_gain_fight_buff(buff_data: Dictionary) -> bool:
	var buff_id := String(buff_data.get("id", buff_data.get("name", "")))
	for buff in player_buffs:
		var existing_id := String(buff.get("id", buff.get("name", "")))
		if existing_id == buff_id:
			return false

	player_buffs.append(buff_data.duplicate(true))
	return true


func apply_damage_to_monster(amount: int) -> Dictionary:
	var blocked: int = mini(monster_block, amount)
	monster_block -= blocked
	var damage_taken: int = amount - blocked
	monster_hp -= damage_taken
	return {
		"blocked": blocked,
		"damage_taken": damage_taken,
	}


func apply_damage_to_player(amount: int) -> Dictionary:
	var blocked: int = mini(player_block, amount)
	player_block -= blocked
	var damage_taken: int = amount - blocked
	player_hp -= damage_taken
	return {
		"blocked": blocked,
		"damage_taken": damage_taken,
	}


func modified_attack_damage(base_damage: int, attacker: String) -> int:
	var total_damage: int = base_damage + attack_flat_bonus(attacker)
	return apply_attack_status_modifiers(total_damage, attacker)


func attack_flat_bonus(attacker: String) -> int:
	var total_bonus := 0
	var buffs := player_buffs if attacker == PLAYER_SIDE else monster_buffs
	if attacker == PLAYER_SIDE:
		total_bonus += player_strength_this_turn

	for buff in buffs:
		if buff.has("strength_every_turn"):
			total_bonus += int(buff["strength_every_turn"])

	return total_bonus


func apply_attack_status_modifiers(total_damage: int, attacker: String) -> int:
	if attacker == PLAYER_SIDE and int(player_statuses.get("weak", 0)) > 0:
		total_damage = maxi(1, int(floor(total_damage * 0.75)))
	if attacker == PLAYER_SIDE and int(monster_statuses.get("vulnerable", 0)) > 0:
		total_damage = int(ceil(total_damage * 1.5))
	return total_damage


func tick_down_player_statuses() -> void:
	for key in player_statuses.keys():
		player_statuses[key] = maxi(int(player_statuses[key]) - 1, 0)


func check_battle_end() -> String:
	if monster_hp <= 0:
		monster_hp = 0
		battle_over = true
		return PLAYER_SIDE
	if player_hp <= 0:
		player_hp = 0
		battle_over = true
		return MONSTER_SIDE
	return ""


func format_statuses(statuses: Dictionary, empty_text: String) -> String:
	var parts: Array[String] = []
	for key in statuses.keys():
		if int(statuses[key]) > 0:
			parts.append("%s %d" % [key.capitalize(), int(statuses[key])])
	if parts.is_empty():
		return empty_text
	return "Statuses: %s" % ", ".join(parts)


func format_buffs(buffs: Array[Dictionary], empty_text: String) -> String:
	if buffs.is_empty():
		return empty_text

	var parts: Array[String] = []
	for buff in buffs:
		parts.append("%s: %s" % [buff["name"], buff["text"]])
	return "Buffs: %s" % " | ".join(parts)


func build_intent_text() -> String:
	if monster_hp <= 0:
		return "Victory. The hallway falls quiet."
	if player_hp <= 0:
		return "Defeat. The hallway looms overhead."
	if pending_intent.is_empty():
		return "The dark is gathering itself."

	var summary := ""
	match pending_intent.get("kind", ""):
		"attack":
			summary = "Attack for %d" % modified_attack_damage(int(pending_intent["damage"]), MONSTER_SIDE)
		"block":
			summary = "Gain %d block" % int(pending_intent["block"])
		"attack_debuff":
			summary = "Attack for %d and %s %d" % [
				modified_attack_damage(int(pending_intent["damage"]), MONSTER_SIDE),
				String(pending_intent["status"]).capitalize(),
				int(pending_intent["amount"]),
			]
		"block_debuff":
			summary = "Gain %d block and %s %d" % [
				int(pending_intent["block"]),
				String(pending_intent["status"]).capitalize(),
				int(pending_intent["amount"]),
			]
		_:
			summary = "Unknown intent"

	return "%s\n%s" % [summary, pending_intent.get("name", "")]


func _duplicate_dictionary_array(source: Array[Dictionary]) -> Array[Dictionary]:
	var copy: Array[Dictionary] = []
	for entry in source:
		copy.append(entry.duplicate(true))
	return copy
