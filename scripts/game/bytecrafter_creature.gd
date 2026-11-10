extends CharacterBody3D
class_name ByteCrafterCreature

signal defeated(creature: ByteCrafterCreature, at_position: Vector3)

const MOVEMENT := preload("res://scripts/game/bytecrafter_movement.gd")
const GRAVITY := 20.0
const SPECIES := {
	"chicken": {"label": "Galinha", "health": 1, "speed": 2.8, "size": Vector3(0.7, 0.75, 0.55), "drops": [[12, 1], [29, 1]], "xp": 3},
	"horse": {"label": "Cavalo", "health": 4, "speed": 1.0, "size": Vector3(1.25, 1.35, 0.8), "drops": [[12, 2], [13, 1]], "xp": 8},
	"sheep": {"label": "Ovelha", "health": 3, "speed": 1.35, "size": Vector3(1.05, 1.15, 0.72), "color": Color("eee7d2"), "drops": [[14, 2], [12, 1]], "xp": 6},
	"dog": {"label": "Cão", "health": 3, "speed": 1.55, "size": Vector3(0.95, 0.9, 0.65), "drops": [[12, 2], [15, 1]], "xp": 6},
	"fish": {"label": "Peixe", "health": 1, "speed": 1.15, "size": Vector3(0.72, 0.4, 0.34), "drops": [], "xp": 0},
}
const MODELS := {
	"chicken": "res://assets/bitmal/Chicken by Quaternius - Z3RCoCYss4.glb",
	"horse": "res://assets/bitmal/Horse by Quaternius - D3hAeqeDBE.glb",
	"sheep": "res://assets/bitmal/Sheep by Quaternius - rgJXF570ZK.glb",
	"dog": "res://assets/bitmal/Dog by Quaternius - 2kUk0QqpCg.glb",
}

var species := "chicken"
var health := 1
var _max_health := 1
var wander_origin := Vector3.ZERO
var _wander_target := Vector3.ZERO
var _turn_timer := 0.0
var _flee_timer := 0.0
var _walk_speed := 1.15
var _defeated := false
var _size_variation := 1.0
var _world: ByteCrafterWorld
var _fish_tail: Node3D
var _fish_time := 0.0

static func is_supported_species(value: String) -> bool:
	return SPECIES.has(value)

func configure(requested_species: String, world: ByteCrafterWorld = null) -> void:
	species = requested_species if is_supported_species(requested_species) else "chicken"
	_world = world
	var spec: Dictionary = SPECIES[species]
	health = int(spec["health"])
	_max_health = health
	_walk_speed = float(spec["speed"])
	_size_variation = randf_range(0.8, 1.2)

func get_display_name() -> String:
	return str((SPECIES.get(species, SPECIES["chicken"]) as Dictionary)["label"])

func get_drops() -> Array:
	var scaled_drops: Array = []
	for entry: Array in (SPECIES.get(species, SPECIES["chicken"]) as Dictionary)["drops"]:
		var expected := float(entry[1]) * _size_variation
		var amount := floori(expected)
		if randf() < expected - float(amount):
			amount += 1
		if amount > 0:
			scaled_drops.append([int(entry[0]), amount])
	return scaled_drops

func get_xp_reward() -> int:
	return int((SPECIES.get(species, SPECIES["chicken"]) as Dictionary)["xp"])

func _ready() -> void:
	name = get_display_name().replace(" ", "")
	floor_snap_length = 0.28
	collision_layer = 2
	collision_mask = 1
	var shape := CapsuleShape3D.new()
	var size: Vector3 = (SPECIES.get(species, SPECIES["chicken"]) as Dictionary)["size"] * _size_variation
	shape.radius = size.x * 0.32
	shape.height = size.y
	var collider := CollisionShape3D.new()
	collider.name = "AnimalCollider"
	collider.shape = shape
	collider.position.y = size.y * 0.5
	add_child(collider)
	_build_model(size)
	wander_origin = global_position
	_pick_target()

func _build_model(size: Vector3) -> void:
	if species == "fish":
		_build_fish_model(size)
		return
	var old_model := get_node_or_null("AnimalModel")
	if old_model != null:
		old_model.queue_free()
	var model_scene := load(str(MODELS.get(species, ""))) as PackedScene
	if model_scene == null:
		push_error("Missing model for creature species: " + species)
		return
	var model := model_scene.instantiate() as Node3D
	model.name = "AnimalModel"
	model.rotation = Vector3(0.0, PI, 0.0)
	var bounds := _find_model_bounds(model)
	if bounds.size.y > 0.001:
		var uniform_scale := size.y / bounds.size.y
		model.scale = Vector3.ONE * uniform_scale
		model.position.y = -bounds.position.y * uniform_scale
	add_child(model)
	var plate := Label3D.new()
	plate.name = "SpeciesLabel"
	plate.text = get_display_name().to_upper()
	plate.position.y = size.y + 0.18
	plate.font_size = 24
	plate.pixel_size = 0.0035
	plate.modulate = Color("f4f0c4")
	plate.outline_size = 6
	plate.outline_modulate = Color(0.03, 0.05, 0.04, 0.95)
	plate.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	plate.no_depth_test = true
	add_child(plate)


func _build_fish_model(size: Vector3) -> void:
	var root := Node3D.new()
	root.name = "FishModel"
	add_child(root)
	var body_mesh := BoxMesh.new()
	body_mesh.size = Vector3(size.x * 0.78, size.y * 0.68, size.z * 1.75)
	var body := MeshInstance3D.new()
	body.name = "FishBody"
	body.mesh = body_mesh
	body.position.y = size.y * 0.52
	var body_material := StandardMaterial3D.new()
	body_material.albedo_color = Color("55b7c9")
	body_material.roughness = 0.78
	body.material_override = body_material
	root.add_child(body)
	_fish_tail = Node3D.new()
	_fish_tail.name = "Tail"
	_fish_tail.position = Vector3(0.0, size.y * 0.5, size.z * 0.86)
	root.add_child(_fish_tail)
	var tail_mesh := BoxMesh.new()
	tail_mesh.size = Vector3(size.x * 0.48, size.y * 0.9, size.z * 0.28)
	var tail := MeshInstance3D.new()
	tail.mesh = tail_mesh
	tail.position.z = size.z * 0.15
	tail.rotation_degrees.x = -10.0
	tail.material_override = body_material
	_fish_tail.add_child(tail)
	var fin_mesh := BoxMesh.new()
	fin_mesh.size = Vector3(size.x * 0.28, size.y * 0.16, size.z * 0.56)
	var fin := MeshInstance3D.new()
	fin.name = "DorsalFin"
	fin.mesh = fin_mesh
	fin.position = Vector3(0.0, size.y * 0.88, 0.0)
	fin.material_override = body_material
	root.add_child(fin)
	var eye_mesh := SphereMesh.new()
	eye_mesh.radius = 0.035
	eye_mesh.height = 0.07
	var eye_material := StandardMaterial3D.new()
	eye_material.albedo_color = Color("17242a")
	for side: float in [-1.0, 1.0]:
		var eye := MeshInstance3D.new()
		eye.mesh = eye_mesh
		eye.position = Vector3(side * size.x * 0.3, size.y * 0.62, -size.z * 0.68)
		eye.material_override = eye_material
		root.add_child(eye)


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

func _physics_process(delta: float) -> void:
	if _defeated:
		return
	if species == "fish":
		_process_fish(delta)
		return
	_turn_timer -= delta
	_flee_timer = maxf(0.0, _flee_timer - delta)
	if _turn_timer <= 0.0 or global_position.distance_to(_wander_target) < 0.5:
		_pick_target()
	var flat_target := _wander_target - global_position
	flat_target.y = 0.0
	var direction := flat_target.normalized()
	var body_height: float = float((SPECIES[species] as Dictionary)["size"].y)
	var in_water := MOVEMENT.is_in_water(_world, self, body_height)
	var speed_scale := 0.7 if in_water else 1.0
	velocity.x = direction.x * _walk_speed * (1.7 if _flee_timer > 0.0 else 1.0) * speed_scale
	velocity.z = direction.z * _walk_speed * (1.7 if _flee_timer > 0.0 else 1.0) * speed_scale
	if direction.length_squared() > 0.01:
		rotation.y = lerp_angle(rotation.y, atan2(-direction.x, -direction.z), minf(delta * 3.0, 1.0))
	if in_water:
		MOVEMENT.apply_buoyancy(self, _world, delta, body_height)
	elif not is_on_floor():
		velocity.y -= GRAVITY * delta
	else:
		velocity.y = 0.0
	MOVEMENT.move_with_step(self, delta, true, in_water)


func _process_fish(delta: float) -> void:
	_fish_time += delta
	_turn_timer -= delta
	if not is_instance_valid(_world):
		return
	if _turn_timer <= 0.0 or global_position.distance_to(_wander_target) < 0.4 or not MOVEMENT.is_in_water(_world, self, 0.4):
		_pick_fish_target()
	var toward := _wander_target - global_position
	var direction := toward.normalized() if toward.length_squared() > 0.0001 else Vector3.ZERO
	velocity = direction * _walk_speed
	if direction.length_squared() > 0.001:
		rotation.y = lerp_angle(rotation.y, atan2(-direction.x, -direction.z), minf(1.0, delta * 4.0))
	move_and_slide()
	if _fish_tail != null:
		_fish_tail.rotation.y = sin(_fish_time * 9.0) * 0.42
		_fish_tail.rotation.x = sin(_fish_time * 3.2) * 0.08


func _pick_fish_target() -> void:
	_turn_timer = randf_range(2.0, 4.5)
	for _attempt: int in 14:
		var angle := randf_range(-PI, PI)
		var radius := randf_range(2.0, 6.0)
		var candidate := global_position + Vector3(cos(angle) * radius, 0.0, sin(angle) * radius)
		var surface := _world.get_water_surface_height_at(candidate)
		if not is_finite(surface):
			continue
		var depth := surface - float(_world.terrain_height(floori(candidate.x), floori(candidate.z)) + 1)
		if depth < 0.35:
			continue
		var swim_depth := randf_range(0.18, minf(1.1, depth - 0.08))
		_wander_target = Vector3(candidate.x, surface - swim_depth, candidate.z)
		return
	_wander_target = global_position

func _pick_target() -> void:
	if species == "fish":
		_pick_fish_target()
		return
	_turn_timer = randf_range(2.5, 6.0)
	var offset := Vector3(randf_range(-5.0, 5.0), 0.0, randf_range(-5.0, 5.0))
	_wander_target = wander_origin + offset

func take_damage(amount: int = 1) -> void:
	if _defeated:
		return
	health = maxi(0, health - maxi(1, amount))
	_flee_timer = 2.5
	_pick_target()
	if health <= 0:
		_defeated = true
		collision_layer = 0
		var collider := get_node_or_null("AnimalCollider") as CollisionShape3D
		if collider != null:
			collider.set_deferred("disabled", true)
		rotation.z = -PI * 0.5
		defeated.emit(self, global_position)
		var timer := get_tree().create_timer(0.25)
		timer.timeout.connect(queue_free)
