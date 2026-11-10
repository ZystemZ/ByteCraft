extends Node3D
class_name ByteCrafterGame

const WORLD_SCRIPT := preload("res://scripts/game/voxel_world.gd")
const PLAYER_SCRIPT := preload("res://scripts/game/bytecrafter_player.gd")
const AVATAR_SCRIPT := preload("res://scripts/game/bytecrafter_avatar.gd")
const MENU_BACKGROUND_TEXTURE := preload("res://assets/ui/menu_background.png")
const LOADING_SCREEN_TEXTURE := preload("res://assets/ui/loading_initial.png")
const GAME_ICON_TEXTURE := preload("res://assets/share/favicon.png")
const VOXEL_ATLAS_TEXTURE := preload("res://assets/textures/voxel_atlas.png")
const CREATURE_SCRIPT := preload("res://scripts/game/bytecrafter_creature.gd")
const ENEMY_SCRIPT := preload("res://scripts/game/bytecrafter_enemy.gd")
const DROP_SCRIPT := preload("res://scripts/game/bytecrafter_drop.gd")
const SHURIKEN_SCRIPT := preload("res://scripts/game/shuriken_projectile.gd")
const PROP_SCRIPT := preload("res://scripts/game/bytecrafter_prop.gd")
const VILLAGE_SYSTEM_SCRIPT := preload("res://scripts/game/bytecrafter_village_system.gd")
const RECIPE_BOOK := preload("res://scripts/game/crafting_recipe_book.gd")
const INVENTORY_SLOT_SCRIPT := preload("res://scripts/game/inventory_slot.gd")
const INVENTORY_STACK_SCRIPT := preload("res://scripts/game/inventory_stack.gd")
const CHEST_MODEL := preload("res://assets/bitmal/Chest by Quaternius - O72u4Drp8k.glb")
const TORCH_MODEL := preload("res://assets/bitmal/Wooden Torch by Quaternius - pNsfJzhXiD.glb")
const BONFIRE_MODEL := preload("res://assets/bitmal/Bonfire by Quaternius - Azj9hJwwwG.glb")
const CRYSTAL_LANTERN_MODEL := preload("res://assets/bitmal/Crystal Block by Quaternius - fGL74AXC4o.glb")
const CRAFTING_TABLE_MODEL := preload("res://assets/bitmal/Crate by Quaternius - CnMGEDwg8s.glb")
const CRATE_MODEL := preload("res://assets/bitmal/Crate by Quaternius - CnMGEDwg8s.glb")
const DOOR_MODEL := preload("res://assets/bitmal/Door by Quaternius - xuFNaNLzfE.glb")
const CROP_MODELS := {
	"carrot": preload("res://assets/bitmal/Carrot by Kenney - 59muuwqSsq.glb"),
	"tomato": preload("res://assets/bitmal/Tomato by Kenney - TZWJgWJs8V.glb"),
	"fruit": preload("res://assets/bitmal/Apple Green by Quaternius - 3VXWnjDOEw.glb"),
}
const UI := preload("res://scripts/ui/screen_factory.gd")
const LICENSES := preload("res://scripts/manus/open_source_licenses.gd")
const SETTINGS_STORE_SCRIPT := preload("res://scripts/game/bytecrafter_settings_store.gd")
const SETTINGS_PANEL_SCRIPT := preload("res://scripts/game/bytecrafter_settings_panel.gd")
const ASYNC_SAVER_SCRIPT := preload("res://scripts/game/bytecrafter_async_saver.gd")
const LAN_PORT := 24567
const PROFILE_PATH := "user://bytecrafter_player.json"
const DEFAULT_HOTBAR_IDS := [1, 2, 3, 4, 6, 7, "picareta", "espada", "tocha"]
const BACKPACK_SIZE := 27
const BREAK_DIST := 7.0
const ITEM_NAMES := {8: "Fruta", 9: "Gelatina", 10: "Fragmento lunar", 11: "Núcleo lunar", 12: "Carne", 13: "Couro", 14: "Lã", 15: "Banha", 16: "Cenoura", 17: "Ferro", 18: "Cristal", 21: "Tijolos", 22: "Tijolos cinzentos", 23: "Carvão", 24: "Bloco de cristal", 25: "Diamante", 26: "Pedra talhada", 27: "Shuriken", 28: "Flores", 29: "Ovo", 30: "Milho", 31: "Alface", 32: "Repolho", 33: "Gema Verde", "sementes_trigo": "Sementes de trigo", "trigo": "Trigo", "mesa_craft": "Mesa de craft", "bau": "Baú", "tocha": "Tocha de madeira", "fogueira": "Fogueira", "lanterna_cristal": "Lanterna de cristal", "caixote": "Caixote", "porta": "Porta", "balde": "Balde", "carne_cozida": "Carne cozida", "carvao": "Carvão", "picareta": "Picareta de madeira", "picareta_pedra": "Picareta de pedra", "picareta_ferro": "Picareta de ferro", "machado_ferro": "Machado de ferro", "pa": "Pá de madeira", "pa_pedra": "Pá de pedra", "pa_ferro": "Pá de ferro", "espada": "Espada de madeira", "espada_pedra": "Espada de pedra", "espada_ferro": "Espada de ferro", "armadura_couro_cabeca": "Capacete de couro", "armadura_couro_peito": "Peitoral de couro", "armadura_couro_pernas": "Calças de couro", "armadura_couro_botas": "Botas de couro"}
const FOOD_NUTRITION := {8: 5.0, 9: 2.0, 12: 3.0, 15: 3.0, 16: 3.0, 29: 3.5, 30: 3.0, 31: 2.5, 32: 2.5, "frutas": 5.0, "gelatina": 2.0, "trigo": 2.0, "carne_cozida": 7.0}
const FOOD_ORDER := ["carne_cozida", "frutas", 12, 29, 16, 30, 15, 31, 32, "gelatina", 9, "trigo"]
const EXTRA_ITEM_IDS := ["fornalha", "alcapao", "janela", "cama", "bedroll", "vidro", "carvao_vegetal", "barraca", "shuriken"]
const EXTRA_ITEM_NAMES := {"fornalha": "Fornalha", "alcapao": "Alçapão", "janela": "Janela de vidro", "cama": "Cama", "bedroll": "Cama portátil", "vidro": "Vidro", "carvao_vegetal": "Carvão vegetal", "barraca": "Barraca de comércio", "shuriken": "Shuriken"}
const FURNACE_FUEL_ITEMS := ["carvao_vegetal", "carvao", 23, 4, 7]
const FURNACE_INPUT_OUTPUT := {13: 17, 6: "vidro", 12: "carne_cozida", 15: "carne_cozida", 4: "carvao_vegetal"}
const AVATAR_IDS := ["boy", "girl", "boy2", "girl2"]
const PROFILE_VERSION := 6
const XP_BY_BLOCK := {1: 1, 2: 1, 3: 3, 4: 2, 5: 1, 6: 1, 7: 1, 21: 4, 22: 4, 23: 5, 24: 8, 25: 12, 26: 3, 27: 2, 28: 2, 29: 2, 30: 2, 31: 2, 32: 2, 34: 1, 35: 1, 36: 1, 37: 1, 38: 1, 39: 3, 40: 4, 41: 1, 42: 1, 43: 1, 44: 8, 45: 12, 46: 5, 47: 4, 48: 5}
const PLAYER_DEATH_DURATION := 1.25
const ENEMY_SCHEDULE_INTERVAL := 0.5
const MAX_ACTIVE_ENEMIES := 5
const MAX_ACTIVE_DROPS := 64
const AUTOSAVE_INTERVAL_SECONDS := 60.0
const VILLAGE_TRADES: Array[Dictionary] = [
	{"title": "3 cenouras → 1 ferro", "cost_item": 16, "cost_count": 3, "reward_item": 17, "reward_count": 1},
	{"title": "2 couros → 4 tábuas", "cost_item": 13, "cost_count": 2, "reward_item": 7, "reward_count": 4},
	{"title": "3 lãs + 2 tábuas → 1 cama", "cost_item": 14, "cost_count": 3, "cost_item_2": 7, "cost_count_2": 2, "reward_item": "cama", "reward_count": 1},
	{"title": "1 gema verde → 2 fragmentos lunares", "cost_item": 33, "cost_count": 1, "reward_item": 10, "reward_count": 2},
]

var _world: ByteCrafterWorld
var _player: ByteCrafterPlayer
var _creatures: Array[ByteCrafterCreature] = []
var _fish: Array[ByteCrafterCreature] = []
var _enemies: Array[ByteCrafterEnemy] = []
var _village_system: ByteCrafterVillageSystem
var _village_update_timer := 0.0
var _environment: Environment
var _sun: DirectionalLight3D
var _sun_disc: MeshInstance3D
var _moon_disc: MeshInstance3D
var _star_field: MultiMeshInstance3D
var _sky_material: ProceduralSkyMaterial
var _cloud_layer: MeshInstance3D
var _screen := "title"
var _network_active := false
var _is_host := false
var _join_pending := false
var _remote_avatars: Dictionary = {}
var _remote_positions: Dictionary = {}
var _pose_timer := 0.0
var _stream_timer := 0.0
var _save_timer := AUTOSAVE_INTERVAL_SECONDS
var _enemy_schedule_timer := 0.0
var _night_spawn_cooldown := 0.0
var _monster_spawn_cooldown := 14.0
var _footstep_timer := 0.0
var _day_phase := 0.22
var _bed_respawn_position := Vector3.ZERO
var _health := 20.0
var _food := 20.0
var _xp := 0
var _level := 1
var _survival_timer := 0.0
var _hunger_tick := 0.0
var _mine_held := false
var _mine_position := Vector3i.ZERO
var _mine_prop: ByteCrafterProp
var _mine_timer := 0.0
var _mine_duration := 1.0
var _attack_cooldown := 0.0
var _damage_invulnerability := 0.0
var _death_in_progress := false
var _selected_slot := 0
var _selected_avatar_id := "boy"
var _inventory: Dictionary = {}
var _hotbar_ids: Array = DEFAULT_HOTBAR_IDS.duplicate(true)
var _backpack_slots: Array = []
var _inventory_state: ByteCrafterInventoryStack = INVENTORY_STACK_SCRIPT.new() as ByteCrafterInventoryStack
var _inventory_signature_cache := ""
var _inventory_layout_signature_cache := ""
var _cursor_stack_label: Label
var _profile_seed := -1
var _profile_position := Vector3.ZERO
var _profile_loaded := false
var _profile_drops: Array = []
var _profile_world_props: Array = []
var _profile_villages: Array = []
var _drop_nodes: Dictionary = {}
var _drop_records: Dictionary = {}
var _fruit_drop_cells: Dictionary = {}
var _fallen_fruit_drop_ids: Dictionary = {}
var _next_drop_id := 1
var _crafting_tables: Array[Node3D] = []
var _world_props: Array[Node3D] = []
var _active_furnace: ByteCrafterProp
var _crops: Dictionary = {}
var _crop_nodes: Dictionary = {}
var _profile_crops: Array = []
var _profile_harvested_plants: Array = []
var _harvested_plant_cells: Array[Vector3i] = []

var _ui_layer: CanvasLayer
var _title_screen: Control
var _title_label: Label
var _title_status: Label
var _ip_input: LineEdit
var _lan_host_button: Button
var _lan_join_button: Button
var _avatar_boy_button: Button
var _avatar_girl_button: Button
var _avatar_boy2_button: Button
var _avatar_girl2_button: Button
var _startup_loading_layer: CanvasLayer
var _startup_loading_started_msec := 0
var _game_hud: Control
var _health_bar: ProgressBar
var _food_bar: ProgressBar
var _level_label: Label
var _xp_bar: ProgressBar
var _position_label: Label
var _game_status: Label
var _hotbar: HBoxContainer
var _hotbar_slots: Array[PanelContainer] = []
var _selected_item_label: Label
var _crosshair: Label
var _mine_progress: ProgressBar
var _craft_panel: PanelContainer
var _furnace_panel: PanelContainer
var _furnace_info: Label
var _shop_overlay: Control
var _shop_panel: PanelContainer
var _shop_status: Label
var _active_villager: ByteCrafterVillager
var _craft_info: Label
var _inventory_grid: GridContainer
var _inventory_hotbar: HBoxContainer
var _inventory_item_ids: Array = [1, 2, 3, 4, 5, 6, 7, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, "gravetos", "picareta", "picareta_pedra", "picareta_ferro", "machado_ferro", "espada", "espada_pedra", "espada_ferro", "frutas", "sementes_trigo", "trigo", "gelatina", "fragmento_lunar", "nucleo_lunar", 12, 13, 14, 15, 16, 17, 18, "mesa_craft", "bau", "tocha", "fogueira", "lanterna_cristal", "caixote", "porta", "balde", "carne_cozida", "carvao", "armadura_couro_cabeca", "armadura_couro_peito", "armadura_couro_pernas", "armadura_couro_botas", "fornalha", "alcapao", "janela", "cama", "vidro", "carvao_vegetal", "barraca", "bedroll", "pa", "pa_pedra", "pa_ferro", 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, "shuriken"]
var _craft_table_slots: Array[PanelContainer] = []
var _inventory_hotbar_slots: Array[PanelContainer] = []
var _craft_grid_items: Array = [null, null, null, null, null, null, null, null, null]
var _craft_output_slot: PanelContainer
var _craft_output_icon: Label
var _craft_output_item: Variant = null
var _craft_output_quantity: int = 0
var _craft_planks: Button
var _craft_sticks: Button
var _craft_pickaxe: Button
var _eat_food: Button
var _pause_screen: Control
var _paused := false
var _target_outline: MeshInstance3D
var _placement_preview: MeshInstance3D
var _placement_material: StandardMaterial3D
var _settings_store: ByteCrafterSettingsStore
var _settings_panel: ByteCrafterSettingsPanel
var _async_saver: ByteCrafterAsyncSaver
var _postprocess_layer: CanvasLayer
var _postprocess_rect: ColorRect
var _binding_capture_action := ""
var _binding_capture_device := ""
var _difficulty := "normal"


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_create_native_loading_screen()
	if I18n.has_method("set_locale"):
		I18n.set_locale("pt-BR")
	_settings_store = SETTINGS_STORE_SCRIPT.new() as ByteCrafterSettingsStore
	_settings_store.load_settings()
	_async_saver = ASYNC_SAVER_SCRIPT.new() as ByteCrafterAsyncSaver
	_build_environment()
	_build_postprocessing()
	_build_interface()
	_connect_network_signals()
	_load_profile()
	_refresh_avatar_selector()
	var saved_world: Dictionary = WORLD_SCRIPT.load_from_disk()
	var seed_value := int(saved_world.get("seed", randi_range(100000, 999999999)))
	var overrides: Array = saved_world.get("overrides", [])
	_create_world(seed_value, overrides)
	_refresh_hud()


func _process(delta: float) -> void:
	if _async_saver != null:
		_async_saver.poll()
	# A tela inicial de carregamento deve ser removida uma única vez. A lógica
	# de jogo precisa continuar executando depois que ela desaparecer.
	if _startup_loading_layer != null and Time.get_ticks_msec() - _startup_loading_started_msec >= 3000:
		_startup_loading_layer.queue_free()
		_startup_loading_layer = null

	if _screen == "game" and not _paused:
		_day_phase = fposmod(_day_phase + delta / 720.0, 1.0)
		_update_day_night()
		_enemy_schedule_timer -= delta
		if _enemy_schedule_timer <= 0.0:
			_enemy_schedule_timer = ENEMY_SCHEDULE_INTERVAL
			_update_enemy_schedule()
			_update_interaction_helpers()
			_process_mining(delta)
			_process_crops(delta)
			_process_furnaces(delta)
			_refresh_survival(delta)
			_process_footsteps(delta)
		_village_update_timer -= delta
		if _village_update_timer <= 0.0 and _village_system != null and _player != null:
			_village_update_timer = 0.5
			_village_system.update_for_player(_player.global_position, is_daytime())
		if _furnace_panel != null and _furnace_panel.visible:
			_refresh_furnace_panel()
		_refresh_position_label()
	else:
		if _target_outline != null:
			_target_outline.visible = false
		if _placement_preview != null:
			_placement_preview.visible = false

	_update_cloud_layer()
	_attack_cooldown = maxf(0.0, _attack_cooldown - delta)
	_damage_invulnerability = maxf(0.0, _damage_invulnerability - delta)
	_stream_timer -= delta
	if _stream_timer <= 0.0 and _world != null and _player != null:
		_stream_timer = 0.25
		_world.update_streaming(_player.global_position)
	_pose_timer -= delta
	if _network_active and _player != null and _pose_timer <= 0.0:
		_pose_timer = 0.12
		_send_player_pose()
	if _screen == "game" and not _paused:
		_save_timer -= delta
		if _save_timer <= 0.0:
			_save_timer = AUTOSAVE_INTERVAL_SECONDS
			_save_game()


func _input(event: InputEvent) -> void:
	if not _binding_capture_action.is_empty():
		_capture_settings_binding(event)
		return
	if _settings_panel != null and _settings_panel.is_settings_open():
		if event.is_action_pressed("pause"):
			_settings_panel.close_active()
			get_viewport().set_input_as_handled()
		return
	if _settings_panel != null and _settings_panel.is_difficulty_open():
		if event.is_action_pressed("pause"):
			_settings_panel.close_active()
			get_viewport().set_input_as_handled()
		return
	if _shop_overlay != null and _shop_overlay.visible:
		if event.is_action_pressed("pause") or event.is_action_pressed("inventory") or event.is_action_pressed("interact"):
			_close_village_shop()
			get_viewport().set_input_as_handled()
			return
		if event is InputEventMouseButton and event.pressed and event.button_index in [MOUSE_BUTTON_LEFT, MOUSE_BUTTON_RIGHT] and _shop_panel != null and not _shop_panel.get_global_rect().has_point(event.position):
			_close_village_shop()
			get_viewport().set_input_as_handled()
			return
		return
	if _furnace_panel != null and _furnace_panel.visible:
		if event.is_action_pressed("pause") or event.is_action_pressed("inventory"):
			_close_furnace()
			get_viewport().set_input_as_handled()
			return
		if event is InputEventMouseButton and event.pressed and event.button_index in [MOUSE_BUTTON_LEFT, MOUSE_BUTTON_RIGHT] and not _furnace_panel.get_global_rect().has_point(event.position):
			_close_furnace()
			get_viewport().set_input_as_handled()
			return
		return
	if event is InputEventMouseButton and event.pressed and event.button_index in [MOUSE_BUTTON_LEFT, MOUSE_BUTTON_RIGHT]:
		if _screen == "game" and not _paused and (_craft_panel == null or not _craft_panel.visible) and _try_mouse_prop_interaction():
			get_viewport().set_input_as_handled()
			return
	if event.is_action_pressed("pause"):
		if _craft_panel != null and _craft_panel.visible:
			_toggle_crafting()
		elif _screen == "game":
			_toggle_pause()
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("attack_mine") and _screen == "game" and not _paused and _craft_panel != null and not _craft_panel.visible:
		if _try_attack_enemy():
			_mine_held = false
		else:
			_mine_held = true
			_mine_timer = 0.0
	if event.is_action_released("attack_mine"):
		_mine_held = false
	if event.is_action_pressed("use_item") and _screen == "game" and not _paused and _craft_panel != null and not _craft_panel.visible:
		_use_selected_item()
		get_viewport().set_input_as_handled()
		return
	if _screen == "game" and not _paused:
		if event.is_action_pressed("toggle_camera"):
			_player.set_third_person(not _player.third_person)
			_set_game_status("Câmera: %s" % ("3ª pessoa" if _player.third_person else "1ª pessoa"))
			get_viewport().set_input_as_handled()
			return
		if event.is_action_pressed("interact"):
			_interact_contextual()
			get_viewport().set_input_as_handled()
			return
		if event.is_action_pressed("inventory"):
			_toggle_crafting()
			get_viewport().set_input_as_handled()
			return
		if event.is_action_pressed("place_table"):
			_place_crafting_table()
			get_viewport().set_input_as_handled()
			return
		if event.is_action_pressed("farm_action"):
			_use_farming_action()
			get_viewport().set_input_as_handled()
			return
		if event.is_action_pressed("save_game"):
			_save_game()
			get_viewport().set_input_as_handled()
			return
		for slot_index in range(9):
			if event.is_action_pressed("slot_%d" % (slot_index + 1)):
				_select_slot(slot_index)
				get_viewport().set_input_as_handled()
				return
	if _craft_panel != null and _craft_panel.visible:
		if event is InputEventMouseButton and event.pressed and event.button_index in [MOUSE_BUTTON_LEFT, MOUSE_BUTTON_RIGHT]:
			if not _craft_panel.get_global_rect().has_point(event.position):
				_drop_cursor_stack(event.button_index == MOUSE_BUTTON_RIGHT)
				get_viewport().set_input_as_handled()
		return
	if not event is InputEventMouseButton or _screen != "game" or _paused:
		return
	if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
		_select_slot(posmod(_selected_slot - 1, _hotbar_ids.size()))
	elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
		_select_slot(posmod(_selected_slot + 1, _hotbar_ids.size()))


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_PREDELETE:
		if _world != null and (not _network_active or _is_host):
			_save_game()
		if _async_saver != null:
			_async_saver.wait_until_idle()


func _build_environment() -> void:
	_environment = Environment.new()
	_environment.background_mode = Environment.BG_SKY
	var sky := Sky.new()
	_sky_material = ProceduralSkyMaterial.new()
	_sky_material.sky_top_color = Color("438ad3")
	_sky_material.sky_horizon_color = Color("b6d7ef")
	_sky_material.ground_bottom_color = Color("263336")
	_sky_material.ground_horizon_color = Color("8c9e8f")
	_sky_material.sun_angle_max = 16.0
	_sky_material.use_debanding = true
	sky.sky_material = _sky_material
	_environment.sky = sky
	_environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	_environment.ambient_light_color = Color("b7d6ed")
	_environment.ambient_light_energy = 0.55
	_environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	_environment.fog_enabled = true
	_environment.fog_light_color = Color("a7c9e3")
	_environment.fog_density = 0.0012
	var world_environment := WorldEnvironment.new()
	world_environment.environment = _environment
	add_child(world_environment)
	_create_cloud_layer()
	_sun = DirectionalLight3D.new()
	_sun.name = "Daylight"
	_sun.rotation_degrees = Vector3(-38.0, -28.0, 0.0)
	_sun.light_color = Color("fff2d9")
	_sun.light_energy = 1.05
	_sun.shadow_enabled = true
	_sun.directional_shadow_max_distance = 72.0
	add_child(_sun)
	_create_celestial_bodies()
	_update_day_night()


func _build_postprocessing() -> void:
	_postprocess_layer = CanvasLayer.new()
	_postprocess_layer.name = "VisualFilterLayer"
	_postprocess_layer.layer = 5
	_postprocess_layer.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(_postprocess_layer)
	_postprocess_rect = ColorRect.new()
	_postprocess_rect.name = "VisualFilter"
	_postprocess_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	UI.full_rect(_postprocess_rect)
	_postprocess_layer.add_child(_postprocess_rect)
	_postprocess_rect.visible = false


func _apply_visual_settings() -> void:
	if _settings_store == null:
		return
	var quality := str(_settings_store.get_value("video", "quality", "media"))
	if _sun != null:
		_sun.shadow_enabled = quality != "baixa"
		_sun.directional_shadow_max_distance = 38.0 if quality == "baixa" else (72.0 if quality == "media" else 112.0)
	var viewport := get_viewport()
	if viewport != null:
		viewport.msaa_3d = Viewport.MSAA_DISABLED if quality == "baixa" else (Viewport.MSAA_2X if quality == "media" else Viewport.MSAA_4X)
	if _player != null and _player.camera != null:
		_player.camera.fov = float(_settings_store.get_value("gameplay", "fov", 76.0))
	if _postprocess_rect == null:
		return
	var shader_name := str(_settings_store.get_value("video", "shader", "normal"))
	var shader_path := ""
	if shader_name == "retrobit":
		shader_path = "res://shaders/bytecrafter_retrobit.gdshader"
	elif shader_name == "celshading":
		shader_path = "res://shaders/bytecrafter_celshading.gdshader"
	if shader_path.is_empty():
		_postprocess_rect.material = null
		_postprocess_rect.visible = false
		return
	var shader := load(shader_path) as Shader
	if shader == null:
		_postprocess_rect.material = null
		_postprocess_rect.visible = false
		push_warning("ByteCrafter: não foi possível carregar o filtro visual %s." % shader_name)
		return
	var material := ShaderMaterial.new()
	material.shader = shader
	_postprocess_rect.material = material
	_postprocess_rect.visible = _screen == "game"


func _apply_gameplay_settings() -> void:
	if _settings_store == null:
		return
	if _world != null:
		var center := _player.global_position if _player != null else _world.get_spawn_position()
		_world.set_stream_radius(int(_settings_store.get_value("gameplay", "chunk_radius", 2)), center)
	if _player != null and _player.camera != null:
		_player.camera.fov = float(_settings_store.get_value("gameplay", "fov", 76.0))
	if not bool(_settings_store.get_value("gameplay", "monsters", true)):
		for enemy: ByteCrafterEnemy in _enemies.duplicate():
			_enemies.erase(enemy)
			if is_instance_valid(enemy):
				enemy.queue_free()


func _on_settings_changed(section: String, key: String) -> void:
	if _settings_store == null:
		return
	if section == "audio":
		_settings_store.apply_audio_settings()
	elif section == "video":
		if key in ["resolution", "fullscreen", "vsync"]:
			_settings_store.apply_display_settings()
		_apply_visual_settings()
	elif section == "gameplay":
		_apply_gameplay_settings()


func _open_settings(paused_context: bool = false) -> void:
	if _settings_panel == null:
		return
	_settings_panel.open_settings(paused_context)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _open_difficulty_selector() -> void:
	if _settings_panel == null:
		return
	_settings_panel.open_difficulty_selector(_difficulty, true)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _open_continue_difficulty_selector() -> void:
	if _settings_panel == null:
		return
	_settings_panel.open_difficulty_selector(_difficulty, false)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _on_settings_closed(_paused_context: bool) -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _begin_binding_capture(action_id: String, device: String) -> void:
	_binding_capture_action = action_id
	_binding_capture_device = device
	if _settings_panel != null:
		_settings_panel.set_capture_prompt(action_id, device)


func _capture_settings_binding(event: InputEvent) -> bool:
	if _binding_capture_action.is_empty():
		return false
	var captured: InputEvent
	if _binding_capture_device == "keyboard" and event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			_binding_capture_action = ""
			_binding_capture_device = ""
			_settings_panel.refresh_controls()
			get_viewport().set_input_as_handled()
			return true
		var key := InputEventKey.new()
		key.keycode = event.keycode
		key.physical_keycode = event.physical_keycode
		captured = key
	elif _binding_capture_device == "joypad" and event is InputEventJoypadButton and event.pressed:
		captured = event
	elif _binding_capture_device == "joypad" and event is InputEventJoypadMotion and absf(event.axis_value) >= 0.70:
		captured = event
	if captured != null:
		_settings_store.set_binding(_binding_capture_action, _binding_capture_device, captured)
		_binding_capture_action = ""
		_binding_capture_device = ""
		_settings_panel.refresh_controls()
	get_viewport().set_input_as_handled()
	return true


func _create_cloud_layer() -> void:
	var cloud_mesh := SphereMesh.new()
	cloud_mesh.radius = 180.0
	cloud_mesh.height = 360.0
	cloud_mesh.radial_segments = 64
	cloud_mesh.rings = 32
	_cloud_layer = MeshInstance3D.new()
	_cloud_layer.name = "PixelCloudDome"
	_cloud_layer.mesh = cloud_mesh
	_cloud_layer.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var cloud_material := ShaderMaterial.new()
	cloud_material.shader = load("res://assets/shaders/cloud_mask.gdshader")
	cloud_material.set_shader_parameter("cloud_texture", load("res://assets/textures/clouds.png"))
	cloud_material.set_shader_parameter("cloud_scale", 0.75)
	_cloud_layer.material_override = cloud_material
	add_child(_cloud_layer)


func _update_cloud_layer() -> void:
	if _cloud_layer == null or _player == null:
		return
	_cloud_layer.global_position = _player.global_position


func _process_footsteps(delta: float) -> void:
	if _player == null or not _player.is_on_floor():
		_footstep_timer = 0.0
		return
	var state := _player.get_animation_state()
	if state not in ["walk", "run"]:
		_footstep_timer = 0.0
		return
	_footstep_timer -= delta
	if _footstep_timer <= 0.0:
		_footstep_timer = 0.28 if state == "run" else 0.42
		AudioDirector.play_cue("player.step", 0.92 if state == "run" else 0.78)


func _update_day_night() -> void:
	if _sun == null or _environment == null:
		return
	var sunlight := clampf(sin(_day_phase * TAU), 0.0, 1.0)
	_sun.rotation_degrees.x = _day_phase * 360.0 - 90.0
	_sun.light_energy = 0.08 + sunlight * 1.15
	_environment.ambient_light_energy = 0.18 + sunlight * 0.52
	_environment.fog_light_color = Color("142239").lerp(Color("a9cde8"), sunlight)
	if _sky_material != null:
		_sky_material.sky_top_color = Color("07142d").lerp(Color("438ad3"), sunlight)
		_sky_material.sky_horizon_color = Color("1b3153").lerp(Color("b6d7ef"), sunlight)
		_sky_material.ground_bottom_color = Color("080c15").lerp(Color("263336"), sunlight)
		_sky_material.ground_horizon_color = Color("171f2b").lerp(Color("8c9e8f"), sunlight)
	if _cloud_layer != null and _cloud_layer.material_override is ShaderMaterial:
		var cloud_material := _cloud_layer.material_override as ShaderMaterial
		cloud_material.set_shader_parameter("cloud_opacity", 0.10 + sunlight * 0.24)
	_update_celestial_bodies(sunlight)


func _create_sky_disc(node_name: String, radius: float, tint: Color) -> MeshInstance3D:
	var disc := MeshInstance3D.new()
	disc.name = node_name
	var sphere := SphereMesh.new()
	sphere.radius = radius
	sphere.height = radius * 2.0
	sphere.radial_segments = 16
	sphere.rings = 8
	disc.mesh = sphere
	var material := StandardMaterial3D.new()
	material.albedo_color = tint
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.emission_enabled = true
	material.emission = tint
	material.emission_energy_multiplier = 0.35
	disc.material_override = material
	disc.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(disc)
	return disc


func _create_celestial_bodies() -> void:
	_sun_disc = _create_sky_disc("VoxelSun", 5.0, Color("fff1bf"))
	_moon_disc = _create_sky_disc("VoxelMoon", 3.3, Color("d7e4ff"))
	_star_field = MultiMeshInstance3D.new()
	_star_field.name = "VoxelStars"
	var star_mesh := SphereMesh.new()
	star_mesh.radius = 0.20
	star_mesh.height = 0.40
	star_mesh.radial_segments = 6
	star_mesh.rings = 4
	var star_material := StandardMaterial3D.new()
	star_material.albedo_color = Color("dceaff")
	star_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	star_material.emission_enabled = true
	star_material.emission = Color("c5dcff")
	star_material.emission_energy_multiplier = 0.7
	star_mesh.material = star_material
	var stars := MultiMesh.new()
	stars.transform_format = MultiMesh.TRANSFORM_3D
	stars.mesh = star_mesh
	stars.instance_count = 150
	var rng := RandomNumberGenerator.new()
	rng.seed = 834712
	for index in stars.instance_count:
		var angle := rng.randf_range(0.0, TAU)
		var vertical := rng.randf_range(-0.08, 0.96)
		var horizontal := sqrt(maxf(0.0, 1.0 - vertical * vertical))
		var direction := Vector3(cos(angle) * horizontal, vertical, sin(angle) * horizontal)
		var scale := rng.randf_range(0.55, 1.5)
		stars.set_instance_transform(index, Transform3D(Basis.from_scale(Vector3.ONE * scale), direction * 148.0))
	_star_field.multimesh = stars
	_star_field.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(_star_field)
	_update_celestial_bodies(get_sunlight_strength())


func _update_celestial_bodies(sunlight: float) -> void:
	if _sun_disc == null or _moon_disc == null or _star_field == null:
		return
	var sun_direction := Vector3(cos(_day_phase * TAU), sin(_day_phase * TAU), -0.28).normalized()
	var observer := _player.global_position if _player != null else Vector3.ZERO
	_sun_disc.global_position = observer + sun_direction * 142.0
	_moon_disc.global_position = observer - sun_direction * 142.0
	_sun_disc.visible = sunlight > 0.04
	_moon_disc.visible = sunlight < 0.30
	_star_field.global_position = observer
	_star_field.visible = sunlight < 0.20


func get_sunlight_strength() -> float:
	return clampf(sin(_day_phase * TAU), 0.0, 1.0)


func is_daytime() -> bool:
	return get_sunlight_strength() > 0.18


func _build_interface() -> void:
	_ui_layer = CanvasLayer.new()
	_ui_layer.layer = 10
	_ui_layer.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(_ui_layer)
	_build_title_screen()
	_build_hud()
	_build_crafting_panel()
	_build_furnace_panel()
	_build_village_shop_panel()
	_build_pause_screen()
	_build_interaction_helpers()
	_settings_panel = SETTINGS_PANEL_SCRIPT.new() as ByteCrafterSettingsPanel
	_settings_panel.name = "SettingsAndDifficulty"
	_ui_layer.add_child(_settings_panel)
	_settings_panel.configure(_settings_store)
	_settings_panel.options_changed.connect(_on_settings_changed)
	_settings_panel.binding_capture_requested.connect(_begin_binding_capture)
	_settings_panel.new_world_requested.connect(_start_new_world)
	_settings_panel.continue_requested.connect(_continue_with_difficulty)
	_settings_panel.closed.connect(_on_settings_closed)
	_apply_visual_settings()


func _build_title_screen() -> void:
	_title_screen = Control.new()
	_title_screen.name = "TitleScreen"
	UI.full_rect(_title_screen)
	_title_screen.process_mode = Node.PROCESS_MODE_ALWAYS
	_ui_layer.add_child(_title_screen)
	var background := TextureRect.new()
	background.name = "MenuBackground"
	background.texture = MENU_BACKGROUND_TEXTURE
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	UI.full_rect(background)
	_title_screen.add_child(background)
	var shade := ColorRect.new()
	shade.color = Color(0.02, 0.035, 0.05, 0.18)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	UI.full_rect(shade)
	_title_screen.add_child(shade)
	var margin := MarginContainer.new()
	UI.full_rect(margin)
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_top", 18)
	margin.add_theme_constant_override("margin_bottom", 18)
	_title_screen.add_child(margin)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 0)
	margin.add_child(row)
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(spacer)
	var panel_width := clampf(get_viewport().get_visible_rect().size.x * 0.36, 320.0, 460.0)
	var button_width := panel_width - 40.0
	var panel := UI.holo_panel(Color("89b578"), Vector2(18.0, 14.0))
	panel.name = "MenuPanel"
	panel.custom_minimum_size = Vector2(panel_width, 0.0)
	panel.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(panel)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 7)
	panel.add_child(content)
	var eyebrow := UI.display_label("MUNDO ABERTO · SOBREVIVÊNCIA · CONSTRUÇÃO", 10, Color("b5d49b"), "eyebrow")
	content.add_child(eyebrow)
	_title_label = UI.display_label("BYTECRAFTER", 36, Color("f4f4e8"), "title")
	_title_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.65))
	_title_label.add_theme_constant_override("shadow_offset_y", 3)
	content.add_child(_title_label)
	var subtitle := UI.label("Explore, sobreviva e construa bloco a bloco.", 12, Color("c5c9bc"))
	content.add_child(subtitle)
	content.add_child(UI.accent_rule(52.0, Color("94bc73")))
	var avatar_heading := UI.label("PERSONAGEM", 10, Color("b5d49b"))
	content.add_child(avatar_heading)
	var avatar_grid := GridContainer.new()
	avatar_grid.columns = 2
	avatar_grid.add_theme_constant_override("h_separation", 10)
	avatar_grid.add_theme_constant_override("v_separation", 6)
	content.add_child(avatar_grid)
	_avatar_boy_button = UI.button("GAROTO", (button_width - 10.0) * 0.5)
	_avatar_boy_button.pressed.connect(_set_selected_avatar.bind("boy"))
	avatar_grid.add_child(_avatar_boy_button)
	_avatar_girl_button = UI.button("GAROTA", (button_width - 10.0) * 0.5)
	_avatar_girl_button.pressed.connect(_set_selected_avatar.bind("girl"))
	avatar_grid.add_child(_avatar_girl_button)
	_avatar_boy2_button = UI.button("GAROTO 2", (button_width - 10.0) * 0.5)
	_avatar_boy2_button.pressed.connect(_set_selected_avatar.bind("boy2"))
	avatar_grid.add_child(_avatar_boy2_button)
	_avatar_girl2_button = UI.button("GAROTA 2", (button_width - 10.0) * 0.5)
	_avatar_girl2_button.pressed.connect(_set_selected_avatar.bind("girl2"))
	avatar_grid.add_child(_avatar_girl2_button)
	_refresh_avatar_selector()
	var play_button := UI.button("CONTINUAR EXPLORAÇÃO", button_width)
	UI.primary(play_button)
	play_button.pressed.connect(_open_continue_difficulty_selector)
	content.add_child(play_button)
	var new_world_button := UI.button("CRIAR NOVO MUNDO", button_width)
	new_world_button.pressed.connect(_open_difficulty_selector)
	content.add_child(new_world_button)
	var settings_button := UI.quiet_button("CONFIGURAÇÕES", 12)
	settings_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	settings_button.pressed.connect(_open_settings.bind(false))
	content.add_child(settings_button)
	var separator := UI.label("COOPERATIVO NA REDE LOCAL", 10, Color("a8b4a2"))
	content.add_child(separator)
	_ip_input = LineEdit.new()
	_ip_input.custom_minimum_size = Vector2(button_width, 38.0)
	_ip_input.placeholder_text = "IP do anfitrião (ex.: 192.168.1.20)"
	_ip_input.text = "127.0.0.1"
	_ip_input.alignment = HORIZONTAL_ALIGNMENT_CENTER
	content.add_child(_ip_input)
	var lan_row := HBoxContainer.new()
	lan_row.add_theme_constant_override("separation", 10)
	content.add_child(lan_row)
	_lan_host_button = UI.button("HOSPEDAR LAN", (button_width - 10.0) * 0.5)
	_lan_host_button.pressed.connect(_host_lan)
	lan_row.add_child(_lan_host_button)
	_lan_join_button = UI.button("ENTRAR", (button_width - 10.0) * 0.5)
	_lan_join_button.pressed.connect(_join_lan)
	lan_row.add_child(_lan_join_button)
	if OS.has_feature("web"):
		_lan_host_button.disabled = true
		_lan_join_button.disabled = true
		_ip_input.editable = false
	var web_note := UI.label("A rede LAN requer uma build nativa do Godot; o Preview web é para testar o protótipo.", 10, Color("d0c5a0"))
	web_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	web_note.visible = OS.has_feature("web")
	content.add_child(web_note)
	_title_status = UI.label("", 11, Color("b5d49b"))
	_title_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content.add_child(_title_status)
	var controls := UI.label("W/S avançar/recuar · A/D deslocar e orientar o avatar · mouse olhar\nEspaço saltar · Shift correr · clique minerar/colocar · 1–7 blocos · E inventário · V câmera · Esc pausar", 10, Color("9ca69a"))
	controls.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content.add_child(controls)
	var licenses_button := UI.quiet_button("Licenças de código aberto", 10)
	licenses_button.pressed.connect(LICENSES.open.bind(self))
	licenses_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	content.add_child(licenses_button)


func _create_native_loading_screen() -> void:
	if OS.has_feature("web") or DisplayServer.get_name() == "headless":
		return
	_startup_loading_layer = CanvasLayer.new()
	_startup_loading_layer.name = "InitialLoadingScreen"
	_startup_loading_layer.layer = 120
	_startup_loading_layer.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(_startup_loading_layer)
	var root := Control.new()
	root.name = "LoadingOverlay"
	root.mouse_filter = Control.MOUSE_FILTER_STOP
	UI.full_rect(root)
	_startup_loading_layer.add_child(root)
	var artwork := TextureRect.new()
	artwork.texture = LOADING_SCREEN_TEXTURE
	artwork.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	artwork.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	artwork.mouse_filter = Control.MOUSE_FILTER_STOP
	UI.full_rect(artwork)
	root.add_child(artwork)
	var panel := UI.holo_panel(Color("89b578"), Vector2(14.0, 10.0))
	panel.anchor_left = 0.0
	panel.anchor_right = 0.0
	panel.anchor_top = 1.0
	panel.anchor_bottom = 1.0
	panel.offset_left = 24.0
	panel.offset_right = 338.0
	panel.offset_top = -108.0
	panel.offset_bottom = -24.0
	root.add_child(panel)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	panel.add_child(row)
	var icon := TextureRect.new()
	icon.texture = GAME_ICON_TEXTURE
	icon.custom_minimum_size = Vector2(48.0, 48.0)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	row.add_child(icon)
	var labels := VBoxContainer.new()
	labels.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	labels.add_child(UI.display_label("BYTECRAFTER", 18, Color("f4f4e8"), "title"))
	labels.add_child(UI.label("Preparando o mundo...", 11, Color("c5c9bc")))
	row.add_child(labels)
	_set_control_tree_mouse_passthrough(root)
	_startup_loading_started_msec = Time.get_ticks_msec()


func _set_control_tree_mouse_passthrough(node: Node) -> void:
	if node is Control:
		(node as Control).mouse_filter = Control.MOUSE_FILTER_IGNORE
	for child: Node in node.get_children():
		_set_control_tree_mouse_passthrough(child)


func _refresh_avatar_selector() -> void:
	var buttons := {
		"boy": _avatar_boy_button,
		"girl": _avatar_girl_button,
		"boy2": _avatar_boy2_button,
		"girl2": _avatar_girl2_button,
	}
	for avatar_id: String in buttons:
		var button := buttons[avatar_id] as Button
		if button == null:
			continue
		button.text = ("✓ " if _selected_avatar_id == avatar_id else "") + _avatar_label(avatar_id)
		button.modulate = Color.WHITE if _selected_avatar_id == avatar_id else Color(0.72, 0.76, 0.72)


func _avatar_label(avatar_id: String) -> String:
	return {
		"boy": "GAROTO",
		"girl": "GAROTA",
		"boy2": "GAROTO 2",
		"girl2": "GAROTA 2",
	}.get(avatar_id, "GAROTO")


func _set_selected_avatar(value: String) -> void:
	if value not in AVATAR_IDS:
		return
	_selected_avatar_id = value
	_refresh_avatar_selector()
	if _player != null:
		_player.set_avatar_id(_selected_avatar_id)
	_save_game()
	if _title_status != null:
		_title_status.text = "Personagem selecionado: %s" % _avatar_label(value).capitalize()


func _build_hud() -> void:
	_game_hud = Control.new()
	_game_hud.name = "GameHUD"
	UI.full_rect(_game_hud)
	_game_hud.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_game_hud.visible = false
	_game_hud.process_mode = Node.PROCESS_MODE_ALWAYS
	_ui_layer.add_child(_game_hud)
	var top := UI.holo_panel(Color("94bc73"), Vector2(14.0, 9.0))
	top.position = Vector2(18.0, 18.0)
	top.custom_minimum_size = Vector2(250.0, 0.0)
	_game_hud.add_child(top)
	var stats := VBoxContainer.new()
	stats.add_theme_constant_override("separation", 5)
	top.add_child(stats)
	var health_row := HBoxContainer.new()
	stats.add_child(health_row)
	health_row.add_child(UI.label("VIDA", 12, Color("edc0ad")))
	_health_bar = ProgressBar.new()
	_health_bar.custom_minimum_size = Vector2(174.0, 14.0)
	_health_bar.max_value = 20.0
	_health_bar.show_percentage = false
	health_row.add_child(_health_bar)
	var food_row := HBoxContainer.new()
	stats.add_child(food_row)
	food_row.add_child(UI.label("FOME", 12, Color("e8d79f")))
	_food_bar = ProgressBar.new()
	_food_bar.custom_minimum_size = Vector2(174.0, 14.0)
	_food_bar.max_value = 20.0
	_food_bar.show_percentage = false
	food_row.add_child(_food_bar)
	var level_row := HBoxContainer.new()
	stats.add_child(level_row)
	_level_label = UI.label("NÍVEL 1", 12, Color("b9dc9a"))
	level_row.add_child(_level_label)
	_xp_bar = ProgressBar.new()
	_xp_bar.custom_minimum_size = Vector2(174.0, 10.0)
	_xp_bar.show_percentage = false
	level_row.add_child(_xp_bar)
	_position_label = UI.label("", 12, Color("e5eadb"))
	_position_label.anchor_left = 1.0
	_position_label.anchor_right = 1.0
	_position_label.anchor_top = 0.0
	_position_label.anchor_bottom = 0.0
	_position_label.offset_left = -320.0
	_position_label.offset_right = -18.0
	_position_label.offset_top = 20.0
	_position_label.offset_bottom = 70.0
	_position_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_game_hud.add_child(_position_label)
	_crosshair = UI.display_label("+", 28, Color("f5f4e9"), "heading")
	_crosshair.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_crosshair.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_crosshair.anchor_left = 0.5
	_crosshair.anchor_right = 0.5
	_crosshair.anchor_top = 0.5
	_crosshair.anchor_bottom = 0.5
	_crosshair.offset_left = -16.0
	_crosshair.offset_right = 16.0
	_crosshair.offset_top = -18.0
	_crosshair.offset_bottom = 18.0
	_crosshair.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.8))
	_crosshair.add_theme_constant_override("shadow_offset_x", 1)
	_crosshair.add_theme_constant_override("shadow_offset_y", 1)
	_crosshair.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_game_hud.add_child(_crosshair)
	_mine_progress = ProgressBar.new()
	_mine_progress.anchor_left = 0.5
	_mine_progress.anchor_right = 0.5
	_mine_progress.anchor_top = 0.5
	_mine_progress.anchor_bottom = 0.5
	_mine_progress.offset_left = -70.0
	_mine_progress.offset_right = 70.0
	_mine_progress.offset_top = 26.0
	_mine_progress.offset_bottom = 38.0
	_mine_progress.show_percentage = false
	_mine_progress.visible = false
	_game_hud.add_child(_mine_progress)
	var hotbar_panel := PanelContainer.new()
	hotbar_panel.anchor_left = 0.5
	hotbar_panel.anchor_right = 0.5
	hotbar_panel.anchor_top = 1.0
	hotbar_panel.anchor_bottom = 1.0
	hotbar_panel.offset_left = -360.0
	hotbar_panel.offset_right = 360.0
	hotbar_panel.offset_top = -92.0
	hotbar_panel.offset_bottom = -14.0
	hotbar_panel.add_theme_stylebox_override("panel", UI.style_box(Color(0.035, 0.045, 0.052, 0.82), Color(0.75, 0.83, 0.69, 0.24), 8, 1))
	_game_hud.add_child(hotbar_panel)
	_hotbar = HBoxContainer.new()
	_hotbar.alignment = BoxContainer.ALIGNMENT_CENTER
	_hotbar.add_theme_constant_override("separation", 5)
	hotbar_panel.add_child(_hotbar)
	for index: int in _hotbar_ids.size():
		var slot := _make_item_slot("hotbar", index, _hotbar_ids[index], Vector2(68.0, 66.0))
		_hotbar.add_child(slot)
		_hotbar_slots.append(slot)
	_selected_item_label = UI.label("", 12, Color("f0f3e8"))
	_selected_item_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_selected_item_label.anchor_left = 0.5
	_selected_item_label.anchor_right = 0.5
	_selected_item_label.anchor_top = 1.0
	_selected_item_label.anchor_bottom = 1.0
	_selected_item_label.offset_left = -180.0
	_selected_item_label.offset_right = 180.0
	_selected_item_label.offset_top = -116.0
	_selected_item_label.offset_bottom = -94.0
	_game_hud.add_child(_selected_item_label)
	var status_panel := UI.holo_panel(Color("91b67a"), Vector2(14.0, 8.0))
	status_panel.anchor_left = 0.5
	status_panel.anchor_right = 0.5
	status_panel.anchor_top = 0.0
	status_panel.anchor_bottom = 0.0
	status_panel.offset_left = -170.0
	status_panel.offset_right = 170.0
	status_panel.offset_top = 14.0
	status_panel.offset_bottom = 54.0
	status_panel.visible = false
	_game_hud.add_child(status_panel)
	_game_status = UI.label("", 12, Color("e9efdf"))
	_game_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_panel.add_child(_game_status)
	var help := UI.label("Esquerdo: atacar/minerar · F: atacar · G: minerar · E: mochila · arraste para a hotbar · V: câmera · F5: salvar · Esc: menu", 11, Color("d8dfd0"))
	help.anchor_left = 0.0
	help.anchor_right = 0.0
	help.anchor_top = 1.0
	help.anchor_bottom = 1.0
	help.offset_left = 18.0
	help.offset_right = 360.0
	help.offset_top = -38.0
	help.offset_bottom = -12.0
	_game_hud.add_child(help)


func _build_crafting_panel() -> void:
	# Inventário inspirado no layout clássico de survival crafting:
	# grade de itens à esquerda e bancada/receitas à direita.
	_craft_panel = PanelContainer.new()
	_craft_panel.name = "InventoryCraftPanel"
	_craft_panel.anchor_left = 0.5
	_craft_panel.anchor_right = 0.5
	_craft_panel.anchor_top = 0.5
	_craft_panel.anchor_bottom = 0.5
	_craft_panel.offset_left = -470.0
	_craft_panel.offset_right = 470.0
	_craft_panel.offset_top = -290.0
	_craft_panel.offset_bottom = 290.0
	_craft_panel.visible = false
	_craft_panel.process_mode = Node.PROCESS_MODE_ALWAYS
	_craft_panel.add_theme_stylebox_override("panel", UI.style_box(Color("20242a"), Color("8a9a83"), 8, 2))
	_ui_layer.add_child(_craft_panel)

	var outer := VBoxContainer.new()
	outer.add_theme_constant_override("separation", 10)
	_craft_panel.add_child(outer)
	var header_row := HBoxContainer.new()
	outer.add_child(header_row)
	var heading := UI.display_label("MOCHILA", 24, Color("f2f2e8"), "heading")
	heading.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header_row.add_child(heading)
	var close := UI.quiet_button("✕  Fechar  (E / Esc)", 14)
	close.pressed.connect(_toggle_crafting)
	header_row.add_child(close)

	var separator := HSeparator.new()
	outer.add_child(separator)
	var main_row := HBoxContainer.new()
	main_row.add_theme_constant_override("separation", 18)
	main_row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	outer.add_child(main_row)

	var inventory_column := VBoxContainer.new()
	inventory_column.custom_minimum_size.x = 470.0
	inventory_column.size_flags_vertical = Control.SIZE_EXPAND_FILL
	inventory_column.add_theme_constant_override("separation", 8)
	main_row.add_child(inventory_column)
	var inventory_heading := UI.label("MOCHILA · 36 SLOTS", 13, Color("c9d6c0"))
	inventory_heading.add_theme_font_size_override("font_size", 14)
	inventory_column.add_child(inventory_heading)
	var inventory_scroll := ScrollContainer.new()
	inventory_scroll.name = "InventoryScroll"
	inventory_scroll.custom_minimum_size = Vector2(470.0, 300.0)
	inventory_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	inventory_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	inventory_column.add_child(inventory_scroll)
	_inventory_grid = GridContainer.new()
	_inventory_grid.columns = 6
	_inventory_grid.add_theme_constant_override("h_separation", 6)
	_inventory_grid.add_theme_constant_override("v_separation", 6)
	inventory_scroll.add_child(_inventory_grid)
	for index in range(BACKPACK_SIZE):
		var item_id: Variant = _backpack_slots[index] if index < _backpack_slots.size() else null
		_inventory_grid.add_child(_make_item_slot("backpack", index, item_id, Vector2(72.0, 72.0)))
	var hotbar_heading := UI.label("BARRA RÁPIDA · 9 SLOTS", 12, Color("c9d6c0"))
	inventory_column.add_child(hotbar_heading)
	_inventory_hotbar = HBoxContainer.new()
	_inventory_hotbar.alignment = BoxContainer.ALIGNMENT_CENTER
	_inventory_hotbar.add_theme_constant_override("separation", 5)
	inventory_column.add_child(_inventory_hotbar)
	for index in range(9):
		var item_id: Variant = _hotbar_ids[index] if index < _hotbar_ids.size() else null
		var hotbar_slot := _make_item_slot("hotbar", index, item_id, Vector2(44.0, 44.0))
		_inventory_hotbar.add_child(hotbar_slot)
		_inventory_hotbar_slots.append(hotbar_slot)
	_craft_info = UI.label("", 11, Color("c4cbbf"))
	_craft_info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_craft_info.size_flags_vertical = Control.SIZE_EXPAND_FILL
	inventory_column.add_child(_craft_info)

	var craft_column := VBoxContainer.new()
	craft_column.custom_minimum_size.x = 390.0
	craft_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	craft_column.add_theme_constant_override("separation", 8)
	main_row.add_child(craft_column)
	var table_heading := UI.label("MESA DE CRAFT", 14, Color("e3c58c"))
	table_heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	craft_column.add_child(table_heading)
	var table_frame := PanelContainer.new()
	table_frame.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	table_frame.add_theme_stylebox_override("panel", UI.style_box(Color("493526"), Color("96714a"), 6, 2))
	craft_column.add_child(table_frame)
	var table_content := VBoxContainer.new()
	table_content.add_theme_constant_override("separation", 8)
	table_frame.add_child(table_content)
	var table_caption := UI.label("ItemStack: esquerdo pega/mescla · direito divide · Shift move · arraste para craft", 10, Color("f0d7ad"))
	table_caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	table_content.add_child(table_caption)
	var craft_row := HBoxContainer.new()
	craft_row.alignment = BoxContainer.ALIGNMENT_CENTER
	craft_row.add_theme_constant_override("separation", 8)
	table_content.add_child(craft_row)
	var grid := GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 4)
	grid.add_theme_constant_override("v_separation", 4)
	craft_row.add_child(grid)
	for i in range(9):
		var slot := _make_craft_table_slot(i)
		grid.add_child(slot)
		_craft_table_slots.append(slot)
	var arrow := UI.label("➜", 26, Color("e8d7ad"))
	arrow.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	craft_row.add_child(arrow)
	_craft_output_slot = _make_craft_table_slot(9)
	_craft_output_slot.custom_minimum_size = Vector2(58, 58)
	craft_row.add_child(_craft_output_slot)
	_craft_output_icon = _craft_output_slot.find_child("CraftIcon", true, false) as Label
	var recipe_heading := UI.label("RESULTADO DA GRADE · clique no resultado para fabricar", 11, Color("d8dfd0"))
	craft_column.add_child(recipe_heading)
	_craft_planks = UI.button("▦  4 tábuas  ·  1 tronco", 350.0)
	_craft_planks.custom_minimum_size.y = 38.0
	_craft_planks.pressed.connect(_craft.bind("planks"))
	craft_column.add_child(_craft_planks)
	_craft_sticks = UI.button("╱╲  4 gravetos  ·  2 tábuas", 350.0)
	_craft_sticks.custom_minimum_size.y = 38.0
	_craft_sticks.pressed.connect(_craft.bind("sticks"))
	craft_column.add_child(_craft_sticks)
	_craft_pickaxe = UI.button("⛏  Picareta  ·  3 tábuas + 2 gravetos", 350.0)
	_craft_pickaxe.custom_minimum_size.y = 38.0
	_craft_pickaxe.pressed.connect(_craft.bind("pickaxe"))
	craft_column.add_child(_craft_pickaxe)
	_eat_food = UI.button("Comer", 350.0)
	_eat_food.custom_minimum_size.y = 38.0
	_eat_food.pressed.connect(_craft.bind("eat"))
	craft_column.add_child(_eat_food)


func _build_furnace_panel() -> void:
	_furnace_panel = PanelContainer.new()
	_furnace_panel.name = "FurnacePanel"
	_furnace_panel.anchor_left = 0.5
	_furnace_panel.anchor_right = 0.5
	_furnace_panel.anchor_top = 0.5
	_furnace_panel.anchor_bottom = 0.5
	_furnace_panel.offset_left = -220.0
	_furnace_panel.offset_right = 220.0
	_furnace_panel.offset_top = -190.0
	_furnace_panel.offset_bottom = 190.0
	_furnace_panel.visible = false
	_furnace_panel.process_mode = Node.PROCESS_MODE_ALWAYS
	_furnace_panel.add_theme_stylebox_override("panel", UI.style_box(Color("272c31"), Color("c07842"), 8, 2))
	_ui_layer.add_child(_furnace_panel)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 12)
	_furnace_panel.add_child(content)
	var title_row := HBoxContainer.new()
	content.add_child(title_row)
	var title := UI.display_label("FORNALHA", 22, Color("f5ddbb"), "heading")
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_row.add_child(title)
	var close_button := UI.quiet_button("Fechar (E / Esc)", 13)
	close_button.pressed.connect(_close_furnace)
	title_row.add_child(close_button)
	_furnace_info = UI.label("", 14, Color("e1e6dc"))
	_furnace_info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_furnace_info.custom_minimum_size.y = 96.0
	content.add_child(_furnace_info)
	var input_button := UI.button("Adicionar minério / areia / madeira / carne", 390.0)
	input_button.pressed.connect(_furnace_add_input)
	content.add_child(input_button)
	var fuel_button := UI.button("Adicionar combustível (carvão ou madeira)", 390.0)
	fuel_button.pressed.connect(_furnace_add_fuel)
	content.add_child(fuel_button)
	var output_button := UI.button("Retirar produto", 390.0)
	output_button.pressed.connect(_furnace_collect_output)
	content.add_child(output_button)
	var help := UI.label("1 combustível mantém a chama por 12 s; cada item leva 4 s. O processamento continua enquanto você explora.", 11, Color("c6bda9"))
	help.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content.add_child(help)


func _make_inventory_slot(item_id: Variant) -> PanelContainer:
	return _make_item_slot("backpack", -1, item_id, Vector2(72.0, 72.0))


func _make_item_slot(kind: String, index: int, item_id: Variant, slot_size: Vector2) -> PanelContainer:
	var slot := INVENTORY_SLOT_SCRIPT.new() as PanelContainer
	slot.name = "%sSlot_%d" % [kind.capitalize(), index]
	slot.custom_minimum_size = slot_size
	slot.call("configure", kind, index, item_id)
	slot.connect("slot_activated", _on_inventory_slot_gui_input)
	slot.connect("item_dropped", _on_slot_item_dropped)
	var slot_style := UI.style_box(Color("343a3e"), Color("68716d"), 5, 1)
	slot_style.content_margin_left = 4.0
	slot_style.content_margin_right = 4.0
	slot_style.content_margin_top = 3.0
	slot_style.content_margin_bottom = 3.0
	slot.add_theme_stylebox_override("panel", slot_style)
	var content := VBoxContainer.new()
	content.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.alignment = BoxContainer.ALIGNMENT_CENTER
	content.add_theme_constant_override("separation", 0)
	slot.add_child(content)
	if kind == "hotbar":
		var number := UI.label(str(index + 1), 10, Color("b3bea9"))
		number.name = "HotbarNumber"
		number.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		content.add_child(number)
	var icon := TextureRect.new()
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon.name = "ItemTexture"
	icon.custom_minimum_size = Vector2(34.0, 34.0)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	content.add_child(icon)
	var glyph := UI.label("", 21, Color("f4f0dc"))
	glyph.mouse_filter = Control.MOUSE_FILTER_IGNORE
	glyph.name = "ItemGlyph"
	glyph.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	glyph.custom_minimum_size.y = 32.0
	content.add_child(glyph)
	var name_label := UI.label("", 9, Color("dfe4d9"))
	name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	name_label.name = "ItemName"
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	name_label.visible = kind != "hotbar"
	content.add_child(name_label)
	var amount := UI.label("", 11, Color("ffffff"))
	amount.mouse_filter = Control.MOUSE_FILTER_IGNORE
	amount.name = "ItemAmount"
	amount.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	content.add_child(amount)
	slot.set_item(item_id, _slot_count_for_kind(kind, index))
	_refresh_item_slot_visual(slot, item_id, kind)
	return slot


func _refresh_item_slot_visual(slot: PanelContainer, item_id: Variant, kind: String) -> void:
	if slot == null:
		return
	var texture_rect := slot.find_child("ItemTexture", true, false) as TextureRect
	var glyph := slot.find_child("ItemGlyph", true, false) as Label
	var name_label := slot.find_child("ItemName", true, false) as Label
	var amount := slot.find_child("ItemAmount", true, false) as Label
	var texture: Texture2D = null
	if item_id is int:
		texture = _make_block_icon(int(item_id))
	else:
		texture = _item_texture(item_id) if item_id != null else null
	if texture_rect != null:
		texture_rect.texture = texture
		texture_rect.visible = texture != null
	if glyph != null:
		glyph.text = "" if item_id == null or texture != null else _item_glyph(item_id)
		glyph.visible = item_id != null and texture == null
	if name_label != null:
		name_label.text = "Vazio" if item_id == null else _item_short_name(item_id)
		name_label.visible = kind == "backpack"
	if amount != null:
		var stack_count := int(slot.get("quantity"))
		amount.text = "" if item_id == null or stack_count <= 0 else str(stack_count)
	slot.tooltip_text = "Arraste um item para configurar" if item_id == null else "%s × %d" % [_item_short_name(item_id), int(slot.get("quantity"))]


func _on_inventory_slot_gui_input(slot: PanelContainer, mouse_event: InputEventMouseButton) -> void:
	if not mouse_event.pressed:
		return
	var slot_kind := str(slot.get("slot_kind"))
	if slot_kind in ["backpack", "hotbar"]:
		# Fora da mochila, a hotbar continua apenas selecionando o item.
		if slot_kind == "hotbar" and (_craft_panel == null or not _craft_panel.visible):
			if mouse_event.button_index == MOUSE_BUTTON_LEFT:
				_select_slot(int(slot.get("slot_index")))
				get_viewport().set_input_as_handled()
			return
		_handle_inventory_click(slot, mouse_event)
		get_viewport().set_input_as_handled()


func _on_slot_item_dropped(slot: PanelContainer, data: Dictionary) -> void:
	_reconcile_inventory_state()
	var source_kind := str(data.get("source_kind", ""))
	var source_index := int(data.get("source_index", -1))
	var target_kind := str(slot.get("slot_kind"))
	var target_index := int(slot.get("slot_index"))
	var item_id: Variant = data.get("item_id", null)
	if item_id == null:
		return
	if target_kind in ["backpack", "hotbar"] and source_kind in ["backpack", "hotbar"]:
		var source_slot := _slot_index_for_kind(source_kind, source_index)
		var target_slot := _slot_index_for_kind(target_kind, target_index)
		if source_slot < 0 or target_slot < 0 or source_slot == target_slot:
			return
		var source_stack: Variant = _inventory_state.stack_at(source_slot)
		var target_stack: Variant = _inventory_state.stack_at(target_slot)
		if source_stack == null:
			var fallback_item: Variant = _canonical_item_id(item_id)
			var fallback_count := int(_inventory.get(fallback_item, 0))
			if fallback_count <= 0:
				return
			_inventory_state.set_stack(source_slot, fallback_item, mini(fallback_count, _inventory_state.max_stack_size(fallback_item)))
			source_stack = _inventory_state.stack_at(source_slot)
		if target_stack != null and _inventory_state.item_ids_equal(target_stack.get("item", null), source_stack.get("item", null)):
			var capacity: int = _inventory_state.max_stack_size(item_id) - int(target_stack.get("count", 0))
			var moved: int = mini(int(source_stack.get("count", 0)), maxi(0, capacity))
			target_stack["count"] = int(target_stack.get("count", 0)) + moved
			source_stack["count"] = int(source_stack.get("count", 0)) - moved
			_inventory_state.set_stack(target_slot, target_stack.get("item", null), int(target_stack.get("count", 0)))
			_inventory_state.set_stack(source_slot, source_stack.get("item", null), int(source_stack.get("count", 0)))
		else:
			_inventory_state.set_stack(target_slot, source_stack.get("item", null), int(source_stack.get("count", 0)))
			_inventory_state.set_stack(source_slot, target_stack.get("item", null) if target_stack != null else null, int(target_stack.get("count", 0)) if target_stack != null else 0)
		_sync_legacy_slot_arrays_from_state()
		_set_game_status("Pilha movida: clique esquerdo pega, direito divide.")
	elif target_kind in ["backpack", "hotbar"] and source_kind == "craft":
		if source_index < 0 or source_index >= _craft_grid_items.size() or _craft_grid_items[source_index] == null:
			return
		var target_slot := _slot_index_for_kind(target_kind, target_index)
		var target_stack: Variant = _inventory_state.stack_at(target_slot)
		var craft_item: Variant = _craft_grid_items[source_index]
		if target_stack != null and target_stack.get("item", null) != craft_item:
			return
		if _inventory_state.add_item(craft_item, 1, target_slot) > 0:
			return
		_craft_grid_items[source_index] = null
		_sync_legacy_slot_arrays_from_state()
		_set_game_status("Ingrediente devolvido à mochila.")
	elif target_kind == "craft" and source_kind in ["backpack", "hotbar"]:
		if target_index < 0 or target_index >= _craft_grid_items.size() or _craft_grid_items[target_index] != null:
			return
		var source_slot := _slot_index_for_kind(source_kind, source_index)
		var source_stack: Variant = _inventory_state.remove_from_slot(source_slot, 1)
		if source_stack == null:
			return
		_craft_grid_items[target_index] = source_stack.get("item", null)
		_sync_legacy_slot_arrays_from_state()
		_set_game_status("Ingrediente colocado na grade.")
	elif target_kind == "craft" and source_kind == "craft":
		if source_index < 0 or source_index >= _craft_grid_items.size() or target_index < 0 or target_index >= _craft_grid_items.size() or source_index == target_index:
			return
		var craft_item: Variant = _craft_grid_items[source_index]
		_craft_grid_items[source_index] = _craft_grid_items[target_index]
		_craft_grid_items[target_index] = craft_item
	else:
		return
	_refresh_crafting()
	_refresh_hud()


func _make_craft_table_slot(index: int) -> PanelContainer:
	var slot := INVENTORY_SLOT_SCRIPT.new() as PanelContainer
	slot.custom_minimum_size = Vector2(48.0, 48.0)
	slot.call("configure", "craft", index, null)
	slot.connect("slot_activated", _on_craft_slot_gui_input)
	slot.connect("item_dropped", _on_slot_item_dropped)
	var craft_style := UI.style_box(Color("292d2d"), Color("777b70"), 3, 1)
	craft_style.content_margin_left = 2.0
	craft_style.content_margin_right = 2.0
	craft_style.content_margin_top = 2.0
	craft_style.content_margin_bottom = 2.0
	slot.add_theme_stylebox_override("panel", craft_style)
	var content := VBoxContainer.new()
	content.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_theme_constant_override("separation", 0)
	slot.add_child(content)
	var texture := TextureRect.new()
	texture.name = "CraftTexture"
	texture.custom_minimum_size = Vector2(28.0, 28.0)
	texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	texture.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	texture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_child(texture)
	var icon := UI.label("", 17, Color("f3e7cc"))
	icon.name = "CraftIcon"
	icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	icon.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	icon.custom_minimum_size.y = 16.0
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_child(icon)
	return slot


func _on_craft_slot_gui_input(slot: PanelContainer, mouse_event: InputEventMouseButton) -> void:
	if not mouse_event.pressed or mouse_event.button_index != MOUSE_BUTTON_LEFT:
		return
	var index := int(slot.get("slot_index"))
	if index == 9:
		_craft_from_grid()
	elif index >= 0 and index < _craft_grid_items.size():
		var item_id: Variant = _craft_grid_items[index]
		if item_id != null:
			if _inventory_add(item_id, 1) == 0:
				_craft_grid_items[index] = null
				_set_game_status("%s devolvido ao inventário." % _item_short_name(item_id))
			else:
				_set_game_status("Não há espaço para devolver o ingrediente.")
		_refresh_crafting()
	get_viewport().set_input_as_handled()


func _craft_recipe_for_grid() -> Dictionary:
	var station := "crafting_table" if _has_nearby_crafting_table() else "inventory"
	var recipe := RECIPE_BOOK.find_grid_recipe(_craft_grid_items, station)
	if not recipe.is_empty():
		return recipe
	var material_to_model := {1: 37, 2: 38, 3: 39, 21: 40, 7: 41, 9: 42, 6: 43, 24: 44, 25: 45, 23: 46, 22: 47, 17: 48}
	for material_id: Variant in material_to_model:
		var pattern: Array = [material_id, material_id, null, material_id, material_id, null, null, null, null]
		if _craft_grid_items == pattern:
			var model_id := int(material_to_model[material_id])
			return {"id": "cubeworld_%d" % model_id, "name": "4 × %s" % WORLD_SCRIPT.BLOCK_NAMES[model_id], "item": model_id, "quantity": 4, "max_stack": 999, "station": station, "ingredients": [{"item": material_id, "quantity": 4}]}
	return {}


func _craft_from_grid() -> void:
	var recipe := _craft_recipe_for_grid()
	if recipe.is_empty():
		_set_game_status("Receita inválida. Organize os ingredientes na grade.")
		return
	var output_id: Variant = recipe["item"]
	var output_quantity := int(recipe["quantity"])
	var output_limit := int(recipe.get("max_stack", 99999))
	if output_limit <= 0 or output_quantity <= 0 or not _inventory_can_add(output_id, output_quantity):
		_set_game_status("Não há espaço para o resultado.")
		return
	if _inventory_add(output_id, output_quantity) > 0:
		_set_game_status("Não há espaço nos 36 slots para o resultado.")
		return
	for i in range(_craft_grid_items.size()):
		_craft_grid_items[i] = null
	_set_game_status("Fabricado: %s." % str(recipe["name"]))
	_refresh_crafting()
	_refresh_hud()


func _item_texture(item_id: Variant) -> Texture2D:
	var paths := {
		1: "res://assets/textures/blocks/grass_top.png",
		2: "res://assets/textures/blocks/dirt.png",
		3: "res://assets/textures/blocks/stone_minecraft.png",
		4: "res://assets/textures/blocks/oak_log_side.png",
		5: "res://assets/textures/blocks/oak_leaves_minecraft.png",
		6: "res://assets/textures/blocks/sand.png",
		7: "res://assets/textures/blocks/oak_planks.png"
	}
	var path := str(paths.get(item_id, ""))
	if path.is_empty() or not ResourceLoader.exists(path):
		return null
	return load(path) as Texture2D


func _item_short_name(item_id: Variant) -> String:
	if EXTRA_ITEM_NAMES.has(item_id):
		return str(EXTRA_ITEM_NAMES[item_id])
	if item_id is int and WORLD_SCRIPT.BLOCK_NAMES.has(item_id):
		return str(WORLD_SCRIPT.BLOCK_NAMES[item_id])
	return str(ITEM_NAMES.get(item_id, item_id))


func _item_glyph(item_id: Variant) -> String:
	var glyphs := {
		1: "▦", 2: "▪", 3: "◆", 4: "▤", 5: "✿", 6: "▧", 7: "▥",
		"gravetos": "╱╲", "sementes_trigo": "⁙", "trigo": "▥", "frutas": "●", "gelatina": "◆",
		"fragmento_lunar": "✦", "nucleo_lunar": "✧", "shuriken": "✹", 12: "●", 13: "⬟", 14: "✿", 15: "◉", 16: "◉", 17: "⬢",
		21: "▦", 22: "▦", 23: "⬢", 24: "✧", 25: "◆", 26: "▤", 27: "✹", 28: "✿", 33: "◆",
		"picareta": "⛏", "picareta_pedra": "⛏", "picareta_ferro": "⛏", "machado_ferro": "⚒", "pa": "╱", "pa_pedra": "╱", "pa_ferro": "╱",
		"espada": "†", "espada_pedra": "†", "espada_ferro": "†", "armadura_couro_cabeca": "⌂",
		"armadura_couro_peito": "▣", "armadura_couro_pernas": "▥", "armadura_couro_botas": "∩",
		"mesa_craft": "⌂", "bau": "▣", "tocha": "♨", "fogueira": "♨", "lanterna_cristal": "✧",
		"caixote": "▣", "porta": "▥", "alcapao": "▦", "janela": "▧", "cama": "▰", "bedroll": "▱", "fornalha": "♨",
		"vidro": "◇", "carvao_vegetal": "⬢", "barraca": "⌂", "balde": "∪", "carvao": "⬢", "carne_cozida": "●"
	}
	return str(glyphs.get(item_id, "■"))


func _build_village_shop_panel() -> void:
	_shop_overlay = Control.new()
	_shop_overlay.name = "VillageShopOverlay"
	UI.full_rect(_shop_overlay)
	_shop_overlay.visible = false
	_shop_overlay.process_mode = Node.PROCESS_MODE_ALWAYS
	_ui_layer.add_child(_shop_overlay)
	var shade := ColorRect.new()
	shade.color = Color(0.02, 0.025, 0.025, 0.72)
	shade.mouse_filter = Control.MOUSE_FILTER_STOP
	UI.full_rect(shade)
	_shop_overlay.add_child(shade)
	var center := CenterContainer.new()
	UI.full_rect(center)
	_shop_overlay.add_child(center)
	_shop_panel = UI.holo_panel(Color("d4b56e"), Vector2(24.0, 20.0))
	_shop_panel.name = "VillageShopPanel"
	_shop_panel.custom_minimum_size = Vector2(480.0, 0.0)
	center.add_child(_shop_panel)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 10)
	_shop_panel.add_child(content)
	var title := UI.display_label("MERCADO DA VILA", 26, Color("f1ead8"), "heading")
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content.add_child(title)
	content.add_child(UI.label("Troque recursos por mercadorias. A troca só acontece se houver espaço na mochila.", 12, Color("d0d5c6")))
	for index: int in range(VILLAGE_TRADES.size()):
		var trade: Dictionary = VILLAGE_TRADES[index]
		var button := UI.button(str(trade.get("title", "Troca")), 420.0)
		if index == 0:
			UI.primary(button)
		button.pressed.connect(_execute_village_trade.bind(index))
		content.add_child(button)
	_shop_status = UI.label("Escolha uma troca.", 12, Color("d8d2bf"))
	_shop_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content.add_child(_shop_status)
	var close_button := UI.quiet_button("Fechar  (F / E / Esc)", 13)
	close_button.pressed.connect(_close_village_shop)
	content.add_child(close_button)


func _build_pause_screen() -> void:
	_pause_screen = Control.new()
	_pause_screen.name = "PauseScreen"
	UI.full_rect(_pause_screen)
	_pause_screen.visible = false
	_pause_screen.process_mode = Node.PROCESS_MODE_ALWAYS
	_ui_layer.add_child(_pause_screen)
	var shade := ColorRect.new()
	shade.color = Color(0.01, 0.02, 0.025, 0.72)
	shade.mouse_filter = Control.MOUSE_FILTER_STOP
	UI.full_rect(shade)
	_pause_screen.add_child(shade)
	var center := CenterContainer.new()
	UI.full_rect(center)
	_pause_screen.add_child(center)
	var panel := UI.holo_panel(Color("94bc73"), Vector2(34.0, 26.0))
	panel.custom_minimum_size = Vector2(420.0, 0.0)
	center.add_child(panel)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 10)
	panel.add_child(content)
	var title := UI.display_label("PAUSADO", 30, Color("eef1e5"), "heading")
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content.add_child(title)
	var resume := UI.button("VOLTAR AO JOGO", 340.0)
	UI.primary(resume)
	resume.pressed.connect(_resume_game)
	content.add_child(resume)
	var save_button := UI.button("SALVAR AGORA", 340.0)
	save_button.pressed.connect(_save_game)
	content.add_child(save_button)
	var settings_button := UI.button("CONFIGURAÇÕES", 340.0)
	settings_button.pressed.connect(_open_settings.bind(true))
	content.add_child(settings_button)
	var exit_button := UI.button("VOLTAR AO MENU", 340.0)
	exit_button.pressed.connect(_return_to_title)
	content.add_child(exit_button)


func _connect_network_signals() -> void:
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)


func _load_profile() -> void:
	_inventory = _default_inventory()
	_ensure_catalog_defaults()
	_hotbar_ids = DEFAULT_HOTBAR_IDS.duplicate(true)
	_backpack_slots = _default_backpack_slots()
	_rebuild_inventory_state_from_aggregate()
	_selected_avatar_id = "boy"
	_profile_seed = -1
	_profile_loaded = false
	_difficulty = "normal"
	_profile_drops.clear()
	_profile_world_props.clear()
	_profile_villages.clear()
	if not FileAccess.file_exists(PROFILE_PATH):
		return
	var file := FileAccess.open(PROFILE_PATH, FileAccess.READ)
	if file == null:
		return
	var parser := JSON.new()
	var parse_error := parser.parse(file.get_as_text())
	file.close()
	if parse_error != OK:
		return
	var parsed: Variant = parser.data
	if not parsed is Dictionary or int(parsed.get("version", 0)) not in [1, 2, 3, 4, 5, PROFILE_VERSION]:
		return
	_difficulty = str(parsed.get("difficulty", "normal"))
	if _difficulty not in ["easy", "normal", "hard"]:
		_difficulty = "normal"
	_profile_seed = int(parsed.get("seed", -1))
	_day_phase = fposmod(float(parsed.get("day_phase", 0.22)), 1.0)
	var bed_position: Variant = parsed.get("bed_spawn", [])
	if bed_position is Array and bed_position.size() >= 3:
		_bed_respawn_position = Vector3(float(bed_position[0]), float(bed_position[1]), float(bed_position[2]))
	else:
		_bed_respawn_position = Vector3.ZERO
	_selected_avatar_id = str(parsed.get("avatar_id", "boy"))
	if _selected_avatar_id not in AVATAR_IDS:
		_selected_avatar_id = "boy"
	var inventory_value: Variant = parsed.get("inventory", {})
	if not inventory_value is Dictionary:
		return
	var inventory_data: Dictionary = inventory_value
	for block_id: int in range(1, 8):
		_inventory[block_id] = clampi(int(inventory_data.get(str(block_id), _inventory[block_id])), 0, 99999)
	_inventory["sementes_trigo"] = clampi(int(inventory_data.get("sementes_trigo", _inventory["sementes_trigo"])), 0, 9999)
	_inventory["trigo"] = clampi(int(inventory_data.get("trigo", 0)), 0, 9999)
	_inventory["gravetos"] = clampi(int(inventory_data.get("gravetos", 0)), 0, 99999)
	_inventory["picareta"] = clampi(int(inventory_data.get("picareta", 0)), 0, 999)
	_inventory["frutas"] = clampi(int(inventory_data.get("frutas", 0)), 0, 9999)
	_inventory["gelatina"] = clampi(int(inventory_data.get("gelatina", 0)), 0, 9999)
	_inventory["fragmento_lunar"] = clampi(int(inventory_data.get("fragmento_lunar", 0)), 0, 9999)
	_inventory["nucleo_lunar"] = clampi(int(inventory_data.get("nucleo_lunar", 0)), 0, 9999)
	for item_id: Variant in [12, 13, 14, 15, 16, 17, 18, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, "sementes_trigo", "trigo", "mesa_craft", "bau", "tocha", "fogueira", "lanterna_cristal", "caixote", "porta", "balde", "carne_cozida", "carvao", "picareta_pedra", "picareta_ferro", "machado_ferro", "espada", "espada_pedra", "espada_ferro", "armadura_couro_cabeca", "armadura_couro_peito", "armadura_couro_pernas", "armadura_couro_botas"]:
		_inventory[item_id] = clampi(int(inventory_data.get(str(item_id), 0)), 0, 9999)
	for item_id: int in range(34, WORLD_SCRIPT.MAX_BLOCK_ID + 1):
		_inventory[item_id] = clampi(int(inventory_data.get(str(item_id), 0)), 0, 9999)
	for item_id: String in EXTRA_ITEM_IDS:
		_inventory[item_id] = clampi(int(inventory_data.get(item_id, 0)), 0, 9999)
	if not inventory_data.has("shuriken") and int(inventory_data.get("27", 0)) > 0:
		_inventory["shuriken"] = clampi(int(inventory_data.get("27", 0)), 0, 9999)
		_inventory[27] = 0
	var saved_hotbar: Variant = parsed.get("hotbar", [])
	if saved_hotbar is Array and saved_hotbar.size() == _hotbar_ids.size():
		for i in range(_hotbar_ids.size()):
			var hotbar_item: Variant = "shuriken" if saved_hotbar[i] is int and int(saved_hotbar[i]) == 27 else saved_hotbar[i]
			_hotbar_ids[i] = hotbar_item if hotbar_item == null or _is_valid_item_id(hotbar_item) else null
	var saved_backpack: Variant = parsed.get("backpack", [])
	if saved_backpack is Array and saved_backpack.size() == BACKPACK_SIZE:
		_backpack_slots.clear()
		for backpack_item: Variant in saved_backpack:
			_backpack_slots.append("shuriken" if backpack_item is int and int(backpack_item) == 27 else (backpack_item if backpack_item == null or _is_valid_item_id(backpack_item) else null))
	var saved_craft_grid: Variant = parsed.get("craft_grid", [])
	if saved_craft_grid is Array and saved_craft_grid.size() == 9:
		var valid_ids: Array = _inventory_item_ids
		for i in range(9):
			var craft_id: Variant = "shuriken" if saved_craft_grid[i] is int and int(saved_craft_grid[i]) == 27 else saved_craft_grid[i]
			_craft_grid_items[i] = craft_id if craft_id == null or valid_ids.has(craft_id) else null
	_health = clampf(float(parsed.get("health", 20.0)), 0.0, 20.0)
	_food = clampf(float(parsed.get("food", 20.0)), 0.0, 20.0)
	_xp = clampi(int(parsed.get("xp", 0)), 0, 999999999)
	_recalculate_level()
	var position_value: Variant = parsed.get("position", [])
	if position_value is Array and position_value.size() >= 3:
		_profile_position = Vector3(float(position_value[0]), float(position_value[1]), float(position_value[2]))
		# Evita restaurar posições corrompidas ou absurdamente distantes.
		if absf(_profile_position.x) > 1000000.0 or absf(_profile_position.y) > 1000000.0 or absf(_profile_position.z) > 1000000.0:
			_profile_position = Vector3.ZERO
	var drops_data: Variant = parsed.get("drops", [])
	if drops_data is Array:
		_profile_drops = drops_data.slice(0, 5000)
	var props_data: Variant = parsed.get("world_props", [])
	if props_data is Array:
		_profile_world_props = props_data.slice(0, 2000)
	var villages_data: Variant = parsed.get("villages", [])
	if villages_data is Array:
		_profile_villages = villages_data.slice(0, 256)
	var crops_data: Variant = parsed.get("crops", [])
	if crops_data is Array:
		_profile_crops = crops_data.slice(0, 500)
	var harvested_data: Variant = parsed.get("harvested_plants", [])
	if harvested_data is Array:
		_profile_harvested_plants = harvested_data.slice(0, 2000)
	var saved_stacks: Variant = parsed.get("slot_stacks", [])
	if _inventory_state.deserialize_slots(saved_stacks):
		_sync_legacy_slot_arrays_from_state()
	else:
		_rebuild_inventory_state_from_aggregate()
	_profile_loaded = true


func _default_inventory() -> Dictionary:
	return {1: 24, 2: 40, 3: 24, 4: 16, 5: 8, 6: 8, 7: 0, 21: 0, 22: 0, 23: 0, 24: 0, 25: 0, 26: 0, 27: 0, 28: 0, 29: 0, 30: 0, 31: 0, 32: 0, 33: 0, "gravetos": 0, "picareta": 0, "picareta_pedra": 0, "picareta_ferro": 0, "frutas": 0, "sementes_trigo": 6, "trigo": 0, "gelatina": 0, "fragmento_lunar": 0, "nucleo_lunar": 0, 12: 0, 13: 0, 14: 0, 15: 0, 16: 0, 17: 0, 18: 0, "mesa_craft": 0, "bau": 0, "tocha": 0, "fogueira": 0, "lanterna_cristal": 0, "caixote": 0, "porta": 0, "balde": 0, "carne_cozida": 0, "carvao": 0, "espada": 0, "espada_pedra": 0, "espada_ferro": 0, "armadura_couro_cabeca": 0, "armadura_couro_peito": 0, "armadura_couro_pernas": 0, "armadura_couro_botas": 0}


func _ensure_catalog_defaults() -> void:
	for item_id: String in EXTRA_ITEM_IDS:
		if not _inventory.has(item_id):
			_inventory[item_id] = 0


func _default_backpack_slots() -> Array:
	var slots: Array = []
	for item_id: Variant in _inventory_item_ids:
		if _hotbar_ids.has(item_id):
			continue
		slots.append(item_id)
	slots.resize(BACKPACK_SIZE)
	return slots


func _is_valid_item_id(item_id: Variant) -> bool:
	return _inventory_item_ids.has(item_id)


func _ensure_item_slots() -> void:
	_reconcile_inventory_state()
	_sync_legacy_slot_arrays_from_state()


func _reset_player_profile() -> void:
	_inventory = _default_inventory()
	_ensure_catalog_defaults()
	_hotbar_ids = DEFAULT_HOTBAR_IDS.duplicate(true)
	_backpack_slots = _default_backpack_slots()
	_rebuild_inventory_state_from_aggregate()
	_health = 20.0
	_food = 20.0
	_xp = 0
	_level = 1
	_survival_timer = 0.0
	_hunger_tick = 0.0
	_profile_seed = -1
	_profile_loaded = false
	_profile_world_props.clear()
	_profile_villages.clear()
	_bed_respawn_position = Vector3.ZERO
	_day_phase = 0.22
	_profile_drops.clear()
	_profile_crops.clear()
	_profile_harvested_plants.clear()
	_harvested_plant_cells.clear()


func _create_world(seed_value: int, saved_overrides: Array) -> void:
	_clear_world()
	_world = WORLD_SCRIPT.new() as ByteCrafterWorld
	_world.name = "VoxelWorld"
	_world.process_mode = Node.PROCESS_MODE_PAUSABLE
	add_child(_world)
	_world.configure(seed_value, saved_overrides, int(_settings_store.get_value("gameplay", "chunk_radius", 2)))
	_world.blocks_changed.connect(_refresh_hud)
	_world.fallen_fruit_generated.connect(_on_fallen_fruit_generated)
	_crops.clear()
	_crop_nodes.clear()
	_harvested_plant_cells.clear()
	_player = PLAYER_SCRIPT.new() as ByteCrafterPlayer
	_player.set_avatar_id(_selected_avatar_id)
	_player.configure_world(_world)
	_player.process_mode = Node.PROCESS_MODE_DISABLED
	add_child(_player)
	_player.global_position = _world.get_spawn_position()
	_apply_visual_settings()
	if _profile_loaded and _profile_seed == seed_value:
		_player.global_position = _profile_position
		_restore_profile_world_props()
		for position_value: Variant in _profile_harvested_plants:
			if position_value is Array and position_value.size() >= 3:
				_harvested_plant_cells.append(Vector3i(int(position_value[0]), int(position_value[1]), int(position_value[2])))
	else:
		_day_phase = 0.22
		_bed_respawn_position = Vector3.ZERO
	_village_system = VILLAGE_SYSTEM_SCRIPT.new() as ByteCrafterVillageSystem
	_village_system.name = "VillageSystem"
	add_child(_village_system)
	var saved_villages: Array = _profile_villages if _profile_loaded and _profile_seed == seed_value else []
	_village_system.configure(_world, seed_value, _player.global_position, saved_villages, is_daytime())
	_village_update_timer = 0.0
	_spawn_creatures()
	_spawn_enemies()
	if _profile_loaded and _profile_seed == seed_value:
		_restore_profile_drops()
		_restore_profile_crops()
	_spawn_fallen_fruit_drops()
	_selected_slot = 0
	_remote_positions.clear()


func _clear_world() -> void:
	if _village_system != null and is_instance_valid(_village_system):
		remove_child(_village_system)
		_village_system.free()
		_village_system = null
	for drop_value: Variant in _drop_nodes.values():
		var drop := drop_value as ByteCrafterDrop
		if is_instance_valid(drop):
			remove_child(drop)
			drop.free()
	_drop_nodes.clear()
	_drop_records.clear()
	_fruit_drop_cells.clear()
	_fallen_fruit_drop_ids.clear()
	_next_drop_id = 1
	for prop: Node3D in _world_props:
		if is_instance_valid(prop):
			prop.queue_free()
	_world_props.clear()
	_crafting_tables.clear()
	_active_furnace = null
	if _furnace_panel != null:
		_furnace_panel.visible = false
	for crop_value: Variant in _crop_nodes.values():
		var crop_node := crop_value as Node3D
		if is_instance_valid(crop_node):
			crop_node.queue_free()
	_crop_nodes.clear()
	_crops.clear()
	for creature: ByteCrafterCreature in _creatures:
		if is_instance_valid(creature):
			creature.set_physics_process(false)
			creature.queue_free()
	_creatures.clear()
	for fish: ByteCrafterCreature in _fish:
		if is_instance_valid(fish):
			fish.set_physics_process(false)
			fish.queue_free()
	_fish.clear()
	for enemy: ByteCrafterEnemy in _enemies:
		if is_instance_valid(enemy):
			enemy.set_physics_process(false)
			enemy.queue_free()
	_enemies.clear()
	if _player != null and is_instance_valid(_player):
		remove_child(_player)
		_player.free()
		_player = null
	if _world != null and is_instance_valid(_world):
		remove_child(_world)
		_world.free()
		_world = null


func _spawn_world_prop(prop_id: String, coords: Vector3i, opened := false, saved_furnace: Dictionary = {}) -> ByteCrafterProp:
	if not _is_placeable_prop(prop_id):
		return null
	var prop := PROP_SCRIPT.new() as ByteCrafterProp
	prop.configure(prop_id, coords, opened, saved_furnace)
	prop.position = Vector3(float(coords.x) + 0.5, float(coords.y), float(coords.z) + 0.5)
	prop.process_mode = Node.PROCESS_MODE_PAUSABLE
	add_child(prop)
	_world_props.append(prop)
	if prop_id == "mesa_craft":
		_crafting_tables.append(prop)
	return prop


func _restore_profile_world_props() -> void:
	for value: Variant in _profile_world_props:
		if not value is Dictionary:
			continue
		var entry: Dictionary = value
		var prop_id := str(entry.get("id", ""))
		var position_value: Variant = entry.get("position", [])
		if not _is_placeable_prop(prop_id) or not position_value is Array or position_value.size() < 3:
			continue
		var coords := Vector3i(int(position_value[0]), int(position_value[1]), int(position_value[2]))
		if absi(coords.x) > 1000000 or absi(coords.z) > 1000000 or coords.y < 0 or coords.y > WORLD_SCRIPT.WORLD_HEIGHT:
			continue
		if _world.get_block_at(coords) != 0:
			continue
		if _world_prop_occupies_cell(coords):
			continue
		var furnace_value: Variant = entry.get("furnace", {})
		var furnace_data: Dictionary = furnace_value if furnace_value is Dictionary else {}
		var prop := _spawn_world_prop(prop_id, coords, bool(entry.get("open", false)), furnace_data)
		if prop != null:
			prop.rotation.y = float(entry.get("rotation_y", 0.0))
			if prop_id == "fornalha":
				prop.set_furnace_lit(float(prop.furnace_state.get("burn_left", 0.0)) > 0.0)


func _serialize_world_props() -> Array:
	var result: Array = []
	for node: Node3D in _world_props:
		var prop := node as ByteCrafterProp
		if is_instance_valid(prop):
			result.append(prop.serialize_state())
	return result


func _world_prop_occupies_cell(coords: Vector3i) -> bool:
	for node: Node3D in _world_props:
		var prop := node as ByteCrafterProp
		if is_instance_valid(prop) and prop.cell == coords:
			return true
	return false


func _spawn_creatures() -> void:
	var species_list := ["chicken", "chicken", "horse", "sheep", "dog"]
	var species_index := 0
	for x: int in range(-12, 13, 4):
		for z: int in range(-12, 13, 4):
			if _creatures.size() >= species_list.size():
				break
			if absi(x) < 5 and absi(z) < 5:
				continue
			var ground := _world.terrain_height(x, z)
			var above := _world.get_block_at(Vector3i(x, ground + 1, z))
			if above != 0:
				continue
			var creature := CREATURE_SCRIPT.new() as ByteCrafterCreature
			creature.configure(str(species_list[species_index]), _world)
			creature.process_mode = Node.PROCESS_MODE_PAUSABLE
			creature.position = Vector3(float(x) + 0.5, float(ground) + 1.05, float(z) + 0.5)
			add_child(creature)
			_creatures.append(creature)
			creature.defeated.connect(_on_creature_defeated)
			species_index += 1
	_spawn_fish()


func _spawn_fish() -> void:
	if _world == null or _player == null:
		return
	var center := _player.global_position
	var water_positions: Array[Vector3] = []
	for index: int in 512:
		var angle := float(index) * 2.39996323
		var radius := 9.0 + sqrt(float(index)) * 4.0
		var x := floori(center.x + cos(angle) * radius)
		var z := floori(center.z + sin(angle) * radius)
		var column := Vector3(float(x) + 0.5, center.y, float(z) + 0.5)
		var surface := _world.get_water_surface_height_at(column)
		if not is_finite(surface):
			continue
		var depth := surface - float(_world.terrain_height(x, z) + 1)
		if depth < 0.45:
			continue
		var too_close := false
		for previous: Vector3 in water_positions:
			if previous.distance_to(column) < 7.0:
				too_close = true
				break
		if too_close:
			continue
		water_positions.append(column)
		var fish := CREATURE_SCRIPT.new() as ByteCrafterCreature
		fish.configure("fish", _world)
		fish.position = Vector3(column.x, surface - randf_range(0.25, minf(1.1, depth - 0.1)), column.z)
		fish.process_mode = Node.PROCESS_MODE_PAUSABLE
		add_child(fish)
		_fish.append(fish)
		fish.defeated.connect(_on_creature_defeated)
		if water_positions.size() >= 6:
			break


func _spawn_initial_plants() -> void:
	if _world == null:
		return
	var spawn := _world.get_spawn_position()
	var center := Vector2i(floori(spawn.x), floori(spawn.z))
	var initial_plants := [
		{"kind": "tomato", "offset": Vector2i(9, 1)},
		{"kind": "tomato", "offset": Vector2i(10, 1)},
		{"kind": "carrot", "offset": Vector2i(9, 3)},
		{"kind": "carrot", "offset": Vector2i(10, 3)},
		{"kind": "fruit", "offset": Vector2i(-9, 1)},
		{"kind": "fruit", "offset": Vector2i(-10, 1)},
		{"kind": "wheat", "offset": Vector2i(-9, 3)},
		{"kind": "wheat", "offset": Vector2i(-10, 3)},
	]
	for plant: Dictionary in initial_plants:
		var point: Vector2i = center + plant.offset
		var ground := _world.terrain_height(point.x, point.y)
		var cell := Vector3i(point.x, ground + 1, point.y)
		if _harvested_plant_cells.has(cell) or _world.get_block_at(cell) != 0 or _world.get_block_at(cell - Vector3i.UP) not in [1, 2, 8]:
			continue
		_crops[cell] = {"kind": str(plant.kind), "stage": 3, "age": 24.0, "wild": true}
		_create_or_update_crop(cell)


func _on_creature_defeated(creature: ByteCrafterCreature, at_position: Vector3) -> void:
	_creatures.erase(creature)
	_fish.erase(creature)
	if not _network_active or _is_host:
		_award_xp(creature.get_xp_reward())
		var creature_drops := creature.get_drops()
		for index: int in creature_drops.size():
			var entry: Array = creature_drops[index]
			_spawn_drop_local(_allocate_drop_id(), int(entry[0]), at_position + Vector3(float(index) * 0.35, 0.3, 0.0), int(entry[1]))
	_set_game_status("%s caçado · carne e materiais disponíveis." % creature.get_display_name())


func _spawn_enemies() -> void:
	if (_network_active and not _is_host) or not _monsters_enabled():
		if not _monsters_enabled():
			_set_game_status("Monstros hostis desativados nas configurações.")
		return
	var spawn := _world.get_spawn_position()
	var center := Vector2i(floori(spawn.x), floori(spawn.z))
	var encounters := [
		{"type": "slime", "point": center + Vector2i(7, 3)},
		{"type": "zombie", "point": center + Vector2i(8, -6)},
	]
	if not is_daytime():
		encounters.append({"type": "et", "point": center + Vector2i(-7, 5)})
		encounters.append({"type": "runner", "point": center + Vector2i(5, 9)})
		if _is_boss_night():
			encounters.append({"type": "boss", "point": center + Vector2i(-11, -9)})
		else:
			encounters.append({"type": "shooter", "point": center + Vector2i(-10, 2)})
	for encounter: Dictionary in encounters:
		_spawn_enemy(str(encounter.get("type", "slime")), encounter.get("point", Vector2i.ZERO))
	_set_game_status("Inimigos próximos: observe os nomes acima deles.")


func _spawn_enemy(enemy_type: String, spawn_point: Vector2i) -> void:
	if not _monsters_enabled() or _active_enemy_count() >= _active_enemy_limit():
		return
	spawn_point = _find_natural_enemy_spawn_point(spawn_point)
	var ground := _world.terrain_height(spawn_point.x, spawn_point.y)
	var enemy := ENEMY_SCRIPT.new() as ByteCrafterEnemy
	enemy.process_mode = Node.PROCESS_MODE_PAUSABLE
	enemy.position = Vector3(float(spawn_point.x) + 0.5, float(ground) + 1.18, float(spawn_point.y) + 0.5)
	enemy.configure(_player, self, enemy_type)
	add_child(enemy)
	enemy.defeated.connect(_on_enemy_defeated)
	_enemies.append(enemy)


func _find_natural_enemy_spawn_point(preferred: Vector2i) -> Vector2i:
	if _player == null or _world == null:
		return _find_safe_enemy_spawn_point(preferred)
	var player_cell := Vector2i(floori(_player.global_position.x), floori(_player.global_position.z))
	for attempt in 32:
		var angle := randf_range(0.0, TAU)
		var radius := randf_range(9.0, 14.5)
		var candidate := Vector2i(floori(_player.global_position.x + cos(angle) * radius), floori(_player.global_position.z + sin(angle) * radius))
		var ground := _world.terrain_height(candidate.x, candidate.y)
		var feet := Vector3i(candidate.x, ground + 1, candidate.y)
		var head := feet + Vector3i.UP
		var ground_block := _world.get_block_at(Vector3i(candidate.x, ground, candidate.y))
		if candidate.distance_to(player_cell) < 8.0 or ground_block == WORLD_SCRIPT.BLOCK_WATER:
			continue
		if _world.get_block_at(feet) == 0 and _world.get_block_at(head) == 0:
			return candidate
	return _find_safe_enemy_spawn_point(preferred)


func _active_enemy_count() -> int:
	var count := 0
	for enemy: ByteCrafterEnemy in _enemies.duplicate():
		if not is_instance_valid(enemy) or bool(enemy.get("_defeated")):
			_enemies.erase(enemy)
			continue
		count += 1
	return count


func _find_safe_enemy_spawn_point(preferred: Vector2i) -> Vector2i:
	for radius: int in range(0, 7):
		for dx: int in range(-radius, radius + 1):
			for dz: int in range(-radius, radius + 1):
				if radius > 0 and absi(dx) != radius and absi(dz) != radius:
					continue
				var candidate := preferred + Vector2i(dx, dz)
				var ground := _world.terrain_height(candidate.x, candidate.y)
				var feet := Vector3i(candidate.x, ground + 1, candidate.y)
				var head := feet + Vector3i.UP
				if _world.get_block_at(feet) == 0 and _world.get_block_at(head) == 0:
					return candidate
	return preferred


func _is_boss_night() -> bool:
	return _difficulty != "easy" and not is_daytime() and get_sunlight_strength() < 0.035


func _update_enemy_schedule() -> void:
	if _world == null or _player == null or (_network_active and not _is_host) or not _monsters_enabled():
		return
	_night_spawn_cooldown = maxf(0.0, _night_spawn_cooldown - ENEMY_SCHEDULE_INTERVAL)
	_monster_spawn_cooldown = maxf(0.0, _monster_spawn_cooldown - ENEMY_SCHEDULE_INTERVAL)
	var et_present := false
	var boss_present := false
	var runner_present := false
	var shooter_present := false
	var zombie_present := false
	for enemy: ByteCrafterEnemy in _enemies.duplicate():
		if not is_instance_valid(enemy):
			continue
		if enemy.enemy_type == "et":
			et_present = true
			if is_daytime():
				# A pele do ET não suporta a luz: a morte também cria o drop normal.
				enemy.take_damage(10.0)
		if enemy.enemy_type == "boss":
			boss_present = true
			if is_daytime():
				enemy.take_damage(10.0)
		if enemy.enemy_type == "runner":
			runner_present = true
		if enemy.enemy_type == "shooter":
			shooter_present = true
		if enemy.enemy_type == "zombie":
			zombie_present = true
			if is_daytime():
				enemy.take_damage(1.0)
		elif enemy.is_day_sensitive() and is_daytime():
			enemy.take_damage(enemy.health)
	if is_daytime():
		return
	var spawn := _world.get_spawn_position()
	var center := Vector2i(floori(spawn.x), floori(spawn.z))
	var enemy_limit := _active_enemy_limit()
	if not zombie_present and _night_spawn_cooldown <= 0.0 and _active_enemy_count() < enemy_limit:
		_spawn_enemy("zombie", center + Vector2i(8, -6))
		_night_spawn_cooldown = 18.0 if _difficulty == "easy" else (5.0 if _difficulty == "hard" else 8.0)
	if _is_boss_night():
		if not boss_present:
			if _active_enemy_count() >= enemy_limit:
				for candidate: ByteCrafterEnemy in _enemies:
					if is_instance_valid(candidate) and candidate.enemy_type in ["shooter", "runner", "et", "slime"]:
						_enemies.erase(candidate)
						candidate.queue_free()
						break
			_spawn_enemy("boss", center + Vector2i(-11, -9))
		if not et_present and _active_enemy_count() < enemy_limit:
			_spawn_enemy("et", center + Vector2i(-7, 5))
		if not runner_present and _active_enemy_count() < enemy_limit:
			_spawn_enemy("runner", center + Vector2i(5, 9))
	else:
		if not et_present and _active_enemy_count() < enemy_limit:
			_spawn_enemy("et", center + Vector2i(-7, 5))
		if not runner_present and _active_enemy_count() < enemy_limit:
			_spawn_enemy("runner", center + Vector2i(5, 9))
		if _difficulty != "easy" and not shooter_present and _active_enemy_count() < enemy_limit:
			_spawn_enemy("shooter", center + Vector2i(-10, 2))
		if _difficulty != "easy" and _monster_spawn_cooldown <= 0.0 and _active_enemy_count() < enemy_limit:
			var monster_type := ENEMY_SCRIPT.pick_monster_type(_is_boss_night())
			if not monster_type.is_empty():
				_spawn_enemy(monster_type, center + Vector2i(randi_range(-12, 12), randi_range(-12, 12)))
				_monster_spawn_cooldown = randf_range(10.0, 18.0) if _difficulty == "hard" else randf_range(18.0, 30.0)


func _monsters_enabled() -> bool:
	return bool(_settings_store.get_value("gameplay", "monsters", true)) if _settings_store != null else true


func _active_enemy_limit() -> int:
	if _difficulty == "easy":
		return 3
	if _difficulty == "hard":
		return 7
	return MAX_ACTIVE_ENEMIES


func _on_enemy_defeated(enemy: Node3D, at_position: Vector3) -> void:
	if enemy is ByteCrafterEnemy:
		_enemies.erase(enemy)
	var reward_item_id: int = enemy.get_reward_item_id() if enemy is ByteCrafterEnemy else 9
	var enemy_name: String = enemy.get_display_name() if enemy is ByteCrafterEnemy else "Inimigo"
	var xp_reward: int = enemy.get_xp_reward() if enemy is ByteCrafterEnemy else 8
	if not _network_active or _is_host:
		_award_xp(xp_reward)
	if enemy is ByteCrafterEnemy:
		_spawn_enemy_loot(enemy as ByteCrafterEnemy, at_position)
	else:
		_spawn_drop_local(_allocate_drop_id(), reward_item_id, at_position + Vector3(0.0, 0.3, 0.0), 1)
	_set_game_status("%s derrotado · loot disponível." % enemy_name)


func _spawn_enemy_loot(enemy: ByteCrafterEnemy, at_position: Vector3) -> void:
	var loot := enemy.get_loot_table()
	if enemy.enemy_type in ["slime", "runner"] and randf() < 0.1:
		var rare_drop_pool := [8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 21, 22, 23, 24, 25, 26, 28, "shuriken"]
		loot.append([rare_drop_pool.pick_random(), 1])
	for index: int in loot.size():
		var entry: Array = loot[index]
		if entry.size() < 2:
			continue
		var item_id: Variant = entry[0]
		var quantity := maxi(1, int(entry[1]))
		var offset := Vector3(float(index - loot.size() * 0.5) * 0.42, 0.35 + float(index) * 0.08, 0.0)
		if _network_active:
			_apply_inventory_delta(item_id, 0, quantity)
		else:
			_spawn_drop_local(_allocate_drop_id(), item_id, at_position + offset, quantity)


func _start_singleplayer() -> void:
	_open_continue_difficulty_selector()


func _start_new_world(difficulty: String = "normal") -> void:
	_reset_player_profile()
	_difficulty = difficulty if difficulty in ["easy", "normal", "hard"] else "normal"
	var new_seed := randi_range(100000, 999999999)
	_create_world(new_seed, [])
	_enter_game()


func _continue_with_difficulty(difficulty: String) -> void:
	_difficulty = difficulty if difficulty in ["easy", "normal", "hard"] else "normal"
	_enter_game()


func _enter_game() -> void:
	if _player == null or _world == null:
		return
	get_tree().paused = false
	_paused = false
	_screen = "game"
	_apply_visual_settings()
	_title_screen.visible = false
	_pause_screen.visible = false
	_game_hud.visible = true
	_craft_panel.visible = false
	_player.process_mode = Node.PROCESS_MODE_PAUSABLE
	_player.can_control = true
	if _player.global_position.y < 0.0 or _player.global_position.distance_to(_world.get_spawn_position()) > 200.0:
		_player.global_position = _world.get_spawn_position()
	_player.velocity = Vector3.ZERO
	_world.update_streaming(_player.global_position)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_refresh_hud()


func _host_lan() -> void:
	if OS.has_feature("web"):
		_set_title_status("Hospedagem LAN está disponível somente na build nativa do Godot.")
		return
	var peer := ENetMultiplayerPeer.new()
	var result := peer.create_server(LAN_PORT, 8)
	if result != OK:
		_set_title_status("Não foi possível abrir a porta UDP %d (código %d)." % [LAN_PORT, result])
		return
	multiplayer.multiplayer_peer = peer
	_network_active = true
	_is_host = true
	_join_pending = false
	_set_title_status("Mundo hospedado na LAN · porta UDP %d" % LAN_PORT)
	_enter_game()


func _join_lan() -> void:
	if OS.has_feature("web"):
		_set_title_status("Para jogar em LAN, abra a build nativa do Godot.")
		return
	var address := _ip_input.text.strip_edges()
	if address.is_empty():
		_set_title_status("Digite o IP local do anfitrião.")
		return
	var peer := ENetMultiplayerPeer.new()
	var result := peer.create_client(address, LAN_PORT)
	if result != OK:
		_set_title_status("Não foi possível iniciar a conexão (código %d)." % result)
		return
	multiplayer.multiplayer_peer = peer
	_network_active = true
	_is_host = false
	_join_pending = true
	_set_title_status("Conectando a %s:%d…" % [address, LAN_PORT])


func _on_connected_to_server() -> void:
	if _join_pending:
		_set_title_status("Conectado. Recebendo o mundo do anfitrião…")
		rpc_id(1, "request_world_state")


func _on_connection_failed() -> void:
	_network_active = false
	_join_pending = false
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	_set_title_status("Conexão falhou. Confira o IP, a mesma rede local e a porta UDP %d." % LAN_PORT)


func _on_server_disconnected() -> void:
	_network_active = false
	_is_host = false
	_join_pending = false
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	_set_game_status("Conexão LAN encerrada pelo anfitrião.")
	_return_to_title()


func _on_peer_connected(peer_id: int) -> void:
	if multiplayer.is_server():
		rpc("register_remote_player", peer_id)


func _on_peer_disconnected(peer_id: int) -> void:
	_remove_remote_player(peer_id)


@rpc("any_peer", "call_remote", "reliable")
func request_world_state() -> void:
	if not multiplayer.is_server() or _world == null:
		return
	var sender := multiplayer.get_remote_sender_id()
	rpc_id(sender, "receive_world_state", _world.world_seed, _world.get_overrides_array())


@rpc("authority", "call_remote", "reliable")
func receive_world_state(seed_value: int, saved_overrides: Array) -> void:
	if not _join_pending:
		return
	_join_pending = false
	_profile_loaded = false
	_create_world(seed_value, saved_overrides)
	_enter_game()
	rpc_id(1, "request_player_roster")
	_set_game_status("Na LAN · sincronizado com o anfitrião")


@rpc("any_peer", "call_remote", "reliable")
func request_player_roster() -> void:
	if not multiplayer.is_server():
		return
	var ids: Array[int] = [1]
	for id: int in multiplayer.get_peers():
		ids.append(id)
	rpc_id(multiplayer.get_remote_sender_id(), "populate_remote_players", ids)


@rpc("authority", "call_remote", "reliable")
func populate_remote_players(peer_ids: Array) -> void:
	for peer_value: Variant in peer_ids:
		_register_remote_player(int(peer_value))


@rpc("authority", "call_local", "reliable")
func register_remote_player(peer_id: int) -> void:
	_register_remote_player(peer_id)


func _register_remote_player(peer_id: int) -> void:
	if peer_id == multiplayer.get_unique_id() or _remote_avatars.has(peer_id):
		return
	var avatar := AVATAR_SCRIPT.new() as ByteCrafterAvatar
	avatar.name = "LANPlayer_%d" % peer_id
	avatar.configure("boy")
	add_child(avatar)
	if _world != null:
		avatar.global_position = _world.get_spawn_position() + Vector3(float(peer_id % 3) * 1.5, 0.0, 2.0)
	_remote_avatars[peer_id] = avatar
	_remote_positions[peer_id] = avatar.global_position


func _remove_remote_player(peer_id: int) -> void:
	if _remote_avatars.has(peer_id):
		var avatar: Node = _remote_avatars[peer_id]
		if is_instance_valid(avatar):
			avatar.queue_free()
		_remote_avatars.erase(peer_id)
	_remote_positions.erase(peer_id)


func _send_player_pose() -> void:
	if not _network_active or _player == null or multiplayer.multiplayer_peer is OfflineMultiplayerPeer:
		return
	var network_position: Vector3 = _player.global_position
	var yaw := _player.get_avatar_yaw()
	var avatar_id := _player.get_avatar_id()
	var animation_state := _player.get_animation_state()
	if multiplayer.is_server():
		_remote_positions[1] = network_position
		rpc("receive_player_pose", 1, network_position, yaw, avatar_id, animation_state)
	else:
		rpc_id(1, "submit_player_pose", network_position, yaw, avatar_id, animation_state)


@rpc("any_peer", "call_remote", "unreliable_ordered")
func submit_player_pose(network_position: Vector3, yaw: float, avatar_id: String, animation_state: String) -> void:
	if not multiplayer.is_server():
		return
	var sender := multiplayer.get_remote_sender_id()
	var last: Vector3 = _remote_positions.get(sender, _world.get_spawn_position() if _world != null else Vector3.ZERO)
	if network_position.distance_to(last) > 14.0:
		return
	if avatar_id not in AVATAR_IDS:
		avatar_id = "boy"
	if animation_state not in ["idle", "walk", "run", "jump", "swim", "float", "sleep1", "sleep2", "sleep3", "dance1", "dance2", "pickup", "mine", "attack", "death"]:
		animation_state = "idle"
	_remote_positions[sender] = network_position
	rpc("receive_player_pose", sender, network_position, yaw, avatar_id, animation_state)


@rpc("authority", "call_remote", "unreliable_ordered")
func receive_player_pose(peer_id: int, network_position: Vector3, yaw: float, avatar_id: String, animation_state: String) -> void:
	if peer_id == multiplayer.get_unique_id():
		return
	if not _remote_avatars.has(peer_id):
		_register_remote_player(peer_id)
	var avatar := _remote_avatars.get(peer_id) as ByteCrafterAvatar
	if is_instance_valid(avatar):
		avatar.configure(avatar_id)
		avatar.global_position = network_position
		avatar.rotation.y = yaw
		avatar.set_animation_state(animation_state)
	_remote_positions[peer_id] = network_position


func _request_block_change(coords: Vector3i, new_block_id: int, spent_block_id: int) -> void:
	if _world == null:
		return
	var old_block := _world.get_block_at(coords)
	if old_block == new_block_id:
		return
	if not _network_active:
		if _world.set_block_at(coords, new_block_id):
			AudioDirector.play_cue("world.place", 1.0)
			if new_block_id == 0 and old_block > 0:
				_spawn_drop_local(_allocate_drop_id(), _drop_item_for_block(old_block), Vector3(float(coords.x) + 0.5, float(coords.y) + 0.5, float(coords.z) + 0.5))
				_award_xp(_xp_for_block(old_block))
			if spent_block_id > 0:
				_apply_inventory_delta(0, spent_block_id)
		return
	if multiplayer.is_server():
		if _world.set_block_at(coords, new_block_id):
			var reward_item_id := _drop_item_for_block(old_block) if new_block_id == 0 else 0
			var drop_id := _allocate_drop_id() if reward_item_id > 0 else -1
			var xp_reward := _xp_for_block(old_block) if new_block_id == 0 and old_block > 0 else 0
			rpc("sync_world_block", coords, new_block_id, reward_item_id, spent_block_id, multiplayer.get_unique_id(), drop_id, xp_reward)
	else:
		rpc_id(1, "request_world_block", coords, new_block_id, spent_block_id)

## F: interage com a estação/estrutura mais próxima; sem estrutura, ataca o alvo.
func _interact_contextual() -> void:
	if (_craft_panel != null and _craft_panel.visible) or (_furnace_panel != null and _furnace_panel.visible):
		return
	var villager := _village_system.get_nearest_villager(_player.global_position, 3.25) if _village_system != null else null
	if villager != null:
		villager.play_interaction_action()
		if villager.is_merchant():
			_open_village_shop(villager)
		else:
			_set_game_status(villager.interaction_text())
		return
	var prop := _nearest_world_prop()
	if prop != null:
		match prop.prop_id:
			"porta", "alcapao", "janela":
				_toggle_openable_prop(prop)
			"mesa_craft":
				_toggle_crafting()
				_set_game_status("Bancada ativa: receitas avançadas liberadas enquanto você estiver a até 3 m.")
			"fornalha":
				_open_furnace(prop)
			"cama", "bedroll":
				_use_bed(prop)
			"bau":
				_player.play_action("door")
				_set_game_status("Baú encontrado. O armazenamento em slots ainda não foi integrado.")
			"barraca":
				_set_game_status("Barraca montada. Encontre um aldeão comerciante para negociar.")
			_:
				_set_game_status("%s está no mundo." % _item_short_name(prop.prop_id))
		return
	if _try_attack_enemy():
		return
	_set_game_status("Nada para interagir aqui.")


func _try_mouse_prop_interaction() -> bool:
	if _player == null or _player.camera == null or not _player.can_control:
		return false
	var hit := _raycast_target()
	if hit.is_empty():
		return false
	var prop := _prop_from_raycast_hit(hit)
	if prop == null or prop.prop_id not in ["porta", "alcapao", "janela"]:
		return false
	if prop.global_position.distance_to(_player.global_position) > 3.25:
		return false
	_toggle_openable_prop(prop)
	return true


func _toggle_openable_prop(prop: ByteCrafterProp) -> void:
	if prop == null or _player == null:
		return
	var opened := prop.toggle_open(_player)
	_player.play_action("door")
	_set_game_status("%s %s." % [_item_short_name(prop.prop_id), "aberta" if opened and prop.prop_id == "janela" else "aberto" if opened else "fechada" if prop.prop_id == "janela" else "fechado"])


func _nearest_world_prop() -> ByteCrafterProp:
	if _player == null:
		return null
	var nearest: ByteCrafterProp = null
	var nearest_distance := 3.25
	for node: Node3D in _world_props:
		var prop := node as ByteCrafterProp
		if not is_instance_valid(prop):
			continue
		if prop.prop_id not in ["porta", "alcapao", "mesa_craft", "fornalha", "cama", "bau", "janela", "barraca"]:
			continue
		var distance := prop.global_position.distance_to(_player.global_position)
		if distance <= nearest_distance:
			nearest = prop
			nearest_distance = distance
	return nearest


func _open_village_shop(villager: ByteCrafterVillager) -> void:
	if villager == null or _shop_overlay == null or _shop_panel == null:
		return
	_active_villager = villager
	_shop_overlay.visible = true
	if _shop_status != null:
		_shop_status.text = "%s está atendendo. Escolha uma troca." % villager.display_name
	if _player != null:
		_player.can_control = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _close_village_shop() -> void:
	if _shop_overlay != null:
		_shop_overlay.visible = false
	_active_villager = null
	if _player != null and _screen == "game" and not _paused:
		_player.can_control = true
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _execute_village_trade(trade_index: int) -> void:
	if trade_index < 0 or trade_index >= VILLAGE_TRADES.size() or _shop_overlay == null or not _shop_overlay.visible:
		return
	var trade: Dictionary = VILLAGE_TRADES[trade_index]
	var first_item: Variant = trade.get("cost_item", null)
	var first_count := int(trade.get("cost_count", 0))
	var second_item: Variant = trade.get("cost_item_2", null)
	var second_count := int(trade.get("cost_count_2", 0))
	var reward_item: Variant = trade.get("reward_item", null)
	var reward_count := int(trade.get("reward_count", 0))
	if first_item == null or reward_item == null or first_count <= 0 or reward_count <= 0:
		return
	if int(_inventory.get(first_item, 0)) < first_count or (second_item != null and int(_inventory.get(second_item, 0)) < second_count):
		if _shop_status != null:
			_shop_status.text = "Faltam recursos para essa troca."
		return
	if not _inventory_can_add(reward_item, reward_count):
		if _shop_status != null:
			_shop_status.text = "A mochila está cheia para receber %s." % _item_short_name(reward_item).to_lower()
		return
	var removed_first := _inventory_remove(first_item, first_count)
	if removed_first != first_count:
		if removed_first > 0:
			_inventory_add(first_item, removed_first)
		if _shop_status != null:
			_shop_status.text = "A troca falhou; seus itens foram preservados."
		return
	var removed_second := 0
	if second_item != null and second_count > 0:
		removed_second = _inventory_remove(second_item, second_count)
		if removed_second != second_count:
			_inventory_add(first_item, removed_first)
			if removed_second > 0:
				_inventory_add(second_item, removed_second)
			if _shop_status != null:
				_shop_status.text = "A troca falhou; seus itens foram devolvidos."
			return
	var leftover := _inventory_add(reward_item, reward_count)
	if leftover > 0:
		_inventory_remove(reward_item, reward_count - leftover)
		_inventory_add(first_item, removed_first)
		if removed_second > 0:
			_inventory_add(second_item, removed_second)
		if _shop_status != null:
			_shop_status.text = "A troca foi cancelada; não havia espaço suficiente."
		return
	if _shop_status != null:
		_shop_status.text = "Troca concluída: %s recebido." % _item_short_name(reward_item).to_lower()
	_set_game_status("Troca com %s concluída." % (_active_villager.display_name if is_instance_valid(_active_villager) else "o comerciante"))
	_refresh_hud()
	_refresh_crafting()


func _has_nearby_crafting_table() -> bool:
	if _player == null:
		return false
	for table: Node3D in _crafting_tables:
		if is_instance_valid(table) and table.global_position.distance_to(_player.global_position) <= 3.2:
			return true
	return false


func _use_bed(bed: ByteCrafterProp) -> void:
	_bed_respawn_position = bed.global_position + Vector3(1.5, 1.15, 0.0)
	if is_daytime():
		_set_game_status("Ponto de renascimento definido na cama.")
		return
	for enemy: ByteCrafterEnemy in _enemies:
		if is_instance_valid(enemy) and enemy.global_position.distance_to(bed.global_position) < 8.0:
			_set_game_status("Não é seguro dormir: há monstros perto da cama.")
			return
	var previous_control := _player.can_control if _player != null else false
	if _player != null:
		_player.can_control = false
		_player.play_action(["sleep1", "sleep2", "sleep3"].pick_random())
	await get_tree().create_timer(2.2).timeout
	if _player != null and is_instance_valid(_player):
		_player.stop_action()
		_player.can_control = previous_control
	_day_phase = 0.22
	_update_day_night()
	_set_game_status("Você dormiu até o amanhecer. Ponto de renascimento atualizado.")


func _open_furnace(prop: ByteCrafterProp) -> void:
	if prop == null or _furnace_panel == null:
		return
	if _craft_panel != null:
		_craft_panel.visible = false
	_active_furnace = prop
	_furnace_panel.visible = true
	_mine_held = false
	if _player != null:
		_player.can_control = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_refresh_furnace_panel()


func _close_furnace() -> void:
	if _furnace_panel != null:
		_furnace_panel.visible = false
	_active_furnace = null
	if _player != null and _screen == "game" and not _paused:
		_player.can_control = true
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _furnace_add_input() -> void:
	if not is_instance_valid(_active_furnace):
		return
	var state := _active_furnace.furnace_state
	var current_input: Variant = state.get("input", null)
	for item_id: Variant in [13, 6, 12, 15, 4]:
		if int(_inventory.get(item_id, 0)) <= 0:
			continue
		if current_input != null and not _inventory_state.item_ids_equal(current_input, item_id):
			continue
		if int(state.get("input_count", 0)) >= 64:
			break
		if _inventory_remove(item_id, 1) == 1:
			state["input"] = item_id
			state["input_count"] = int(state.get("input_count", 0)) + 1
			_active_furnace.furnace_state = state
			_refresh_hud()
			_refresh_furnace_panel()
			return
	_set_game_status("Sem item fundível compatível: minério brilhante, areia, carne, banha ou tronco.")


func _furnace_add_fuel() -> void:
	if not is_instance_valid(_active_furnace):
		return
	var state := _active_furnace.furnace_state
	for item_id: Variant in FURNACE_FUEL_ITEMS:
		if int(_inventory.get(item_id, 0)) <= 0:
			continue
		if int(state.get("fuel_count", 0)) >= 64:
			break
		if _inventory_remove(item_id, 1) == 1:
			state["fuel_count"] = int(state.get("fuel_count", 0)) + 1
			_active_furnace.furnace_state = state
			_refresh_hud()
			_refresh_furnace_panel()
			return
	_set_game_status("Combustível aceito: carvão, carvão vegetal, tronco ou tábua.")


func _furnace_collect_output() -> void:
	if not is_instance_valid(_active_furnace):
		return
	var state := _active_furnace.furnace_state
	var output_id: Variant = state.get("output", null)
	var count := int(state.get("output_count", 0))
	if output_id == null or count <= 0:
		_set_game_status("A fornalha ainda não produziu nada.")
		return
	var leftover := _inventory_add(output_id, count)
	var collected := count - leftover
	if collected > 0:
		state["output_count"] = leftover
		if leftover == 0:
			state["output"] = null
		_active_furnace.furnace_state = state
		_set_game_status("Retirado: %s × %d." % [_item_short_name(output_id), collected])
		_refresh_hud()
	_refresh_furnace_panel()


func _process_furnaces(delta: float) -> void:
	for node: Node3D in _world_props:
		var prop := node as ByteCrafterProp
		if not is_instance_valid(prop) or prop.prop_id != "fornalha":
			continue
		var state := prop.furnace_state
		var input_id: Variant = state.get("input", null)
		var output_id: Variant = FURNACE_INPUT_OUTPUT.get(input_id, null)
		var output_slot: Variant = state.get("output", null)
		var output_count := int(state.get("output_count", 0))
		var output_fits := output_id != null and (output_slot == null or _inventory_state.item_ids_equal(output_slot, output_id)) and output_count < _inventory_state.max_stack_size(output_id)
		var has_input := input_id != null and int(state.get("input_count", 0)) > 0 and output_fits
		if has_input and float(state.get("burn_left", 0.0)) <= 0.0 and int(state.get("fuel_count", 0)) > 0:
			state["fuel_count"] = int(state.get("fuel_count", 0)) - 1
			state["burn_left"] = 12.0
		if has_input and float(state.get("burn_left", 0.0)) > 0.0:
			state["burn_left"] = maxf(0.0, float(state.get("burn_left", 0.0)) - delta)
			state["cook_progress"] = float(state.get("cook_progress", 0.0)) + delta
			if float(state["cook_progress"]) >= 4.0:
				state["cook_progress"] = float(state["cook_progress"]) - 4.0
				state["output"] = output_id
				state["output_count"] = output_count + 1
				state["input_count"] = int(state.get("input_count", 0)) - 1
				if int(state["input_count"]) <= 0:
					state["input"] = null
		prop.furnace_state = state
		prop.set_furnace_lit(float(state.get("burn_left", 0.0)) > 0.0)


func _refresh_furnace_panel() -> void:
	if _furnace_info == null or not is_instance_valid(_active_furnace):
		return
	var state := _active_furnace.furnace_state
	var input_id: Variant = state.get("input", null)
	var output_id: Variant = state.get("output", null)
	var input_text := "vazio" if input_id == null else "%s × %d" % [_item_short_name(input_id), int(state.get("input_count", 0))]
	var output_text := "vazio" if output_id == null else "%s × %d" % [_item_short_name(output_id), int(state.get("output_count", 0))]
	_furnace_info.text = "Entrada: %s\nCombustível restante: %d item(ns) + %.1f s de chama\nSaída: %s\nProgresso: %.1f / 4.0 s" % [input_text, int(state.get("fuel_count", 0)), float(state.get("burn_left", 0.0)), output_text, float(state.get("cook_progress", 0.0))]


func _try_attack_enemy() -> bool:
	if _player == null or _attack_cooldown > 0.0:
		return false
	var selected_item: Variant = _selected_hotbar_item()
	if str(_canonical_item_id(selected_item)) == "shuriken" and _selected_hotbar_count() > 0:
		_throw_shuriken()
		return true
	var ray_start := _player.camera.global_position
	var forward := -_player.camera.global_basis.z.normalized()
	var enemy: ByteCrafterEnemy = null
	var best_distance := 3.4
	for candidate: ByteCrafterEnemy in _enemies:
		if not is_instance_valid(candidate) or bool(candidate.get("_defeated")):
			continue
		var to_enemy := candidate.global_position + Vector3.UP * 0.45 - ray_start
		var forward_distance := to_enemy.dot(forward)
		var lateral_distance := (to_enemy - forward * forward_distance).length()
		if forward_distance > 0.0 and forward_distance <= best_distance and lateral_distance <= 0.72:
			enemy = candidate
			best_distance = forward_distance
	if enemy != null:
		_attack_cooldown = 0.48
		_player.play_action("attack")
		AudioDirector.play_cue("player.attack", 1.0)
		var selected_weapon: Variant = _selected_hotbar_item()
		var damage := 1.0
		match str(selected_weapon):
			"espada_ferro": damage = 5.0
			"espada_pedra": damage = 3.8
			"espada": damage = 2.8
			"picareta_ferro": damage = 2.2
			"picareta_pedra": damage = 1.7
			"picareta": damage = 1.4
			"machado_ferro": damage = 2.4
			"pa_ferro": damage = 1.5
			"pa_pedra": damage = 1.3
			"pa": damage = 1.2
		enemy.take_damage(damage)
		_set_game_status("Golpe acertou %s · vida %.1f" % [enemy.get_display_name(), enemy.health])
		return true
	var creature_target: ByteCrafterCreature = null
	best_distance = 3.4
	for creature: ByteCrafterCreature in _creatures:
		if not is_instance_valid(creature) or bool(creature.get("_defeated")):
			continue
		var to_creature := creature.global_position + Vector3.UP * 0.45 - ray_start
		var forward_distance := to_creature.dot(forward)
		var lateral_distance := (to_creature - forward * forward_distance).length()
		if forward_distance > 0.0 and forward_distance <= best_distance and lateral_distance <= 0.9:
			creature_target = creature
			best_distance = forward_distance
	if creature_target == null:
		return false
	_attack_cooldown = 0.48
	_player.play_action("attack")
	AudioDirector.play_cue("player.attack", 1.0)
	var selected_weapon: Variant = _selected_hotbar_item()
	var creature_damage := 4 if str(selected_weapon) == "espada_ferro" else (3 if str(selected_weapon) == "espada_pedra" else (2 if str(selected_weapon) == "espada" else 1))
	creature_target.take_damage(creature_damage)
	_set_game_status("Golpe acertou %s · vida %d" % [creature_target.get_display_name(), creature_target.health])
	return true


func _throw_shuriken() -> void:
	if _player == null:
		return
	var projectile := SHURIKEN_SCRIPT.new() as Area3D
	var direction := -_player.camera.global_basis.z
	projectile.configure(_player.camera.global_position + direction * 0.8, direction, 3.0)
	add_child(projectile)
	_inventory_remove("shuriken", 1, _selected_slot)
	_attack_cooldown = 0.35
	_player.play_action("attack")
	AudioDirector.play_cue("player.attack", 1.2)
	_refresh_hud()


@rpc("any_peer", "call_remote", "reliable")
func request_world_block(coords: Vector3i, new_block_id: int, spent_block_id: int) -> void:
	if not multiplayer.is_server() or _world == null:
		return
	var sender := multiplayer.get_remote_sender_id()
	if new_block_id < 0 or new_block_id > WORLD_SCRIPT.MAX_BLOCK_ID or spent_block_id < 0 or spent_block_id > WORLD_SCRIPT.MAX_BLOCK_ID:
		return
	if new_block_id != 0 and (not _is_placeable_voxel_item(new_block_id) or spent_block_id != new_block_id):
		return
	if new_block_id == 0 and spent_block_id != 0:
		return
	var player_position: Vector3 = _remote_positions.get(sender, _world.get_spawn_position())
	var block_center := Vector3(float(coords.x) + 0.5, float(coords.y) + 0.5, float(coords.z) + 0.5)
	if player_position.distance_to(block_center) > BREAK_DIST:
		return
	var old_block := _world.get_block_at(coords)
	if old_block == new_block_id or (new_block_id == 0 and old_block == 0):
		return
	if _world.set_block_at(coords, new_block_id):
		var reward_item_id := _drop_item_for_block(old_block) if new_block_id == 0 else 0
		var drop_id := _allocate_drop_id() if reward_item_id > 0 else -1
		var xp_reward := _xp_for_block(old_block) if new_block_id == 0 and old_block > 0 else 0
		rpc("sync_world_block", coords, new_block_id, reward_item_id, spent_block_id, sender, drop_id, xp_reward)


@rpc("authority", "call_local", "reliable")
func sync_world_block(coords: Vector3i, new_block_id: int, reward_item_id: int, spent_block_id: int, actor_id: int, drop_id: int, xp_reward := 0) -> void:
	if _world != null:
		_world.set_block_at(coords, new_block_id)
	if reward_item_id > 0 and drop_id >= 0:
		_spawn_drop_local(drop_id, reward_item_id, Vector3(float(coords.x) + 0.5, float(coords.y) + 0.5, float(coords.z) + 0.5))
	if actor_id == multiplayer.get_unique_id() and spent_block_id > 0:
		_apply_inventory_delta(0, spent_block_id)
	if actor_id == multiplayer.get_unique_id() and xp_reward > 0:
		_award_xp(xp_reward)


func _world_prop_break_key(prop: ByteCrafterProp) -> String:
	if prop.has_meta("village_prop_key"):
		return "village|%s|%s" % [str(prop.get_meta("village_owner", "")), str(prop.get_meta("village_prop_key", ""))]
	return "world|%s@%d,%d,%d" % [prop.prop_id, prop.cell.x, prop.cell.y, prop.cell.z]


func _find_world_prop_by_break_key(prop_key: String) -> ByteCrafterProp:
	if prop_key.is_empty() or prop_key.length() > 256:
		return null
	for node: Node in get_tree().get_nodes_in_group("bytecrafter_props"):
		var prop := node as ByteCrafterProp
		if is_instance_valid(prop) and _world_prop_break_key(prop) == prop_key:
			return prop
	return null


func _request_prop_break(prop: ByteCrafterProp) -> void:
	if prop == null or not is_instance_valid(prop) or not _is_placeable_prop(prop.prop_id):
		return
	if not _network_active:
		_authoritative_prop_break(prop, multiplayer.get_unique_id())
	elif multiplayer.is_server():
		_authoritative_prop_break(prop, multiplayer.get_unique_id())
	else:
		rpc_id(1, "request_world_prop_break", _world_prop_break_key(prop))


func _authoritative_prop_break(prop: ByteCrafterProp, actor_id: int) -> void:
	if prop == null or not is_instance_valid(prop):
		return
	var prop_key := _world_prop_break_key(prop)
	var prop_id := prop.prop_id
	var drop_position := prop.global_position + Vector3.UP * 0.55
	var drop_id := _allocate_drop_id()
	if _network_active:
		rpc("sync_world_prop_broken", prop_key, prop_id, drop_position, actor_id, drop_id)
	else:
		sync_world_prop_broken(prop_key, prop_id, drop_position, actor_id, drop_id)


@rpc("any_peer", "call_remote", "reliable")
func request_world_prop_break(prop_key: String) -> void:
	if not _network_active or not multiplayer.is_server() or prop_key.is_empty() or prop_key.length() > 256:
		return
	var sender := multiplayer.get_remote_sender_id()
	var prop := _find_world_prop_by_break_key(prop_key)
	if sender <= 1 or prop == null or not is_instance_valid(prop):
		return
	if not _remote_positions.has(sender):
		return
	var player_position: Vector3 = _remote_positions[sender]
	if player_position.distance_to(prop.global_position) > BREAK_DIST + 1.25:
		return
	_authoritative_prop_break(prop, sender)


@rpc("authority", "call_local", "reliable")
func sync_world_prop_broken(prop_key: String, prop_id: String, drop_position: Vector3, actor_id: int, drop_id: int) -> void:
	if not _is_placeable_prop(prop_id):
		return
	var prop := _find_world_prop_by_break_key(prop_key)
	if prop != null:
		if prop.prop_id != prop_id:
			return
		if _village_system != null:
			_village_system.mark_prop_broken(prop)
		if prop == _active_furnace:
			_close_furnace()
		if prop.prop_id in ["cama", "bedroll"]:
			var saved_spawn := prop.global_position + Vector3(1.5, 1.15, 0.0)
			if _bed_respawn_position.distance_to(saved_spawn) <= 0.2:
				_bed_respawn_position = Vector3.ZERO
		_world_props.erase(prop)
		_crafting_tables.erase(prop)
		prop.queue_free()
	if drop_id >= 0:
		_spawn_drop_local(drop_id, prop_id, drop_position)
	if actor_id == multiplayer.get_unique_id():
		_set_game_status("Você recuperou 1 %s." % _item_short_name(prop_id).to_lower())


func _apply_inventory_delta(reward_id: Variant, spent_id: int, reward_quantity: int = 1) -> void:
	if reward_id != null and _is_valid_item_id(_canonical_item_id(reward_id)):
		_inventory_add(_canonical_item_id(reward_id), reward_quantity)
	if spent_id > 0:
		_inventory_remove(_canonical_item_id(spent_id), 1, _selected_slot)
	_refresh_hud()


func _drop_item_for_block(block_id: int) -> int:
	if block_id == 27:
		return 16
	if block_id in [28, 32]:
		return 8
	if block_id == 29:
		return 30
	if block_id == 30:
		return 31
	if block_id == 31:
		return 32
	if block_id == 11 or block_id == 13:
		return 18
	if block_id == 12:
		return 3
	if block_id in [21, 22, 23, 24, 25, 26]:
		return block_id
	return 8 if block_id == 5 and randf() < 0.24 else block_id


func _xp_for_block(block_id: int) -> int:
	return int(XP_BY_BLOCK.get(block_id, 0))


func _xp_for_next_level(level: int) -> int:
	return 20 + maxi(0, level - 1) * 12


func _recalculate_level() -> void:
	_level = 1
	var remaining := _xp
	while remaining >= _xp_for_next_level(_level) and _level < 999:
		remaining -= _xp_for_next_level(_level)
		_level += 1


func _xp_into_current_level() -> int:
	var remaining := _xp
	for level: int in range(1, _level):
		remaining -= _xp_for_next_level(level)
	return maxi(0, remaining)


func _award_xp(amount: int) -> void:
	if amount <= 0:
		return
	var previous_level := _level
	_xp = clampi(_xp + amount, 0, 999999999)
	_recalculate_level()
	if _level > previous_level:
		_set_game_status("Nível %d alcançado!" % _level)
	_refresh_hud()


func _allocate_drop_id() -> int:
	var result := _next_drop_id
	_next_drop_id += 1
	return result


func _discard_oldest_drop() -> bool:
	var oldest_id := -1
	var oldest_created_msec := Time.get_ticks_msec() + 1
	for drop_id_value: Variant in _drop_nodes.keys():
		var record_value: Variant = _drop_records.get(drop_id_value, {})
		var created_msec := int((record_value as Dictionary).get("created_msec", 0)) if record_value is Dictionary else 0
		if created_msec < oldest_created_msec:
			oldest_created_msec = created_msec
			oldest_id = int(drop_id_value)
	if oldest_id < 0:
		return false
	_mark_fallen_fruit_collected(oldest_id)
	_remove_drop_local(oldest_id)
	return true


func _spawn_drop_local(drop_id: int, item_id: Variant, drop_position: Vector3, quantity: int = 1) -> void:
	if drop_id < 0 or not _is_valid_item_id(_canonical_item_id(item_id)) or _drop_nodes.has(drop_id):
		return
	while _drop_nodes.size() >= MAX_ACTIVE_DROPS:
		if not _discard_oldest_drop():
			break
	var drop := DROP_SCRIPT.new() as ByteCrafterDrop
	drop.configure(drop_id, item_id, maxi(1, quantity))
	drop.process_mode = Node.PROCESS_MODE_PAUSABLE
	drop.position = drop_position
	add_child(drop)
	_drop_nodes[drop_id] = drop
	_drop_records[drop_id] = {"item_id": item_id, "quantity": maxi(1, quantity), "position": drop_position, "created_msec": Time.get_ticks_msec()}
	_next_drop_id = maxi(_next_drop_id, drop_id + 1)


func _spawn_fallen_fruit_drops() -> void:
	if _world == null:
		return
	var fruit_cells: Dictionary = _world.get("_fallen_fruit_cells")
	for cell_value: Variant in fruit_cells.keys():
		_on_fallen_fruit_generated(cell_value)


func _on_fallen_fruit_generated(cell: Vector3i) -> void:
	if _world == null or _harvested_plant_cells.has(cell):
		if _world != null and _harvested_plant_cells.has(cell):
			_world.mark_fruit_collected(cell)
		return
	if _fallen_fruit_drop_ids.has(cell):
		var existing_id := int(_fallen_fruit_drop_ids[cell])
		if _drop_records.has(existing_id):
			return
		_fallen_fruit_drop_ids.erase(cell)
	for key: Variant in _drop_records.keys():
		var record: Dictionary = _drop_records[key]
		var record_item: Variant = record.get("item_id", 0)
		if str(record_item) not in ["8", "frutas"]:
			continue
		var drop_position: Vector3 = record.get("position", Vector3.ZERO)
		if Vector2(drop_position.x - float(cell.x) - 0.5, drop_position.z - float(cell.z) - 0.5).length() <= 0.45:
			var saved_id := int(key)
			_fruit_drop_cells[saved_id] = cell
			_fallen_fruit_drop_ids[cell] = saved_id
			return
	var drop_id := _allocate_drop_id()
	_spawn_drop_local(drop_id, 8, Vector3(float(cell.x) + 0.5, float(cell.y) + 0.25, float(cell.z) + 0.5))
	if _drop_records.has(drop_id):
		_fruit_drop_cells[drop_id] = cell
		_fallen_fruit_drop_ids[cell] = drop_id


func _mark_fallen_fruit_collected(drop_id: int) -> void:
	if not _fruit_drop_cells.has(drop_id):
		return
	var cell: Vector3i = _fruit_drop_cells[drop_id]
	_fruit_drop_cells.erase(drop_id)
	_fallen_fruit_drop_ids.erase(cell)
	if not _harvested_plant_cells.has(cell):
		_harvested_plant_cells.append(cell)
	if _world != null and is_instance_valid(_world):
		_world.mark_fruit_collected(cell)


func _update_drop_position(drop_id: int, drop_position: Vector3) -> void:
	if _drop_records.has(drop_id):
		(_drop_records[drop_id] as Dictionary)["position"] = drop_position


func _restore_profile_drops() -> void:
	for entry: Variant in _profile_drops:
		if not entry is Array or entry.size() < 5:
			continue
		var drop_id := int(entry[0])
		var item_id: Variant = "shuriken" if entry[1] is int and int(entry[1]) == 27 else entry[1]
		if not _is_valid_item_id(_canonical_item_id(item_id)):
			continue
		var quantity := maxi(1, int(entry[5])) if entry.size() >= 6 else 1
		_spawn_drop_local(drop_id, item_id, Vector3(float(entry[2]), float(entry[3]), float(entry[4])), quantity)


func _serialize_drops() -> Array:
	var result: Array = []
	for key: Variant in _drop_records.keys():
		var drop_id := int(key)
		var record: Dictionary = _drop_records[drop_id]
		var drop_position: Vector3 = record.get("position", Vector3.ZERO)
		result.append([drop_id, record.get("item_id", 0), drop_position.x, drop_position.y, drop_position.z, int(record.get("quantity", 1))])
	return result


func _remove_drop_local(drop_id: int) -> void:
	var drop: Variant = _drop_nodes.get(drop_id)
	if drop is ByteCrafterDrop and is_instance_valid(drop):
		drop.queue_free()
	_drop_nodes.erase(drop_id)
	_drop_records.erase(drop_id)


func _on_drop_expired(drop_id: int) -> void:
	if not _drop_records.has(drop_id):
		return
	_mark_fallen_fruit_collected(drop_id)
	_remove_drop_local(drop_id)


func _on_drop_touched(drop_id: int) -> void:
	if not _drop_records.has(drop_id):
		return
	if not _network_active:
		var item_id: Variant = (_drop_records[drop_id] as Dictionary).get("item_id", 0)
		var quantity := int((_drop_records[drop_id] as Dictionary).get("quantity", 1))
		_mark_fallen_fruit_collected(drop_id)
		_remove_drop_local(drop_id)
		_apply_inventory_delta(item_id, 0, quantity)
		if _player != null:
			_player.play_action("pickup")
	elif multiplayer.is_server():
		_collect_drop_authoritatively(drop_id, multiplayer.get_unique_id())
	else:
		rpc_id(1, "request_collect_drop", drop_id)


func _collect_drop_authoritatively(drop_id: int, actor_id: int) -> void:
	if not _drop_records.has(drop_id):
		if actor_id != multiplayer.get_unique_id():
			rpc_id(actor_id, "drop_collection_rejected", drop_id)
		return
	var record: Dictionary = _drop_records[drop_id]
	var drop_position: Vector3 = record.get("position", Vector3.ZERO)
	var player_position := _player.global_position if actor_id == multiplayer.get_unique_id() and _player != null else Vector3.ZERO
	if actor_id != multiplayer.get_unique_id():
		player_position = _remote_positions.get(actor_id, Vector3.ZERO)
		if player_position.distance_to(drop_position) > 2.1:
			if actor_id != multiplayer.get_unique_id():
				rpc_id(actor_id, "drop_collection_rejected", drop_id)
			return
		var item_id: Variant = record.get("item_id", 0)
		_drop_records.erase(drop_id)
		rpc("sync_drop_collected", drop_id, item_id, actor_id)


@rpc("any_peer", "call_remote", "reliable")
func request_collect_drop(drop_id: int) -> void:
	if not _network_active or not multiplayer.is_server():
		return
	_collect_drop_authoritatively(drop_id, multiplayer.get_remote_sender_id())


@rpc("authority", "call_local", "reliable")
func sync_drop_collected(drop_id: int, item_id: Variant, actor_id: int) -> void:
	var quantity := 1
	if _drop_records.has(drop_id):
		quantity = int((_drop_records[drop_id] as Dictionary).get("quantity", 1))
	_mark_fallen_fruit_collected(drop_id)
	_remove_drop_local(drop_id)
	if actor_id == multiplayer.get_unique_id():
		_apply_inventory_delta(item_id, 0, quantity)
		if _player != null:
			_player.play_action("pickup")


@rpc("authority", "call_remote", "reliable")
func drop_collection_rejected(drop_id: int) -> void:
	var drop: Variant = _drop_nodes.get(drop_id)
	if drop is ByteCrafterDrop and is_instance_valid(drop):
		drop.allow_retry()


func _raycast_target() -> Dictionary:
	if _player == null or _player.camera == null:
		return {}
	var camera := _player.camera
	var origin := camera.global_position
	var end := origin + (-camera.global_transform.basis.z * BREAK_DIST)
	var query := PhysicsRayQueryParameters3D.create(origin, end, 1)
	query.exclude = [_player.get_rid()]
	query.collide_with_bodies = true
	query.collide_with_areas = false
	return get_world_3d().direct_space_state.intersect_ray(query)


func _hit_block_position(hit: Dictionary, outside: bool) -> Vector3i:
	var point: Vector3 = hit.get("position", Vector3.ZERO)
	var normal: Vector3 = hit.get("normal", Vector3.UP)
	if outside:
		point += normal * 0.02
	else:
		point -= normal * 0.02
	return Vector3i(floori(point.x), floori(point.y), floori(point.z))


func _process_mining(delta: float) -> void:
	if not _mine_held or _world == null or _player == null or (_craft_panel != null and _craft_panel.visible):
		_mine_prop = null
		_mine_position = Vector3i(-2147483647, -2147483647, -2147483647)
		_mine_progress.visible = false
		return
	var hit := _raycast_target()
	if hit.is_empty():
		_mine_timer = 0.0
		_mine_prop = null
		_mine_position = Vector3i(-2147483647, -2147483647, -2147483647)
		_mine_progress.visible = false
		return
	var target_prop := _prop_from_raycast_hit(hit)
	if target_prop != null:
		if not _is_placeable_prop(target_prop.prop_id):
			_mine_timer = 0.0
			_mine_prop = null
			_mine_progress.visible = false
			return
		if target_prop != _mine_prop:
			_mine_prop = target_prop
			_mine_position = Vector3i(-2147483647, -2147483647, -2147483647)
			_mine_timer = 0.0
			_mine_duration = _break_duration_for_prop(target_prop.prop_id)
			_player.play_action("mine")
		_mine_timer += delta
		_mine_progress.visible = true
		_mine_progress.value = clampf(_mine_timer / _mine_duration, 0.0, 1.0) * 100.0
		if _mine_timer >= _mine_duration:
			_request_prop_break(target_prop)
			_mine_held = false
			_mine_prop = null
			_mine_position = Vector3i(-2147483647, -2147483647, -2147483647)
			_mine_timer = 0.0
			_mine_progress.visible = false
		return
	if _mine_prop != null:
		_mine_prop = null
		_mine_position = Vector3i(-2147483647, -2147483647, -2147483647)
		_mine_timer = 0.0
	var coords := _hit_block_position(hit, false)
	var block_id := _world.get_block_at(coords)
	if block_id == 0:
		_mine_timer = 0.0
		_mine_progress.visible = false
		return
	if block_id == WORLD_SCRIPT.BLOCK_WATER:
		_mine_progress.visible = false
		_set_game_status("A água não pode ser minerada.")
		_mine_held = false
		return
	var selected_tool: Variant = _selected_hotbar_item()
	if block_id == 3 and str(selected_tool) not in ["picareta", "picareta_pedra", "picareta_ferro"]:
		_mine_progress.visible = false
		_set_game_status("Pedra exige uma picareta equipada.")
		_mine_held = false
		return
	if coords != _mine_position:
		_mine_position = coords
		_mine_timer = 0.0
		_mine_duration = _break_duration(block_id)
		_player.play_action("mine")
	_mine_timer += delta
	_mine_progress.visible = true
	_mine_progress.value = clampf(_mine_timer / _mine_duration, 0.0, 1.0) * 100.0
	if _mine_timer >= _mine_duration:
		_request_block_change(coords, 0, 0)
		_mine_held = false
		_mine_position = Vector3i(-2147483647, -2147483647, -2147483647)
		_mine_timer = 0.0
		_mine_progress.visible = false


func _prop_from_raycast_hit(hit: Dictionary) -> ByteCrafterProp:
	var collider_value: Variant = hit.get("collider", null)
	if not collider_value is Node:
		return null
	var node := collider_value as Node
	while node != null:
		if node is ByteCrafterProp:
			return node as ByteCrafterProp
		node = node.get_parent()
	return null


func _break_duration_for_prop(prop_id: String) -> float:
	var duration := 0.72
	if prop_id in ["barraca", "mesa_craft", "fornalha"]:
		duration = 0.95
	if prop_id in ["porta", "alcapao", "cama", "bedroll", "bau", "caixote"] and str(_selected_hotbar_item()) == "machado_ferro":
		duration *= 0.38
	return maxf(0.24, duration)


func _break_duration(block_id: int) -> float:
	var base := 1.0
	if block_id in [34, 35, 36]:
		base = 0.20
	elif block_id in [1, 2, 6]:
		base = 0.43
	elif block_id in [4, 5, 7]:
		base = 0.72
	elif block_id == 3:
		base = 1.25
	var selected_tool: String = str(_selected_hotbar_item())
	if block_id == 3 and selected_tool in ["picareta", "picareta_pedra", "picareta_ferro"]:
		base *= 0.22 if selected_tool == "picareta_ferro" else (0.29 if selected_tool == "picareta_pedra" else 0.34)
	if block_id in [4, 5] and selected_tool == "machado_ferro":
		base *= 0.28
	if block_id in [1, 2, 6] and selected_tool in ["pa", "pa_pedra", "pa_ferro"]:
		base *= 0.46 if selected_tool == "pa" else (0.32 if selected_tool == "pa_pedra" else 0.24)
	return base


func _place_crafting_table() -> void:
	if _player == null or _world == null or int(_inventory.get("mesa_craft", 0)) <= 0:
		_set_game_status("Fabrique uma mesa de craft primeiro.")
		return
	var point := _player.global_position - _player.global_basis.z * 1.7
	var cell_x := floori(point.x)
	var cell_z := floori(point.z)
	var coords := Vector3i(cell_x, _world.terrain_height(cell_x, cell_z) + 1, cell_z)
	if _world.get_block_at(coords) != 0 or _world_prop_occupies_cell(coords) or _placement_overlaps_player(coords):
		_set_game_status("Não há espaço seguro para colocar a mesa.")
		return
	var table := _spawn_world_prop("mesa_craft", coords)
	if table == null:
		return
	table.rotation.y = _player.rotation.y
	_inventory_remove("mesa_craft", 1, _selected_slot)
	_refresh_hud()
	_set_game_status("Mesa colocada. Pressione E próximo dela para abrir o crafting.")


func _use_farming_action() -> void:
	if _world == null or _player == null:
		return
	var hit := _raycast_target()
	if hit.is_empty():
		if _try_consume_selected_food():
			return
		_set_game_status("Aponte para terra ou grama para plantar.")
		return
	var target_cell := _hit_block_position(hit, false)
	if WORLD_SCRIPT.is_plant_block(_world.get_block_at(target_cell)):
		_request_block_change(target_cell, 0, 0)
		return
	var cell := _hit_block_position(hit, true)
	if _crops.has(cell):
		var crop_data: Dictionary = _crops[cell]
		if int(crop_data.get("stage", 0)) < 3:
			_set_game_status("A planta ainda está crescendo.")
			return
		_crops.erase(cell)
		var old_node := _crop_nodes.get(cell) as Node3D
		if is_instance_valid(old_node):
			old_node.queue_free()
		_crop_nodes.erase(cell)
		var kind := str(crop_data.get("kind", "wheat"))
		var harvested_name := "Trigo"
		match kind:
			"wheat":
				_inventory_add("trigo", 2)
				_inventory_add("sementes_trigo", 1)
			"carrot":
				_inventory_add(16, 1)
				harvested_name = "Cenoura"
			_:
				_inventory_add("frutas", 1)
				harvested_name = "Fruta"
		if bool(crop_data.get("wild", false)) and not _harvested_plant_cells.has(cell):
			_harvested_plant_cells.append(cell)
		_award_xp(2)
		_set_game_status("%s colhido." % harvested_name)
		_refresh_hud()
		return
	if _try_consume_selected_food():
		return
	var support := _world.get_block_at(cell - Vector3i.UP)
	if support not in [1, 2, 8] or _world.get_block_at(cell) != 0:
		_set_game_status("Plante sobre terra ou grama vazia.")
		return
	if int(_inventory.get("sementes_trigo", 0)) <= 0:
		_set_game_status("Você precisa de sementes de trigo.")
		return
	_inventory_remove("sementes_trigo", 1, _selected_slot)
	_crops[cell] = {"stage": 0, "age": 0.0, "kind": "wheat", "wild": false}
	_create_or_update_crop(cell)
	_set_game_status("Semente plantada. Pressione P novamente quando o trigo amadurecer.")
	_refresh_hud()


func _try_consume_selected_food() -> bool:
	if _selected_slot >= _hotbar_ids.size() or _food >= 20.0:
		return false
	var item_id: Variant = _hotbar_ids[_selected_slot]
	var nutrition_value: Variant = FOOD_NUTRITION.get(item_id, 0.0)
	var nutrition: float = 0.0
	if nutrition_value is int or nutrition_value is float:
		nutrition = float(nutrition_value)
	var inventory_key: Variant = item_id
	if str(item_id) == "8":
		inventory_key = "frutas"
	elif str(item_id) == "9":
		inventory_key = "gelatina"
	if nutrition <= 0.0 or _selected_hotbar_count() <= 0 or int(_inventory.get(inventory_key, 0)) <= 0:
		return false
	if _inventory_remove(inventory_key, 1, _selected_slot) <= 0:
		return false
	_food = minf(20.0, _food + float(nutrition))
	AudioDirector.play_cue("score.reward", 1.0)
	_set_game_status("Você comeu %s · +%.0f fome" % [_item_short_name(item_id), nutrition])
	_refresh_hud()
	return true


func _food_inventory_key(item_id: Variant) -> Variant:
	if str(item_id) == "8":
		return "frutas"
	if str(item_id) == "9":
		return "gelatina"
	return item_id


func _has_available_food() -> bool:
	if _food >= 20.0:
		return false
	for item_id: Variant in FOOD_ORDER:
		if int(_inventory.get(_food_inventory_key(item_id), 0)) > 0:
			return true
	return false


func _eat_available_food() -> void:
	if _food >= 20.0:
		_set_game_status("Sua fome já está cheia.")
		return
	var selected_food: Variant = null
	var selected_nutrition := 0.0
	for item_id: Variant in FOOD_ORDER:
		var inventory_key: Variant = _food_inventory_key(item_id)
		var nutrition := float(FOOD_NUTRITION.get(item_id, 0.0))
		if int(_inventory.get(inventory_key, 0)) > 0 and nutrition > selected_nutrition:
			selected_food = item_id
			selected_nutrition = nutrition
	if selected_food == null:
		_set_game_status("Você não tem comida para consumir.")
		return
	var selected_key: Variant = _food_inventory_key(selected_food)
	_inventory_remove(selected_key, 1)
	_food = minf(20.0, _food + selected_nutrition)
	AudioDirector.play_cue("score.reward", 1.0)
	_set_game_status("Você comeu %s · +%.0f fome" % [_item_short_name(selected_food), selected_nutrition])
	_refresh_crafting()
	_refresh_hud()


func _process_crops(delta: float) -> void:
	for cell_value: Variant in _crops.keys():
		var cell := cell_value as Vector3i
		var crop_data: Dictionary = _crops[cell]
		var stage := int(crop_data.get("stage", 0))
		if stage < 3:
			crop_data["age"] = float(crop_data.get("age", 0.0)) + delta
			crop_data["stage"] = mini(3, int(floor(float(crop_data["age"]) / 8.0)))
			_crops[cell] = crop_data
			stage = int(crop_data["stage"])
		var crop_node := _crop_nodes.get(cell) as Node3D
		var rendered_stage := int(crop_node.get_meta("rendered_stage", -1)) if is_instance_valid(crop_node) else -1
		if rendered_stage != stage:
			_create_or_update_crop(cell)


func _create_or_update_crop(cell: Vector3i) -> void:
	if not _crops.has(cell):
		return
	var crop_data: Dictionary = _crops[cell]
	var stage := int(crop_data.get("stage", 0))
	var kind := str(crop_data.get("kind", "wheat"))
	var crop := _crop_nodes.get(cell) as Node3D
	if not is_instance_valid(crop):
		crop = Node3D.new()
		crop.name = "%s_%d_%d_%d" % [kind, cell.x, cell.y, cell.z]
		add_child(crop)
		_crop_nodes[cell] = crop
	for child: Node in crop.get_children():
		child.queue_free()
	if kind == "wheat":
		var stalk := MeshInstance3D.new()
		var mesh := BoxMesh.new()
		mesh.size = Vector3(0.12 + stage * 0.05, 0.22 + stage * 0.20, 0.12 + stage * 0.05)
		stalk.mesh = mesh
		stalk.position.y = mesh.size.y * 0.5
		var material := StandardMaterial3D.new()
		material.albedo_color = Color("6c9e36") if stage < 3 else Color("d8b43d")
		material.roughness = 0.9
		stalk.material_override = material
		crop.add_child(stalk)
	else:
		var plant_scene: PackedScene = CROP_MODELS.get(kind, null)
		if plant_scene != null:
			var plant_model := plant_scene.instantiate() as Node3D
			plant_model.scale = Vector3.ONE * (0.22 + float(stage) * 0.08)
			plant_model.position.y = 0.05
			crop.add_child(plant_model)
	crop.set_meta("rendered_stage", stage)
	crop.position = Vector3(float(cell.x) + 0.5, float(cell.y), float(cell.z) + 0.5)


func _restore_profile_crops() -> void:
	for entry_value: Variant in _profile_crops:
			if not entry_value is Dictionary:
				continue
			var entry: Dictionary = entry_value
			var position_value: Variant = entry.get("position", [])
			if not position_value is Array or position_value.size() < 3:
				continue
			var cell := Vector3i(int(position_value[0]), int(position_value[1]), int(position_value[2]))
			if _world.get_block_at(cell - Vector3i.UP) not in [1, 2, 8] or _world.get_block_at(cell) != 0:
				continue
			_crops[cell] = {"stage": clampi(int(entry.get("stage", 0)), 0, 3), "age": maxf(0.0, float(entry.get("age", 0.0))), "kind": str(entry.get("kind", "wheat")), "wild": bool(entry.get("wild", false))}
			_create_or_update_crop(cell)


func _simple_material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.86
	return material


func _armor_damage_reduction() -> float:
	var pieces := 0
	for item_id: String in ["armadura_couro_cabeca", "armadura_couro_peito", "armadura_couro_pernas", "armadura_couro_botas"]:
		pieces += mini(1, int(_inventory.get(item_id, 0)))
	return minf(0.60, float(pieces) * 0.15)


func _place_selected_block() -> void:
	if _world == null or _player == null:
		return
	var selected_item: Variant = _hotbar_ids[_selected_slot]
	if selected_item is String and _is_placeable_prop(selected_item):
		_place_world_prop(selected_item)
		return
	if not selected_item is int:
		_set_game_status("Selecione um bloco para colocar.")
		return
	var block_id := int(selected_item)
	if not _is_placeable_voxel_item(selected_item):
		_set_game_status("Esse item não pode ser colocado como bloco.")
		return
	if int(_inventory.get(block_id, 0)) <= 0:
		_set_game_status("Sem %s no inventário." % WORLD_SCRIPT.BLOCK_NAMES.get(block_id, "bloco").to_lower())
		return
	var hit := _raycast_target()
	if hit.is_empty():
		return
	var coords := _hit_block_position(hit, true)
	if _world.get_block_at(coords) != 0:
		return
	if _placement_overlaps_player(coords):
		return
	_request_block_change(coords, block_id, block_id)


func _is_placeable_voxel_item(item_id: Variant) -> bool:
	return item_id is int and (int(item_id) in [1, 2, 3, 4, 5, 6, 7, 21, 22, 23, 24, 25, 26] or (int(item_id) >= 34 and int(item_id) <= WORLD_SCRIPT.MAX_BLOCK_ID))


func _is_placeable_prop(item_id: Variant) -> bool:
	if not item_id is String:
		return false
	return item_id in ["bau", "tocha", "fogueira", "lanterna_cristal", "mesa_craft", "caixote", "porta", "alcapao", "janela", "cama", "bedroll", "fornalha", "barraca"]


func _prop_model(prop_id: String) -> PackedScene:
	match prop_id:
		"bau":
			return CHEST_MODEL
		"tocha":
			return TORCH_MODEL
		"fogueira":
			return BONFIRE_MODEL
		"lanterna_cristal":
			return CRYSTAL_LANTERN_MODEL
		"mesa_craft":
			return CRAFTING_TABLE_MODEL
		"caixote":
			return CRATE_MODEL
		"porta":
			return DOOR_MODEL
	return TORCH_MODEL


func _place_world_prop(prop_id: String) -> void:
	if not _is_placeable_prop(prop_id):
		return
	if int(_inventory.get(prop_id, 0)) <= 0:
		_set_game_status("Sem %s no inventário." % _item_short_name(prop_id).to_lower())
		return
	var hit := _raycast_target()
	if hit.is_empty():
		return
	var coords := _hit_block_position(hit, true)
	if _world.get_block_at(coords) != 0 or _world_prop_occupies_cell(coords) or _placement_overlaps_player(coords):
		return
	var prop := _spawn_world_prop(prop_id, coords)
	if prop == null:
		return
	prop.rotation.y = _player.rotation.y
	AudioDirector.play_cue("world.place", 1.08)
	_inventory_remove(prop_id, 1, _selected_slot)
	_refresh_hud()
	_set_game_status("%s colocado." % _item_short_name(prop_id))


func _prop_scale(prop_id: String) -> float:
	match prop_id:
		"bau":
			return 0.82
		"tocha":
			return 0.72
		"fogueira":
			return 0.72
		"lanterna_cristal":
			return 0.48
		"mesa_craft":
			return 0.9
		"caixote":
			return 0.72
		"porta":
			return 0.9
	return 1.0


func _placement_overlaps_player(coords: Vector3i) -> bool:
	if _player == null or get_world_3d() == null:
		return false
	var query_shape := BoxShape3D.new()
	query_shape.size = Vector3.ONE * 0.98
	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = query_shape
	query.transform = Transform3D(Basis.IDENTITY, Vector3(coords) + Vector3.ONE * 0.5)
	query.collision_mask = 1
	query.collide_with_bodies = true
	for result: Dictionary in get_world_3d().direct_space_state.intersect_shape(query, 16):
		if result.get("collider") == _player:
			return true
	var player_collider := _player.get_node_or_null("PlayerCollider") as CollisionShape3D
	var capsule := player_collider.shape as CapsuleShape3D if player_collider != null else null
	if capsule == null:
		return false
	var capsule_center := _player.global_position + player_collider.position
	var capsule_min := capsule_center - Vector3(capsule.radius, capsule.height * 0.5, capsule.radius)
	var capsule_max := capsule_center + Vector3(capsule.radius, capsule.height * 0.5, capsule.radius)
	var block_min := Vector3(coords)
	var block_max := block_min + Vector3.ONE
	return capsule_min.x < block_max.x and capsule_max.x > block_min.x and capsule_min.y < block_max.y and capsule_max.y > block_min.y and capsule_min.z < block_max.z and capsule_max.z > block_min.z


func _select_slot(index: int) -> void:
	_selected_slot = posmod(index, _hotbar_ids.size())
	_refresh_hud()


func _toggle_crafting() -> void:
	if _craft_panel == null:
		return
	var will_close := _craft_panel.visible
	if will_close:
		_return_craft_grid_to_inventory()
		if not _return_cursor_stack_to_inventory():
			_set_game_status("Coloque ou descarte a pilha que está no cursor antes de fechar.")
			_refresh_crafting()
			return
	_craft_panel.visible = not _craft_panel.visible
	_mine_held = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if _craft_panel.visible else Input.MOUSE_MODE_CAPTURED
	_refresh_crafting()


func _return_craft_grid_to_inventory() -> void:
	for i in range(_craft_grid_items.size()):
		var item_id: Variant = _craft_grid_items[i]
		if item_id == null:
			continue
		_inventory_add(item_id, 1)
		_craft_grid_items[i] = null


func _craft(recipe: String) -> void:
	_reconcile_inventory_state()
	if recipe == "eat":
		_eat_available_food()
		return
	var crafted := false
	var failure_message := "Recursos insuficientes ou não é possível usar isso agora."
	var result_name := ""
	var recipe_data: Dictionary = RECIPE_BOOK.get_quick_recipe(recipe)
	if not recipe_data.is_empty():
		if str(recipe_data.get("station", "inventory")) == "crafting_table" and not _has_nearby_crafting_table():
			_set_game_status("Essa receita exige uma mesa de craft a até 3 m.")
			return
		var ingredients: Array = recipe_data.get("ingredients", [])
		var has_ingredients := true
		for ingredient_value: Variant in ingredients:
			if not ingredient_value is Dictionary:
				has_ingredients = false
				break
			var ingredient: Dictionary = ingredient_value
			var ingredient_id: Variant = ingredient.get("item", null)
			var ingredient_quantity := int(ingredient.get("quantity", 0))
			if ingredient_id == null or ingredient_quantity <= 0 or int(_inventory.get(ingredient_id, 0)) < ingredient_quantity:
				has_ingredients = false
				break
		var output_id: Variant = recipe_data.get("item", null)
		var output_quantity := int(recipe_data.get("quantity", 0))
		var output_limit := int(recipe_data.get("max_stack", 99999))
		var has_space := output_id != null and output_quantity > 0 and output_limit > 0 and _inventory_can_add(output_id, output_quantity)
		if not has_space:
			failure_message = "Não há espaço para o resultado."
		elif has_ingredients:
			for ingredient_value: Variant in ingredients:
				var ingredient: Dictionary = ingredient_value
				_inventory_remove(ingredient.get("item", null), int(ingredient.get("quantity", 0)))
			_inventory_add(output_id, output_quantity)
			crafted = true
			result_name = str(recipe_data.get("name", recipe))
	if crafted:
		_set_game_status("Receita concluída: %s." % result_name)
	else:
		_set_game_status(failure_message)
	_refresh_crafting()
	_refresh_hud()

func _refresh_crafting() -> void:
	if _craft_panel == null:
		return
	_ensure_item_slots()
	if _craft_info != null:
		var cursor_text := "vazio"
		if _inventory_state != null and _inventory_state.cursor != null:
			cursor_text = "%s × %d" % [_item_short_name(_inventory_state.cursor.get("item", null)), int(_inventory_state.cursor.get("count", 0))]
		var station_text := "Bancada 3×3 próxima" if _has_nearby_crafting_table() else "Sem bancada: receitas básicas disponíveis"
		_craft_info.text = "%s\nClique esquerdo pega/mescla · direito divide 1 unidade · Shift move\nDuplo clique coleta a mesma pilha · arraste para a grade de craft\nCursor: %s\nGravetos: %d · Picaretas: %d\nFrutas: %d · Gelatina: %d" % [
			station_text,
			cursor_text,
			int(_inventory.get("gravetos", 0)), int(_inventory.get("picareta", 0)),
			int(_inventory.get("frutas", 0)), int(_inventory.get("gelatina", 0))]
	if _inventory_grid != null:
		for index in range(_inventory_grid.get_child_count()):
			var slot := _inventory_grid.get_child(index) as PanelContainer
			var item_id: Variant = _backpack_slots[index] if index < _backpack_slots.size() else null
			slot.call("set_item", item_id, _slot_count_for_kind("backpack", index))
			_refresh_item_slot_visual(slot, item_id, "backpack")
	if _inventory_hotbar_slots.size() == ByteCrafterInventoryStack.HOTBAR_SIZE:
		for index in range(_inventory_hotbar_slots.size()):
			var slot := _inventory_hotbar_slots[index]
			var item_id: Variant = _hotbar_ids[index]
			slot.call("set_item", item_id, _slot_count_for_kind("hotbar", index))
			_refresh_item_slot_visual(slot, item_id, "hotbar")
	for i in range(_craft_table_slots.size()):
		var craft_slot := _craft_table_slots[i]
		var craft_icon := craft_slot.find_child("CraftIcon", true, false) as Label
		var craft_texture := craft_slot.find_child("CraftTexture", true, false) as TextureRect
		var craft_item: Variant = _craft_grid_items[i]
		craft_slot.call("set_item", craft_item, 1 if craft_item != null else 0)
		if craft_icon != null:
			craft_icon.text = "" if craft_item == null else _item_glyph(craft_item)
		if craft_texture != null:
			craft_texture.texture = null if craft_item == null else _item_texture(craft_item)
			craft_texture.visible = craft_texture.texture != null
		if craft_icon != null and craft_texture != null and craft_texture.visible and craft_item is int:
			craft_icon.text = ""
	var grid_recipe := _craft_recipe_for_grid()
	_craft_output_item = grid_recipe.get("item", null)
	_craft_output_quantity = int(grid_recipe.get("quantity", 0))
	if _craft_output_icon != null:
		var output_texture: TextureRect = null
		if _craft_output_slot != null:
			output_texture = _craft_output_slot.find_child("CraftTexture", true, false) as TextureRect
		if _craft_output_item == null:
			_craft_output_icon.text = "?"
			if output_texture != null:
				output_texture.texture = null
				output_texture.visible = false
		else:
			var output_item_texture := _item_texture(_craft_output_item)
			if output_texture != null:
				output_texture.texture = output_item_texture
				output_texture.visible = output_item_texture != null
			_craft_output_icon.text = "×%d" % _craft_output_quantity if output_item_texture != null else "%s\n×%d" % [_item_glyph(_craft_output_item), _craft_output_quantity]
	if _craft_planks != null:
		_craft_planks.disabled = int(_inventory.get(4, 0)) < 1
	if _craft_sticks != null:
		_craft_sticks.disabled = int(_inventory.get(7, 0)) < 2
	if _craft_pickaxe != null:
		_craft_pickaxe.disabled = int(_inventory.get(7, 0)) < 3 or int(_inventory.get("gravetos", 0)) < 2
	if _eat_food != null:
		_eat_food.disabled = not _has_available_food()


func _refresh_hud() -> void:
	_ensure_item_slots()
	if _player != null:
		var equipped := ""
		var selected_item: Variant = _hotbar_ids[_selected_slot] if _selected_slot < _hotbar_ids.size() else null
		if selected_item is String and selected_item in ["espada", "espada_pedra", "espada_ferro", "picareta", "picareta_pedra", "picareta_ferro", "machado_ferro", "pa", "pa_pedra", "pa_ferro", "tocha", "balde", "shuriken"]:
			equipped = selected_item
		_player.set_equipped_tool(equipped)
	if _game_hud == null:
		return
	if _health_bar != null:
		_health_bar.value = _health
	if _food_bar != null:
		_food_bar.value = _food
	if _level_label != null:
		_level_label.text = "NÍVEL %d" % _level
	if _xp_bar != null:
		_xp_bar.max_value = _xp_for_next_level(_level)
		_xp_bar.value = _xp_into_current_level()
	for index: int in _hotbar_slots.size():
		var slot := _hotbar_slots[index]
		var item_id: Variant = _hotbar_ids[index] if index < _hotbar_ids.size() else null
		slot.call("set_item", item_id, _slot_count_for_kind("hotbar", index))
		_refresh_item_slot_visual(slot, item_id, "hotbar")
		var accent := Color("c0d899") if index == _selected_slot else Color(0.75, 0.83, 0.69, 0.2)
		var background := Color(0.13, 0.16, 0.12, 0.94) if index == _selected_slot else Color(0.035, 0.045, 0.052, 0.9)
		slot.add_theme_stylebox_override("panel", UI.style_box(background, accent, 6, 2 if index == _selected_slot else 1))
	if _selected_item_label != null:
		var selected_item: Variant = _hotbar_ids[_selected_slot]
		_selected_item_label.text = "%d · %s  (%d)" % [_selected_slot + 1, "Vazio" if selected_item == null else _item_short_name(selected_item), _slot_count_for_kind("hotbar", _selected_slot)]
	if _position_label != null and _player != null and _world != null:
		_position_label.text = "SEMENTE %d\nX %d · Y %d · Z %d\nNÍVEL %d · XP %d/%d" % [_world.world_seed, floori(_player.global_position.x), floori(_player.global_position.y), floori(_player.global_position.z), _level, _xp_into_current_level(), _xp_for_next_level(_level)]
	_refresh_crafting()


func _refresh_position_label() -> void:
	if _position_label == null or _player == null or _world == null:
		return
	_position_label.text = "SEMENTE %d\nX %d · Y %d · Z %d\nNÍVEL %d · XP %d/%d" % [_world.world_seed, floori(_player.global_position.x), floori(_player.global_position.y), floori(_player.global_position.z), _level, _xp_into_current_level(), _xp_for_next_level(_level)]


func _make_block_icon(block_id: int) -> AtlasTexture:
	var tiles: Array = WORLD_SCRIPT.BLOCK_ATLAS_TILES.get(block_id, [0])
	var tile_index := int(tiles[0]) if not tiles.is_empty() else 0
	var atlas_size := VOXEL_ATLAS_TEXTURE.get_size()
	var atlas_columns: float = float(WORLD_SCRIPT.ATLAS_COLUMNS)
	var atlas_rows: float = float(WORLD_SCRIPT.ATLAS_ROWS)
	var tile_width: float = atlas_size.x / atlas_columns
	var tile_height: float = atlas_size.y / atlas_rows
	var tile_size: Vector2 = Vector2(tile_width, tile_height)
	var tile_column: int = posmod(tile_index, int(WORLD_SCRIPT.ATLAS_COLUMNS))
	var tile_row: int = floori(float(tile_index) / atlas_columns)
	var icon := AtlasTexture.new()
	icon.atlas = VOXEL_ATLAS_TEXTURE
	icon.region = Rect2(Vector2(float(tile_column), float(tile_row)) * tile_size, tile_size)
	icon.filter_clip = true
	return icon


func _set_title_status(message: String) -> void:
	if _title_status != null:
		_title_status.text = message


func _set_game_status(message: String) -> void:
	if _game_status != null:
		_game_status.text = message
		var status_panel := _game_status.get_parent() as Control
		if status_panel != null:
			status_panel.visible = not message.is_empty()


func _toggle_pause() -> void:
	if _screen != "game":
		return
	if _paused:
		_resume_game()
	else:
		_paused = true
		_mine_held = false
		_craft_panel.visible = false
		_pause_screen.visible = true
		get_tree().paused = true
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		_save_game()


func _resume_game() -> void:
	get_tree().paused = false
	_paused = false
	_pause_screen.visible = false
	_player.can_control = true
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _return_to_title() -> void:
	_save_game()
	get_tree().paused = false
	_paused = false
	if multiplayer.multiplayer_peer != null and not multiplayer.multiplayer_peer is OfflineMultiplayerPeer:
		multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
	_network_active = false
	_is_host = false
	_join_pending = false
	_screen = "title"
	_apply_visual_settings()
	_player.can_control = false
	_player.process_mode = Node.PROCESS_MODE_DISABLED
	_title_screen.visible = true
	_game_hud.visible = false
	_pause_screen.visible = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _save_game() -> void:
	if _world == null or (_network_active and not _is_host):
		return
	_save_timer = AUTOSAVE_INTERVAL_SECONDS
	_ensure_item_slots()
	var world_snapshot: Dictionary = _world.create_save_snapshot()
	if _player == null:
		if _async_saver != null:
			_async_saver.request_save(world_snapshot, {})
		return
	var player_position := _player.position
	if _player.is_inside_tree():
		player_position = _player.global_position
	var inventory_data: Dictionary = {}
	for block_id: int in range(1, 8):
		inventory_data[str(block_id)] = int(_inventory.get(block_id, 0))
	inventory_data["gravetos"] = int(_inventory.get("gravetos", 0))
	inventory_data["picareta"] = int(_inventory.get("picareta", 0))
	inventory_data["frutas"] = int(_inventory.get("frutas", 0))
	inventory_data["gelatina"] = int(_inventory.get("gelatina", 0))
	inventory_data["fragmento_lunar"] = int(_inventory.get("fragmento_lunar", 0))
	inventory_data["nucleo_lunar"] = int(_inventory.get("nucleo_lunar", 0))
	for item_id: Variant in [12, 13, 14, 15, 16, 17, 18, 21, 22, 23, 24, 25, 26, 27, 28, 29, 33, "sementes_trigo", "trigo", "mesa_craft", "bau", "tocha", "fogueira", "lanterna_cristal", "caixote", "porta", "balde", "carne_cozida", "carvao", "picareta_pedra", "picareta_ferro", "machado_ferro", "espada", "espada_pedra", "espada_ferro", "armadura_couro_cabeca", "armadura_couro_peito", "armadura_couro_pernas", "armadura_couro_botas"]:
		inventory_data[str(item_id)] = int(_inventory.get(item_id, 0))
	for item_id: String in EXTRA_ITEM_IDS:
		inventory_data[item_id] = int(_inventory.get(item_id, 0))
	var save_data := {
		"version": PROFILE_VERSION,
		"avatar_id": _selected_avatar_id,
		"difficulty": _difficulty,
		"seed": _world.world_seed,
		"inventory": inventory_data,
		"backpack": _backpack_slots.duplicate(true),
		"hotbar": _hotbar_ids.duplicate(true),
		"slot_stacks": _inventory_state.serialize_slots(),
		"craft_grid": _craft_grid_items.duplicate(true),
		"health": _health,
		"food": _food,
		"xp": _xp,
		"level": _level,
		"day_phase": _day_phase,
		"bed_spawn": [_bed_respawn_position.x, _bed_respawn_position.y, _bed_respawn_position.z],
		"world_props": _serialize_world_props(),
		"villages": _village_system.serialize_state() if _village_system != null and is_instance_valid(_village_system) else [],
		"drops": _serialize_drops(),
		"crops": _serialize_crops(),
		"harvested_plants": _serialize_harvested_plants(),
		"position": [player_position.x, player_position.y, player_position.z],
	}
	if _async_saver != null:
		_async_saver.request_save(world_snapshot, save_data)


func _serialize_crops() -> Array:
	var result: Array = []
	for cell_value: Variant in _crops.keys():
		var cell := cell_value as Vector3i
		var crop_data: Dictionary = _crops[cell]
		result.append({"position": [cell.x, cell.y, cell.z], "stage": int(crop_data.get("stage", 0)), "age": float(crop_data.get("age", 0.0)), "kind": str(crop_data.get("kind", "wheat")), "wild": bool(crop_data.get("wild", false))})
	return result


func _serialize_harvested_plants() -> Array:
	var result: Array = []
	for cell: Vector3i in _harvested_plant_cells:
		result.append([cell.x, cell.y, cell.z])
	return result


func _start_survival_tick(delta: float) -> void:
	var previous_health := _health
	var previous_food := _food
	_survival_timer += delta
	var food_interval := 70.0 if _difficulty == "easy" else (36.0 if _difficulty == "hard" else 50.0)
	if _survival_timer >= food_interval:
		_survival_timer = 0.0
		_food = maxf(0.0, _food - 1.0)
	if _food <= 0.0:
		_hunger_tick += delta
		var starvation_interval := 13.0 if _difficulty == "easy" else (6.0 if _difficulty == "hard" else 9.0)
		if _hunger_tick >= starvation_interval:
			_hunger_tick = 0.0
			_health = maxf(0.0, _health - 1.0)
	elif _food >= 18.0 and _health < 20.0:
		_hunger_tick += delta
		if _hunger_tick >= 25.0:
			_hunger_tick = 0.0
			_health = minf(20.0, _health + 1.0)
	if _health != previous_health or _food != previous_food:
		_refresh_hud()
	if _health <= 0.0:
		_begin_player_respawn()


func _refresh_survival(delta: float) -> void:
	if _screen != "game" or _paused:
		return
	_start_survival_tick(delta)
	if _player != null and _player.global_position.y < -12.0:
		_health = maxf(1.0, _health - 3.0)
		_player.global_position = _world.get_spawn_position()
		_player.velocity = Vector3.ZERO
		_refresh_hud()


func _damage_player(amount: float, attacker_name := "Slime") -> void:
	if _screen != "game" or _paused or _player == null or amount <= 0.0:
		return
	if _damage_invulnerability > 0.0 or _death_in_progress:
		return
	_damage_invulnerability = 0.7
	var difficulty_multiplier := 0.70 if _difficulty == "easy" else (1.40 if _difficulty == "hard" else 1.0)
	var protected_amount := amount * difficulty_multiplier * (1.0 - _armor_damage_reduction())
	_health = maxf(0.0, _health - protected_amount)
	_set_game_status("%s atacou você · -%.1f de vida" % [attacker_name, protected_amount])
	if _health <= 0.0:
		_begin_player_respawn()
	_refresh_hud()


func _begin_player_respawn() -> void:
	if _death_in_progress or _player == null or _world == null:
		return
	_death_in_progress = true
	_mine_held = false
	_attack_cooldown = 0.0
	_player.can_control = false
	_player.velocity = Vector3.ZERO
	_player.play_action("death")
	_set_game_status("Você foi derrotado...")
	_refresh_hud()
	await get_tree().create_timer(PLAYER_DEATH_DURATION).timeout
	if not is_inside_tree() or _player == null or not is_instance_valid(_player):
		_death_in_progress = false
		return
	_health = 12.0
	_food = maxf(8.0, _food)
	var respawn_position := _bed_respawn_position if _bed_respawn_position != Vector3.ZERO else _world.get_spawn_position()
	var respawn_cell := Vector3i(floori(respawn_position.x), floori(respawn_position.y), floori(respawn_position.z))
	if _world.get_block_at(respawn_cell) != 0 or _world.get_block_at(respawn_cell + Vector3i.UP) != 0:
		respawn_position = _world.get_spawn_position()
	_player.global_position = respawn_position
	_player.velocity = Vector3.ZERO
	_player.can_control = true
	_player.set_animation_state("idle")
	_death_in_progress = false
	_set_game_status("Você renasceu no ponto inicial.")
	_refresh_hud()


func _on_window_focus_out() -> void:
	if _screen == "game" and not _paused:
		_toggle_pause()


func _on_ui_button_focus() -> void:
	pass


func _notification_unused() -> void:
	pass


func _save_profile_only() -> void:
	_save_game()


func _build_interaction_helpers() -> void:
	var outline_material := StandardMaterial3D.new()
	outline_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	outline_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	outline_material.albedo_color = Color(0.97, 0.92, 0.63, 0.94)
	outline_material.no_depth_test = true
	outline_material.render_priority = 3
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_LINES)
	surface.set_material(outline_material)
	var corners: Array[Vector3] = [
		Vector3(-0.505, -0.505, -0.505), Vector3(0.505, -0.505, -0.505),
		Vector3(0.505, 0.505, -0.505), Vector3(-0.505, 0.505, -0.505),
		Vector3(-0.505, -0.505, 0.505), Vector3(0.505, -0.505, 0.505),
		Vector3(0.505, 0.505, 0.505), Vector3(-0.505, 0.505, 0.505),
	]
	var edges: Array[Vector2i] = [
		Vector2i(0, 1), Vector2i(1, 2), Vector2i(2, 3), Vector2i(3, 0),
		Vector2i(4, 5), Vector2i(5, 6), Vector2i(6, 7), Vector2i(7, 4),
		Vector2i(0, 4), Vector2i(1, 5), Vector2i(2, 6), Vector2i(3, 7),
	]
	for edge: Vector2i in edges:
		surface.add_vertex(corners[edge.x])
		surface.add_vertex(corners[edge.y])
	_target_outline = MeshInstance3D.new()
	_target_outline.name = "TargetBlockOutline"
	_target_outline.mesh = surface.commit()
	_target_outline.material_override = outline_material
	_target_outline.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_target_outline.visible = false
	add_child(_target_outline)
	var preview_box := BoxMesh.new()
	preview_box.size = Vector3.ONE * 1.003
	_placement_material = StandardMaterial3D.new()
	_placement_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_placement_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_placement_material.albedo_color = Color(0.56, 0.88, 0.43, 0.34)
	_placement_material.render_priority = 1
	_placement_preview = MeshInstance3D.new()
	_placement_preview.name = "PlacementPreview"
	_placement_preview.mesh = preview_box
	_placement_preview.material_override = _placement_material
	_placement_preview.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_placement_preview.visible = false
	add_child(_placement_preview)


func _update_interaction_helpers() -> void:
	if _target_outline == null or _placement_preview == null:
		return
	if _screen != "game" or _paused or _world == null or _player == null or (_craft_panel != null and _craft_panel.visible):
		_target_outline.visible = false
		_placement_preview.visible = false
		return
	var hit := _raycast_target()
	if hit.is_empty():
		_target_outline.visible = false
		_placement_preview.visible = false
		return
	var target_coords := _hit_block_position(hit, false)
	if _world.get_block_at(target_coords) == 0:
		_target_outline.visible = false
		_placement_preview.visible = false
		return
	_target_outline.position = Vector3(target_coords) + Vector3.ONE * 0.5
	_target_outline.visible = true
	var placement_coords := _hit_block_position(hit, true)
	var placement_center := Vector3(placement_coords) + Vector3.ONE * 0.5
	var selected_item: Variant = _hotbar_ids[_selected_slot]
	var selected_block := int(selected_item) if selected_item is int else 0
	var has_item := selected_item is int and int(_inventory.get(selected_item, 0)) > 0
	var overlaps_player := _placement_overlaps_player(placement_coords)
	var can_place := _world.get_block_at(placement_coords) == 0 and has_item and _is_placeable_voxel_item(selected_item) and not overlaps_player
	_placement_preview.visible = can_place
	if can_place:
		_placement_preview.position = placement_center
		var color: Color = WORLD_SCRIPT.BLOCK_COLORS.get(selected_block, Color.WHITE)
		_placement_material.albedo_color = Color(color.r, color.g, color.b, 0.34)


## -----------------------------------------------------------------------------
## Inventário por ItemStack — adaptação Godot do comportamento de Container.
## -----------------------------------------------------------------------------

func _slot_index_for_kind(kind: String, index: int) -> int:
	if kind == "hotbar" and index >= 0 and index < ByteCrafterInventoryStack.HOTBAR_SIZE:
		return index
	if kind == "backpack" and index >= 0 and index < BACKPACK_SIZE:
		return ByteCrafterInventoryStack.HOTBAR_SIZE + index
	return -1


func _slot_count_for_kind(kind: String, index: int) -> int:
	if _inventory_state == null:
		return 0
	var absolute_index := _slot_index_for_kind(kind, index)
	return _inventory_state.get_count(absolute_index)


func _inventory_signature() -> String:
	var entries: Array[String] = []
	for key: Variant in _inventory.keys():
		entries.append("%s:%s=%d" % [str(typeof(key)), str(key), int(_inventory.get(key, 0))])
	entries.sort()
	return "|".join(entries)


func _inventory_layout_signature() -> String:
	var layout: Array = _hotbar_ids.duplicate(true)
	layout.append_array(_backpack_slots)
	return JSON.stringify(layout)


func _canonical_item_id(item_id: Variant) -> Variant:
	if item_id is int:
		match int(item_id):
			8:
				return "frutas"
			9:
				return "gelatina"
			10:
				return "fragmento_lunar"
			11:
				return "nucleo_lunar"
		return item_id
	var text := str(item_id)
	return {
		"8": "frutas",
		"9": "gelatina",
		"10": "fragmento_lunar",
		"11": "nucleo_lunar",
	}.get(text, item_id)


func _sync_legacy_slot_arrays_from_state() -> void:
	if _inventory_state == null:
		return
	_hotbar_ids.resize(ByteCrafterInventoryStack.HOTBAR_SIZE)
	_backpack_slots.resize(BACKPACK_SIZE)
	var aggregate := _inventory_state.aggregate_counts()
	for key: Variant in _inventory.keys():
		_inventory[key] = int(aggregate.get(key, 0))
	for key: Variant in aggregate.keys():
		_inventory[key] = int(aggregate[key])
	for index in range(ByteCrafterInventoryStack.HOTBAR_SIZE):
		_hotbar_ids[index] = _inventory_state.get_item(index)
	for index in range(BACKPACK_SIZE):
		_backpack_slots[index] = _inventory_state.get_item(ByteCrafterInventoryStack.HOTBAR_SIZE + index)
	_inventory_signature_cache = _inventory_signature()
	_inventory_layout_signature_cache = _inventory_layout_signature()


func _rebuild_inventory_state_from_aggregate() -> void:
	if _inventory_state == null:
		_inventory_state = INVENTORY_STACK_SCRIPT.new() as ByteCrafterInventoryStack
	_inventory_state.reset()
	if _hotbar_ids.size() != ByteCrafterInventoryStack.HOTBAR_SIZE:
		_hotbar_ids = DEFAULT_HOTBAR_IDS.duplicate(true)
	if _backpack_slots.size() != BACKPACK_SIZE:
		_backpack_slots = _default_backpack_slots()
	var remaining: Dictionary = {}
	for key: Variant in _inventory.keys():
		remaining[key] = maxi(0, int(_inventory.get(key, 0)))
	var layout: Array = _hotbar_ids.duplicate(true)
	layout.append_array(_backpack_slots)
	for index in range(mini(layout.size(), ByteCrafterInventoryStack.TOTAL_SIZE)):
		var item_id: Variant = layout[index]
		if item_id == null or not _is_valid_item_id(item_id):
			continue
		var amount := int(remaining.get(item_id, 0))
		if amount <= 0:
			continue
		var moved := mini(amount, _inventory_state.max_stack_size(item_id))
		_inventory_state.set_stack(index, item_id, moved)
		remaining[item_id] = amount - moved
	for item_id: Variant in _inventory_item_ids:
		var amount := int(remaining.get(item_id, 0))
		while amount > 0:
			var empty_index := -1
			for candidate in range(ByteCrafterInventoryStack.TOTAL_SIZE):
				if _inventory_state.stack_at(candidate) == null:
					empty_index = candidate
					break
			if empty_index < 0:
				break
			var moved := mini(amount, _inventory_state.max_stack_size(item_id))
			_inventory_state.set_stack(empty_index, item_id, moved)
			amount -= moved
		remaining[item_id] = amount
	_sync_legacy_slot_arrays_from_state()


func _reconcile_inventory_state() -> void:
	if _inventory_state == null:
		_inventory_state = INVENTORY_STACK_SCRIPT.new() as ByteCrafterInventoryStack
	if _inventory_signature_cache.is_empty() or _inventory_signature() != _inventory_signature_cache or _inventory_layout_signature() != _inventory_layout_signature_cache:
		_rebuild_inventory_state_from_aggregate()


func _inventory_add(item_id: Variant, amount: int, preferred_slot: int = -1) -> int:
	_reconcile_inventory_state()
	var canonical: Variant = _canonical_item_id(item_id)
	var leftover: int = _inventory_state.add_item(canonical, amount, preferred_slot)
	_sync_legacy_slot_arrays_from_state()
	return leftover


func _inventory_remove(item_id: Variant, amount: int, preferred_slot: int = -1) -> int:
	_reconcile_inventory_state()
	var canonical: Variant = _canonical_item_id(item_id)
	var removed: int = _inventory_state.remove_item(canonical, amount, preferred_slot)
	_sync_legacy_slot_arrays_from_state()
	return removed


func _selected_hotbar_item() -> Variant:
	_reconcile_inventory_state()
	return _inventory_state.get_item(_selected_slot)


func _selected_hotbar_count() -> int:
	_reconcile_inventory_state()
	return _inventory_state.get_count(_selected_slot)


func _handle_inventory_click(slot: PanelContainer, mouse_event: InputEventMouseButton) -> void:
	_reconcile_inventory_state()
	var kind := str(slot.get("slot_kind"))
	var relative_index := int(slot.get("slot_index"))
	var absolute_index := _slot_index_for_kind(kind, relative_index)
	if absolute_index < 0 or mouse_event.button_index not in [MOUSE_BUTTON_LEFT, MOUSE_BUTTON_RIGHT]:
		return
	var clicked_item: Variant = _inventory_state.get_item(absolute_index)
	if mouse_event.double_click and mouse_event.button_index == MOUSE_BUTTON_LEFT and clicked_item != null:
		if _inventory_state.cursor == null:
			_inventory_state.cursor = _inventory_state.remove_from_slot(absolute_index, _inventory_state.get_count(absolute_index))
		_inventory_state.collect_matching(clicked_item)
	else:
		_inventory_state.click_slot(absolute_index, mouse_event.button_index, mouse_event.shift_pressed)
	_sync_legacy_slot_arrays_from_state()
	if mouse_event.shift_pressed:
		_set_game_status("Pilha movida para a outra seção do inventário.")
	elif _inventory_state.cursor != null:
		_set_game_status("Cursor: %s × %d" % [_item_short_name(_inventory_state.cursor.get("item", null)), int(_inventory_state.cursor.get("count", 0))])
	else:
		_set_game_status("Pilha guardada no slot.")
	_refresh_crafting()
	_refresh_hud()


func _drop_cursor_stack(drop_one: bool) -> void:
	_reconcile_inventory_state()
	if _inventory_state.cursor == null:
		return
	var item_id: Variant = _inventory_state.cursor.get("item", null)
	var count := int(_inventory_state.cursor.get("count", 0))
	var dropped := 1 if drop_one else count
	_inventory_state.cursor["count"] = count - dropped
	if int(_inventory_state.cursor.get("count", 0)) <= 0:
		_inventory_state.cursor = null
	_set_game_status("%s descartado × %d." % [_item_short_name(item_id), dropped])
	_sync_legacy_slot_arrays_from_state()
	_refresh_crafting()


func _return_cursor_stack_to_inventory() -> bool:
	_reconcile_inventory_state()
	if _inventory_state.cursor == null:
		return true
	var cursor_item: Variant = _inventory_state.cursor.get("item", null)
	var cursor_count := int(_inventory_state.cursor.get("count", 0))
	var leftover := _inventory_state.add_item(cursor_item, cursor_count)
	if leftover <= 0:
		_inventory_state.cursor = null
	else:
		_inventory_state.cursor["count"] = leftover
	_sync_legacy_slot_arrays_from_state()
	return leftover <= 0


func _use_selected_item() -> void:
	if _screen != "game" or _paused:
		return
	_reconcile_inventory_state()
	var item_id: Variant = _selected_hotbar_item()
	if item_id == null or _selected_hotbar_count() <= 0:
		_set_game_status("Selecione um item com quantidade disponível.")
		return
	if _try_consume_selected_food():
		return
	if item_id is String and _is_placeable_prop(item_id):
		_place_world_prop(item_id)
		return
	if _is_placeable_voxel_item(item_id):
		_place_selected_block()
		return
	_set_game_status("%s não tem uso contextual agora." % _item_short_name(item_id))


func _inventory_can_add(item_id: Variant, amount: int) -> bool:
	_reconcile_inventory_state()
	var probe := INVENTORY_STACK_SCRIPT.new() as ByteCrafterInventoryStack
	probe.slots = _inventory_state.slots.duplicate(true)
	return probe.add_item(_canonical_item_id(item_id), amount) == 0
