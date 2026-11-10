extends Node3D
class_name ByteCrafterProp

const BED_MODEL := "res://assets/userpack/cubeworld/Bed Single by Kenney - sn8az3odMR.glb"
const BEDROLL_MODEL := "res://assets/userpack/cubeworld/Bedroll by Kenney - efwd5fjuMU.glb"
const BED_SCALE := 1.75
const CHEST_MODEL := "res://assets/userpack/cubeworld/Wood Chest.glb"
const CRATE_MODEL := "res://assets/userpack/cubeworld/Crate.glb"

## Props de sobrevivência construídos com formas voxel. O estado lógico fica no nó
## para que o jogo possa salvar posição, porta e inventário da fornalha.

var prop_id := ""
var cell := Vector3i.ZERO
var is_open := false
var furnace_state: Dictionary = {}
var _moving_panel: Node3D
var _fire_light: OmniLight3D


func configure(id: String, block_cell: Vector3i, opened := false, saved_furnace: Dictionary = {}) -> void:
	prop_id = id
	cell = block_cell
	is_open = opened
	furnace_state = saved_furnace.duplicate(true) if not saved_furnace.is_empty() else {
		"input": null, "input_count": 0, "fuel": null, "fuel_count": 0,
		"output": null, "output_count": 0, "burn_left": 0.0, "cook_progress": 0.0
	}


func _ready() -> void:
	name = "%s_%d_%d_%d" % [prop_id.capitalize(), cell.x, cell.y, cell.z]
	add_to_group("bytecrafter_props")
	_build_visual()
	set_open(is_open)


func _material(color: Color, transparent := false) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.88
	if transparent:
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		material.shading_mode = BaseMaterial3D.SHADING_MODE_PER_PIXEL
	return material


func _box(parent: Node3D, node_name: String, size: Vector3, at: Vector3, color: Color, transparent := false) -> MeshInstance3D:
	var mesh_node := MeshInstance3D.new()
	mesh_node.name = node_name
	var box := BoxMesh.new()
	box.size = size
	mesh_node.mesh = box
	mesh_node.position = at
	mesh_node.material_override = _material(color, transparent)
	parent.add_child(mesh_node)
	return mesh_node


func _add_collider(size: Vector3, at: Vector3) -> void:
	_add_collider_to(self, size, at)


func _add_collider_to(parent: Node3D, size: Vector3, at: Vector3) -> void:
	var body := StaticBody3D.new()
	body.name = "PropCollision"
	body.collision_layer = 1
	body.collision_mask = 0
	var shape_node := CollisionShape3D.new()
	shape_node.name = "PropCollisionShape"
	var shape := BoxShape3D.new()
	shape.size = size
	shape_node.shape = shape
	shape_node.position = at
	body.add_child(shape_node)
	parent.add_child(body)


func _add_model(model_path: String, model_name: String, uniform_scale: float) -> void:
	var scene := load(model_path) as PackedScene
	if scene == null:
		push_warning("Não foi possível carregar o modelo do prop: " + model_path)
		return
	var model := scene.instantiate() as Node3D
	model.name = model_name
	model.scale = Vector3.ONE * uniform_scale
	add_child(model)


func _build_visual() -> void:
	match prop_id:
		"porta":
			_box(self, "FrameLeft", Vector3(0.10, 2.05, 0.12), Vector3(-0.49, 1.02, 0.0), Color("6b452c"))
			_box(self, "FrameRight", Vector3(0.10, 2.05, 0.12), Vector3(0.49, 1.02, 0.0), Color("6b452c"))
			_moving_panel = Node3D.new()
			_moving_panel.name = "DoorLeaf"
			_moving_panel.position = Vector3(-0.43, 0.0, 0.0)
			add_child(_moving_panel)
			_box(_moving_panel, "DoorPanel", Vector3(0.86, 1.94, 0.09), Vector3(0.43, 1.0, 0.0), Color("9b6b3e"))
			for y: float in [0.45, 1.0, 1.55]:
				_box(_moving_panel, "DoorPlank", Vector3(0.82, 0.035, 0.105), Vector3(0.43, y, 0.0), Color("684329"))
			_box(_moving_panel, "DoorHandle", Vector3(0.06, 0.12, 0.06), Vector3(0.76, 1.0, -0.075), Color("d3ad5b"))
			_add_collider_to(_moving_panel, Vector3(0.86, 1.94, 0.12), Vector3(0.43, 1.0, 0.0))
		"alcapao":
			_moving_panel = Node3D.new()
			_moving_panel.name = "TrapdoorLeaf"
			_moving_panel.position = Vector3(0.0, 0.13, -0.42)
			add_child(_moving_panel)
			_box(_moving_panel, "TrapdoorPanel", Vector3(0.94, 0.13, 0.84), Vector3(0.0, 0.0, 0.42), Color("94643a"))
			for x: float in [-0.25, 0.0, 0.25]:
				_box(_moving_panel, "TrapdoorPlank", Vector3(0.045, 0.15, 0.82), Vector3(x, 0.0, 0.42), Color("64432d"))
			_add_collider_to(_moving_panel, Vector3(0.94, 0.13, 0.84), Vector3(0.0, 0.0, 0.42))
		"janela":
			_moving_panel = Node3D.new()
			_moving_panel.name = "WindowLeaf"
			_moving_panel.position = Vector3(-0.45, 0.0, 0.0)
			add_child(_moving_panel)
			_box(_moving_panel, "GlassPane", Vector3(0.78, 0.78, 0.09), Vector3(0.45, 0.50, 0.0), Color(0.48, 0.80, 0.91, 0.50), true)
			_box(_moving_panel, "WindowFrameLeft", Vector3(0.09, 1.0, 0.13), Vector3(0.045, 0.50, 0.0), Color("835d39"))
			_box(_moving_panel, "WindowFrameRight", Vector3(0.09, 1.0, 0.13), Vector3(0.855, 0.50, 0.0), Color("835d39"))
			for y: float in [0.05, 0.95]:
				_box(_moving_panel, "WindowFrame", Vector3(0.90, 0.09, 0.13), Vector3(0.45, y, 0.0), Color("835d39"))
			_box(_moving_panel, "WindowCrossbar", Vector3(0.78, 0.055, 0.12), Vector3(0.45, 0.50, 0.0), Color("835d39"))
			_add_collider_to(_moving_panel, Vector3(0.92, 0.92, 0.12), Vector3(0.45, 0.50, 0.0))
		"cama":
			_add_model(BED_MODEL, "KenneySingleBed", BED_SCALE)
			_add_collider(Vector3(0.98, 0.58, 1.88) * BED_SCALE, Vector3(0.0, 0.29 * BED_SCALE, 0.0))
		"bedroll":
			_add_model(BEDROLL_MODEL, "KenneyBedroll", 1.0)
			_add_collider(Vector3(0.95, 0.24, 1.72), Vector3(0.0, 0.12, 0.0))
		"barraca":
			for x: float in [-1.25, 1.25]:
				for z: float in [-1.05, 1.05]:
					_box(self, "TentPole", Vector3(0.12, 2.05, 0.12), Vector3(x, 1.02, z), Color("704a30"))
					_add_collider(Vector3(0.14, 2.05, 0.14), Vector3(x, 1.02, z))
			_box(self, "TentCanopy", Vector3(3.1, 0.22, 2.8), Vector3(0.0, 2.05, 0.0), Color("d7b979"))
			for x: float in [-0.9, 0.0, 0.9]:
				_box(self, "TentStripe", Vector3(0.92, 0.035, 2.76), Vector3(x, 2.18, 0.0), Color("b94c43") if x != 0.0 else Color("eee1bf"))
			_box(self, "TentCounter", Vector3(2.2, 0.75, 0.55), Vector3(0.0, 0.38, -0.78), Color("94623c"))
			_box(self, "TentCounterTop", Vector3(2.32, 0.1, 0.65), Vector3(0.0, 0.8, -0.78), Color("c09358"))
			_add_collider(Vector3(2.2, 0.75, 0.55), Vector3(0.0, 0.38, -0.78))
		"fornalha":
			_box(self, "FurnaceBody", Vector3(0.88, 0.88, 0.88), Vector3(0.0, 0.46, 0.0), Color("777b80"))
			_box(self, "FurnaceMouth", Vector3(0.42, 0.34, 0.035), Vector3(0.0, 0.48, -0.46), Color("20252a"))
			_box(self, "FurnaceEmber", Vector3(0.22, 0.12, 0.045), Vector3(0.0, 0.32, -0.49), Color("e77732"))
			_box(self, "FurnaceTop", Vector3(0.66, 0.05, 0.66), Vector3(0.0, 0.92, 0.0), Color("96999b"))
			_add_collider(Vector3(0.9, 0.92, 0.9), Vector3(0.0, 0.46, 0.0))
			_fire_light = OmniLight3D.new()
			_fire_light.name = "FurnaceLight"
			_fire_light.position = Vector3(0.0, 0.43, -0.62)
			_fire_light.light_color = Color("ff883c")
			_fire_light.light_energy = 0.0
			_fire_light.omni_range = 3.0
			add_child(_fire_light)
		"mesa_craft":
			_box(self, "TableBody", Vector3(0.96, 0.82, 0.96), Vector3(0.0, 0.43, 0.0), Color("875b39"))
			_box(self, "TableTop", Vector3(1.0, 0.12, 1.0), Vector3(0.0, 0.90, 0.0), Color("bb8750"))
			_box(self, "CraftMark", Vector3(0.58, 0.025, 0.58), Vector3(0.0, 0.97, 0.0), Color("6d492f"))
			_add_collider(Vector3(0.96, 0.96, 0.96), Vector3(0.0, 0.48, 0.0))
		"bau":
			_add_model(CHEST_MODEL, "CubeWorldWoodChest", 1.0)
			_add_collider(Vector3(0.9, 0.9, 0.9), Vector3(0.0, 0.45, 0.0))
		"caixote":
			_add_model(CRATE_MODEL, "CubeWorldCrate", 1.0)
			_add_collider(Vector3(0.9, 0.9, 0.9), Vector3(0.0, 0.45, 0.0))
		"tocha", "fogueira", "lanterna_cristal":
			var base_color := Color("5b3d2a") if prop_id != "lanterna_cristal" else Color("6752a3")
			_box(self, "LightBase", Vector3(0.34, 0.28, 0.34), Vector3(0.0, 0.14, 0.0), base_color)
			_box(self, "LightCore", Vector3(0.22, 0.36, 0.22), Vector3(0.0, 0.43, 0.0), Color("eaa64f") if prop_id != "lanterna_cristal" else Color("85e4ff"))
			var light := OmniLight3D.new()
			light.name = "CampfireLight" if prop_id == "fogueira" else "PropLight"
			light.position.y = 0.62
			light.light_color = Color("ffb45a") if prop_id != "lanterna_cristal" else Color("a7e7ff")
			light.light_energy = 2.0 if prop_id == "fogueira" else 1.1
			light.omni_range = 10.0 if prop_id == "fogueira" else 4.0
			add_child(light)
			_add_collider(Vector3(0.38, 0.8, 0.38), Vector3(0.0, 0.4, 0.0))
		_:
			_box(self, "PropBody", Vector3(0.8, 0.8, 0.8), Vector3(0.0, 0.4, 0.0), Color("88745b"))
			_add_collider(Vector3(0.8, 0.8, 0.8), Vector3(0.0, 0.4, 0.0))


func set_open(value: bool) -> void:
	is_open = value
	if _moving_panel == null:
		return
	if prop_id == "porta":
		_moving_panel.rotation.y = -PI * 0.5 if is_open else 0.0
	elif prop_id == "alcapao":
		_moving_panel.rotation.x = -PI * 0.5 if is_open else 0.0
	elif prop_id == "janela":
		_moving_panel.rotation.y = -PI * 0.5 if is_open else 0.0


func toggle_open(actor: Node) -> bool:
	if not actor is ByteCrafterPlayer:
		return is_open
	set_open(not is_open)
	return is_open


func set_furnace_lit(value: bool) -> void:
	if _fire_light != null:
		_fire_light.light_energy = 1.1 if value else 0.0


func serialize_state() -> Dictionary:
	return {
		"id": prop_id,
		"position": [cell.x, cell.y, cell.z],
		"rotation_y": rotation.y,
		"open": is_open,
		"furnace": furnace_state.duplicate(true),
	}
