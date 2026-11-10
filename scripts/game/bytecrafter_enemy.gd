extends CharacterBody3D
class_name ByteCrafterEnemy

signal defeated(enemy: Node3D, at_position: Vector3)

const MOVEMENT := preload("res://scripts/game/bytecrafter_movement.gd")
const GRAVITY := 20.0
const MODELS := {
	"slime": preload("res://assets/bitmal/Simple Green Slime by Garrett LeFever - az-ryr8W44N.glb"),
	"et": preload("res://assets/userpack/characters/ETE_RIGGED.fbx"),
	"zombie": preload("res://assets/userpack/characters/ZUMBIRIGGED.fbx"),
	"boss": preload("res://assets/userpack/characters/ETE_RIGGED.fbx"),
	"runner": preload("res://assets/bitmal/Slime by Quaternius - LyjSUKHKnh.glb"),
	"shooter": preload("res://assets/userpack/characters/ETE_RIGGED.fbx"),
}
const TEXTURES := {
	"et": null,
	"zombie": null,
	"boss": null,
}
const MODEL_SCALES := {
	"et": 1.0,
	"zombie": 1.0,
	"shooter": 1.0,
	"boss": 1.0,
	"runner": 1.0,
}
const PLAYER_REFERENCE_HEIGHT := 1.8
const MAX_ENEMY_HEIGHT := PLAYER_REFERENCE_HEIGHT * 3.0
const ANIMATION_CONTROLLER := preload("res://scripts/game/rig_animation_controller.gd")
const SPECS := {
	"slime": {"label": "Slime", "hits": 1, "speed": 2.15, "range": 1.35, "aggro_range": 0.0, "damage": 0.5, "cooldown": 1.35, "xp": 8, "reward": 9, "can_chase": false},
	"et": {"label": "ET", "hits": 2, "speed": 1.72, "range": 1.25, "aggro_range": 10.0, "damage": 1.5, "cooldown": 1.75, "xp": 13, "reward": 8, "can_chase": true},
	"zombie": {"label": "Zumbi", "hits": 3, "speed": 2.55, "range": 1.05, "aggro_range": 10.0, "damage": 2.0, "cooldown": 1.2, "xp": 18, "reward": 4, "can_chase": true},
	"boss": {"label": "Chefe Lunar", "hits": 8, "speed": 1.45, "range": 2.15, "aggro_range": 18.0, "damage": 1.6, "cooldown": 1.85, "xp": 90, "reward": 11, "can_chase": true},
	"runner": {"label": "Slime Corredor", "hits": 2, "speed": 5.2, "range": 1.05, "aggro_range": 16.0, "damage": 1.45, "cooldown": 0.9, "xp": 22, "reward": 9, "can_chase": true, "fast": true},
	"shooter": {"label": "Atirador Lunar", "hits": 3, "speed": 1.35, "range": 10.0, "aggro_range": 18.0, "damage": 1.6, "cooldown": 2.2, "xp": 28, "reward": 10, "can_chase": true, "ranged": true},
}

const LOOT_TABLES := {
	"slime": [[9, 1]],
	"et": [[8, 1], [10, 1], ["shuriken", 1]],
	"zombie": [[4, 1], [7, 1]],
	"boss": [[11, 1], [10, 2], [8, 3]],
	"runner": [[9, 2], [8, 1]],
	"shooter": [[10, 1], [11, 1], ["shuriken", 1]],
}

const MONSTER_CATALOG := {
	"alien_pack": {"file": "Alien.glb", "label": "Alien Errante", "tier": "common"},
	"alien_scout": {"file": "Alien-RRliSQBP7r.glb", "label": "Alien Batedor", "tier": "ranged"},
	"alpaking": {"file": "Alpaking.glb", "label": "Alpaking", "tier": "common"},
	"alpaking_evolved": {"file": "Alpaking Evolved.glb", "label": "Alpaking Evoluído", "tier": "elite"},
	"armabee": {"file": "Armabee.glb", "label": "Armabee", "tier": "common"},
	"armabee_evolved": {"file": "Armabee Evolved.glb", "label": "Armabee Evoluída", "tier": "elite"},
	"blue_demon": {"file": "Blue Demon.glb", "label": "Demônio Azul", "tier": "elite"},
	"cactoro": {"file": "Cactoro.glb", "label": "Cactoro", "tier": "common"},
	"cactoro_evolved": {"file": "Cactoro-IGn9lhdama.glb", "label": "Cactoro Ancião", "tier": "elite"},
	"demon": {"file": "Demon.glb", "label": "Demônio", "tier": "common"},
	"demon_ancient": {"file": "Demon-LnfIziKv4o.glb", "label": "Demônio Ancião", "tier": "elite"},
	"dino": {"file": "Dino.glb", "label": "Dinossauro Sombrio", "tier": "common"},
	"dragon": {"file": "Dragon.glb", "label": "Dragão", "tier": "elite"},
	"dragon_evolved": {"file": "Dragon Evolved.glb", "label": "Dragão Ancestral", "tier": "boss"},
	"ghost": {"file": "Ghost.glb", "label": "Fantasma", "tier": "common"},
	"ghost_skull": {"file": "Ghost Skull.glb", "label": "Caveira Fantasma", "tier": "elite"},
	"glub": {"file": "Glub.glb", "label": "Glub", "tier": "common"},
	"glub_evolved": {"file": "Glub Evolved.glb", "label": "Glub Evoluído", "tier": "elite"},
	"goleling": {"file": "Goleling.glb", "label": "Goleling", "tier": "common"},
	"goleling_evolved": {"file": "Goleling Evolved.glb", "label": "Goleling Evoluído", "tier": "elite"},
	"green_blob": {"file": "Green Blob.glb", "label": "Gosma Verde", "tier": "common"},
	"green_spiky_blob": {"file": "Green Spiky Blob.glb", "label": "Gosma Espinhosa", "tier": "elite"},
	"hywirl": {"file": "Hywirl.glb", "label": "Hywirl", "tier": "common"},
	"monkroose": {"file": "Monkroose.glb", "label": "Monkroose", "tier": "common"},
	"mushnub": {"file": "Mushnub.glb", "label": "Mushnub", "tier": "common"},
	"mushnub_evolved": {"file": "Mushnub Evolved.glb", "label": "Mushnub Evoluído", "tier": "elite"},
	"mushroom_king": {"file": "Mushroom King.glb", "label": "Rei Cogumelo", "tier": "boss"},
	"ninja": {"file": "Ninja.glb", "label": "Ninja Sombrio", "tier": "common"},
	"ninja_elite": {"file": "Ninja-xGYmeDpfTu.glb", "label": "Ninja das Sombras", "tier": "elite"},
	"orc": {"file": "Orc.glb", "label": "Orc", "tier": "common"},
	"orc_enemy": {"file": "Orc Enemy.glb", "label": "Orc Veterano", "tier": "elite"},
	"pink_blob": {"file": "Pink Blob.glb", "label": "Gosma Rosa", "tier": "common"},
	"squidle": {"file": "Squidle.glb", "label": "Squidle", "tier": "common"},
	"tribal": {"file": "Tribal.glb", "label": "Guerreiro Tribal", "tier": "common"},
	"wizard": {"file": "Wizard.glb", "label": "Mago Sombrio", "tier": "ranged"},
	"yeti": {"file": "Yeti.glb", "label": "Yeti", "tier": "elite"},
	"yeti_ancient": {"file": "Yeti-ceRHrn8HHE.glb", "label": "Yeti Ancestral", "tier": "boss"},
}
const MONSTER_ARCHETYPES := {
	"common": {"hits": 2, "speed": 2.2, "range": 1.2, "aggro_range": 13.0, "damage": 1.5, "cooldown": 1.4, "xp": 20, "reward": 33, "height": 1.35, "can_chase": true, "day_sensitive": true, "loot": [[33, 1]]},
	"elite": {"hits": 4, "speed": 2.7, "range": 1.3, "aggro_range": 17.0, "damage": 2.0, "cooldown": 1.3, "xp": 42, "reward": 33, "height": 1.8, "can_chase": true, "fast": true, "day_sensitive": true, "loot": [[33, 1], [10, 1]]},
	"boss": {"hits": 8, "speed": 1.65, "range": 1.9, "aggro_range": 22.0, "damage": 1.6, "cooldown": 1.85, "xp": 90, "reward": 33, "height": 2.7, "can_chase": true, "day_sensitive": true, "boss": true, "loot": [[33, 2], [11, 1], [10, 2]]},
	"ranged": {"hits": 3, "speed": 1.5, "range": 10.0, "aggro_range": 18.0, "damage": 1.6, "cooldown": 2.2, "xp": 34, "reward": 33, "height": 1.7, "can_chase": true, "ranged": true, "day_sensitive": true, "loot": [[33, 1], [10, 1]]},
}

var enemy_type := "slime"
var health := 1.0
var hits_remaining := 1
var target: ByteCrafterPlayer
var game: Node
var _world: ByteCrafterWorld
var _model_root: Node3D
var _base_model_scale := Vector3.ONE
var _base_model_position := Vector3.ZERO
var _attack_timer := 0.4
var _hit_flash_timer := 0.0
var _defeated := false
var _death_timer := 0.0
var _visual_time := 0.0
var _max_health := 1.0
var _health_bar: Label3D
var _health_text: Label3D
var _animation_controller


static func is_supported_type(value: String) -> bool:
	return SPECS.has(value) or MONSTER_CATALOG.has(value)


static func pick_monster_type(boss_night := false) -> String:
	var choices: Array[String] = []
	for type_value: Variant in MONSTER_CATALOG.keys():
		var type_id := str(type_value)
		var tier := str((MONSTER_CATALOG[type_id] as Dictionary).get("tier", "common"))
		if boss_night and tier in ["elite", "boss"]:
			choices.append(type_id)
		elif not boss_night and tier != "boss":
			choices.append(type_id)
	return choices.pick_random() if not choices.is_empty() else ""


func _get_spec() -> Dictionary:
	if SPECS.has(enemy_type):
		return SPECS[enemy_type] as Dictionary
	var catalog_entry: Dictionary = MONSTER_CATALOG.get(enemy_type, {})
	var archetype := str(catalog_entry.get("tier", "common"))
	var result: Dictionary = (MONSTER_ARCHETYPES.get(archetype, MONSTER_ARCHETYPES["common"]) as Dictionary).duplicate(true)
	result["label"] = str(catalog_entry.get("label", enemy_type.capitalize()))
	return result


func configure(player: ByteCrafterPlayer, owner_game: Node, requested_type := "slime") -> void:
	target = player
	game = owner_game
	var world_value: Variant = owner_game.get("_world") if owner_game != null else null
	_world = world_value as ByteCrafterWorld
	enemy_type = requested_type if is_supported_type(requested_type) else "slime"
	hits_remaining = int(_get_spec().get("hits", 1))
	health = float(hits_remaining)
	_max_health = health
	if is_inside_tree():
		_clear_collider()
		_build_collider()
		_build_model()
		_build_nameplate()


func _ready() -> void:
	name = "%sHostil" % get_display_name().replace(" ", "")
	collision_layer = 2
	collision_mask = 1
	floor_snap_length = 0.24
	_build_collider()
	_build_model()
	_build_nameplate()


func _build_collider() -> void:
	var collider := CollisionShape3D.new()
	collider.name = "SlimeCollider" if enemy_type == "slime" else "EnemyCollider"
	var shape := CapsuleShape3D.new()
	if enemy_type == "slime":
		shape.radius = 0.46
		shape.height = 0.92
		collider.position.y = 0.46
	else:
		var height := _target_height()
		shape.radius = 0.38 * (height / 1.8)
		shape.height = height
		collider.position.y = height * 0.5
	collider.shape = shape
	add_child(collider)


func _clear_collider() -> void:
	var old_collider := get_node_or_null("SlimeCollider")
	if old_collider == null:
		old_collider = get_node_or_null("EnemyCollider")
	if old_collider != null:
		remove_child(old_collider)
		old_collider.queue_free()


func _build_model() -> void:
	if _model_root != null and is_instance_valid(_model_root):
		remove_child(_model_root)
		_model_root.queue_free()
	var model_scene: PackedScene = MODELS.get(enemy_type, null) as PackedScene
	if model_scene == null and MONSTER_CATALOG.has(enemy_type):
		var catalog_entry: Dictionary = MONSTER_CATALOG[enemy_type]
		model_scene = load("res://assets/monsters/%s" % str(catalog_entry.get("file", ""))) as PackedScene
	if model_scene == null:
		push_error("Missing model for enemy type: " + enemy_type)
		return
	_model_root = model_scene.instantiate() as Node3D
	_model_root.name = "%sModelo" % get_display_name().replace(" ", "")
	# Os rigs importados já têm Y como eixo vertical. Inclinar o root em X os
	# deitava; mantemos somente a rotação de frente no eixo vertical.
	_model_root.rotation = Vector3.ZERO if enemy_type == "slime" else Vector3(0.0, PI, 0.0)
	var source_bounds := _find_model_bounds(_model_root)
	var target_height := minf(_target_height(), MAX_ENEMY_HEIGHT)
	var vertical_bounds := _find_rig_vertical_bounds(_model_root)
	var source_height := vertical_bounds.y - vertical_bounds.x
	if source_height <= 0.001:
		source_height = source_bounds.size.y
	var uniform_scale := target_height / maxf(source_height, 0.001)
	if enemy_type != "slime":
		uniform_scale *= float(MODEL_SCALES.get(enemy_type, 1.0))
	# A escala 1.0 significa altura normal de 1,8 m; o boss não ganha
	# multiplicador próprio e respeita a mesma referência do zumbi.
	uniform_scale = minf(uniform_scale, MAX_ENEMY_HEIGHT / maxf(source_height, 0.001))
	_model_root.scale = Vector3.ONE * uniform_scale
	# Alinha a base dos pés ao chão usando os ossos, não o AABB parcial da malha.
	_model_root.position.y = -vertical_bounds.x * uniform_scale
	_base_model_position = _model_root.position
	_base_model_scale = _model_root.scale
	_apply_texture()
	add_child(_model_root)
	if enemy_type != "slime" and not MONSTER_CATALOG.has(enemy_type) and _model_root.find_child("Skeleton3D", true, false) != null and _model_root.find_child("AnimationPlayer", true, false) != null:
		if _animation_controller != null and is_instance_valid(_animation_controller):
			_animation_controller.queue_free()
		_animation_controller = ANIMATION_CONTROLLER.new() as Node
		_animation_controller.name = "RigAnimationController"
		add_child(_animation_controller)
		var extra_clip_names: Array[String] = []
		if enemy_type == "zombie":
			extra_clip_names = ["zombie_idle", "zombie_walk", "zombie_punch"]
		elif enemy_type == "et":
			extra_clip_names = ["et_wheelbarrow"]
		_animation_controller.setup(_model_root, extra_clip_names)
		if enemy_type == "zombie":
			_animation_controller.set_clip_overrides({"idle": "zombie_idle", "walk": "zombie_walk", "attack": "zombie_punch"})
		elif enemy_type == "et":
			_animation_controller.set_clip_overrides({"walk": "et_wheelbarrow"})


func _build_nameplate() -> void:
	var old_plate := get_node_or_null("Nameplate")
	if old_plate != null:
		old_plate.queue_free()
	var plate := Label3D.new()
	plate.name = "Nameplate"
	plate.text = get_display_name().to_upper()
	plate.position.y = _target_height() + 0.28
	plate.font_size = 32
	plate.pixel_size = 0.0035
	plate.modulate = Color("f4f0c4")
	plate.outline_size = 8
	plate.outline_modulate = Color(0.03, 0.05, 0.04, 0.95)
	plate.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	plate.no_depth_test = true
	plate.render_priority = 4
	add_child(plate)
	_build_health_bar()


func _build_health_bar() -> void:
	for child_name: String in ["HealthBarBack", "HealthBar"]:
		var old_bar := get_node_or_null(child_name)
		if old_bar != null:
			old_bar.queue_free()
	var y := _target_height() + 0.08
	_health_bar = Label3D.new()
	_health_bar.name = "HealthBarBack"
	_health_bar.text = "■■■■■■■■"
	_health_bar.position = Vector3(0.0, y, 0.0)
	_health_bar.font_size = 26
	_health_bar.pixel_size = 0.0032
	_health_bar.modulate = Color(0.06, 0.08, 0.06, 0.9)
	_health_bar.outline_size = 2
	_health_bar.outline_modulate = Color(0.02, 0.02, 0.02, 0.95)
	_health_bar.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_health_bar.no_depth_test = true
	_health_bar.render_priority = 5
	add_child(_health_bar)
	_health_text = Label3D.new()
	_health_text.name = "HealthBar"
	_health_text.position = Vector3(0.0, y, 0.01)
	_health_text.font_size = 26
	_health_text.pixel_size = 0.0032
	_health_text.outline_size = 2
	_health_text.outline_modulate = Color(0.02, 0.02, 0.02, 0.95)
	_health_text.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_health_text.no_depth_test = true
	_health_text.render_priority = 6
	add_child(_health_text)
	_refresh_health_bar()


func _refresh_health_bar() -> void:
	if _health_text == null:
		return
	var ratio := clampf(health / maxf(_max_health, 1.0), 0.0, 1.0)
	var filled := clampi(ceili(ratio * 8.0), 0, 8)
	_health_text.text = "■".repeat(filled)
	_health_text.modulate = Color("8ee388") if ratio > 0.5 else (Color("f4d35e") if ratio > 0.25 else Color("ed786f"))
	_health_text.position.x = -0.03 * float(8 - filled)


func _find_model_bounds(root: Node3D) -> AABB:
	var result := _collect_model_bounds(root, Transform3D.IDENTITY)
	return result if result.size != Vector3.ZERO else AABB(Vector3.ZERO, Vector3.ONE)


func _collect_model_bounds(node: Node, parent_transform: Transform3D) -> AABB:
	var current := parent_transform * (node as Node3D).transform if node is Node3D else parent_transform
	var result := AABB()
	if node is MeshInstance3D:
		result = current * (node as MeshInstance3D).get_aabb()
	for child: Node in node.get_children():
		var child_bounds := _collect_model_bounds(child, current)
		if child_bounds.size != Vector3.ZERO:
			result = child_bounds if result.size == Vector3.ZERO else result.merge(child_bounds)
	return result


func _find_rig_vertical_bounds(root: Node3D) -> Vector2:
	var skeleton := root.find_child("Skeleton3D", true, false) as Skeleton3D
	if skeleton == null:
		var mesh_bounds := _find_model_bounds(root)
		return Vector2(mesh_bounds.position.y, mesh_bounds.end.y)
	var skeleton_to_root := Transform3D.IDENTITY
	var current: Node = skeleton
	while current != null and current != root:
		if current is Node3D:
			skeleton_to_root = (current as Node3D).transform * skeleton_to_root
		current = current.get_parent()
	var min_y := INF
	var max_y := -INF
	for bone_index: int in skeleton.get_bone_count():
		var bone_position := skeleton_to_root * skeleton.get_bone_global_rest(bone_index).origin
		min_y = minf(min_y, bone_position.y)
		max_y = maxf(max_y, bone_position.y)
	return Vector2(min_y, max_y) if min_y < INF and max_y > -INF else Vector2.ZERO


func _apply_texture() -> void:
	var meshes := _find_meshes(_model_root)
	if meshes.is_empty():
		push_warning("Enemy model has no MeshInstance3D: " + enemy_type)
		return
	for mesh: MeshInstance3D in meshes:
		var texture: Texture2D = TEXTURES.get(enemy_type, null) as Texture2D
		var source_material := mesh.get_active_material(0) as StandardMaterial3D
		var material := source_material.duplicate(true) as StandardMaterial3D if source_material != null else StandardMaterial3D.new()
		if texture != null:
			material.albedo_texture = texture
		if enemy_type == "boss":
			material.albedo_color = Color("bf78ff")
			material.emission_enabled = true
			material.emission = Color("57218f")
			material.emission_energy_multiplier = 0.55
		material.roughness = 0.84
		mesh.material_override = material
		mesh.visible = true
		mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON


func _find_first_mesh(parent: Node) -> MeshInstance3D:
	for child: Node in parent.get_children():
		if child is MeshInstance3D:
			return child as MeshInstance3D
		var nested := _find_first_mesh(child)
		if nested != null:
			return nested
	return null


func _find_meshes(parent: Node) -> Array[MeshInstance3D]:
	var result: Array[MeshInstance3D] = []
	for child: Node in parent.get_children():
		if child is MeshInstance3D:
			result.append(child as MeshInstance3D)
		result.append_array(_find_meshes(child))
	return result


func _target_height() -> float:
	if MONSTER_CATALOG.has(enemy_type):
		return float(_get_spec().get("height", 1.35))
	match enemy_type:
		"zombie", "et", "boss", "shooter":
			return 1.8
		_:
			return 0.9


func _physics_process(delta: float) -> void:
	_visual_time += delta
	if _defeated:
		_process_death(delta)
		return
	_attack_timer = maxf(0.0, _attack_timer - delta)
	_hit_flash_timer = maxf(0.0, _hit_flash_timer - delta)
	_process_visuals(delta)
	if target == null or not is_instance_valid(target) or not target.can_control:
		_set_animation_state("idle")
		velocity.x = move_toward(velocity.x, 0.0, 12.0 * delta)
		velocity.z = move_toward(velocity.z, 0.0, 12.0 * delta)
		_move_body(delta)
		return
	var daytime := true
	if game != null and game.has_method("is_daytime"):
		daytime = game.is_daytime()
	var spec: Dictionary = _get_spec()
	if (enemy_type in ["et", "shooter"] and daytime) or (enemy_type == "zombie" and daytime) or (enemy_type == "boss" and daytime) or (bool(spec.get("day_sensitive", false)) and daytime):
		_set_animation_state("idle")
		velocity.x = 0.0
		velocity.z = 0.0
		_move_body(delta)
		return
	var offset := target.global_position - global_position
	offset.y = 0.0
	var distance := offset.length()
	var direction := offset.normalized() if distance > 0.01 else Vector3.ZERO
	if direction.length_squared() > 0.01:
		rotation.y = lerp_angle(rotation.y, atan2(-direction.x, -direction.z), minf(delta * (3.2 if enemy_type in ["zombie", "runner"] else 2.3), 1.0))
	var attack_range := float(spec.get("range", 1.35))
	var ranged := bool(spec.get("ranged", false))
	var can_move := bool(spec.get("can_chase", false)) and distance <= float(spec.get("aggro_range", 0.0))
	var desired_distance := 6.5 if ranged else attack_range
	var should_move := distance > desired_distance if ranged else distance > attack_range
	if ranged and distance < 4.0:
		should_move = true
		direction = -direction
	if should_move and can_move:
		_set_animation_state("walk")
		var speed := float(spec.get("speed", 2.0))
		if bool(spec.get("fast", false)):
			speed *= 1.0 + (1.0 - _get_sunlight_strength()) * 0.45
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		_set_animation_state("idle")
		velocity.x = move_toward(velocity.x, 0.0, 14.0 * delta)
		velocity.z = move_toward(velocity.z, 0.0, 14.0 * delta)
	if ((ranged and distance <= attack_range and distance >= 3.5) or (not ranged and distance <= attack_range)) and _attack_timer <= 0.0 and _has_clear_attack_path() and game != null and game.has_method("_damage_player"):
		_attack_timer = float(spec.get("cooldown", 1.35))
		if _animation_controller != null:
			_animation_controller.play_action("attack")
		game.call("_damage_player", float(spec.get("damage", 2.0)) * (1.0 + (1.0 - _get_sunlight_strength()) * 0.25), "%s%s" % [get_display_name(), " disparo" if ranged else ""])
		_move_body(delta)

func _get_sunlight_strength() -> float:
	if game != null and game.has_method("get_sunlight_strength"):
		return clampf(float(game.call("get_sunlight_strength")), 0.0, 1.0)
	return 1.0
func _has_clear_attack_path() -> bool:
	if target == null or get_world_3d() == null:
		return false
	var origin := global_position + Vector3.UP * minf(_target_height() * 0.72, 1.25)
	var destination := target.global_position + Vector3.UP * 0.9
	var query := PhysicsRayQueryParameters3D.create(origin, destination, 3)
	query.exclude = [get_rid()]
	query.collide_with_bodies = true
	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	return hit.is_empty() or hit.get("collider") == target


func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	else:
		velocity.y = 0.0


func _move_body(delta: float) -> void:
	var in_water := MOVEMENT.is_in_water(_world, self, _target_height())
	if in_water:
		MOVEMENT.apply_buoyancy(self, _world, delta, _target_height())
	else:
		_apply_gravity(delta)
	MOVEMENT.move_with_step(self, delta, true, in_water)


func _process_visuals(_delta: float) -> void:
	if _model_root == null:
		return
	if enemy_type == "et":
		_model_root.position = _base_model_position + Vector3(0.0, sin(_visual_time * 2.4) * 0.035, 0.0)
	else:
		_model_root.position = _base_model_position + Vector3(0.0, sin(_visual_time * 4.2) * 0.025, 0.0)


func _process_death(delta: float) -> void:
	if _model_root != null:
		_model_root.position = _base_model_position
	_death_timer -= delta
	if _death_timer <= 0.0:
		queue_free()


func take_damage(amount: float) -> void:
	if _defeated or amount <= 0.0:
		return
	health = maxf(0.0, health - amount)
	hits_remaining = ceili(health)
	_hit_flash_timer = 0.16
	_refresh_health_bar()
	if health <= 0.0:
		_defeated = true
		_death_timer = 0.9
		if _animation_controller != null:
			_animation_controller.play_action("death")
		collision_layer = 0
		var collider := get_node_or_null("SlimeCollider") as CollisionShape3D
		if collider == null:
			collider = get_node_or_null("EnemyCollider") as CollisionShape3D
		if collider != null:
			collider.set_deferred("disabled", true)
		defeated.emit(self, global_position)


func _set_animation_state(state: String) -> void:
	if _animation_controller != null:
		_animation_controller.set_locomotion_state(state)


func is_day_sensitive() -> bool:
	return bool(_get_spec().get("day_sensitive", false))


func get_display_name() -> String:
	return str(_get_spec().get("label", "Slime"))


func get_reward_item_id() -> int:
	return int(_get_spec().get("reward", 9))


func get_xp_reward() -> int:
	return int(_get_spec().get("xp", 8))


func get_loot_table() -> Array:
	if MONSTER_CATALOG.has(enemy_type):
		return (_get_spec().get("loot", []) as Array).duplicate(true)
	return (LOOT_TABLES.get(enemy_type, LOOT_TABLES["slime"]) as Array).duplicate(true)


func is_boss() -> bool:
	return enemy_type == "boss" or bool(_get_spec().get("boss", false))
