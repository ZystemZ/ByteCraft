extends Control
class_name ByteCrafterSettingsPanel

signal options_changed(section: String, key: String)
signal binding_capture_requested(action_id: String, device: String)
signal new_world_requested(difficulty: String)
signal continue_requested(difficulty: String)
signal closed(paused_context: bool)

const UI := preload("res://scripts/ui/screen_factory.gd")

var store: ByteCrafterSettingsStore
var _settings_overlay: Control
var _difficulty_overlay: Control
var _controls_list: VBoxContainer
var _difficulty_description: Label
var _difficulty_heading: Label
var _difficulty_prompt: Label
var _difficulty_start_button: Button
var _difficulty_choices: Dictionary = {}
var _difficulty_selected := "normal"
var _creating_new_world := true
var _opened_from_pause := false


func configure(settings_store: ByteCrafterSettingsStore) -> void:
	store = settings_store
	process_mode = Node.PROCESS_MODE_ALWAYS
	UI.full_rect(self)
	visible = false
	_build_settings_overlay()
	_build_difficulty_overlay()


func is_settings_open() -> bool:
	return _settings_overlay != null and _settings_overlay.visible


func is_difficulty_open() -> bool:
	return _difficulty_overlay != null and _difficulty_overlay.visible


func open_settings(paused_context: bool = false) -> void:
	_opened_from_pause = paused_context
	visible = true
	_settings_overlay.visible = true
	_difficulty_overlay.visible = false
	refresh_controls()


func open_difficulty_selector(selected: String = "normal", create_new_world: bool = true) -> void:
	_difficulty_selected = selected if selected in ["easy", "normal", "hard"] else "normal"
	_creating_new_world = create_new_world
	visible = true
	_settings_overlay.visible = false
	_difficulty_overlay.visible = true
	_difficulty_heading.text = "NOVO MUNDO SOLO" if _creating_new_world else "CONTINUAR MUNDO SOLO"
	_difficulty_prompt.text = "Escolha a dificuldade antes de criar seu mundo." if _creating_new_world else "Escolha o nível desta sessão; o progresso do mundo será mantido."
	_difficulty_start_button.text = "CRIAR MUNDO" if _creating_new_world else "CONTINUAR EXPLORAÇÃO"
	_refresh_difficulty_choices()


func close_active() -> void:
	if is_settings_open():
		_settings_overlay.visible = false
		visible = false
		closed.emit(_opened_from_pause)
	elif is_difficulty_open():
		_difficulty_overlay.visible = false
		visible = false


func refresh_controls() -> void:
	if store == null or _controls_list == null:
		return
	for child: Node in _controls_list.get_children():
		child.queue_free()
	var header := HBoxContainer.new()
	_controls_list.add_child(header)
	_add_header(header, "AÇÃO", 1.0)
	_add_header(header, "TECLADO", 0.78)
	_add_header(header, "CONTROLE", 0.9)
	for definition_value: Variant in store.get_control_defs():
		var definition: Dictionary = definition_value
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)
		_controls_list.add_child(row)
		var label := UI.label(str(definition.label), 12, Color("e5e7da"))
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label.custom_minimum_size.x = 230.0
		row.add_child(label)
		var key_button := UI.quiet_button(store.get_binding_text(str(definition.id), "keyboard"), 11)
		key_button.custom_minimum_size = Vector2(150.0, 34.0)
		key_button.pressed.connect(_request_capture.bind(str(definition.id), "keyboard"))
		row.add_child(key_button)
		var joy_button := UI.quiet_button(store.get_binding_text(str(definition.id), "joypad"), 11)
		joy_button.custom_minimum_size = Vector2(190.0, 34.0)
		joy_button.pressed.connect(_request_capture.bind(str(definition.id), "joypad"))
		row.add_child(joy_button)


func set_capture_prompt(action_id: String, device: String) -> void:
	if _controls_list == null:
		return
	for row: Node in _controls_list.get_children():
		if row is not HBoxContainer or row.get_child_count() < 3:
			continue
		var label := row.get_child(0) as Label
		if label == null:
			continue
		var definition := _find_control_def(action_id)
		if definition.is_empty() or label.text != str(definition.label):
			continue
		var button_index := 1 if device == "keyboard" else 2
		var button := row.get_child(button_index) as Button
		if button != null:
			button.text = "Pressione uma tecla…" if device == "keyboard" else "Pressione botão/eixo…"
			button.grab_focus()
		return


func _find_control_def(action_id: String) -> Dictionary:
	if store == null:
		return {}
	for value: Variant in store.get_control_defs():
		var definition: Dictionary = value
		if str(definition.id) == action_id:
			return definition
	return {}


func _request_capture(action_id: String, device: String) -> void:
	binding_capture_requested.emit(action_id, device)


func _build_settings_overlay() -> void:
	_settings_overlay = Control.new()
	_settings_overlay.name = "SettingsOverlay"
	_settings_overlay.visible = false
	_settings_overlay.process_mode = Node.PROCESS_MODE_ALWAYS
	UI.full_rect(_settings_overlay)
	add_child(_settings_overlay)
	var shade := ColorRect.new()
	shade.color = Color(0.015, 0.025, 0.035, 0.88)
	shade.mouse_filter = Control.MOUSE_FILTER_STOP
	UI.full_rect(shade)
	_settings_overlay.add_child(shade)
	var center := CenterContainer.new()
	UI.full_rect(center)
	_settings_overlay.add_child(center)
	var viewport_size := get_viewport_rect().size
	var panel := UI.holo_panel(Color("89b578"), Vector2(20.0, 16.0))
	panel.name = "SettingsPanel"
	panel.custom_minimum_size = Vector2(minf(viewport_size.x * 0.90, 980.0), minf(viewport_size.y * 0.90, 660.0))
	center.add_child(panel)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 10)
	panel.add_child(content)
	var header := HBoxContainer.new()
	content.add_child(header)
	var title := UI.display_label("CONFIGURAÇÕES", 26, Color("f1ead8"), "heading")
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)
	var close := UI.quiet_button("Fechar (Esc)", 12)
	close.pressed.connect(close_active)
	header.add_child(close)
	var tabs := TabContainer.new()
	tabs.size_flags_vertical = Control.SIZE_EXPAND_FILL
	tabs.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_child(tabs)
	_add_controls_tab(tabs)
	_add_audio_tab(tabs)
	_add_video_tab(tabs)
	_add_gameplay_tab(tabs)


func _add_controls_tab(tabs: TabContainer) -> void:
	var scroll := ScrollContainer.new()
	scroll.name = "Controles"
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	tabs.add_child(scroll)
	var page := VBoxContainer.new()
	page.add_theme_constant_override("separation", 8)
	page.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(page)
	page.add_child(UI.label("Escolha um campo e pressione a tecla, botão ou eixo que deseja associar. As alterações são salvas automaticamente.", 12, Color("d0d5c6")))
	_controls_list = VBoxContainer.new()
	_controls_list.add_theme_constant_override("separation", 5)
	page.add_child(_controls_list)
	refresh_controls()
	page.add_child(UI.label("Mouse: botão esquerdo ataca/minera; botão direito usa ou posiciona o item selecionado; roda troca o atalho.", 11, Color("aeb8a4")))


func _add_header(row: HBoxContainer, text: String, expand: float) -> void:
	var label := UI.label(text, 10, Color("b5d49b"))
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL if expand >= 1.0 else Control.SIZE_SHRINK_BEGIN
	label.custom_minimum_size.x = 230.0 if expand >= 1.0 else (150.0 if text == "TECLADO" else 190.0)
	row.add_child(label)


func _add_audio_tab(tabs: TabContainer) -> void:
	var page := VBoxContainer.new()
	page.name = "Som"
	page.add_theme_constant_override("separation", 18)
	tabs.add_child(page)
	page.add_child(UI.label("Ajuste música e efeitos separadamente. O áudio pode permanecer silencioso quando uma faixa ou efeito não tem arquivo associado.", 12, Color("d0d5c6")))
	_add_slider(page, "Volume da música", "audio", "music", 0.0, 1.0, 0.01, "%d%%")
	_add_slider(page, "Volume dos efeitos e da interface", "audio", "effects", 0.0, 1.0, 0.01, "%d%%")


func _add_video_tab(tabs: TabContainer) -> void:
	var scroll := ScrollContainer.new()
	scroll.name = "Vídeo"
	tabs.add_child(scroll)
	var page := VBoxContainer.new()
	page.add_theme_constant_override("separation", 12)
	scroll.add_child(page)
	page.add_child(UI.label("A resolução e a tela cheia só podem ser alteradas em uma build nativa. As opções gráficas são aplicadas imediatamente.", 12, Color("d0d5c6")))
	_add_option(page, "Resolução", ByteCrafterSettingsStore.RESOLUTIONS, str(store.get_value("video", "resolution", "1280x720")), "video", "resolution", _resolution_label)
	var fullscreen := CheckButton.new()
	fullscreen.text = "Tela cheia"
	fullscreen.button_pressed = bool(store.get_value("video", "fullscreen", false))
	fullscreen.toggled.connect(_on_toggle.bind("video", "fullscreen"))
	fullscreen.disabled = OS.has_feature("web")
	page.add_child(fullscreen)
	_add_option(page, "Qualidade gráfica", ByteCrafterSettingsStore.QUALITIES, str(store.get_value("video", "quality", "media")), "video", "quality", _quality_label)
	_add_option(page, "Filtro de imagem", ByteCrafterSettingsStore.SHADERS, str(store.get_value("video", "shader", "normal")), "video", "shader", _shader_label)
	_add_option(page, "Sincronização vertical", ByteCrafterSettingsStore.VERTICAL_SYNC, str(store.get_value("video", "vsync", "ligado")), "video", "vsync", _vsync_label)
	_add_slider(page, "Campo de visão", "gameplay", "fov", 60.0, 110.0, 1.0, "%d°")


func _add_gameplay_tab(tabs: TabContainer) -> void:
	var page := VBoxContainer.new()
	page.name = "Jogabilidade"
	page.add_theme_constant_override("separation", 14)
	tabs.add_child(page)
	page.add_child(UI.label("Opções de desempenho e exploração. A distância de chunks também limita o trabalho de geração de terreno.", 12, Color("d0d5c6")))
	var monsters := CheckButton.new()
	monsters.text = "Permitir monstros hostis"
	monsters.button_pressed = bool(store.get_value("gameplay", "monsters", true))
	monsters.toggled.connect(_on_toggle.bind("gameplay", "monsters"))
	page.add_child(monsters)
	_add_slider(page, "Distância de visão (anéis de chunks)", "gameplay", "chunk_radius", 1.0, 4.0, 1.0, "%d")
	page.add_child(UI.label("1 = desempenho maior e visão curta; 4 = visão longa e maior uso de memória. A dificuldade é escolhida na criação de um novo mundo.", 11, Color("aeb8a4")))


func _add_slider(parent: Control, title_text: String, section: String, key: String, minimum: float, maximum: float, step: float, value_format: String) -> void:
	var row := VBoxContainer.new()
	row.add_theme_constant_override("separation", 4)
	parent.add_child(row)
	var heading := HBoxContainer.new()
	row.add_child(heading)
	var title := UI.label(title_text, 13, Color("e5e7da"))
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	heading.add_child(title)
	var value_label := UI.label(_format_value(float(store.get_value(section, key, minimum)), value_format), 12, Color("b5d49b"))
	heading.add_child(value_label)
	var slider := HSlider.new()
	slider.min_value = minimum
	slider.max_value = maximum
	slider.step = step
	slider.value = clampf(float(store.get_value(section, key, minimum)), minimum, maximum)
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.value_changed.connect(_on_slider_changed.bind(section, key, value_label, value_format))
	slider.drag_ended.connect(_on_slider_released.bind(section, key, slider))
	row.add_child(slider)


func _on_slider_changed(value: float, section: String, key: String, value_label: Label, value_format: String) -> void:
	store.set_value(section, key, value, false)
	value_label.text = _format_value(value, value_format)
	options_changed.emit(section, key)


func _on_slider_released(_changed: bool, section: String, key: String, slider: HSlider) -> void:
	store.set_value(section, key, slider.value, true)
	options_changed.emit(section, key)


func _on_toggle(value: bool, section: String, key: String) -> void:
	store.set_value(section, key, value)
	options_changed.emit(section, key)


func _add_option(parent: Control, title_text: String, values: Array, current: String, section: String, key: String, label_func: Callable) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 14)
	parent.add_child(row)
	var title := UI.label(title_text, 13, Color("e5e7da"))
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(title)
	var option := OptionButton.new()
	option.custom_minimum_size = Vector2(250.0, 34.0)
	for value: Variant in values:
		option.add_item(str(label_func.call(str(value))))
		option.set_item_metadata(option.item_count - 1, str(value))
		if str(value) == current:
			option.select(option.item_count - 1)
	option.item_selected.connect(_on_option_selected.bind(option, section, key))
	if OS.has_feature("web") and key == "resolution":
		option.disabled = true
	row.add_child(option)


func _on_option_selected(index: int, option: OptionButton, section: String, key: String) -> void:
	var value: Variant = option.get_item_metadata(index)
	store.set_value(section, key, value)
	options_changed.emit(section, key)


func _resolution_label(value: String) -> String:
	return value.replace("x", " × ")


func _quality_label(value: String) -> String:
	return {"baixa": "Baixa", "media": "Média", "alta": "Alta"}.get(value, value)


func _shader_label(value: String) -> String:
	return {"normal": "Normal", "retrobit": "Retrobit", "celshading": "Cel shading"}.get(value, value)


func _vsync_label(value: String) -> String:
	return {"ligado": "Ligado", "adaptativo": "Adaptativo", "desligado": "Desligado"}.get(value, value)


func _format_value(value: float, value_format: String) -> String:
	if value_format == "%d%%":
		return "%d%%" % roundi(value * 100.0)
	if value_format == "%d°":
		return "%d°" % roundi(value)
	return "%d" % roundi(value)


func _build_difficulty_overlay() -> void:
	_difficulty_overlay = Control.new()
	_difficulty_overlay.name = "DifficultySelector"
	_difficulty_overlay.visible = false
	_difficulty_overlay.process_mode = Node.PROCESS_MODE_ALWAYS
	UI.full_rect(_difficulty_overlay)
	add_child(_difficulty_overlay)
	var shade := ColorRect.new()
	shade.color = Color(0.015, 0.025, 0.035, 0.90)
	shade.mouse_filter = Control.MOUSE_FILTER_STOP
	UI.full_rect(shade)
	_difficulty_overlay.add_child(shade)
	var center := CenterContainer.new()
	UI.full_rect(center)
	_difficulty_overlay.add_child(center)
	var panel := UI.holo_panel(Color("e0b86f"), Vector2(28.0, 24.0))
	panel.custom_minimum_size = Vector2(620.0, 0.0)
	center.add_child(panel)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 12)
	panel.add_child(content)
	_difficulty_heading = UI.display_label("NOVO MUNDO SOLO", 28, Color("f1ead8"), "heading")
	_difficulty_heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content.add_child(_difficulty_heading)
	_difficulty_prompt = UI.label("Escolha a dificuldade antes de criar seu mundo.", 13, Color("d0d5c6"))
	content.add_child(_difficulty_prompt)
	var choices := HBoxContainer.new()
	choices.add_theme_constant_override("separation", 8)
	content.add_child(choices)
	for difficulty: String in ["easy", "normal", "hard"]:
		var button := UI.button(_difficulty_title(difficulty), 172.0)
		button.toggle_mode = true
		button.pressed.connect(_select_difficulty.bind(difficulty))
		choices.add_child(button)
		_difficulty_choices[difficulty] = button
	_difficulty_description = UI.label("", 12, Color("e2dfd0"))
	_difficulty_description.custom_minimum_size.y = 48.0
	_difficulty_description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content.add_child(_difficulty_description)
	_difficulty_start_button = UI.button("CRIAR MUNDO", 280.0)
	UI.primary(_difficulty_start_button)
	_difficulty_start_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_difficulty_start_button.pressed.connect(_confirm_new_world)
	content.add_child(_difficulty_start_button)
	var cancel := UI.quiet_button("Cancelar", 12)
	cancel.pressed.connect(close_active)
	cancel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	content.add_child(cancel)


func _select_difficulty(difficulty: String) -> void:
	_difficulty_selected = difficulty if difficulty in ["easy", "normal", "hard"] else "normal"
	_refresh_difficulty_choices()


func _refresh_difficulty_choices() -> void:
	for difficulty: String in _difficulty_choices:
		var button := _difficulty_choices[difficulty] as Button
		if button != null:
			button.button_pressed = difficulty == _difficulty_selected
	if _difficulty_description != null:
		_difficulty_description.text = _difficulty_description_for(_difficulty_selected)


func _confirm_new_world() -> void:
	_difficulty_overlay.visible = false
	visible = false
	if _creating_new_world:
		new_world_requested.emit(_difficulty_selected)
	else:
		continue_requested.emit(_difficulty_selected)


func _difficulty_title(value: String) -> String:
	return {"easy": "FÁCIL", "normal": "MÉDIO", "hard": "DIFÍCIL"}.get(value, "MÉDIO")


func _difficulty_description_for(value: String) -> String:
	return {
		"easy": "Menos monstros, dano reduzido e fome mais lenta. Indicada para explorar e construir.",
		"normal": "Combate e sobrevivência equilibrados. A experiência padrão do ByteCrafter.",
		"hard": "Mais dano, encontros mais frequentes e fome mais rápida. Para quem busca desafio.",
	}.get(value, "Combate e sobrevivência equilibrados.")
