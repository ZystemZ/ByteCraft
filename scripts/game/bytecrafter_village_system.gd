extends Node3D
class_name ByteCrafterVillageSystem

const VILLAGER_SCRIPT: Script = preload("res://scripts/game/bytecrafter_villager.gd")
const PROP_SCRIPT: Script = preload("res://scripts/game/bytecrafter_prop.gd")
const VILLAGE_SPACING := 192
const LOAD_DISTANCE := 155.0
const UNLOAD_DISTANCE := 205.0
const HOUSE_OFFSETS: Array[Vector2i] = [Vector2i(-7, 3), Vector2i(7, 3), Vector2i(0, 11)]
const MARKET_OFFSET := Vector2i(0, -7)

var _world: ByteCrafterWorld
var _world_seed := 0
var _villages: Dictionary = {}
var _anchor_cache: Dictionary = {}
var _material_cache: Dictionary = {}
var _primary_anchor := Vector3.ZERO
var _last_player_position := Vector3(INF, 0.0, INF)
var _saved_village_states: Dictionary = {}
var _removed_village_prop_keys: Dictionary = {}
var _is_daytime := true


static func village_roll(seed_value: int, grid_cell: Vector2i) -> int:
	var raw := float(grid_cell.x * 92821 + grid_cell.y * 68917 + seed_value * 31 + 7919)
	return int(absf(sin(raw * 0.0174533) * 43758.5453))


static func should_generate_village(seed_value: int, grid_cell: Vector2i) -> bool:
	return grid_cell == Vector2i.ZERO or posmod(village_roll(seed_value, grid_cell), 7) == 0


func configure(world: ByteCrafterWorld, seed_value: int, player_position: Vector3, saved_villages: Array = [], daytime: bool = true) -> void:
	_world = world
	_world_seed = seed_value
	_villages.clear()
	_anchor_cache.clear()
	_material_cache.clear()
	_saved_village_states.clear()
	_removed_village_prop_keys.clear()
	_is_daytime = daytime
	for saved_value: Variant in saved_villages.slice(0, 256):
		if not saved_value is Dictionary:
			continue
		var record: Dictionary = saved_value
		var cell_value: Variant = record.get("cell", [])
		var villagers_value: Variant = record.get("villagers", [])
		if not cell_value is Array or cell_value.size() < 2 or not villagers_value is Array:
			continue
		var cell := Vector2i(int(cell_value[0]), int(cell_value[1]))
		if absi(cell.x) > 100000 or absi(cell.y) > 100000:
			continue
		var valid_villagers: Array = []
		for villager_value: Variant in villagers_value.slice(0, 3):
			if villager_value is Dictionary and str(villager_value.get("name", "")) in ["Mila", "Téo", "Bia"]:
				valid_villagers.append(villager_value.duplicate(true))
		var broken_props: Array = []
		var broken_value: Variant = record.get("broken_props", [])
		if broken_value is Array:
			for prop_value: Variant in broken_value.slice(0, 64):
				var prop_key := str(prop_value)
				if not prop_key.is_empty() and prop_key.length() <= 128 and not broken_props.has(prop_key):
					broken_props.append(prop_key)
		var owner_key := _cell_key(cell)
		_removed_village_prop_keys[owner_key] = broken_props
		_saved_village_states[owner_key] = {"cell": [cell.x, cell.y], "villagers": valid_villagers, "broken_props": broken_props}
	_primary_anchor = _find_primary_site()
	_anchor_cache[Vector2i.ZERO] = _primary_anchor
	_last_player_position = Vector3(INF, 0.0, INF)
	update_for_player(player_position, daytime)


func update_for_player(player_position: Vector3, daytime: bool) -> void:
	if _world == null:
		return
	_is_daytime = daytime
	if _last_player_position.distance_to(player_position) > 18.0:
		_last_player_position = player_position
		_ensure_nearby_villages(player_position)
	for village_value: Variant in _villages.values():
		var village := village_value as Node3D
		if not is_instance_valid(village):
			continue
		for child: Node in village.get_children():
			if child is ByteCrafterVillager:
				(child as ByteCrafterVillager).set_day_state(daytime)


func get_nearest_villager(origin: Vector3, max_distance: float) -> ByteCrafterVillager:
	var nearest: ByteCrafterVillager
	var merchant: ByteCrafterVillager
	var nearest_distance := max_distance
	var merchant_distance := max_distance
	for village_value: Variant in _villages.values():
		var village := village_value as Node3D
		if not is_instance_valid(village):
			continue
		for child: Node in village.get_children():
			if not child is ByteCrafterVillager:
				continue
			var villager := child as ByteCrafterVillager
			var distance := villager.global_position.distance_to(origin)
			if villager.is_merchant():
				if distance <= merchant_distance:
					merchant = villager
					merchant_distance = distance
			elif distance <= nearest_distance:
				nearest = villager
				nearest_distance = distance
	return merchant if merchant != null else nearest


func get_village_count() -> int:
	return _villages.size()


func get_villager_count() -> int:
	var count := 0
	for village_value: Variant in _villages.values():
		var village := village_value as Node3D
		if not is_instance_valid(village):
			continue
		for child: Node in village.get_children():
			if child is ByteCrafterVillager:
				count += 1
	return count


func serialize_state() -> Array:
	for cell_value: Variant in _villages.keys():
		var cell := cell_value as Vector2i
		var village := _villages[cell] as Node3D
		if is_instance_valid(village):
			_saved_village_states[_cell_key(cell)] = _serialize_village_record(cell, village)
	var result: Array = []
	var keys: Array = _saved_village_states.keys()
	keys.sort()
	for key: Variant in keys:
		result.append((_saved_village_states[key] as Dictionary).duplicate(true))
	return result


func _cell_key(cell: Vector2i) -> String:
	return "%d,%d" % [cell.x, cell.y]


func _serialize_village_record(cell: Vector2i, village: Node3D) -> Dictionary:
	var villagers: Array = []
	for child: Node in village.get_children():
		if child is ByteCrafterVillager:
			villagers.append((child as ByteCrafterVillager).serialize_state())
	var owner_key := _cell_key(cell)
	var broken_props: Array = _removed_village_prop_keys.get(owner_key, [])
	return {"cell": [cell.x, cell.y], "villagers": villagers, "broken_props": broken_props.duplicate(true)}


func _ensure_nearby_villages(player_position: Vector3) -> void:
	var center := Vector2i(floori(player_position.x / float(VILLAGE_SPACING)), floori(player_position.z / float(VILLAGE_SPACING)))
	for grid_x: int in range(center.x - 1, center.x + 2):
		for grid_z: int in range(center.y - 1, center.y + 2):
			var grid_cell := Vector2i(grid_x, grid_z)
			if not should_generate_village(_world_seed, grid_cell):
				continue
			var approximate := Vector3(float(grid_x * VILLAGE_SPACING), 0.0, float(grid_z * VILLAGE_SPACING))
			if grid_cell != Vector2i.ZERO and Vector2(approximate.x - player_position.x, approximate.z - player_position.z).length() > LOAD_DISTANCE + 75.0:
				continue
			var anchor := _anchor_for_cell(grid_cell)
			if anchor.distance_to(player_position) <= LOAD_DISTANCE and not _villages.has(grid_cell):
				_build_village(grid_cell, anchor)
	var expired: Array[Vector2i] = []
	for cell_value: Variant in _villages.keys():
		var cell := cell_value as Vector2i
		var root := _villages[cell] as Node3D
		if not is_instance_valid(root) or root.global_position.distance_to(player_position) > UNLOAD_DISTANCE:
			expired.append(cell)
	for expired_cell: Vector2i in expired:
		var expired_root := _villages[expired_cell] as Node3D
		_villages.erase(expired_cell)
		var owner_key := _cell_key(expired_cell)
		if is_instance_valid(expired_root):
			_saved_village_states[owner_key] = _serialize_village_record(expired_cell, expired_root)
			expired_root.queue_free()
		if _world != null:
			_world.unregister_village_structure(owner_key)


func _anchor_for_cell(grid_cell: Vector2i) -> Vector3:
	if _anchor_cache.has(grid_cell):
		return _anchor_cache[grid_cell] as Vector3
	var roll := village_roll(_world_seed, grid_cell)
	var base_x := grid_cell.x * VILLAGE_SPACING + posmod(roll, 81) - 40
	var base_z := grid_cell.y * VILLAGE_SPACING + posmod(roll / 13, 81) - 40
	var candidate := Vector3(float(base_x) + 0.5, 0.0, float(base_z) + 0.5)
	var anchor := _find_flat_site(candidate, 34, false)
	_anchor_cache[grid_cell] = anchor
	return anchor


func _find_primary_site() -> Vector3:
	if _world == null:
		return Vector3.ZERO
	var spawn := _world.get_spawn_position()
	var best := Vector3(floorf(spawn.x) + 0.5, spawn.y, floorf(spawn.z) + 0.5)
	var best_score := INF
	var angle_offset := float(posmod(village_roll(_world_seed, Vector2i.ZERO), 360)) * PI / 180.0
	for index: int in range(32):
		var angle := angle_offset + TAU * float(index) / 32.0
		var radius := 22.0 + float(posmod(index, 3)) * 4.0
		var x := floori(spawn.x + cos(angle) * radius)
		var z := floori(spawn.z + sin(angle) * radius)
		var candidate := Vector3(float(x) + 0.5, 0.0, float(z) + 0.5)
		var score := _site_score(candidate, Vector2(spawn.x, spawn.z))
		if score < best_score:
			best_score = score
			best = candidate
	return Vector3(best.x, float(_world.terrain_height(floori(best.x), floori(best.z))) + 1.12, best.z)


func _find_flat_site(candidate: Vector3, search_radius: int, near_spawn: bool) -> Vector3:
	var best := candidate
	var best_score := INF
	var origin := Vector2(candidate.x, candidate.z)
	for step: int in range(25):
		var angle := TAU * float(step) / 24.0
		var ring := float(posmod(step, 5)) * float(search_radius) / 5.0
		var x := floori(candidate.x + cos(angle) * ring)
		var z := floori(candidate.z + sin(angle) * ring)
		var site := Vector3(float(x) + 0.5, 0.0, float(z) + 0.5)
		var score := _site_score(site, origin)
		if near_spawn:
			score += Vector2(site.x - origin.x, site.z - origin.y).length() * 0.05
		if score < best_score:
			best_score = score
			best = site
	return Vector3(best.x, float(_world.terrain_height(floori(best.x), floori(best.z))) + 1.12, best.z)


func _site_score(site: Vector3, origin: Vector2) -> float:
	var center_x := floori(site.x)
	var center_z := floori(site.z)
	var center_height := _world.terrain_height(center_x, center_z)
	var lowest := center_height
	var highest := center_height
	var deviation := 0.0
	for dx: int in [-6, -3, 3, 6]:
		for dz: int in [-6, -3, 3, 6]:
			var height := _world.terrain_height(center_x + dx, center_z + dz)
			lowest = mini(lowest, height)
			highest = maxi(highest, height)
			deviation += absf(float(height - center_height))
	var biome := _world.get_biome(center_x, center_z)
	var biome_penalty := 0.0
	if biome == "frozen":
		biome_penalty = 9.0
	elif biome == "volcanic":
		biome_penalty = 15.0
	elif biome == "crystal":
		biome_penalty = 7.0
	var slope_penalty := float(highest - lowest) * 8.0 + deviation * 0.16
	var distance_penalty := Vector2(site.x - origin.x, site.z - origin.y).length() * 0.012
	return slope_penalty + biome_penalty + distance_penalty


func _build_village(grid_cell: Vector2i, anchor: Vector3) -> void:
	var village := Node3D.new()
	village.name = "Village_%d_%d" % [grid_cell.x, grid_cell.y]
	add_child(village)
	village.global_position = anchor
	_villages[grid_cell] = village
	var structure_blocks: Dictionary = {}
	var house_one := _build_house(village, grid_cell, HOUSE_OFFSETS[0], anchor.y, 0)
	var house_two := _build_house(village, grid_cell, HOUSE_OFFSETS[1], anchor.y, 1)
	var house_three := _build_house(village, grid_cell, HOUSE_OFFSETS[2], anchor.y, 2)
	for house_value: Variant in [house_one, house_two, house_three]:
		var house_blocks: Dictionary = house_value.get("blocks", {})
		structure_blocks.merge(house_blocks, true)
	var market_info := _build_market(village, grid_cell, MARKET_OFFSET, anchor.y)
	var market_blocks: Dictionary = market_info.get("blocks", {})
	structure_blocks.merge(market_blocks, true)
	_world.register_village_structure(_cell_key(grid_cell), structure_blocks)
	var market_position := village.to_global(market_info.get("vendor", Vector3.ZERO) as Vector3)
	_add_villager(village, "Mila", true, "merchant", house_one, market_position, market_position)
	_add_villager(village, "Téo", false, "resident", house_two, village.to_global(house_two.get("porch", Vector3.ZERO) as Vector3), market_position)
	_add_villager(village, "Bia", true, "resident", house_three, village.to_global(house_three.get("porch", Vector3.ZERO) as Vector3), market_position)
	_restore_village_state(grid_cell, village)


func _restore_village_state(grid_cell: Vector2i, village: Node3D) -> void:
	var owner_key := _cell_key(grid_cell)
	var record: Dictionary = _saved_village_states.get(owner_key, {})
	var villagers_value: Variant = record.get("villagers", [])
	var saved_by_name: Dictionary = {}
	if villagers_value is Array:
		for villager_value: Variant in villagers_value:
			if villager_value is Dictionary:
				saved_by_name[str(villager_value.get("name", ""))] = villager_value
	for child: Node in village.get_children():
		if child is ByteCrafterVillager:
			var villager := child as ByteCrafterVillager
			villager.set_day_state(_is_daytime)
			var bed_key := str(villager.get_meta("village_bed_prop_key", ""))
			villager.set_bed_available(not bed_key.is_empty() and not _is_village_prop_removed(owner_key, bed_key))
			if saved_by_name.has(villager.display_name):
				villager.restore_state(saved_by_name[villager.display_name] as Dictionary, _is_daytime)


func _add_villager(village: Node3D, name_text: String, female: bool, role: String, house: Dictionary, day_position: Vector3, alternate_day_position: Vector3) -> void:
	var villager := VILLAGER_SCRIPT.new() as ByteCrafterVillager
	var bed_position := village.to_global(house.get("bed", Vector3.ZERO) as Vector3)
	var home_start := village.to_global(house.get("porch", Vector3.ZERO) as Vector3)
	var bed_available := bool(house.get("bed_available", true))
	villager.configure(_world, name_text, female, role, bed_position, day_position, alternate_day_position, day_position, bed_available)
	villager.set_meta("village_bed_prop_key", str(house.get("bed_key", "")))
	village.add_child(villager)
	villager.global_position = home_start


func _build_house(parent: Node3D, grid_cell: Vector2i, offset: Vector2i, anchor_y: float, house_index: int) -> Dictionary:
	var world_x := floori(parent.global_position.x + float(offset.x))
	var world_z := floori(parent.global_position.z + float(offset.y))
	var floor_y := _max_terrain_height(world_x, world_z, 3)
	var house := Node3D.new()
	house.name = "Casa_%d" % house_index
	house.position = Vector3(float(offset.x), float(floor_y + 1.12) - anchor_y, float(offset.y))
	parent.add_child(house)
	var wall_options: Array[int] = [7, 3, 21, 4]
	var style := posmod(house_index + posmod(village_roll(_world_seed, grid_cell), wall_options.size()), wall_options.size())
	var wall_block := wall_options[style]
	var roof_block := 7 if posmod(style + house_index, 2) == 0 else 4
	var blocks: Dictionary = {}
	for dx: int in range(-3, 4):
		for dz: int in range(-3, 4):
			var local_x := world_x + dx
			var local_z := world_z + dz
			var local_ground := _world.terrain_height(local_x, local_z)
			for support_y: int in range(local_ground + 1, floor_y):
				blocks[Vector3i(local_x, support_y, local_z)] = 3
			var edge := absi(dx) == 3 or absi(dz) == 3
			blocks[Vector3i(local_x, floor_y, local_z)] = 3 if edge else 7
	for dx: int in range(-2, 3):
		for dz: int in range(-2, 3):
			for air_y: int in range(floor_y + 1, floor_y + 8):
				blocks[Vector3i(world_x + dx, air_y, world_z + dz)] = 0
	for wall_y: int in range(floor_y + 1, floor_y + 4):
		for dx: int in range(-3, 4):
			for dz: int in range(-3, 4):
				if absi(dx) != 3 and absi(dz) != 3:
					continue
				var door_opening := dz == -3 and dx == 0 and wall_y <= floor_y + 2
				var window_opening := absi(dx) == 3 and dz == 0 and wall_y == floor_y + 2
				var cell := Vector3i(world_x + dx, wall_y, world_z + dz)
				blocks[cell] = 0 if door_opening or window_opening else wall_block
	for dz: int in range(-3, 4):
		var roof_y := floor_y + 4 + (3 - absi(dz))
		for dx: int in range(-3, 4):
			blocks[Vector3i(world_x + dx, roof_y, world_z + dz)] = roof_block
	var door_cell := Vector3i(world_x, floor_y + 1, world_z - 3)
	_create_village_prop(house, grid_cell, "porta", door_cell)
	_create_village_prop(house, grid_cell, "janela", Vector3i(world_x - 3, floor_y + 2, world_z), PI * 0.5)
	_create_village_prop(house, grid_cell, "janela", Vector3i(world_x + 3, floor_y + 2, world_z), -PI * 0.5)
	var bed_cell := Vector3i(world_x, floor_y + 1, world_z + 1)
	var bed_key := _village_prop_key("cama", bed_cell)
	var bed_available := not _is_village_prop_removed(_cell_key(grid_cell), bed_key)
	if bed_available:
		_create_village_prop(house, grid_cell, "cama", bed_cell)
	return {
		"blocks": blocks,
		"bed": Vector3(float(offset.x), float(floor_y + 1) + 0.30 - anchor_y, float(offset.y) + 1.0),
		"bed_key": bed_key,
		"bed_available": bed_available,
		"porch": Vector3(float(offset.x), float(floor_y + 1.12) - anchor_y, float(offset.y) - 4.0),
	}


func _build_market(parent: Node3D, grid_cell: Vector2i, offset: Vector2i, anchor_y: float) -> Dictionary:
	var world_x := floori(parent.global_position.x + float(offset.x))
	var world_z := floori(parent.global_position.z + float(offset.y))
	var floor_y := _max_terrain_height(world_x, world_z, 2)
	var market := Node3D.new()
	market.name = "Barraca_Mercado"
	market.position = Vector3(float(offset.x), float(floor_y + 1.12) - anchor_y, float(offset.y))
	parent.add_child(market)
	var blocks: Dictionary = {}
	for dx: int in range(-2, 3):
		for dz: int in range(-2, 3):
			var local_x := world_x + dx
			var local_z := world_z + dz
			var local_ground := _world.terrain_height(local_x, local_z)
			for support_y: int in range(local_ground + 1, floor_y):
				blocks[Vector3i(local_x, support_y, local_z)] = 3
			blocks[Vector3i(local_x, floor_y, local_z)] = 7
			for air_y: int in range(floor_y + 1, floor_y + 4):
				blocks[Vector3i(local_x, air_y, local_z)] = 0
	for post_x: int in [-2, 2]:
		for post_z: int in [-2, 2]:
			for post_y: int in range(floor_y + 1, floor_y + 4):
				blocks[Vector3i(world_x + post_x, post_y, world_z + post_z)] = 4
	for dx: int in range(-2, 3):
		for dz: int in range(-2, 3):
			blocks[Vector3i(world_x + dx, floor_y + 4, world_z + dz)] = 7 if posmod(dx + dz + village_roll(_world_seed, grid_cell), 2) == 0 else 4
	for dx: int in range(-1, 2):
		blocks[Vector3i(world_x + dx, floor_y + 1, world_z - 1)] = 7
		blocks[Vector3i(world_x + dx, floor_y + 2, world_z - 1)] = 7
	var sign := Label3D.new()
	sign.name = "MarketSign"
	sign.text = "MERCADO"
	sign.position = Vector3(0.0, 3.7, -1.3)
	sign.font_size = 32
	sign.outline_size = 6
	sign.modulate = Color("fff0c9")
	sign.outline_modulate = Color("483729")
	sign.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	market.add_child(sign)
	return {
		"blocks": blocks,
		"vendor": Vector3(float(offset.x), float(floor_y + 1) + 0.30 - anchor_y, float(offset.y) + 0.68),
	}


func _add_box(parent: Node3D, collision_body: StaticBody3D, node_name: String, size: Vector3, at: Vector3, color: Color) -> MeshInstance3D:
	var mesh_node := MeshInstance3D.new()
	mesh_node.name = node_name
	var box := BoxMesh.new()
	box.size = size
	mesh_node.mesh = box
	mesh_node.position = at
	var material := _material(color)
	mesh_node.material_override = material
	parent.add_child(mesh_node)
	if collision_body != null:
		var shape_node := CollisionShape3D.new()
		var shape := BoxShape3D.new()
		shape.size = size
		shape_node.shape = shape
		shape_node.position = at
		collision_body.add_child(shape_node)
	return mesh_node


func _material(color: Color) -> StandardMaterial3D:
	var key := color.to_html(true)
	if _material_cache.has(key):
		return _material_cache[key] as StandardMaterial3D
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.9
	if color.a < 0.99:
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		material.shading_mode = BaseMaterial3D.SHADING_MODE_PER_PIXEL
	_material_cache[key] = material
	return material


func _max_terrain_height(center_x: int, center_z: int, radius: int) -> int:
	var result := _world.terrain_height(center_x, center_z)
	for dx: int in range(-radius, radius + 1):
		for dz: int in range(-radius, radius + 1):
			result = maxi(result, _world.terrain_height(center_x + dx, center_z + dz))
	return result


func _village_prop_key(prop_id: String, cell: Vector3i) -> String:
	return "%s@%d,%d,%d" % [prop_id, cell.x, cell.y, cell.z]


func _is_village_prop_removed(owner_key: String, prop_key: String) -> bool:
	var removed: Variant = _removed_village_prop_keys.get(owner_key, [])
	return removed is Array and removed.has(prop_key)


func _create_village_prop(parent: Node3D, grid_cell: Vector2i, prop_id: String, cell: Vector3i, rotation_y := 0.0) -> ByteCrafterProp:
	var owner_key := _cell_key(grid_cell)
	var prop_key := _village_prop_key(prop_id, cell)
	if _is_village_prop_removed(owner_key, prop_key):
		return null
	var prop := PROP_SCRIPT.new() as ByteCrafterProp
	prop.configure(prop_id, cell)
	prop.process_mode = Node.PROCESS_MODE_PAUSABLE
	prop.set_meta("village_owner", owner_key)
	prop.set_meta("village_cell", grid_cell)
	prop.set_meta("village_prop_key", prop_key)
	parent.add_child(prop)
	prop.global_position = Vector3(float(cell.x) + 0.5, float(cell.y), float(cell.z) + 0.5)
	prop.rotation.y = rotation_y
	return prop


func mark_prop_broken(prop: ByteCrafterProp) -> bool:
	if prop == null or not is_instance_valid(prop):
		return false
	var owner_key := str(prop.get_meta("village_owner", ""))
	var prop_key := str(prop.get_meta("village_prop_key", ""))
	if owner_key.is_empty() or prop_key.is_empty():
		return false
	var removed: Array = _removed_village_prop_keys.get(owner_key, [])
	if not removed.has(prop_key):
		removed.append(prop_key)
	_removed_village_prop_keys[owner_key] = removed
	var grid_value: Variant = prop.get_meta("village_cell", Vector2i.ZERO)
	if not grid_value is Vector2i:
		return true
	var grid_cell: Vector2i = grid_value
	var record: Dictionary = _saved_village_states.get(owner_key, {"cell": [grid_cell.x, grid_cell.y], "villagers": []})
	record["broken_props"] = removed.duplicate(true)
	_saved_village_states[owner_key] = record
	var village := _villages.get(grid_cell) as Node3D
	if is_instance_valid(village) and prop.prop_id == "cama":
		for child: Node in village.get_children():
			if child is ByteCrafterVillager and str(child.get_meta("village_bed_prop_key", "")) == prop_key:
				(child as ByteCrafterVillager).set_bed_available(false)
	return true
