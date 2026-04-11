extends CanvasLayer

const SUCCESS_CHANCE := 0.8
const MULTIPLIER_POOL := [1.2, 1.35, 1.5, 1.75, 2.0, 2.5, 3.0]
const TILE_COUNT := 9
const TILE_WIDTH := 210.0
const STEP_DURATION := 0.28
const CHARACTER_JUMP_HEIGHT := 58.0

@export var money_text: Label
@export var multiplier_text: Label
@export var status_text: Label
@export var tiles_hbox: HBoxContainer
@export var character: TextureRect
@export var character_idle_texture: Texture2D
@export var character_jump_texture: Texture2D
@export var character_fail_texture: Texture2D

@export var step_button: Button
@export var stand_button: Button
@export var bet_10_button: Button
@export var bet_25_button: Button
@export var bet_50_button: Button
@export var bet_100_button: Button
@export var tile_panel_1: Panel
@export var tile_panel_2: Panel
@export var tile_panel_3: Panel
@export var tile_panel_4: Panel
@export var tile_panel_5: Panel
@export var tile_panel_6: Panel
@export var tile_panel_7: Panel
@export var tile_panel_8: Panel
@export var tile_panel_9: Panel

@export var tile_label_1: Label
@export var tile_label_2: Label
@export var tile_label_3: Label
@export var tile_label_4: Label
@export var tile_label_5: Label
@export var tile_label_6: Label
@export var tile_label_7: Label
@export var tile_label_8: Label
@export var tile_label_9: Label

var rng := RandomNumberGenerator.new()

var selected_bet_percent := 0.1
var round_started := false
var round_finished := false
var is_animating := false

var initial_bet: Big = Big.new(0)
var accumulated_money: Big = Big.new(0)
var tile_panels: Array[Panel] = []
var tile_labels: Array[Label] = []
var tile_values: Array[float] = []
@warning_ignore("integer_division")
var current_tile_index:int = 0
var current_multiplier := 1.0

func _ready() -> void:
	if not _validate_ui_references():
		push_error("GamblingWindow: faltan referencias de UI en el inspector")
		return

	rng.randomize()
	if character_idle_texture != null:
		character.texture = character_idle_texture
	_connect_buttons()
	if not _initialize_tiles_from_exports():
		_set_status("Configura tile_panel_* y tile_label_* en el inspector")
		step_button.disabled = true
		return

	_update_bet_button_visuals()
	_update_money_text()
	GameManager.on_money_changed.connect(_on_wallet_money_changed)
	_set_status("Selecciona apuesta y pulsa Step")


func _connect_buttons() -> void:
	step_button.button_up.connect(_on_step_pressed)
	stand_button.button_up.connect(_on_stand_pressed)
	bet_10_button.button_up.connect(func(): _select_bet(0.10))
	bet_25_button.button_up.connect(func(): _select_bet(0.25))
	bet_50_button.button_up.connect(func(): _select_bet(0.50))
	bet_100_button.button_up.connect(func(): _select_bet(1.00))


func _validate_ui_references() -> bool:
	return (
		money_text != null
		and multiplier_text != null
		and status_text != null
		and tiles_hbox != null
		and character != null
		and step_button != null
		and stand_button != null
		and bet_10_button != null
		and bet_25_button != null
		and bet_50_button != null
		and bet_100_button != null
	)


func _initialize_tiles_from_exports() -> bool:
	tile_panels.clear()
	tile_labels.clear()

	var exported_panels: Array[Panel] = [
		tile_panel_1,
		tile_panel_2,
		tile_panel_3,
		tile_panel_4,
		tile_panel_5,
		tile_panel_6,
		tile_panel_7,
		tile_panel_8,
		tile_panel_9,
	]

	var exported_labels: Array[Label] = [
		tile_label_1,
		tile_label_2,
		tile_label_3,
		tile_label_4,
		tile_label_5,
		tile_label_6,
		tile_label_7,
		tile_label_8,
		tile_label_9,
	]

	for panel in exported_panels:
		if panel == null:
			return false
		tile_panels.append(panel)

	for label in exported_labels:
		if label == null:
			return false
		tile_labels.append(label)

	tile_values.clear()
	for _i in range(tile_labels.size()):
		tile_values.append(_random_multiplier())

	@warning_ignore("integer_division")
	_update_tile_labels()
	_update_current_multiplier()
	return true


func _random_multiplier() -> float:
	return MULTIPLIER_POOL[rng.randi_range(0, MULTIPLIER_POOL.size() - 1)]


func _on_wallet_money_changed(_money: Big) -> void:
	_update_money_text()


func _select_bet(percent: float) -> void:
	if round_started:
		_set_status("No puedes cambiar la apuesta durante la ronda")
		return

	selected_bet_percent = percent
	_update_bet_button_visuals()
	_update_money_text()


func _update_bet_button_visuals() -> void:
	var percent_by_button := {
		bet_10_button: 0.10,
		bet_25_button: 0.25,
		bet_50_button: 0.50,
		bet_100_button: 1.00,
	}

	for button in percent_by_button:
		if is_equal_approx(percent_by_button[button], selected_bet_percent):
			button.modulate = Color(1, 1, 1, 1)
		else:
			button.modulate = Color(0.72, 0.72, 0.72, 1)


func _start_round_if_needed() -> bool:
	if round_started:
		return true

	var wallet: Big = GameManager.get_current_money()
	if wallet.isLessThanOrEqualTo(0):
		_set_status("No tienes dinero para apostar")
		AudioManager.play_sound("Deny")
		return false

	var bet_amount: Big = Big.roundDown(Big.times(wallet, selected_bet_percent))
	if bet_amount.isLessThanOrEqualTo(0):
		bet_amount = Big.new(wallet)

	if not GameManager.try_buy(bet_amount):
		_set_status("Saldo insuficiente para iniciar")
		return false

	initial_bet = Big.new(bet_amount)
	accumulated_money = Big.new(bet_amount)
	round_started = true
	_set_status("Ronda iniciada, sigue con Step o cobra con Stand")
	_update_money_text()
	return true


func _on_step_pressed() -> void:
	if round_finished or is_animating:
		return

	if tile_labels.is_empty():
		_set_status("No hay baldosas disponibles")
		return

	if not _start_round_if_needed():
		return

	is_animating = true
	step_button.disabled = true
	stand_button.disabled = true

	_animate_step()
	_resolve_landing()
	
	if round_finished:
		return

	is_animating = false
	step_button.disabled = false
	stand_button.disabled = false


func _on_stand_pressed() -> void:
	if is_animating or round_finished:
		return

	round_finished = true

	if round_started and accumulated_money.isGreaterThan(0):
		GameManager.add_money(accumulated_money)
		_set_status("Te plantas y cobras " + accumulated_money.toAA() + "€")
		await get_tree().create_timer(0.2).timeout

	queue_free()


func _animate_step() -> void:
	var tile_shift := _get_tile_shift()
	if character_jump_texture != null:
		character.texture = character_jump_texture

	var character_base_position = character.position
	var jump_up_pos:Vector2 = character_base_position + Vector2(0, -CHARACTER_JUMP_HEIGHT)
	var track_target_pos := tiles_hbox.position + Vector2(-tile_shift, 0)

	var jump_tween := create_tween()
	jump_tween.tween_property(character, "position", jump_up_pos, STEP_DURATION * 0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	jump_tween.tween_property(character, "position", character_base_position, STEP_DURATION * 0.55).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)

	var track_tween := create_tween()
	track_tween.tween_property(tiles_hbox, "position", track_target_pos, STEP_DURATION).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	await get_tree().create_timer(STEP_DURATION + 0.08, true).timeout
	if character_idle_texture != null:
		character.texture = character_idle_texture
	_settle_tiles_after_step()


func _get_tile_shift() -> float:
	if tile_panels.is_empty():
		return TILE_WIDTH

	var first_tile := tile_panels[0]
	var tile_width := first_tile.size.x
	if tile_width <= 0.0:
		tile_width = first_tile.custom_minimum_size.x
	if tile_width <= 0.0:
		tile_width = TILE_WIDTH
	var separation := float(tiles_hbox.get_theme_constant("separation"))
	return tile_width + separation


func _settle_tiles_after_step() -> void:
	if tile_values.is_empty() or tile_labels.is_empty():
		return
		
	current_tile_index += 1
	if current_tile_index >= tile_values.size(): 
		current_tile_index = 0
		_on_stand_pressed()
	else:
		_update_tile_labels()
		_update_current_multiplier()


func _resolve_landing() -> void:
	if rng.randf() <= SUCCESS_CHANCE:
		accumulated_money = Big.times(accumulated_money, current_multiplier)
		_set_status("Exito: x" + _format_multiplier(current_multiplier))
		AudioManager.play_sound("Coin")
		_update_money_text()
		return

	accumulated_money = Big.new(0)
	_update_money_text()
	if character_fail_texture != null:
		character.texture = character_fail_texture
	_set_status("Error: pierdes todo lo acumulado")
	AudioManager.play_sound("Deny")
	round_finished = true
	await get_tree().create_timer(0.75).timeout
	queue_free()


func _update_tile_labels() -> void:
	for i in range(tile_labels.size()):
		var multiplier: float = tile_values[i]
		tile_labels[i].text = "x" + _format_multiplier(multiplier)
		tile_panels[i].self_modulate = _tile_color_for(multiplier)


func _tile_color_for(multiplier: float) -> Color:
	var t:float = clamp((multiplier - 1.2) / 1.8, 0.0, 1.0)
	return Color(0.19 + 0.45 * t, 0.23 + 0.34 * t, 0.18, 1.0)


func _update_current_multiplier() -> void:
	current_multiplier = tile_values[current_tile_index]
	multiplier_text.text = "Multiplicador actual: x" + _format_multiplier(current_multiplier)


func _update_money_text() -> void:
	var wallet: Big = GameManager.get_current_money()
	var preview_bet: Big

	if round_started:
		preview_bet = initial_bet
	else:
		preview_bet = Big.roundDown(Big.times(wallet, selected_bet_percent))
		if preview_bet.isLessThanOrEqualTo(0) and wallet.isGreaterThan(0):
			preview_bet = Big.new(wallet)

	var pot_to_show: Big = accumulated_money if round_started else Big.new(0)

	money_text.text = "Wallet: %s€  |  Pot: %s€  |  Bet %d%%: %s€" % [
		wallet.toAA(),
		pot_to_show.toAA(),
		int(selected_bet_percent * 100.0),
		preview_bet.toAA(),
	]


func _set_status(message: String) -> void:
	status_text.text = message


func _format_multiplier(value: float) -> String:
	if is_equal_approx(value, round(value)):
		return str(int(round(value)))

	var text := String.num(value, 2)
	while text.ends_with("0"):
		text = text.left(text.length() - 1)
	if text.ends_with("."):
		text = text.left(text.length() - 1)
	return text


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_on_stand_pressed()
