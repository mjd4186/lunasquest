class_name CardLibrary
extends RefCounted

var cards_data_path: String
var starting_deck_data_path: String
var card_art_directory: String
var card_art_extensions: Array

var card_definitions: Array[Dictionary] = []
var card_definitions_by_id: Dictionary = {}
var card_definitions_by_name: Dictionary = {}
var card_art_textures: Dictionary = {}


func _init(
	cards_path: String,
	starting_deck_path: String,
	art_directory: String,
	art_extensions: Array
) -> void:
	cards_data_path = cards_path
	starting_deck_data_path = starting_deck_path
	card_art_directory = art_directory
	card_art_extensions = art_extensions.duplicate()


func load_definitions() -> void:
	card_definitions.clear()
	card_definitions_by_id.clear()
	card_definitions_by_name.clear()

	var cards_data := _load_json_dictionary(cards_data_path)
	for card_variant in cards_data.get("cards", []):
		if typeof(card_variant) != TYPE_DICTIONARY:
			continue
		var normalized_card := _normalize_card_definition(card_variant)
		if normalized_card.is_empty():
			continue
		card_definitions.append(normalized_card)
		card_definitions_by_id[normalized_card["id"]] = normalized_card
		card_definitions_by_name[String(normalized_card["name"]).to_lower()] = normalized_card

	_load_card_art_textures(card_definitions)


func build_starting_deck() -> Array[Dictionary]:
	var deck: Array[Dictionary] = []
	var deck_data := _load_json_dictionary(starting_deck_data_path)
	for card_reference_variant in deck_data.get("cards", []):
		var card_reference := String(card_reference_variant).strip_edges()
		if card_reference.is_empty():
			continue
		var card_definition := _find_card_definition(card_reference)
		if card_definition.is_empty():
			push_error("Unknown card in starting deck: %s" % card_reference)
			continue
		deck.append(_decorate_card(card_definition))
	return deck


func _load_json_dictionary(resource_path: String) -> Dictionary:
	if not FileAccess.file_exists(resource_path):
		push_error("Missing JSON file: %s" % resource_path)
		return {}

	var file := FileAccess.open(resource_path, FileAccess.READ)
	if file == null:
		push_error("Unable to open JSON file: %s" % resource_path)
		return {}

	var json := JSON.new()
	var parse_result := json.parse(file.get_as_text())
	if parse_result != OK:
		push_error("Failed to parse %s at line %d: %s" % [resource_path, json.get_error_line(), json.get_error_message()])
		return {}

	if typeof(json.data) != TYPE_DICTIONARY:
		push_error("Expected a JSON object in %s." % resource_path)
		return {}

	return json.data


func _normalize_card_definition(raw_card: Dictionary) -> Dictionary:
	var card := raw_card.duplicate(true)
	var properties: Dictionary = {}
	var raw_properties: Variant = card.get("properties", {})
	if typeof(raw_properties) == TYPE_DICTIONARY:
		properties = raw_properties

	var legacy_property_mappings := {
		"block_on_turn_start": "block_every_turn",
		"courage_on_turn_start": "energy_every_turn",
		"attack_bonus": "strength_every_turn",
	}
	for legacy_key in legacy_property_mappings.keys():
		if properties.has(legacy_key) and not properties.has(legacy_property_mappings[legacy_key]):
			properties[legacy_property_mappings[legacy_key]] = properties[legacy_key]
		properties.erase(legacy_key)

	for immediate_key in ["damage", "block", "draw", "heal"]:
		if card.has(immediate_key) and not properties.has(immediate_key):
			properties[immediate_key] = card[immediate_key]
		card.erase(immediate_key)

	card["id"] = String(card.get("id", _card_slug_for(card))).strip_edges().to_lower()
	card["name"] = String(card.get("name", card["id"])).strip_edges()
	card["type"] = String(card.get("type", "skill")).strip_edges().to_lower()
	card["cost"] = int(card.get("cost", 0))
	card["text"] = String(card.get("text", "")).strip_edges()
	card["flavor_text"] = String(card.get("flavor_text", "")).strip_edges()
	card["properties"] = properties
	return card


func _find_card_definition(card_reference: String) -> Dictionary:
	var normalized_id := card_reference.to_lower()
	if card_definitions_by_id.has(normalized_id):
		return card_definitions_by_id[normalized_id]

	var normalized_name := card_reference.to_lower()
	if card_definitions_by_name.has(normalized_name):
		return card_definitions_by_name[normalized_name]

	return {}


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
	return "%s/%s.%s" % [card_art_directory, slug, extension]


func _find_existing_card_art_path(slug: String) -> String:
	for extension_variant in card_art_extensions:
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
		var texture: Texture2D = load(resource_path) as Texture2D
		if texture != null:
			card_art_textures[slug] = texture
