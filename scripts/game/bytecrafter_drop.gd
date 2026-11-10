extends Area3D
class_name ByteCrafterDrop

const DROP_LIFETIME_SECONDS := 300.0
const FLOOR_SAMPLE_INTERVAL_SECONDS := 0.5
const SAVE_POSITION_INTERVAL_SECONDS := 1.0

var drop_id := -1
var block_id: Variant = 1
var quantity := 1
var pending_collection := false
var _elapsed := 0.0
var _base_y := 0.0
var _floor_sample_elapsed := FLOOR_SAMPLE_INTERVAL_SECONDS
var _save_position_elapsed := SAVE_POSITION_INTERVAL_SECONDS
const DROP_TEXTURES := {
	1: preload("res://assets/textures/blocks/grass_side.png"),
	2: preload("res://assets/textures/blocks/dirt.png"),
	3: preload("res://assets/textures/blocks/stone_minecraft.png"),
	4: preload("res://assets/textures/blocks/oak_log_side.png"),
	5: preload("res://assets/textures/blocks/oak_leaves_minecraft.png"),
	6: preload("res://assets/textures/blocks/sand.png"),
	7: preload("res://assets/textures/blocks/oak_planks.png"),
}
const DROP_MODELS := {
	"cama": preload("res://assets/userpack/cubeworld/Bed Single by Kenney - sn8az3odMR.glb"),
	"bedroll": preload("res://assets/userpack/cubeworld/Bedroll by Kenney - efwd5fjuMU.glb"),
	8: preload("res://assets/bitmal/Apple Green by Quaternius - 3VXWnjDOEw.glb"),
	10: preload("res://assets/userpack/cubeworld/Crystal.glb"),
	11: preload("res://assets/userpack/cubeworld/Big Crystal.glb"),
	12: preload("res://assets/bitmal/Chicken Leg by Quaternius - Ed5NPaeT2N.glb"),
	"shuriken": preload("res://assets/bitmal/Shuriken by iPoly3D - mrzNkmPnMo.glb"),
	28: preload("res://assets/bitmal/Flowers by Quaternius - 4JgnDpC3SK.glb"),
		29: preload("res://assets/bitmal/Egg by Poly by Google - 6IlWtCejyrO.glb"),
		30: preload("res://assets/bitmal/Corn by Kenney - NaEnzEW0JQ.glb"),
		31: preload("res://assets/bitmal/Lettuce by Quaternius - MEmUwHUHNR.glb"),
		32: preload("res://assets/bitmal/Cabbage by Kenney - 6urnIRBhzr.glb"),
		33: preload("res://assets/bitmal/Gem Green by Quaternius - kbgiCMzdxg.glb"),
		34: preload("res://assets/userpack/cubeworld/Mushroom.glb"),
		35: preload("res://assets/userpack/cubeworld/Bamboo.glb"),
		36: preload("res://assets/userpack/cubeworld/Flowers.glb"),
		37: preload("res://assets/userpack/cubeworld/Grass Block.glb"),
		38: preload("res://assets/userpack/cubeworld/Dirt Block.glb"),
		39: preload("res://assets/userpack/cubeworld/Stone Block.glb"),
		40: preload("res://assets/userpack/cubeworld/Brick Block.glb"),
		41: preload("res://assets/userpack/cubeworld/Wood Planks Block.glb"),
		42: preload("res://assets/userpack/cubeworld/Ice Block.glb"),
		43: preload("res://assets/userpack/cubeworld/Snow Block.glb"),
		44: preload("res://assets/userpack/cubeworld/Crystal Block.glb"),
		45: preload("res://assets/userpack/cubeworld/Diamond Block.glb"),
		46: preload("res://assets/userpack/cubeworld/Coal Block.glb"),
		47: preload("res://assets/userpack/cubeworld/Grey Bricks.glb"),
		48: preload("res://assets/userpack/cubeworld/Metal Block.glb"),
	}
const DROP_MODEL_VARIANTS := {
	8: [preload("res://assets/bitmal/Apple Green by Quaternius - 3VXWnjDOEw.glb"), preload("res://assets/bitmal/Banana by Kenney - 5Z07I9KMob.glb"), preload("res://assets/bitmal/Orange by Kenney - UnygaDfm1J.glb"), preload("res://assets/bitmal/Pear by Kenney - 6arz55szEl.glb"), preload("res://assets/bitmal/Tomato by Kenney - TZWJgWJs8V.glb")],
	12: [preload("res://assets/bitmal/Chicken Leg by Quaternius - Ed5NPaeT2N.glb")],
	16: [preload("res://assets/bitmal/Carrot by Kenney - 59muuwqSsq.glb"), preload("res://assets/bitmal/Leek by Kenney - jnfaimryxs.glb"), preload("res://assets/bitmal/Corn by Kenney - NaEnzEW0JQ.glb"), preload("res://assets/bitmal/Skewer Vegetables by Kenney - nc8j1mYNwJ.glb")],
}


func configure(id: int, voxel_id: Variant, amount: int = 1) -> void:
	drop_id = id
	block_id = voxel_id
	quantity = maxi(1, amount)


func _ready() -> void:
	name = "Drop_%d" % drop_id
	collision_layer = 0
	collision_mask = 1
	monitoring = true
	monitorable = false
	_base_y = position.y
	var shape := SphereShape3D.new()
	shape.radius = 0.72
	var collision := CollisionShape3D.new()
	collision.shape = shape
	add_child(collision)
	var cube := MeshInstance3D.new()
	if block_id is String:
		cube.name = "PropItem"
		var box := BoxMesh.new()
		box.size = Vector3(0.34, 0.24, 0.34)
		cube.mesh = box
	elif block_id in [8, 12, 16, 29, 30, 31, 32]:
		cube.name = "ResourceItem"
		var fruit := SphereMesh.new()
		fruit.radius = 0.20 if block_id in [8, 12, 15, 16] else 0.17
		fruit.height = 0.40 if block_id in [8, 12, 15, 16] else 0.34
		cube.mesh = fruit
	else:
		cube.name = "ResourceVoxel"
		var box := BoxMesh.new()
		box.size = Vector3(0.4, 0.4, 0.4)
		cube.mesh = box
	var material := StandardMaterial3D.new()
	if block_id is String:
		material.albedo_color = {
			"cama": Color("c45b69"),
			"porta": Color("a77a4e"),
			"janela": Color("77bfd0"),
			"fornalha": Color("626b76"),
			"mesa_craft": Color("9a704b"),
			"bau": Color("b68b4f"),
			"alcapao": Color("8f6842"),
			"barraca": Color("e0c778"),
		}.get(str(block_id), Color("b99563"))
	elif block_id == 8:
		material.albedo_color = Color("d9853c")
	elif block_id == 9:
		material.albedo_color = Color("74e5bf")
		material.emission_enabled = true
		material.emission = Color("2bb88e")
		material.emission_energy_multiplier = 0.7
	elif block_id == 10:
		material.albedo_color = Color("9d73e8")
		material.emission_enabled = true
		material.emission = Color("53219b")
		material.emission_energy_multiplier = 0.85
	elif block_id == 11:
		material.albedo_color = Color("f1c96b")
		material.emission_enabled = true
		material.emission = Color("b66c1e")
		material.emission_energy_multiplier = 1.2
	elif block_id == 12:
		material.albedo_color = Color("b85245")
	elif block_id == 13:
		material.albedo_color = Color("9a704b")
	elif block_id == 14:
		material.albedo_color = Color("eee7d2")
	elif block_id == 15:
		material.albedo_color = Color("f0c85e")
	elif block_id == 16:
		material.albedo_color = Color("c87845")
	elif block_id == 21:
		material.albedo_color = Color("a95f4a")
	elif block_id == 22:
		material.albedo_color = Color("7e858d")
	elif block_id == 23:
		material.albedo_color = Color("20252e")
	elif block_id == 24:
		material.albedo_color = Color("6e54c7")
		material.emission_enabled = true
		material.emission = Color("34206e")
		material.emission_energy_multiplier = 0.35
	elif block_id == 25:
		material.albedo_color = Color("54d8e8")
		material.emission_enabled = true
		material.emission = Color("1d8390")
		material.emission_energy_multiplier = 0.45
	elif block_id == 26:
		material.albedo_color = Color("9b9da5")
	else:
		material.albedo_color = Color.WHITE
		material.albedo_texture = DROP_TEXTURES.get(block_id, DROP_TEXTURES[3])
		material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
		if block_id == 5:
			material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
			material.alpha_scissor_threshold = 0.18
	material.roughness = 0.9
	cube.material_override = material
	cube.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(cube)
	if block_id is String:
		var item_label := Label3D.new()
		item_label.name = "PropItemLabel"
		item_label.text = str(block_id).replace("_", " ").to_upper()
		item_label.position = Vector3(0.0, 0.37, 0.0)
		item_label.font_size = 18
		item_label.pixel_size = 0.004
		item_label.modulate = Color("fff1c4")
		item_label.outline_size = 5
		item_label.outline_modulate = Color(0.05, 0.03, 0.1, 0.95)
		item_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		item_label.no_depth_test = true
		add_child(item_label)
	var drop_model_scene: PackedScene = DROP_MODELS.get(block_id, null)
	var variants: Array = DROP_MODEL_VARIANTS.get(block_id, [])
	if not variants.is_empty():
		drop_model_scene = variants.pick_random()
	if drop_model_scene != null:
		var drop_model := drop_model_scene.instantiate() as Node3D
		drop_model.name = "AssetDrop"
		drop_model.rotation.y = 0.35
		var bounds := _collect_model_bounds(drop_model, Transform3D.IDENTITY)
		var model_extent := maxf(maxf(bounds.size.x, bounds.size.y), bounds.size.z)
		var pickup_scale := 0.30 / maxf(model_extent, 0.001)
		drop_model.scale = Vector3.ONE * pickup_scale
		drop_model.position = -bounds.get_center() * pickup_scale + Vector3.UP * 0.16
		add_child(drop_model)
		cube.visible = false
	if quantity > 1:
		var quantity_label := Label3D.new()
		quantity_label.name = "Quantity"
		quantity_label.text = "x%d" % quantity
		quantity_label.position = Vector3(0.0, 0.42, 0.0)
		quantity_label.font_size = 28
		quantity_label.pixel_size = 0.0035
		quantity_label.modulate = Color("fff2b0")
		quantity_label.outline_size = 6
		quantity_label.outline_modulate = Color(0.05, 0.03, 0.1, 0.95)
		quantity_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		quantity_label.no_depth_test = true
		add_child(quantity_label)
	body_entered.connect(_on_body_entered)


func _collect_model_bounds(node: Node, parent_transform: Transform3D) -> AABB:
	var current := parent_transform * (node as Node3D).transform if node is Node3D else parent_transform
	var result := AABB()
	if node is MeshInstance3D:
		result = current * (node as MeshInstance3D).get_aabb()
	for child: Node in node.get_children():
		var child_bounds := _collect_model_bounds(child, current)
		if child_bounds.size != Vector3.ZERO:
			result = child_bounds if result.size == Vector3.ZERO else result.merge(child_bounds)
	return result if result.size != Vector3.ZERO else AABB(Vector3.ZERO, Vector3.ONE)


func _process(delta: float) -> void:
	_elapsed += delta
	if _elapsed >= DROP_LIFETIME_SECONDS:
		var expiry_owner := get_parent()
		if is_instance_valid(expiry_owner) and expiry_owner.has_method("_on_drop_expired"):
			expiry_owner.call_deferred("_on_drop_expired", drop_id)
		else:
			queue_free()
		set_process(false)
		return
	rotation.y += delta * 1.25
	_floor_sample_elapsed += delta
	if _floor_sample_elapsed >= FLOOR_SAMPLE_INTERVAL_SECONDS:
		var sample_delta := _floor_sample_elapsed
		_floor_sample_elapsed = 0.0
		var floor_y := _find_floor_y()
		if floor_y != INF:
			_base_y = move_toward(_base_y, floor_y, sample_delta * 8.0)
	position.y = _base_y + sin(_elapsed * 2.5) * 0.10
	_save_position_elapsed += delta
	if _save_position_elapsed >= SAVE_POSITION_INTERVAL_SECONDS:
		_save_position_elapsed = 0.0
		var owner_node := get_parent()
		if is_instance_valid(owner_node) and owner_node.has_method("_update_drop_position"):
			owner_node.call("_update_drop_position", drop_id, Vector3(global_position.x, _base_y, global_position.z))


func _find_floor_y() -> float:
	var space := get_world_3d().direct_space_state
	var origin := global_position + Vector3.UP * 0.55
	var target := global_position + Vector3.DOWN * 64.0
	var query := PhysicsRayQueryParameters3D.create(origin, target, 1)
	query.exclude = [get_rid()]
	var hit := space.intersect_ray(query)
	if hit.is_empty():
		return INF
	return float((hit.get("position") as Vector3).y) + 0.24


func _on_body_entered(body: Node3D) -> void:
	if pending_collection or not body is ByteCrafterPlayer:
		return
	pending_collection = true
	set_deferred("monitoring", false)
	var owner_node := get_parent()
	if is_instance_valid(owner_node) and owner_node.has_method("_on_drop_touched"):
		owner_node.call_deferred("_on_drop_touched", drop_id)


func allow_retry() -> void:
	pending_collection = false
	set_deferred("monitoring", true)
