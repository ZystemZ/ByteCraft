extends CharacterBody3D
class_name ByteCrafterVillager

const MOVEMENT := preload("res://scripts/game/bytecrafter_movement.gd")
const ANIMATION_CONTROLLER := preload("res://scripts/game/rig_animation_controller.gd")
const MALE_MODEL := "res://assets/userpack/characters/ALDEAO_RIGGED.fbx"
const FEMALE_MODEL := "res://assets/userpack/characters/ALDEABIKINIRIGGED.fbx"
const MALE_TEXTURE := "res://assets/userpack/characters/ALDEAO_RIGGED_0.png"
const FEMALE_TEXTURE := "res://assets/userpack/characters/ALDEABIKINIRIGGED_0.png"
const WALK_SPEED := 1.35
const GRAVITY := 22.0
const MODEL_VISUAL_SCALE := 0.86
const SLEEP_CLIPS := ["sleep1", "sleep2", "sleep3"]
const DANCE_CLIPS := ["dance1", "dance2"]

var display_name := "Morador"
var role := "resident"
var is_female := false
var _world: ByteCrafterWorld
var _model_root: Node3D
var _animation_controller: RigAnimationController
var _name_tag: Label3D
var _bed_position := Vector3.ZERO
var _day_position := Vector3.ZERO
var _day_position_alt := Vector3.ZERO
var _market_position := Vector3.ZERO
var _target_position := Vector3.ZERO
var _is_daytime := true
var _is_sleeping := false
var _bed_available := true
var _use_alt_day_position := false
var _wander_timer := 0.0
var _bob_time := 0.0
var _work_action_timer := 2.0
var _sleep_animation := "sleep1"
var _dance_check_timer := 20.0
var _comic_dance_active := false
var _comic_dance_playing := false
var _comic_dance_elapsed := 0.0
var _comic_dance_clip := ""
var _comic_dance_target := Vector3.ZERO
var _comic_dance_fire_position := Vector3.ZERO


func configure(world: ByteCrafterWorld, name_text: String, female: bool, villager_role: String, bed_position: Vector3, day_position: Vector3, alternate_day_position: Vector3, market_position: Vector3, bed_available := true) -> void:
	_world = world
	display_name = name_text
	is_female = female
	role = villager_role
	_bed_position = bed_position
	_bed_available = bed_available
	_day_position = day_position
	_day_position_alt = alternate_day_position
	_market_position = market_position
	_target_position = _market_position if role == "merchant" else _day_position


func _ready() -> void:
	name = "Villager_%s" % display_name.replace(" ", "_")
	add_to_group("bytecrafter_villagers")
	_dance_check_timer = randf_range(18.0, 36.0)
	collision_layer = 4
	collision_mask = 1
	floor_snap_length = 0.28
	floor_max_angle = deg_to_rad(50.0)
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.29
	capsule.height = 1.62
	var collider := CollisionShape3D.new()
	collider.name = "VillagerCollider"
	collider.shape = capsule
	collider.position = Vector3(0.0, 0.81, 0.0)
	add_child(collider)
	_build_model()
	_build_name_tag()


func _build_model() -> void:
	var model_path: String = FEMALE_MODEL if is_female else MALE_MODEL
	var scene := load(model_path) as PackedScene
	if scene == null:
		push_warning("Não foi possível carregar o modelo do aldeão: " + model_path)
		return
	_model_root = scene.instantiate() as Node3D
	_model_root.name = "VillagerModel"
	_model_root.scale = Vector3.ONE * MODEL_VISUAL_SCALE
	_model_root.rotation.y = PI
	add_child(_model_root)
	var mesh := _find_first_mesh(_model_root)
	if mesh != null:
		var source_material := mesh.get_active_material(0) as StandardMaterial3D
		var material := source_material.duplicate(true) as StandardMaterial3D if source_material != null else StandardMaterial3D.new()
		var texture_path: String = FEMALE_TEXTURE if is_female else MALE_TEXTURE
		material.albedo_texture = load(texture_path) as Texture2D
		material.albedo_color = Color.WHITE
		material.roughness = 0.86
		mesh.material_override = material
		mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	_animation_controller = ANIMATION_CONTROLLER.new() as RigAnimationController
	_animation_controller.name = "VillagerAnimationController"
	add_child(_animation_controller)
	var npc_clips: Array[String] = ["work", "pickup", "sleep1", "sleep2", "sleep3", "dance1", "dance2"]
	_animation_controller.setup(_model_root, npc_clips)


func _find_first_mesh(parent: Node) -> MeshInstance3D:
	for child: Node in parent.get_children():
		if child is MeshInstance3D:
			return child as MeshInstance3D
		var nested := _find_first_mesh(child)
		if nested != null:
			return nested
	return null


func _build_name_tag() -> void:
	_name_tag = Label3D.new()
	_name_tag.name = "VillagerName"
	_name_tag.text = "%s\n%s" % [display_name, "COMERCIANTE" if role == "merchant" else "ALDEÃO"]
	_name_tag.position = Vector3(0.0, 2.12, 0.0)
	_name_tag.font_size = 28
	_name_tag.outline_size = 5
	_name_tag.modulate = Color("fff1c6")
	_name_tag.outline_modulate = Color("30312a")
	_name_tag.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_name_tag.no_depth_test = false
	_name_tag.pixel_size = 0.0045
	add_child(_name_tag)


func is_merchant() -> bool:
	return role == "merchant"


func play_interaction_action() -> void:
	if _animation_controller != null:
		_animation_controller.play_action("reaction")


func set_day_state(daytime: bool) -> void:
	if _is_daytime == daytime:
		return
	_is_daytime = daytime
	_wander_timer = 0.0
	if daytime:
		if _comic_dance_active:
			_finish_campfire_dance()
		_is_sleeping = false
		_target_position = _market_position if role == "merchant" else _day_position
		if _model_root != null:
			_model_root.rotation.x = 0.0
			_model_root.position.y = 0.0
	else:
		_target_position = _bed_position if _bed_available else _day_position
		_sleep_animation = SLEEP_CLIPS.pick_random()


func set_bed_available(value: bool) -> void:
	if _bed_available == value:
		return
	_bed_available = value
	if _is_daytime:
		return
	_wander_timer = 0.0
	if _bed_available:
		_target_position = _bed_position
	else:
		_is_sleeping = false
		_target_position = _day_position_alt if _use_alt_day_position else _day_position
		if _model_root != null:
			_model_root.rotation.x = 0.0


func _physics_process(delta: float) -> void:
	if not is_instance_valid(_world) or not is_inside_tree():
		return
	var in_water := MOVEMENT.is_in_water(_world, self, 1.8)
	if _is_daytime and role != "merchant" and not _comic_dance_active:
		_wander_timer -= delta
		if _wander_timer <= 0.0 and global_position.distance_to(_target_position) < 0.8:
			_use_alt_day_position = not _use_alt_day_position
			_target_position = _day_position_alt if _use_alt_day_position else _day_position
			_wander_timer = 4.0 + float(posmod(get_instance_id(), 31)) * 0.11
	_process_campfire_dance(delta)
	var direction_vector := _target_position - global_position
	direction_vector.y = 0.0
	var distance := direction_vector.length()
	if distance > 0.42:
		_is_sleeping = false
		var direction := direction_vector / distance
		var movement_scale := 0.72 if in_water else 1.0
		velocity.x = direction.x * WALK_SPEED * movement_scale
		velocity.z = direction.z * WALK_SPEED * movement_scale
		if in_water:
			MOVEMENT.apply_buoyancy(self, _world, delta, 1.8)
		elif is_on_floor():
			velocity.y = 0.0
		else:
			velocity.y -= GRAVITY * delta
		rotation.y = atan2(-direction.x, -direction.z)
		var stepped_up := MOVEMENT.move_with_step(self, delta, true, in_water)
		if _animation_controller != null:
			_animation_controller.set_locomotion_state("jump" if stepped_up or not is_on_floor() else "walk")
		_bob_time += delta * 8.0
		if _model_root != null:
			_model_root.rotation.x = 0.0
			_model_root.position.y = 0.025 + sin(_bob_time) * 0.035
	else:
		velocity.x = move_toward(velocity.x, 0.0, WALK_SPEED * 4.0 * delta)
		velocity.z = move_toward(velocity.z, 0.0, WALK_SPEED * 4.0 * delta)
		if in_water:
			MOVEMENT.apply_buoyancy(self, _world, delta, 1.8)
		elif not is_on_floor():
			velocity.y -= GRAVITY * delta
		else:
			velocity.y = 0.0
		MOVEMENT.move_with_step(self, delta, true, in_water)
		if not _is_daytime and _bed_available:
			_is_sleeping = true
		if _animation_controller != null:
			if _is_sleeping:
				_animation_controller.set_locomotion_state(_sleep_animation)
			elif _comic_dance_active:
				if not _comic_dance_playing:
					_animation_controller.play_action(_comic_dance_clip)
					_comic_dance_playing = true
				_comic_dance_elapsed += delta
				if _comic_dance_elapsed >= 6.0:
					_finish_campfire_dance()
			elif role == "merchant" and _is_daytime:
				_work_action_timer -= delta
				if _work_action_timer <= 0.0:
					_animation_controller.play_action("pickup")
					_work_action_timer = 5.0 + float(posmod(get_instance_id(), 19)) * 0.2
			else:
				_animation_controller.set_locomotion_state("idle")
		if _model_root != null:
			_model_root.position.y = 0.0
			_model_root.rotation.x = 0.0
			if _comic_dance_active:
				var fire_direction := _comic_dance_fire_position - global_position
				rotation.y = atan2(-fire_direction.x, -fire_direction.z)


func _process_campfire_dance(delta: float) -> void:
	if _comic_dance_active:
		_target_position = _comic_dance_target
		return
	_dance_check_timer -= delta
	if _dance_check_timer > 0.0:
		return
	_dance_check_timer = randf_range(18.0, 36.0)
	if not _is_daytime or role != "resident":
		return
	for dancer: Node in get_tree().get_nodes_in_group("bytecrafter_comic_dancer"):
		if dancer != self and is_instance_valid(dancer):
			return
	if randf() > 0.24:
		return
	var nearest_fire: ByteCrafterProp = null
	var nearest_distance := 18.0
	for prop_value: Node in get_tree().get_nodes_in_group("bytecrafter_props"):
		var prop := prop_value as ByteCrafterProp
		if prop == null or prop.prop_id != "fogueira":
			continue
		var distance := global_position.distance_to(prop.global_position)
		if distance < nearest_distance:
			nearest_fire = prop
			nearest_distance = distance
	if nearest_fire == null:
		return
	var angle := randf_range(-PI, PI)
	var offset := Vector3(cos(angle), 0.0, sin(angle)) * 1.45
	_comic_dance_fire_position = nearest_fire.global_position
	_comic_dance_target = Vector3(_comic_dance_fire_position.x + offset.x, global_position.y, _comic_dance_fire_position.z + offset.z)
	_comic_dance_clip = DANCE_CLIPS.pick_random()
	_comic_dance_elapsed = 0.0
	_comic_dance_playing = false
	_comic_dance_active = true
	add_to_group("bytecrafter_comic_dancer")
	_target_position = _comic_dance_target


func _finish_campfire_dance() -> void:
	if _animation_controller != null:
		_animation_controller.stop_action()
	if is_in_group("bytecrafter_comic_dancer"):
		remove_from_group("bytecrafter_comic_dancer")
	_comic_dance_active = false
	_comic_dance_playing = false
	_comic_dance_elapsed = 0.0
	_target_position = _market_position if role == "merchant" else (_day_position_alt if _use_alt_day_position else _day_position)


func serialize_state() -> Dictionary:
	return {
		"name": display_name,
		"position": [position.x, position.y, position.z],
		"position_space": "village_local",
		"use_alt_day_position": _use_alt_day_position,
		"sleeping": _is_sleeping,
	}


func restore_state(snapshot: Dictionary, daytime: bool) -> void:
	if str(snapshot.get("name", display_name)) != display_name:
		return
	var position_value: Variant = snapshot.get("position", [])
	if not position_value is Array or position_value.size() < 3:
		return
	var saved_position := Vector3(float(position_value[0]), float(position_value[1]), float(position_value[2]))
	if str(snapshot.get("position_space", "global")) == "village_local":
		var village_root := get_parent() as Node3D
		if village_root == null or not village_root.is_inside_tree():
			return
		saved_position = village_root.to_global(saved_position)
	if absf(saved_position.x) > 1000000.0 or absf(saved_position.y) > 1000000.0 or absf(saved_position.z) > 1000000.0:
		return
	var nearest_home_distance := minf(saved_position.distance_to(_bed_position), minf(saved_position.distance_to(_day_position), minf(saved_position.distance_to(_day_position_alt), saved_position.distance_to(_market_position))))
	if nearest_home_distance > 48.0:
		return
	_use_alt_day_position = bool(snapshot.get("use_alt_day_position", false))
	_is_daytime = not daytime
	set_day_state(daytime)
	global_position = saved_position
	velocity = Vector3.ZERO
	if daytime:
		_target_position = _market_position if role == "merchant" else (_day_position_alt if _use_alt_day_position else _day_position)
		_is_sleeping = false
	else:
		_target_position = _bed_position if _bed_available else _day_position
		_is_sleeping = _bed_available and bool(snapshot.get("sleeping", false)) and saved_position.distance_to(_bed_position) <= 1.4
	if _model_root != null:
		_model_root.position.y = 0.0
		_model_root.rotation.x = PI * 0.5 if _is_sleeping else 0.0


func interaction_text() -> String:
	if role == "merchant":
		return "%s: veja as mercadorias da vila." % display_name
	if _is_sleeping:
		return "%s está dormindo em casa. Volte durante o dia." % display_name
	return "%s: bem-vindo à nossa vila!" % display_name
