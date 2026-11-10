extends Node3D
class_name ByteCrafterWorld

signal chunk_ready(chunk_coord: Vector2i)
signal blocks_changed
signal fallen_fruit_generated(cell: Vector3i)

const CHUNK_SIZE := 16
const WORLD_HEIGHT := 40
const STREAM_RADIUS := 2
const SPAWN_CLEAR_RADIUS := 7
const WATER_LEVEL := 7
const BLOCK_WATER := 14
const MAX_BLOCK_ID := 48
const SAVE_PATH := "user://bytecrafter_world.json"
const TEMP_SAVE_PATH := "user://bytecrafter_world.json.tmp"
const MAX_SAVED_OVERRIDES := 250000
const BLOCK_NAMES := {
	0: "Ar",
	1: "Grama",
	2: "Terra",
	3: "Pedra",
	4: "Tronco",
	5: "Folhas",
	6: "Areia",
	7: "Tábuas",
	8: "Musgo",
	9: "Gelo",
	10: "Basalto",
	11: "Cristal",
	12: "Pedra antiga",
	13: "Minério brilhante",
	14: "Água",
	21: "Tijolos",
	22: "Tijolos cinzentos",
	23: "Carvão",
	24: "Bloco de cristal",
	25: "Diamante",
	26: "Pedra talhada",
	27: "Planta de cenoura",
	28: "Planta de tomate",
	29: "Pé de milho",
	30: "Alface",
	31: "Repolho",
		32: "Fruta caída",
		34: "Cogumelo",
		35: "Bambu",
		36: "Flores",
		37: "Bloco de grama Cube World",
		38: "Bloco de terra Cube World",
		39: "Bloco de pedra Cube World",
		40: "Bloco de tijolos Cube World",
		41: "Bloco de tábuas Cube World",
		42: "Bloco de gelo Cube World",
		43: "Bloco de neve Cube World",
		44: "Bloco de cristal Cube World",
		45: "Bloco de diamante Cube World",
		46: "Bloco de carvão Cube World",
		47: "Bloco de tijolos cinzentos Cube World",
		48: "Bloco de metal Cube World",
}
const PLANT_BLOCK_MODELS := {
	27: preload("res://assets/bitmal/Carrot by Kenney - 59muuwqSsq.glb"),
	28: preload("res://assets/bitmal/Tomato by Kenney - TZWJgWJs8V.glb"),
	29: preload("res://assets/bitmal/Corn by Kenney - NaEnzEW0JQ.glb"),
	30: preload("res://assets/bitmal/Lettuce by Quaternius - MEmUwHUHNR.glb"),
	31: preload("res://assets/bitmal/Cabbage by Kenney - 6urnIRBhzr.glb"),
	34: preload("res://assets/userpack/cubeworld/Mushroom.glb"),
	35: preload("res://assets/userpack/cubeworld/Bamboo.glb"),
	36: preload("res://assets/userpack/cubeworld/Flowers.glb"),
}
const CUBE_BLOCK_MODELS := {
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
const FALLEN_FRUIT_MODELS := [
	preload("res://assets/bitmal/Apple Green by Quaternius - 3VXWnjDOEw.glb"),
	preload("res://assets/bitmal/Banana by Kenney - 5Z07I9KMob.glb"),
	preload("res://assets/bitmal/Orange by Kenney - UnygaDfm1J.glb"),
	preload("res://assets/bitmal/Pear by Kenney - 6arz55szEl.glb"),
]
const PLANTABLE_GROUND_IDS := [1, 2, 8]
const PROCEDURAL_PLANT_BLOCKS := [27, 28, 29, 30, 31]
const BLOCK_COLORS := {
	1: Color("79a95a"),
	2: Color("8f6242"),
	3: Color("777c82"),
	4: Color("91633f"),
	5: Color("4f8b4c"),
	6: Color("d2bd82"),
	7: Color("bd8c50"),
	8: Color("4f9b67"),
	9: Color("b8e6f2"),
	10: Color("3e414b"),
	11: Color("9f7bea"),
	12: Color("806c58"),
	13: Color("e2b75a"),
	14: Color("3e9bd1"),
	21: Color("a95f4a"),
	22: Color("7e858d"),
	23: Color("20252e"),
	24: Color("6e54c7"),
	25: Color("54d8e8"),
	26: Color("9b9da5"),
	27: Color("78a94d"), 28: Color("6f9d45"), 29: Color("78a94d"),
	30: Color("62a957"), 31: Color("5b963f"), 32: Color("b88141"),
	34: Color("d36a48"), 35: Color("70a54d"), 36: Color("eaa9d6"),
	37: Color("79a95a"), 38: Color("8f6242"), 39: Color("777c82"), 40: Color("a95f4a"),
	41: Color("bd8c50"), 42: Color("b8e6f2"), 43: Color("e6eef3"), 44: Color("6e54c7"),
	45: Color("54d8e8"), 46: Color("20252e"), 47: Color("7e858d"), 48: Color("78818e"),
}
const BLOCK_ATLAS_TILES := {
	1: [16, 16, 0, 17, 16, 16],
	2: [18, 18, 18, 18, 18, 18],
	3: [32, 32, 32, 32, 32, 32],
	4: [2, 2, 18, 18, 2, 2],
	5: [12, 13, 12, 14, 12, 13],
	6: [16, 16, 16, 16, 16, 16],
	7: [18, 18, 18, 18, 18, 18],
	8: [12, 13, 12, 13, 12, 13],
	9: [51, 51, 51, 51, 51, 51],
	10: [34, 34, 34, 34, 34, 34],
	11: [53, 53, 53, 53, 53, 53],
	12: [32, 32, 32, 32, 32, 32],
	13: [44, 44, 44, 44, 44, 44],
	14: [50, 50, 50, 50, 50, 50],
	21: [44, 44, 44, 44, 44, 44],
	22: [32, 32, 32, 32, 32, 32],
	23: [72, 72, 72, 72, 72, 72],
	24: [54, 54, 54, 54, 54, 54],
	25: [51, 51, 51, 51, 51, 51],
	26: [34, 34, 34, 34, 34, 34],
}
const ATLAS_COLUMNS := 16
const ATLAS_ROWS := 16
const ATLAS_PIXEL_DIMENSION := 512.0
const FACE_DIRS := [
	Vector3i(1, 0, 0), Vector3i(-1, 0, 0),
	Vector3i(0, 1, 0), Vector3i(0, -1, 0),
	Vector3i(0, 0, 1), Vector3i(0, 0, -1),
]

var world_seed: int = 0
var _terrain_noise := FastNoiseLite.new()
var _height_cache: Dictionary = {}
var _cave_noise := FastNoiseLite.new()
var _biome_noise := FastNoiseLite.new()
var _chunks: Dictionary = {}
var _chunk_queue: Array[Vector2i] = []
var _queued: Dictionary = {}
var _overrides: Dictionary = {}
var _overrides_by_chunk: Dictionary = {}
var _override_chunk_buffers: Dictionary = {}
var _tree_blocks: Dictionary = {}
var _flora_blocks: Dictionary = {}
var _fallen_fruit_cells: Dictionary = {}
var _built_flora_chunks: Dictionary = {}
var _structure_cells: Dictionary = {}
var _village_structure_cells: Dictionary = {}
var _village_structures_by_owner: Dictionary = {}
var _built_structure_chunks: Dictionary = {}
var _built_tree_chunks: Dictionary = {}
var _center_chunk := Vector2i(999999, 999999)
var _spawn_column := Vector2i.ZERO
var _voxel_material := StandardMaterial3D.new()
var _water_material: ShaderMaterial
var _stream_radius := STREAM_RADIUS
var _chunk_worker: Thread
var _worker_coord := Vector2i.ZERO
var _worker_revision := -1
var _worker_stream_epoch := -1
var _world_revision := 0
var _stream_epoch := 0
var _async_chunks_installed := 0


func _ready() -> void:
	_voxel_material.albedo_texture = load("res://assets/textures/voxel_atlas.png")
	_voxel_material.vertex_color_use_as_albedo = true
	_voxel_material.roughness = 1.0
	_voxel_material.metallic = 0.0
	_voxel_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	_voxel_material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	_voxel_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
	_voxel_material.alpha_scissor_threshold = 0.18
	_water_material = ShaderMaterial.new()
	var water_shader := Shader.new()
	water_shader.code = """
	shader_type spatial;
	render_mode blend_mix, cull_disabled, diffuse_burley, specular_schlick_ggx;

	uniform vec4 water_tint : source_color = vec4(0.08, 0.48, 0.78, 0.68);

	void vertex() {
		vec3 world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
		if (VERTEX.y > 0.72) {
			VERTEX.y += sin(world_position.x * 1.7 + TIME * 1.35) * 0.035;
			VERTEX.y += cos(world_position.z * 1.45 + TIME * 1.10) * 0.025;
		}
	}

	void fragment() {
		float ripple = sin((UV.x + UV.y) * 7.0 + TIME * 1.8) * 0.5 + 0.5;
		ALBEDO = mix(water_tint.rgb, vec3(0.34, 0.78, 0.96), ripple * 0.14);
		ALPHA = water_tint.a;
		ROUGHNESS = 0.08;
		METALLIC = 0.0;
	}
	"""
	_water_material.shader = water_shader


func configure(seed_value: int, saved_overrides: Array = [], radius: int = STREAM_RADIUS) -> void:
	_world_revision += 1
	_stream_epoch += 1
	world_seed = seed_value
	_stream_radius = clampi(radius, 1, 4)
	_terrain_noise.seed = world_seed
	_terrain_noise.frequency = 0.028
	_terrain_noise.fractal_octaves = 4
	_terrain_noise.fractal_gain = 0.48
	_terrain_noise.fractal_lacunarity = 2.0
	_cave_noise.seed = world_seed ^ 0x5f3759df
	_cave_noise.frequency = 0.065
	_cave_noise.fractal_octaves = 2
	_biome_noise.seed = world_seed ^ 0x13579bdf
	_biome_noise.frequency = 0.012
	_biome_noise.fractal_octaves = 2
	_height_cache.clear()
	_spawn_column = _select_spawn_column()
	_overrides.clear()
	_overrides_by_chunk.clear()
	_override_chunk_buffers.clear()
	_tree_blocks.clear()
	_flora_blocks.clear()
	_fallen_fruit_cells.clear()
	_built_flora_chunks.clear()
	_built_tree_chunks.clear()
	_structure_cells.clear()
	_village_structure_cells.clear()
	_village_structures_by_owner.clear()
	_built_structure_chunks.clear()
	var accepted := 0
	for entry: Variant in saved_overrides:
		if accepted >= MAX_SAVED_OVERRIDES:
			break
		if not entry is Array or entry.size() < 4:
			continue
		var coords := Vector3i(int(entry[0]), int(entry[1]), int(entry[2]))
		var block_id := int(entry[3])
		if coords.y < 0 or coords.y > WORLD_HEIGHT + 8 or absi(coords.x) > 1000000 or absi(coords.z) > 1000000:
			continue
		if block_id < 0 or block_id > MAX_BLOCK_ID:
			continue
		_overrides[coords] = block_id
		var chunk_coord := _override_chunk_coord(coords)
		var chunk_overrides: Dictionary = _overrides_by_chunk.get(chunk_coord, {})
		chunk_overrides[coords] = block_id
		_overrides_by_chunk[chunk_coord] = chunk_overrides
		accepted += 1
	for chunk_coord: Vector2i in _overrides_by_chunk.keys():
		_rebuild_override_chunk_buffer(chunk_coord)
	_center_chunk = Vector2i(999999, 999999)
	update_streaming(get_spawn_position())
	_sanitize_leaf_overrides()


func set_stream_radius(radius: int, world_position: Vector3) -> void:
	var next_radius := clampi(radius, 1, 4)
	if next_radius == _stream_radius:
		return
	_stream_radius = next_radius
	_center_chunk = Vector2i(999999, 999999)
	update_streaming(world_position)


func update_streaming(world_position: Vector3) -> void:
	var center := Vector2i(floori(world_position.x / CHUNK_SIZE), floori(world_position.z / CHUNK_SIZE))
	if center == _center_chunk:
		return
	_stream_epoch += 1
	_center_chunk = center
	# Bound procedural caches to the active streaming area. Tree edits are kept
	# in _overrides, so clearing this derived cache does not regrow mined blocks.
	_height_cache.clear()
	_tree_blocks.clear()
	_flora_blocks.clear()
	_fallen_fruit_cells.clear()
	_built_flora_chunks.clear()
	_built_tree_chunks.clear()
	_structure_cells.clear()
	_built_structure_chunks.clear()
	var keep_distance := _stream_radius + 1
	var retained_queue: Array[Vector2i] = []
	_queued.clear()
	for queued_coord: Vector2i in _chunk_queue:
		if absi(queued_coord.x - center.x) <= keep_distance and absi(queued_coord.y - center.y) <= keep_distance:
			retained_queue.append(queued_coord)
			_queued[queued_coord] = true
	_chunk_queue = retained_queue
	# Cache trees for the visible ring as well as the chunks being generated,
	# because retained edge chunks may contain trees rooted just across a border.
	for x: int in range(center.x - keep_distance, center.x + keep_distance + 1):
		for z: int in range(center.y - keep_distance, center.y + keep_distance + 1):
			var coord := Vector2i(x, z)
			_populate_tree_cache(coord)
			_populate_flora_cache(coord)
			if absi(x - center.x) <= _stream_radius and absi(z - center.y) <= _stream_radius:
				_enqueue_chunk(coord)
	for key: Variant in _chunks.keys():
		var coord: Vector2i = key
		if absi(coord.x - center.x) > keep_distance or absi(coord.y - center.y) > keep_distance:
			var old_chunk: Node = _chunks[coord]
			_chunks.erase(coord)
			old_chunk.queue_free()
	_chunk_queue.sort_custom(func(a: Vector2i, b: Vector2i) -> bool:
		return _chunk_distance_sq(a, center) < _chunk_distance_sq(b, center)
	)
	# The chunk under the player must never depend on the asynchronous queue.
	# Build it immediately when entering a new chunk; surrounding chunks can stream
	# one per frame without leaving a temporary hole directly beneath the player.
	if not _chunks.has(center):
		_build_chunk(center)


func _process(_delta: float) -> void:
	if _chunk_worker != null:
		if _chunk_worker.is_alive():
			return
		var result: Variant = _chunk_worker.wait_to_finish()
		_chunk_worker = null
		if result is Dictionary:
			var coord: Vector2i = result.get("coord", _worker_coord)
			var in_range := absi(coord.x - _center_chunk.x) <= _stream_radius + 1 and absi(coord.y - _center_chunk.y) <= _stream_radius + 1
			var current := int(result.get("world_revision", -1)) == _world_revision and int(result.get("stream_epoch", -1)) == _stream_epoch
			if in_range and current and not _chunks.has(coord):
				_install_chunk_geometry(coord, result)
				if _chunks.has(coord):
					_async_chunks_installed += 1
			elif in_range and not _chunks.has(coord):
				_enqueue_chunk(coord)
	if _chunk_worker != null or _chunk_queue.is_empty():
		return
	var next_coord: Vector2i = _chunk_queue.pop_front()
	_queued.erase(next_coord)
	if absi(next_coord.x - _center_chunk.x) > _stream_radius + 1 or absi(next_coord.y - _center_chunk.y) > _stream_radius + 1 or _chunks.has(next_coord):
		return
	var snapshot := _sample_chunk_snapshot(next_coord)
	_worker_coord = next_coord
	_worker_revision = _world_revision
	_worker_stream_epoch = _stream_epoch
	_chunk_worker = Thread.new()
	var error := _chunk_worker.start(Callable(self, "_thread_compute_chunk").bind(next_coord, snapshot, _world_revision, _stream_epoch))
	if error != OK:
		_chunk_worker = null
		_build_chunk(next_coord)


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE and _chunk_worker != null and _chunk_worker.is_started():
		_chunk_worker.wait_to_finish()


func _chunk_distance_sq(a: Vector2i, b: Vector2i) -> int:
	return (a.x - b.x) * (a.x - b.x) + (a.y - b.y) * (a.y - b.y)


func _enqueue_chunk(coord: Vector2i) -> void:
	if _chunks.has(coord) or _queued.has(coord):
		return
	_queued[coord] = true
	_chunk_queue.append(coord)


func _populate_tree_cache(chunk_coord: Vector2i) -> void:
	if _built_tree_chunks.has(chunk_coord):
		return
	_built_tree_chunks[chunk_coord] = true
	var start_x := chunk_coord.x * CHUNK_SIZE - 2
	var end_x := (chunk_coord.x + 1) * CHUNK_SIZE + 2
	var start_z := chunk_coord.y * CHUNK_SIZE - 2
	var end_z := (chunk_coord.y + 1) * CHUNK_SIZE + 2
	for x: int in range(start_x, end_x):
		for z: int in range(start_z, end_z):
			if not _is_tree_root(x, z):
				continue
			var ground := terrain_height(x, z)
			for y: int in range(ground + 1, ground + 5):
				_tree_blocks[Vector3i(x, y, z)] = 4
			var crown_y := ground + 4
			for y: int in range(crown_y, crown_y + 3):
				var radius := 2 if y >= crown_y + 1 else 1
				for dx: int in range(-radius, radius + 1):
						for dz: int in range(-radius, radius + 1):
							if absi(dx) + absi(dz) <= radius + 1:
								var leaf_pos := Vector3i(x + dx, y, z + dz)
								# Copas em encostas não podem substituir terreno sólido.
								if not _tree_blocks.has(leaf_pos) and _base_block(leaf_pos) == 0:
									_tree_blocks[leaf_pos] = 5


func _populate_flora_cache(chunk_coord: Vector2i) -> void:
	if _built_flora_chunks.has(chunk_coord):
		return
	_built_flora_chunks[chunk_coord] = true
	var start_x := chunk_coord.x * CHUNK_SIZE
	var start_z := chunk_coord.y * CHUNK_SIZE
	for x: int in range(start_x, start_x + CHUNK_SIZE):
		for z: int in range(start_z, start_z + CHUNK_SIZE):
			if Vector2(float(x - _spawn_column.x), float(z - _spawn_column.y)).length() < float(SPAWN_CLEAR_RADIUS + 4):
				continue
			var ground_y := terrain_height(x, z)
			var ground_cell := Vector3i(x, ground_y, z)
			if get_block_at(ground_cell) not in PLANTABLE_GROUND_IDS:
				continue
			var plant_cell := Vector3i(x, ground_y + 1, z)
			var plant_roll := _flora_hash(x, z, 11)
			if get_block_at(plant_cell) == 0 and _flora_hash(x, z, 71) % 1700 == 0:
				_flora_blocks[plant_cell] = 34
			elif get_block_at(plant_cell) == 0 and _flora_hash(x, z, 73) % 2300 == 0:
				_flora_blocks[plant_cell] = 35
			elif get_block_at(plant_cell) == 0 and _flora_hash(x, z, 79) % 900 == 0:
				_flora_blocks[plant_cell] = 36
			elif plant_roll % 1130 == 0 and get_block_at(plant_cell) == 0:
				_flora_blocks[plant_cell] = int(PROCEDURAL_PLANT_BLOCKS[posmod(floori(float(plant_roll) / 1130.0), PROCEDURAL_PLANT_BLOCKS.size())])
	# A cada algumas árvores, deixa uma fruta caída encostada à base do tronco.
	for x: int in range(start_x - 2, start_x + CHUNK_SIZE + 2):
		for z: int in range(start_z - 2, start_z + CHUNK_SIZE + 2):
			if not _is_tree_root(x, z) or _flora_hash(x, z, 23) % 30 != 0:
				continue
			var offsets := [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]
			var offset: Vector2i = offsets[posmod(_flora_hash(x, z, 37), offsets.size())]
			var fruit_x := x + offset.x
			var fruit_z := z + offset.y
			var fruit_ground := terrain_height(fruit_x, fruit_z)
			var fruit_cell := Vector3i(fruit_x, fruit_ground + 1, fruit_z)
			if get_block_at(Vector3i(fruit_x, fruit_ground, fruit_z)) in PLANTABLE_GROUND_IDS and get_block_at(fruit_cell) == 0 and not _overrides.has(fruit_cell):
				_fallen_fruit_cells[fruit_cell] = true
				fallen_fruit_generated.emit(fruit_cell)


func mark_fruit_collected(cell: Vector3i) -> void:
	_fallen_fruit_cells.erase(cell)
	_set_override(cell, 0)
	_world_revision += 1
	blocks_changed.emit()


func _flora_hash(x: int, z: int, salt: int) -> int:
	var value := float(x) * 127.1 + float(z) * 311.7 + float(world_seed) * 0.173 + float(salt) * 74.7
	return int(absf(sin(value) * 43758.5453))


func _populate_structure_cache(chunk_coord: Vector2i) -> void:
	if _built_structure_chunks.has(chunk_coord):
		return
	_built_structure_chunks[chunk_coord] = true
	var hash_value := absi(chunk_coord.x * 92821 + chunk_coord.y * 68917 + world_seed * 31)
	if hash_value % 13 != 0:
		return
	var center_x := chunk_coord.x * CHUNK_SIZE + 8
	var center_z := chunk_coord.y * CHUNK_SIZE + 8
	if Vector2(center_x - _spawn_column.x, center_z - _spawn_column.y).length() < 24.0:
		return
	var ground := terrain_height(center_x, center_z)
	var structure_block := 21 if get_biome(center_x, center_z) in ["plains", "mossland"] else 22
	if get_biome(center_x, center_z) == "crystal":
		structure_block = 24
	if get_biome(center_x, center_z) == "volcanic":
		structure_block = 23
	for dx: int in range(-2, 3):
		for dz: int in range(-2, 3):
			if absi(dx) == 2 or absi(dz) == 2:
				_structure_cells[Vector3i(center_x + dx, ground + 1, center_z + dz)] = structure_block
	for tower_height: int in range(1, 4):
		_structure_cells[Vector3i(center_x, ground + tower_height, center_z)] = structure_block
	_structure_cells[Vector3i(center_x, ground + 4, center_z)] = 25 if structure_block == 24 else 26


func get_biome(x: int, z: int) -> String:
	var climate := _biome_noise.get_noise_2d(float(x), float(z))
	if climate > 0.58:
		return "crystal"
	if climate < -0.62:
		return "volcanic"
	if climate < -0.18:
		return "frozen"
	if climate > 0.18:
		return "mossland"
	return "plains"


func _is_tree_root(x: int, z: int) -> bool:
	if absi(x - _spawn_column.x) <= SPAWN_CLEAR_RADIUS and absi(z - _spawn_column.y) <= SPAWN_CLEAR_RADIUS:
		return false
	var height := terrain_height(x, z)
	if height < 7 or height > WORLD_HEIGHT - 8:
		return false
	if _base_block(Vector3i(x, height, z)) != 1:
		return false
	var seed_value := float(x * 127 + z * 311 + world_seed * 17)
	var roll := int(absf(sin(seed_value * 0.0174533) * 43758.5453)) % 37
	return roll == 0


func terrain_height(x: int, z: int) -> int:
	var key := Vector2i(x, z)
	if _height_cache.has(key):
		return int(_height_cache[key])
	var broad := _terrain_noise.get_noise_2d(float(x), float(z))
	var ridge := sin(float(x) * 0.065 + float(world_seed % 97)) * cos(float(z) * 0.053)
	var result := clampi(10 + roundi(broad * 7.0 + ridge * 2.0), 4, WORLD_HEIGHT - 7)
	_height_cache[key] = result
	return result


func _select_spawn_column() -> Vector2i:
	var best := Vector2i.ZERO
	var best_score: float = INF
	for x: int in range(-12, 13, 2):
		for z: int in range(-12, 13, 2):
			var center_height := terrain_height(x, z)
			var min_height := center_height
			var max_height := center_height
			var height_deviation := 0.0
			for dx: int in range(-4, 5, 2):
				for dz: int in range(-4, 5, 2):
					var neighbor_height := terrain_height(x + dx, z + dz)
					min_height = mini(min_height, neighbor_height)
					max_height = maxi(max_height, neighbor_height)
					height_deviation += absf(float(neighbor_height - center_height))
			var distance_penalty := Vector2(float(x), float(z)).length() * 0.035
			var score := float(max_height - min_height) * 4.0 + height_deviation + distance_penalty
			if score < best_score:
				best_score = score
				best = Vector2i(x, z)
	return best


func get_block_at(coords: Vector3i) -> int:
	if coords.y < 0 or coords.y > WORLD_HEIGHT:
		return 0
	if _overrides.has(coords):
		var override_id := int(_overrides[coords])
		# Perfis antigos podem conter folhas colocadas no chão. Nunca as
		# devolva ao renderer fora de uma célula de copa procedural válida.
		if override_id == 5 and int(_tree_blocks.get(coords, 0)) != 5:
			return _base_block(coords)
		return override_id
	if _village_structure_cells.has(coords):
		return int(_village_structure_cells[coords])
	if _tree_blocks.has(coords):
		return int(_tree_blocks[coords])
	if _structure_cells.has(coords):
		return int(_structure_cells[coords])
	if _flora_blocks.has(coords):
		return int(_flora_blocks[coords])
	return _base_block(coords)


func get_water_surface_height_at(world_position: Vector3) -> float:
	var x := floori(world_position.x)
	var z := floori(world_position.z)
	var bottom_y := maxi(0, terrain_height(x, z) + 1)
	for y: int in range(WATER_LEVEL, bottom_y - 1, -1):
		if get_block_at(Vector3i(x, y, z)) == BLOCK_WATER:
			return float(y) + 0.88
	return -INF


func is_actor_in_water(actor_position: Vector3, actor_height: float) -> bool:
	var surface := get_water_surface_height_at(actor_position)
	if not is_finite(surface):
		return false
	var water_bottom := float(terrain_height(floori(actor_position.x), floori(actor_position.z)) + 1)
	return actor_position.y < surface and actor_position.y + maxf(actor_height, 0.1) > water_bottom


func _base_block(coords: Vector3i) -> int:
	var height := terrain_height(coords.x, coords.z)
	if coords.y > height:
		if coords.y <= WATER_LEVEL and height < WATER_LEVEL:
			return BLOCK_WATER
		return 0
	if coords.y > 2 and coords.y < height - 3 and _cave_noise.get_noise_3d(float(coords.x), float(coords.y), float(coords.z)) > 0.52:
		return 0
	var biome := get_biome(coords.x, coords.z)
	if coords.y == height:
		if biome == "frozen":
			return 9
		if biome == "volcanic":
			return 10
		if biome == "crystal":
			return 11
		if biome == "mossland":
			return 8
		return 6 if height <= 7 else 1
	if coords.y >= height - 3:
		return 10 if biome == "volcanic" and coords.y == height - 1 else 2
	return 3


func get_spawn_position() -> Vector3:
	var x := _spawn_column.x
	var z := _spawn_column.y
	return Vector3(float(x) + 0.5, float(terrain_height(x, z)) + 1.12, float(z) + 0.5)


func set_block_at(coords: Vector3i, block_id: int) -> bool:
	if coords.y < 0 or coords.y > WORLD_HEIGHT or block_id < 0 or block_id > MAX_BLOCK_ID:
		return false
	# Folhas são parte da copa procedural; não podem ser usadas como piso ou
	# colocadas livremente no mundo. Uma célula de copa ainda pode ser restaurada.
	if block_id == 5 and int(_tree_blocks.get(coords, 0)) != 5:
		return false
	if get_block_at(coords) == block_id:
		return false
	_set_override(coords, block_id)
	_world_revision += 1
	_rebuild_chunk_and_neighbours(coords)
	blocks_changed.emit()
	return true


func _sanitize_leaf_overrides() -> void:
	var invalid_leaf_cells: Array[Vector3i] = []
	for coords: Vector3i in _overrides.keys():
		if int(_overrides[coords]) == 5 and int(_tree_blocks.get(coords, 0)) != 5:
			invalid_leaf_cells.append(coords)
	for coords: Vector3i in invalid_leaf_cells:
		_erase_override(coords)
		_world_revision += 1
		_rebuild_chunk_and_neighbours(coords)


func _rebuild_chunk_and_neighbours(coords: Vector3i) -> void:
	var base := Vector2i(floori(float(coords.x) / CHUNK_SIZE), floori(float(coords.z) / CHUNK_SIZE))
	var candidates := [base]
	if posmod(coords.x, CHUNK_SIZE) == 0:
		candidates.append(base + Vector2i(-1, 0))
	elif posmod(coords.x, CHUNK_SIZE) == CHUNK_SIZE - 1:
		candidates.append(base + Vector2i(1, 0))
	if posmod(coords.z, CHUNK_SIZE) == 0:
		candidates.append(base + Vector2i(0, -1))
	elif posmod(coords.z, CHUNK_SIZE) == CHUNK_SIZE - 1:
		candidates.append(base + Vector2i(0, 1))
	for coord: Vector2i in candidates:
		if _chunks.has(coord):
			_build_chunk(coord)


## Registra a geometria procedural de uma vila sem transformá-la em milhares de
## overrides salvos. Os blocos podem incluir 0 para abrir portas, janelas e interior.
func register_village_structure(owner_key: String, blocks: Dictionary) -> void:
	if owner_key.is_empty():
		return
	var next_blocks: Dictionary = {}
	for cell_value: Variant in blocks.keys():
		if not cell_value is Vector3i:
			continue
		var cell: Vector3i = cell_value
		var block_id := int(blocks[cell_value])
		if cell.y < 0 or cell.y > WORLD_HEIGHT or block_id < 0 or block_id > MAX_BLOCK_ID:
			continue
		next_blocks[cell] = block_id
	var previous_blocks: Dictionary = _village_structures_by_owner.get(owner_key, {})
	if previous_blocks == next_blocks:
		return
	var changed_cells: Dictionary = {}
	for cell_value: Variant in previous_blocks.keys():
		var cell: Vector3i = cell_value
		var previous_id := int(previous_blocks[cell])
		if int(_village_structure_cells.get(cell, -1)) == previous_id:
			_village_structure_cells.erase(cell)
			changed_cells[cell] = true
	_village_structures_by_owner[owner_key] = next_blocks
	for cell_value: Variant in next_blocks.keys():
		var cell: Vector3i = cell_value
		var block_id := int(next_blocks[cell])
		if int(_village_structure_cells.get(cell, -1)) == block_id:
			continue
		_village_structure_cells[cell] = block_id
		changed_cells[cell] = true
	if not changed_cells.is_empty():
		_world_revision += 1
		_rebuild_village_structure_chunks(changed_cells.keys())
		blocks_changed.emit()


func unregister_village_structure(owner_key: String) -> void:
	if not _village_structures_by_owner.has(owner_key):
		return
	var previous_blocks: Dictionary = _village_structures_by_owner[owner_key]
	_village_structures_by_owner.erase(owner_key)
	var changed_cells: Dictionary = {}
	for cell_value: Variant in previous_blocks.keys():
		var cell: Vector3i = cell_value
		if int(_village_structure_cells.get(cell, -1)) == int(previous_blocks[cell]):
			_village_structure_cells.erase(cell)
			changed_cells[cell] = true
	if not changed_cells.is_empty():
		_world_revision += 1
		_rebuild_village_structure_chunks(changed_cells.keys())
		blocks_changed.emit()


func _rebuild_village_structure_chunks(cells: Array) -> void:
	var affected_chunks: Dictionary = {}
	for cell_value: Variant in cells:
		if not cell_value is Vector3i:
			continue
		var cell: Vector3i = cell_value
		var base := Vector2i(floori(float(cell.x) / CHUNK_SIZE), floori(float(cell.z) / CHUNK_SIZE))
		affected_chunks[base] = true
		if posmod(cell.x, CHUNK_SIZE) == 0:
			affected_chunks[base + Vector2i(-1, 0)] = true
		elif posmod(cell.x, CHUNK_SIZE) == CHUNK_SIZE - 1:
			affected_chunks[base + Vector2i(1, 0)] = true
		if posmod(cell.z, CHUNK_SIZE) == 0:
			affected_chunks[base + Vector2i(0, -1)] = true
		elif posmod(cell.z, CHUNK_SIZE) == CHUNK_SIZE - 1:
			affected_chunks[base + Vector2i(0, 1)] = true
	for chunk_value: Variant in affected_chunks.keys():
		var chunk_coord: Vector2i = chunk_value
		if _chunks.has(chunk_coord):
			_build_chunk(chunk_coord)


const _PAD_X := CHUNK_SIZE + 2
const _PAD_Z := CHUNK_SIZE + 2
const _PAD_Y := WORLD_HEIGHT + 3


static func _snapshot_index(local_x: int, y: int, local_z: int) -> int:
	return ((local_x + 1) * _PAD_Z + (local_z + 1)) * _PAD_Y + (y + 1)


## Amostra uma única vez todos os blocos do chunk com 1 bloco de margem em cada
## direção. A malha, as colisões e as faces de borda saem do mesmo snapshot, que
## por sua vez vem de get_block_at() (única fonte de verdade: overrides + árvores
## + estruturas + terreno procedural).
func _sample_chunk_snapshot(coord: Vector2i) -> PackedByteArray:
	var origin_x := coord.x * CHUNK_SIZE
	var origin_z := coord.y * CHUNK_SIZE
	var snapshot := PackedByteArray()
	snapshot.resize(_PAD_X * _PAD_Z * _PAD_Y)
	for local_x: int in range(-1, CHUNK_SIZE + 1):
		for local_z: int in range(-1, CHUNK_SIZE + 1):
			var x := origin_x + local_x
			var z := origin_z + local_z
			# y=-1 e y=WORLD_HEIGHT+1 ficam como ar (get_block_at já retorna 0).
			for y: int in range(0, WORLD_HEIGHT + 1):
				snapshot[_snapshot_index(local_x, y, local_z)] = get_block_at(Vector3i(x, y, z))
	return snapshot


func _build_chunk(coord: Vector2i) -> void:
	var snapshot := _sample_chunk_snapshot(coord)
	var geometry := _compute_chunk_geometry(coord, snapshot, _world_revision, _stream_epoch)
	_install_chunk_geometry(coord, geometry)


func _thread_compute_chunk(coord: Vector2i, snapshot: PackedByteArray, revision: int, epoch: int) -> Dictionary:
	return _compute_chunk_geometry(coord, snapshot, revision, epoch)


static func _compute_chunk_geometry(coord: Vector2i, snapshot: PackedByteArray, revision: int, epoch: int) -> Dictionary:
	var origin_x := coord.x * CHUNK_SIZE
	var origin_z := coord.y * CHUNK_SIZE
	var solid_vertices := PackedVector3Array()
	var solid_normals := PackedVector3Array()
	var solid_colors := PackedColorArray()
	var solid_uvs := PackedVector2Array()
	var water_vertices := PackedVector3Array()
	var water_normals := PackedVector3Array()
	var water_colors := PackedColorArray()
	var water_uvs := PackedVector2Array()
	var trunk_cells: Array[Vector3i] = []
	var plant_cells: Array[Dictionary] = []
	var triangle_order := [0, 1, 2, 0, 2, 3]
	var face_normals := [Vector3.RIGHT, Vector3.LEFT, Vector3.UP, Vector3.DOWN, Vector3.BACK, Vector3.FORWARD]
	var face_points := [
		[Vector3(1, 0, 0), Vector3(1, 1, 0), Vector3(1, 1, 1), Vector3(1, 0, 1)],
		[Vector3(0, 0, 0), Vector3(0, 0, 1), Vector3(0, 1, 1), Vector3(0, 1, 0)],
		[Vector3(0, 1, 0), Vector3(0, 1, 1), Vector3(1, 1, 1), Vector3(1, 1, 0)],
		[Vector3(0, 0, 0), Vector3(1, 0, 0), Vector3(1, 0, 1), Vector3(0, 0, 1)],
		[Vector3(0, 0, 1), Vector3(1, 0, 1), Vector3(1, 1, 1), Vector3(0, 1, 1)],
		[Vector3(0, 0, 0), Vector3(0, 1, 0), Vector3(1, 1, 0), Vector3(1, 0, 0)],
	]
	var water_face_points := [
		[Vector3(1, 0, 0), Vector3(1, 0.88, 0), Vector3(1, 0.88, 1), Vector3(1, 0, 1)],
		[Vector3(0, 0, 0), Vector3(0, 0, 1), Vector3(0, 0.88, 1), Vector3(0, 0.88, 0)],
		[Vector3(0, 0.88, 0), Vector3(0, 0.88, 1), Vector3(1, 0.88, 1), Vector3(1, 0.88, 0)],
		[Vector3(0, 0, 0), Vector3(1, 0, 0), Vector3(1, 0, 1), Vector3(0, 0, 1)],
		[Vector3(0, 0, 1), Vector3(1, 0, 1), Vector3(1, 0.88, 1), Vector3(0, 0.88, 1)],
		[Vector3(0, 0, 0), Vector3(0, 0.88, 0), Vector3(1, 0.88, 0), Vector3(1, 0, 0)],
	]
	var side_uvs := [Vector2(0, 1), Vector2(0, 0), Vector2(1, 0), Vector2(1, 1)]
	var top_bottom_uvs := [Vector2(0, 0), Vector2(0, 1), Vector2(1, 1), Vector2(1, 0)]
	var water_face_uv_factors := side_uvs
	for local_x: int in CHUNK_SIZE:
		for local_z: int in CHUNK_SIZE:
			for y: int in range(0, WORLD_HEIGHT + 1):
				var block_id := int(snapshot[_snapshot_index(local_x, y, local_z)])
				if block_id == 0:
					continue
				var block_pos := Vector3i(origin_x + local_x, y, origin_z + local_z)
				if block_id == 4:
					trunk_cells.append(Vector3i(local_x, y, local_z))
				if is_plant_block(block_id):
					plant_cells.append({"cell": Vector3i(local_x, y, local_z), "block_id": block_id})
					continue
				for face_index: int in FACE_DIRS.size():
					var dir: Vector3i = FACE_DIRS[face_index]
					var neighbor_id := int(snapshot[_snapshot_index(local_x + dir.x, y + dir.y, local_z + dir.z)])
					if not _face_is_exposed(block_id, neighbor_id):
						continue
					var is_water := block_id == BLOCK_WATER
					var tint: Color
					var tile_origin := Vector2.ZERO
					var tile_size := Vector2(1.0 / float(ATLAS_COLUMNS), 1.0 / float(ATLAS_ROWS))
					if is_water:
						var water_variation := 0.94 + float(absi(block_pos.x * 13 + block_pos.y * 29 + block_pos.z * 7) % 7) * 0.018
						tint = Color(0.34 * water_variation, 0.78 * water_variation, 0.96 * water_variation, 0.68)
					else:
						var shade := 1.0 if face_index == 2 else (0.58 if face_index == 3 else 0.82)
						var variation := 0.94 + float(absi(block_pos.x * 13 + block_pos.y * 29 + block_pos.z * 7) % 7) * 0.018
						var brightness := shade * variation
						var base_tint: Color = BLOCK_COLORS.get(block_id, Color.WHITE)
						tint = Color(base_tint.r * brightness, base_tint.g * brightness, base_tint.b * brightness, 1.0) if block_id >= 8 else Color(brightness, brightness, brightness, 1.0)
						var tile_indices: Array = BLOCK_ATLAS_TILES.get(block_id, BLOCK_ATLAS_TILES[3])
						var tile_index := int(tile_indices[face_index])
						tile_origin = Vector2(atlas_tile_coords(tile_index)) * tile_size
						var pixel_inset := Vector2(0.5 / ATLAS_PIXEL_DIMENSION, 0.5 / ATLAS_PIXEL_DIMENSION)
						tile_origin += pixel_inset
						tile_size -= pixel_inset * 2.0
					var points: Array = water_face_points[face_index] if is_water else face_points[face_index]
					var face_uvs: Array = water_face_uv_factors if is_water else (side_uvs if face_index in [0, 1, 4, 5] else top_bottom_uvs)
					for point_index: int in triangle_order:
						var point: Vector3 = points[point_index]
						var vertex: Vector3 = Vector3(float(local_x), float(y), float(local_z)) + point
						var factor: Vector2 = face_uvs[point_index]
						var uv: Vector2 = Vector2(lerpf(tile_origin.x, tile_origin.x + tile_size.x, factor.x), lerpf(tile_origin.y, tile_origin.y + tile_size.y, factor.y)) if not is_water else factor
						if is_water:
							water_vertices.append(vertex)
							water_normals.append(face_normals[face_index])
							water_colors.append(tint)
							water_uvs.append(uv)
						else:
							solid_vertices.append(vertex)
							solid_normals.append(face_normals[face_index])
							solid_colors.append(tint)
							solid_uvs.append(uv)
	return {
		"coord": coord,
		"world_revision": revision,
		"stream_epoch": epoch,
		"solid_vertices": solid_vertices,
		"solid_normals": solid_normals,
		"solid_colors": solid_colors,
		"solid_uvs": solid_uvs,
		"water_vertices": water_vertices,
		"water_normals": water_normals,
		"water_colors": water_colors,
		"water_uvs": water_uvs,
		"trunk_cells": trunk_cells,
		"plant_cells": plant_cells,
	}


func _mesh_from_buffers(vertices: PackedVector3Array, normals: PackedVector3Array, colors: PackedColorArray, uvs: PackedVector2Array) -> ArrayMesh:
	if vertices.is_empty():
		return null
	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_COLOR] = colors
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	return mesh


func _install_chunk_geometry(coord: Vector2i, geometry: Dictionary) -> void:
	var solid_vertices: PackedVector3Array = geometry.get("solid_vertices", PackedVector3Array())
	var water_vertices: PackedVector3Array = geometry.get("water_vertices", PackedVector3Array())
	var trunk_cells: Array = geometry.get("trunk_cells", [])
	var plant_cells: Array = geometry.get("plant_cells", [])
	if solid_vertices.is_empty() and water_vertices.is_empty():
		_discard_chunk(coord)
		return
	var mesh := _mesh_from_buffers(solid_vertices, geometry.get("solid_normals", PackedVector3Array()), geometry.get("solid_colors", PackedColorArray()), geometry.get("solid_uvs", PackedVector2Array()))
	var water_mesh := _mesh_from_buffers(water_vertices, geometry.get("water_normals", PackedVector3Array()), geometry.get("water_colors", PackedColorArray()), geometry.get("water_uvs", PackedVector2Array()))
	var collision_mesh: ConcavePolygonShape3D = null
	if mesh != null:
		collision_mesh = mesh.create_trimesh_shape() as ConcavePolygonShape3D
		if collision_mesh == null or collision_mesh.get_faces().is_empty():
			push_error("ByteCrafter: não foi possível gerar a colisão do chunk %s." % [coord])
			return
		collision_mesh.backface_collision = true
	var body := StaticBody3D.new()
	body.name = "Chunk_%d_%d" % [coord.x, coord.y]
	body.position = Vector3(float(coord.x * CHUNK_SIZE), 0.0, float(coord.y * CHUNK_SIZE))
	body.collision_layer = 1
	body.collision_mask = 0
	if mesh != null:
		var mesh_instance := MeshInstance3D.new()
		mesh_instance.name = "SolidMesh"
		mesh_instance.mesh = mesh
		mesh_instance.material_override = _voxel_material
		body.add_child(mesh_instance)
		var collider := CollisionShape3D.new()
		collider.name = "ChunkCollision"
		collider.shape = collision_mesh
		body.add_child(collider)
	if water_mesh != null:
		var water_instance := MeshInstance3D.new()
		water_instance.name = "WaterMesh"
		water_instance.mesh = water_mesh
		water_instance.material_override = _water_material
		water_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		body.add_child(water_instance)
	for trunk_index: int in trunk_cells.size():
		var cell: Vector3i = trunk_cells[trunk_index]
		var trunk_shape := BoxShape3D.new()
		trunk_shape.size = Vector3.ONE * 0.98
		var trunk_collider := CollisionShape3D.new()
		trunk_collider.name = "TreeTrunkCollision_%d" % trunk_index
		trunk_collider.shape = trunk_shape
		trunk_collider.position = Vector3(float(cell.x) + 0.5, float(cell.y) + 0.5, float(cell.z) + 0.5)
		body.add_child(trunk_collider)
	for plant_data: Dictionary in plant_cells:
		_add_plant_to_chunk(body, plant_data["cell"], int(plant_data["block_id"]))
	var previous: Node = _chunks.get(coord)
	if previous != null:
		_detach_chunk_body(previous)
	add_child(body)
	_chunks[coord] = body
	chunk_ready.emit(coord)


func _add_plant_to_chunk(body: StaticBody3D, cell: Vector3i, block_id: int) -> void:
	var scene: PackedScene = null
	if CUBE_BLOCK_MODELS.has(block_id):
		scene = CUBE_BLOCK_MODELS[block_id]
	elif block_id == 32:
		var fruit_index := posmod(_flora_hash(cell.x + int(body.position.x), cell.z + int(body.position.z), 53), FALLEN_FRUIT_MODELS.size())
		scene = FALLEN_FRUIT_MODELS[fruit_index]
	else:
		scene = PLANT_BLOCK_MODELS.get(block_id, null)
	if scene == null:
		return
	var plant := scene.instantiate() as Node3D
	plant.name = "WorldPlant_%d_%d_%d" % [block_id, cell.x, cell.z]
	var bounds := _collect_node_aabb(plant, Transform3D.IDENTITY)
	var maximum_extent := maxf(maxf(bounds.size.x, bounds.size.y), bounds.size.z)
	var target_extent := 1.0 if CUBE_BLOCK_MODELS.has(block_id) else (0.34 if block_id == 32 else (0.92 if block_id == 35 else 0.78))
	var visual_scale := target_extent / maxf(maximum_extent, 0.001)
	plant.scale = Vector3.ONE * visual_scale
	plant.position = Vector3(float(cell.x) + 0.5, float(cell.y), float(cell.z) + 0.5) - Vector3(bounds.get_center().x * visual_scale, bounds.position.y * visual_scale, bounds.get_center().z * visual_scale)
	body.add_child(plant)
	var shape := BoxShape3D.new()
	if CUBE_BLOCK_MODELS.has(block_id):
		shape.size = Vector3.ONE
	elif block_id == 32:
		shape.size = Vector3(0.34, 0.32, 0.34)
	elif block_id == 35:
		shape.size = Vector3(0.40, 0.90, 0.40)
	else:
		shape.size = Vector3(0.42, 0.58, 0.42) if block_id == 34 else Vector3(0.48, 0.72, 0.48)
	var collision := CollisionShape3D.new()
	collision.name = "PlantCollision_%d_%d_%d" % [cell.x, cell.y, cell.z]
	collision.shape = shape
	collision.position = Vector3(float(cell.x) + 0.5, float(cell.y) + shape.size.y * 0.5, float(cell.z) + 0.5)
	body.add_child(collision)


func _collect_node_aabb(node: Node, parent_transform: Transform3D) -> AABB:
	var current := parent_transform * (node as Node3D).transform if node is Node3D else parent_transform
	var bounds := AABB()
	if node is MeshInstance3D:
		bounds = current * (node as MeshInstance3D).get_aabb()
	for child: Node in node.get_children():
		var child_bounds := _collect_node_aabb(child, current)
		if child_bounds.size != Vector3.ZERO:
			bounds = child_bounds if bounds.size == Vector3.ZERO else bounds.merge(child_bounds)
	return bounds if bounds.size != Vector3.ZERO else AABB(Vector3.ZERO, Vector3.ONE)


static func is_plant_block(block_id: int) -> bool:
	return (block_id >= 27 and block_id <= 32) or (block_id >= 34 and block_id <= 48)


## Uma face é visível se o vizinho é ar, ou se é folha (transparente) e o bloco
## atual não é folha. Folha contra folha continua omitida (face interna da copa).
static func _face_is_exposed(block_id: int, neighbor_id: int) -> bool:
	if block_id == BLOCK_WATER:
		return neighbor_id == 0 or neighbor_id == 5 or is_plant_block(neighbor_id)
	return neighbor_id == 0 or (neighbor_id == 5 and block_id != 5) or neighbor_id == BLOCK_WATER or is_plant_block(neighbor_id)


func _discard_chunk(coord: Vector2i) -> void:
	var previous: Node = _chunks.get(coord)
	if previous != null:
		_chunks.erase(coord)
		_detach_chunk_body(previous)


func _detach_chunk_body(body: Node) -> void:
	if body.get_parent() == self:
		remove_child(body)
	body.queue_free()


func _add_face(surface: SurfaceTool, origin: Vector3, block_id: int, face_index: int, block_pos: Vector3i) -> void:
	var points: Array[Vector3]
	var normal: Vector3
	match face_index:
		0:
			normal = Vector3.RIGHT
			points = [Vector3(1, 0, 0), Vector3(1, 1, 0), Vector3(1, 1, 1), Vector3(1, 0, 1)]
		1:
			normal = Vector3.LEFT
			points = [Vector3(0, 0, 0), Vector3(0, 0, 1), Vector3(0, 1, 1), Vector3(0, 1, 0)]
		2:
			normal = Vector3.UP
			points = [Vector3(0, 1, 0), Vector3(0, 1, 1), Vector3(1, 1, 1), Vector3(1, 1, 0)]
		3:
			normal = Vector3.DOWN
			points = [Vector3(0, 0, 0), Vector3(1, 0, 0), Vector3(1, 0, 1), Vector3(0, 0, 1)]
		4:
			normal = Vector3.BACK
			points = [Vector3(0, 0, 1), Vector3(1, 0, 1), Vector3(1, 1, 1), Vector3(0, 1, 1)]
		_:
			normal = Vector3.FORWARD
			points = [Vector3(0, 0, 0), Vector3(0, 1, 0), Vector3(1, 1, 0), Vector3(1, 0, 0)]
	var shade := 1.0 if face_index == 2 else (0.58 if face_index == 3 else 0.82)
	var variation := 0.94 + float(absi(block_pos.x * 13 + block_pos.y * 29 + block_pos.z * 7) % 7) * 0.018
	var brightness := shade * variation
	var base_tint: Color = BLOCK_COLORS.get(block_id, Color.WHITE)
	var color := Color(base_tint.r * brightness, base_tint.g * brightness, base_tint.b * brightness, 1.0) if block_id >= 8 else Color(brightness, brightness, brightness, 1.0)
	var tile_indices: Array = BLOCK_ATLAS_TILES.get(block_id, BLOCK_ATLAS_TILES[3])
	var tile_index := int(tile_indices[face_index])
	var tile_size := Vector2(1.0 / float(ATLAS_COLUMNS), 1.0 / float(ATLAS_ROWS))
	var tile_origin := Vector2(atlas_tile_coords(tile_index)) * tile_size
	var pixel_inset := Vector2(0.5 / ATLAS_PIXEL_DIMENSION, 0.5 / ATLAS_PIXEL_DIMENSION)
	var uv_min := tile_origin + pixel_inset
	var uv_max := tile_origin + tile_size - pixel_inset
	# As faces verticais percorrem a malha de baixo para cima. Inverter V
	# nelas mantém a grama no topo e a terra na parte inferior do tile lateral.
	var face_uvs: Array[Vector2]
	if face_index == 0 or face_index == 1 or face_index == 4 or face_index == 5:
		face_uvs = [Vector2(0, 1), Vector2(0, 0), Vector2(1, 0), Vector2(1, 1)]
	else:
		face_uvs = [Vector2(0, 0), Vector2(0, 1), Vector2(1, 1), Vector2(1, 0)]
	for point_index: int in [0, 1, 2, 0, 2, 3]:
		surface.set_normal(normal)
		surface.set_color(color)
		var uv_factor: Vector2 = face_uvs[point_index]
		surface.set_uv(Vector2(lerpf(uv_min.x, uv_max.x, uv_factor.x), lerpf(uv_min.y, uv_max.y, uv_factor.y)))
		surface.add_vertex(origin + points[point_index])


func _add_water_face(surface: SurfaceTool, origin: Vector3, face_index: int, block_pos: Vector3i) -> void:
	var water_height := 0.88
	var points: Array[Vector3]
	var normal: Vector3
	match face_index:
		0:
			normal = Vector3.RIGHT
			points = [Vector3(1, 0, 0), Vector3(1, water_height, 0), Vector3(1, water_height, 1), Vector3(1, 0, 1)]
		1:
			normal = Vector3.LEFT
			points = [Vector3(0, 0, 0), Vector3(0, 0, 1), Vector3(0, water_height, 1), Vector3(0, water_height, 0)]
		2:
			normal = Vector3.UP
			points = [Vector3(0, water_height, 0), Vector3(0, water_height, 1), Vector3(1, water_height, 1), Vector3(1, water_height, 0)]
		3:
			normal = Vector3.DOWN
			points = [Vector3(0, 0, 0), Vector3(1, 0, 0), Vector3(1, 0, 1), Vector3(0, 0, 1)]
		4:
			normal = Vector3.BACK
			points = [Vector3(0, 0, 1), Vector3(1, 0, 1), Vector3(1, water_height, 1), Vector3(0, water_height, 1)]
		_:
			normal = Vector3.FORWARD
			points = [Vector3(0, 0, 0), Vector3(0, water_height, 0), Vector3(1, water_height, 0), Vector3(1, 0, 0)]
	var variation := 0.94 + float(absi(block_pos.x * 13 + block_pos.y * 29 + block_pos.z * 7) % 7) * 0.018
	var color := Color(0.34 * variation, 0.78 * variation, 0.96 * variation, 0.68)
	var face_uvs: Array[Vector2] = [Vector2(0, 1), Vector2(0, 0), Vector2(1, 0), Vector2(1, 1)]
	for point_index: int in [0, 1, 2, 0, 2, 3]:
		surface.set_normal(normal)
		surface.set_color(color)
		surface.set_uv(face_uvs[point_index])
		surface.add_vertex(origin + points[point_index])


static func atlas_tile_coords(tile_index: int) -> Vector2i:
	return Vector2i(posmod(tile_index, ATLAS_COLUMNS), floori(float(tile_index) / float(ATLAS_COLUMNS)))


func get_chunk_count() -> int:
	return _chunks.size()


func get_override_count() -> int:
	return _overrides.size()


func _override_chunk_coord(coords: Vector3i) -> Vector2i:
	return Vector2i(floori(float(coords.x) / float(CHUNK_SIZE)), floori(float(coords.z) / float(CHUNK_SIZE)))


func _set_override(coords: Vector3i, block_id: int) -> void:
	_overrides[coords] = block_id
	var chunk_coord := _override_chunk_coord(coords)
	var chunk_overrides: Dictionary = _overrides_by_chunk.get(chunk_coord, {})
	chunk_overrides[coords] = block_id
	_overrides_by_chunk[chunk_coord] = chunk_overrides
	_rebuild_override_chunk_buffer(chunk_coord)


func _erase_override(coords: Vector3i) -> void:
	_overrides.erase(coords)
	var chunk_coord := _override_chunk_coord(coords)
	var chunk_overrides: Dictionary = _overrides_by_chunk.get(chunk_coord, {})
	chunk_overrides.erase(coords)
	if chunk_overrides.is_empty():
		_overrides_by_chunk.erase(chunk_coord)
		_override_chunk_buffers.erase(chunk_coord)
	else:
		_overrides_by_chunk[chunk_coord] = chunk_overrides
		_rebuild_override_chunk_buffer(chunk_coord)


func _rebuild_override_chunk_buffer(chunk_coord: Vector2i) -> void:
	var chunk_overrides: Dictionary = _overrides_by_chunk.get(chunk_coord, {})
	if chunk_overrides.is_empty():
		_override_chunk_buffers.erase(chunk_coord)
		return
	var packed := PackedInt32Array()
	packed.resize(chunk_overrides.size() * 4)
	var offset := 0
	for coords_value: Variant in chunk_overrides.keys():
		var coords: Vector3i = coords_value
		packed[offset] = coords.x
		packed[offset + 1] = coords.y
		packed[offset + 2] = coords.z
		packed[offset + 3] = int(chunk_overrides[coords])
		offset += 4
	_override_chunk_buffers[chunk_coord] = packed


func get_overrides_array() -> Array:
	var result: Array = []
	for key: Variant in _overrides.keys():
		var coords: Vector3i = key
		result.append([coords.x, coords.y, coords.z, int(_overrides[coords])])
	return result


func create_save_snapshot() -> Dictionary:
	# Chunk buffers are immutable after publication; edits replace only the touched
	# chunk's PackedInt32Array. A shallow copy is cheap even for very large worlds.
	return {"version": 1, "seed": world_seed, "override_chunks": _override_chunk_buffers.duplicate(false)}


func save_to_disk() -> bool:
	var file := FileAccess.open(TEMP_SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("ByteCrafter: não foi possível abrir o arquivo temporário do mundo para gravação.")
		return false
	file.store_string(JSON.stringify({"version": 1, "seed": world_seed, "overrides": get_overrides_array()}))
	file.flush()
	file.close()

	var temporary := ProjectSettings.globalize_path(TEMP_SAVE_PATH)
	var destination := ProjectSettings.globalize_path(SAVE_PATH)
	var backup := ProjectSettings.globalize_path(SAVE_PATH + ".bak")
	var had_previous := FileAccess.file_exists(SAVE_PATH)
	if had_previous:
		if FileAccess.file_exists(SAVE_PATH + ".bak"):
			DirAccess.remove_absolute(backup)
		var backup_error := DirAccess.rename_absolute(destination, backup)
		if backup_error != OK:
			push_error("ByteCrafter: não foi possível proteger o save anterior.")
			return false
	var commit_error := DirAccess.rename_absolute(temporary, destination)
	if commit_error != OK:
		if had_previous:
			DirAccess.rename_absolute(backup, destination)
		push_error("ByteCrafter: falha ao finalizar o salvamento do mundo.")
		return false
	if FileAccess.file_exists(SAVE_PATH + ".bak"):
		DirAccess.remove_absolute(backup)
	return true

static func load_from_disk() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		return {}
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if not parsed is Dictionary or int(parsed.get("version", 0)) != 1:
		return {}
	var raw_overrides: Variant = parsed.get("overrides", [])
	if not raw_overrides is Array:
		return {}
	var clean_overrides: Array = []
	for entry: Variant in raw_overrides:
		if clean_overrides.size() >= MAX_SAVED_OVERRIDES:
			break
		if not entry is Array or entry.size() < 4:
			continue
		var x := int(entry[0])
		var y := int(entry[1])
		var z := int(entry[2])
		var block_id := int(entry[3])
		if y < 0 or y > WORLD_HEIGHT + 8 or absi(x) > 1000000 or absi(z) > 1000000:
			continue
		if block_id < 0 or block_id > MAX_BLOCK_ID:
			continue
		clean_overrides.append([x, y, z, block_id])
	return {"version": 1, "seed": int(parsed.get("seed", 0)), "overrides": clean_overrides}
