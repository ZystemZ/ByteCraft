extends RefCounted
class_name ByteCrafterSettingsStore

const CONFIG_PATH := "user://bytecrafter_settings.cfg"
const RESOLUTIONS := ["960x540", "1280x720", "1600x900", "1920x1080"]
const QUALITIES := ["baixa", "media", "alta"]
const SHADERS := ["normal", "retrobit", "celshading"]
const VERTICAL_SYNC := ["ligado", "adaptativo", "desligado"]
const DEFAULT_OPTIONS := {
	"audio": {"music": 0.85, "effects": 0.90},
	"video": {"resolution": "1280x720", "fullscreen": false, "quality": "media", "shader": "normal", "vsync": "ligado"},
	"gameplay": {"monsters": true, "chunk_radius": 2, "fov": 76.0},
}
const CONTROL_DEFS := [
	{"id": "move_up", "label": "Mover para frente", "key": KEY_W, "axis": JOY_AXIS_LEFT_Y, "axis_value": -1.0, "axis_label": "Analógico esquerdo ↑"},
	{"id": "move_down", "label": "Mover para trás", "key": KEY_S, "axis": JOY_AXIS_LEFT_Y, "axis_value": 1.0, "axis_label": "Analógico esquerdo ↓"},
	{"id": "move_left", "label": "Mover à esquerda", "key": KEY_A, "axis": JOY_AXIS_LEFT_X, "axis_value": -1.0, "axis_label": "Analógico esquerdo ←"},
	{"id": "move_right", "label": "Mover à direita", "key": KEY_D, "axis": JOY_AXIS_LEFT_X, "axis_value": 1.0, "axis_label": "Analógico esquerdo →"},
	{"id": "jump", "label": "Pular", "key": KEY_SPACE, "button": JOY_BUTTON_A},
	{"id": "sprint", "label": "Correr", "key": KEY_SHIFT, "button": JOY_BUTTON_LEFT_STICK},
	{"id": "attack_mine", "label": "Atacar / minerar", "key": KEY_G, "axis": JOY_AXIS_TRIGGER_RIGHT, "axis_value": 1.0, "axis_label": "Gatilho direito", "mouse": MOUSE_BUTTON_LEFT},
	{"id": "use_item", "label": "Usar / posicionar item", "key": KEY_R, "button": JOY_BUTTON_B, "mouse": MOUSE_BUTTON_RIGHT},
	{"id": "interact", "label": "Interagir", "key": KEY_F, "button": JOY_BUTTON_X},
	{"id": "inventory", "label": "Mochila / crafting", "key": KEY_E, "button": JOY_BUTTON_Y},
	{"id": "toggle_camera", "label": "Alternar câmera", "key": KEY_V, "button": JOY_BUTTON_RIGHT_STICK},
	{"id": "pause", "label": "Pausar / voltar", "key": KEY_ESCAPE, "button": JOY_BUTTON_START},
	{"id": "place_table", "label": "Colocar mesa de craft", "key": KEY_T},
	{"id": "farm_action", "label": "Ação de plantio", "key": KEY_P, "button": JOY_BUTTON_LEFT_SHOULDER},
	{"id": "save_game", "label": "Salvar agora", "key": KEY_F5},
	{"id": "slot_1", "label": "Atalho 1", "key": KEY_1, "button": JOY_BUTTON_DPAD_UP},
	{"id": "slot_2", "label": "Atalho 2", "key": KEY_2, "button": JOY_BUTTON_DPAD_RIGHT},
	{"id": "slot_3", "label": "Atalho 3", "key": KEY_3, "button": JOY_BUTTON_DPAD_DOWN},
	{"id": "slot_4", "label": "Atalho 4", "key": KEY_4, "button": JOY_BUTTON_DPAD_LEFT},
	{"id": "slot_5", "label": "Atalho 5", "key": KEY_5},
	{"id": "slot_6", "label": "Atalho 6", "key": KEY_6},
	{"id": "slot_7", "label": "Atalho 7", "key": KEY_7},
	{"id": "slot_8", "label": "Atalho 8", "key": KEY_8},
	{"id": "slot_9", "label": "Atalho 9", "key": KEY_9},
]

var options: Dictionary = DEFAULT_OPTIONS.duplicate(true)
var _config := ConfigFile.new()


func load_settings() -> void:
	options = DEFAULT_OPTIONS.duplicate(true)
	_config = ConfigFile.new()
	_config.load(CONFIG_PATH)
	for section_value: Variant in DEFAULT_OPTIONS.keys():
		var section := str(section_value)
		var defaults: Dictionary = DEFAULT_OPTIONS[section]
		var loaded_section: Dictionary = {}
		for key_value: Variant in defaults.keys():
			var key := str(key_value)
			loaded_section[key] = _validate_value(section, key, _config.get_value(section, key, defaults[key]), defaults[key])
		options[section] = loaded_section
	configure_input_map()
	apply_audio_settings()
	apply_display_settings()


func get_value(section: String, key: String, fallback: Variant = null) -> Variant:
	var values: Variant = options.get(section, {})
	return values.get(key, fallback) if values is Dictionary else fallback


func set_value(section: String, key: String, value: Variant, persist: bool = true) -> void:
	var defaults: Dictionary = DEFAULT_OPTIONS.get(section, {})
	if not defaults.has(key):
		return
	var checked: Variant = _validate_value(section, key, value, defaults[key])
	var values: Dictionary = options.get(section, {}).duplicate(true)
	values[key] = checked
	options[section] = values
	if persist:
		_config.set_value(section, key, checked)
		_config.save(CONFIG_PATH)


func get_control_defs() -> Array:
	return CONTROL_DEFS.duplicate(true)


func get_binding_text(action_id: String, device: String) -> String:
	if not InputMap.has_action(action_id):
		return "—"
	for event: InputEvent in InputMap.action_get_events(action_id):
		if device == "keyboard" and event is InputEventKey:
			var text := event.as_text().replace(" (Physical)", "")
			return text if not text.is_empty() else "—"
		if device == "joypad" and event is InputEventJoypadButton:
			return _joy_button_name(event.button_index)
		if device == "joypad" and event is InputEventJoypadMotion:
			return _joy_axis_name(event.axis, event.axis_value)
	return "—"


func set_binding(action_id: String, device: String, event: InputEvent) -> bool:
	if action_id.is_empty() or not InputMap.has_action(action_id) or device not in ["keyboard", "joypad"] or event == null:
		return false
	var copied := event.duplicate() as InputEvent
	copied.device = -1
	if device == "keyboard" and not copied is InputEventKey:
		return false
	if device == "joypad" and not (copied is InputEventJoypadButton or copied is InputEventJoypadMotion):
		return false
	for old_event: InputEvent in InputMap.action_get_events(action_id).duplicate():
		if _event_matches_device(old_event, device):
			InputMap.action_erase_event(action_id, old_event)
	InputMap.action_add_event(action_id, copied)
	_config.set_value("controls", action_id + "_" + device, _serialize_event(copied))
	_config.save(CONFIG_PATH)
	return true


func configure_input_map() -> void:
	for definition_value: Variant in CONTROL_DEFS:
		var definition: Dictionary = definition_value
		var action_id := str(definition.id)
		if not InputMap.has_action(action_id):
			InputMap.add_action(action_id, 0.22)
		else:
			InputMap.action_set_deadzone(action_id, 0.22)
		for old_event: InputEvent in InputMap.action_get_events(action_id).duplicate():
			if old_event is InputEventKey or old_event is InputEventJoypadButton or old_event is InputEventJoypadMotion or old_event is InputEventMouseButton:
				InputMap.action_erase_event(action_id, old_event)
		var key_value: Variant = _config.get_value("controls", action_id + "_keyboard", {})
		var key_event: InputEvent = _make_key_event(int(definition.get("key", 0)))
		if key_value is Dictionary and not key_value.is_empty():
			var loaded_key := _deserialize_event(key_value)
			if loaded_key is InputEventKey:
				key_event = loaded_key
		if key_event is InputEventKey:
			InputMap.action_add_event(action_id, key_event)
		var joy_value: Variant = _config.get_value("controls", action_id + "_joypad", {})
		var joy_event: InputEvent = _make_joy_event(definition)
		if joy_value is Dictionary and not joy_value.is_empty():
			var loaded_joy := _deserialize_event(joy_value)
			if loaded_joy is InputEventJoypadButton or loaded_joy is InputEventJoypadMotion:
				joy_event = loaded_joy
		if joy_event != null:
			InputMap.action_add_event(action_id, joy_event)
		if definition.has("mouse"):
			var mouse_event := InputEventMouseButton.new()
			mouse_event.button_index = int(definition.mouse)
			InputMap.action_add_event(action_id, mouse_event)


func apply_audio_settings() -> void:
	var mappings := {"Music": "music", "SFX": "effects", "UI": "effects"}
	for bus_name: String in mappings:
		var bus_index := AudioServer.get_bus_index(bus_name)
		if bus_index < 0:
			continue
		var linear_volume := clampf(float(get_value("audio", mappings[bus_name], 0.85)), 0.0, 1.0)
		AudioServer.set_bus_volume_db(bus_index, linear_to_db(maxf(linear_volume, 0.0001)))
		AudioServer.set_bus_mute(bus_index, linear_volume <= 0.0)


func apply_display_settings() -> void:
	if OS.has_feature("web"):
		return
	var resolution_parts := str(get_value("video", "resolution", "1280x720")).split("x")
	if resolution_parts.size() == 2:
		var size := Vector2i(int(resolution_parts[0]), int(resolution_parts[1]))
		DisplayServer.window_set_size(size)
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if bool(get_value("video", "fullscreen", false)) else DisplayServer.WINDOW_MODE_WINDOWED)
	var vsync_value := str(get_value("video", "vsync", "ligado"))
	match vsync_value:
		"adaptativo":
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ADAPTIVE)
		"desligado":
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		_:
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)


func _validate_value(section: String, key: String, value: Variant, fallback: Variant) -> Variant:
	match section:
		"audio":
			return clampf(float(value), 0.0, 1.0)
		"video":
			match key:
				"resolution": return str(value) if str(value) in RESOLUTIONS else fallback
				"fullscreen": return bool(value)
				"quality": return str(value) if str(value) in QUALITIES else fallback
				"shader": return str(value) if str(value) in SHADERS else fallback
				"vsync": return str(value) if str(value) in VERTICAL_SYNC else fallback
		"gameplay":
			match key:
				"monsters": return bool(value)
				"chunk_radius": return clampi(int(value), 1, 4)
				"fov": return clampf(float(value), 60.0, 110.0)
	return fallback


func _make_key_event(keycode: int) -> InputEventKey:
	var event := InputEventKey.new()
	event.device = -1
	event.physical_keycode = keycode
	event.keycode = keycode
	return event


func _make_joy_event(definition: Dictionary) -> InputEvent:
	if definition.has("button"):
		var button := InputEventJoypadButton.new()
		button.device = -1
		button.button_index = int(definition.button)
		return button
	if definition.has("axis"):
		var motion := InputEventJoypadMotion.new()
		motion.device = -1
		motion.axis = int(definition.axis)
		motion.axis_value = float(definition.get("axis_value", 1.0))
		return motion
	return null


func _serialize_event(event: InputEvent) -> Dictionary:
	if event is InputEventKey:
		return {"kind": "key", "keycode": event.keycode, "physical": event.physical_keycode}
	if event is InputEventJoypadButton:
		return {"kind": "button", "button": event.button_index}
	if event is InputEventJoypadMotion:
		return {"kind": "axis", "axis": event.axis, "value": event.axis_value}
	return {}


func _deserialize_event(data: Dictionary) -> InputEvent:
	match str(data.get("kind", "")):
		"key":
			var key := InputEventKey.new()
			key.device = -1
			key.keycode = int(data.get("keycode", 0))
			key.physical_keycode = int(data.get("physical", key.keycode))
			return key
		"button":
			var button := InputEventJoypadButton.new()
			button.device = -1
			button.button_index = int(data.get("button", 0))
			return button
		"axis":
			var motion := InputEventJoypadMotion.new()
			motion.device = -1
			motion.axis = int(data.get("axis", 0))
			motion.axis_value = clampf(float(data.get("value", 1.0)), -1.0, 1.0)
			return motion
	return null


func _event_matches_device(event: InputEvent, device: String) -> bool:
	if device == "keyboard":
		return event is InputEventKey
	return event is InputEventJoypadButton or event is InputEventJoypadMotion


func _joy_button_name(button_index: int) -> String:
	var names := {
		JOY_BUTTON_A: "A", JOY_BUTTON_B: "B", JOY_BUTTON_X: "X", JOY_BUTTON_Y: "Y",
		JOY_BUTTON_BACK: "Voltar", JOY_BUTTON_START: "Start", JOY_BUTTON_LEFT_STICK: "L3",
		JOY_BUTTON_RIGHT_STICK: "R3", JOY_BUTTON_LEFT_SHOULDER: "LB", JOY_BUTTON_RIGHT_SHOULDER: "RB",
		JOY_BUTTON_DPAD_UP: "Direcional ↑", JOY_BUTTON_DPAD_DOWN: "Direcional ↓",
		JOY_BUTTON_DPAD_LEFT: "Direcional ←", JOY_BUTTON_DPAD_RIGHT: "Direcional →",
	}
	return str(names.get(button_index, "Botão %d" % button_index))


func _joy_axis_name(axis: int, value: float) -> String:
	if axis == JOY_AXIS_LEFT_X:
		return "Analógico esquerdo →" if value > 0.0 else "Analógico esquerdo ←"
	if axis == JOY_AXIS_LEFT_Y:
		return "Analógico esquerdo ↓" if value > 0.0 else "Analógico esquerdo ↑"
	if axis == JOY_AXIS_RIGHT_X:
		return "Analógico direito →" if value > 0.0 else "Analógico direito ←"
	if axis == JOY_AXIS_RIGHT_Y:
		return "Analógico direito ↓" if value > 0.0 else "Analógico direito ↑"
	if axis == JOY_AXIS_TRIGGER_LEFT:
		return "Gatilho esquerdo"
	if axis == JOY_AXIS_TRIGGER_RIGHT:
		return "Gatilho direito"
	return "Eixo %d" % axis
