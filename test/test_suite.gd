extends Node

const WORLD_SCRIPT := preload("res://scripts/game/voxel_world.gd")
const GAME_SCENE := preload("res://scenes/main.tscn")
const RECIPE_BOOK := preload("res://scripts/game/crafting_recipe_book.gd")

var _failures := PackedStringArray()
var _checks := 0
var _saved_user_files: Dictionary = {}


func _ready() -> void:
	call_deferred("_run")


func _run() -> void:
	# Exercise saves in a disposable fixture and restore every user's file byte-for-byte.
	for path: String in ["user://bytecrafter_world.json", "user://bytecrafter_player.json", "user://bytecrafter_settings.cfg", SaveStore.SAVE_PATH]:
		_saved_user_files[path] = FileAccess.get_file_as_bytes(path) if FileAccess.file_exists(path) else null
	_check(int(ProjectSettings.get_setting("application/run/max_fps", 0)) == 60, "the project must cap its rendering rate at 60 FPS")
	_check(not ByteCrafterMovement.is_in_water(null, null, 1.0), "water movement helpers must safely reject null world and actor references")
	var released_actor := CharacterBody3D.new()
	released_actor.free()
	_check(not ByteCrafterMovement.is_in_water(null, released_actor, 1.0), "water movement helpers must safely reject an actor that was already freed")
	_test_localization()
	_test_recipe_book()
	_test_inventory_stack()
	await _test_player_only_open_props()
	_test_seeded_world()
	_test_voxel_integrity()
	await _test_playable_loop()
	Input.action_release("move_up")
	Input.action_release("move_down")
	Input.action_release("move_left")
	Input.action_release("move_right")
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	await get_tree().process_frame
	_restore_user_files()
	if _failures.is_empty():
		print("[bytecrafter-tests] PASS: %d checks" % _checks)
		get_tree().quit(0)
		return
	for failure: String in _failures:
		push_error("[bytecrafter-tests] " + failure)
	print("[bytecrafter-tests] FAIL: %d failures across %d checks" % [_failures.size(), _checks])
	get_tree().quit(1)


func _check(condition: bool, message: String) -> void:
	_checks += 1
	if not condition:
		_failures.append(message)


func _test_player_only_open_props() -> void:
	var player := ByteCrafterPlayer.new()
	var npc := ByteCrafterVillager.new()
	var door := ByteCrafterProp.new()
	door.configure("porta", Vector3i(0, 0, 0))
	var window_prop := ByteCrafterProp.new()
	window_prop.configure("janela", Vector3i(2, 0, 0))
	var bed_prop := ByteCrafterProp.new()
	bed_prop.configure("cama", Vector3i(4, 0, 0))
	get_tree().root.add_child(player)
	get_tree().root.add_child(npc)
	get_tree().root.add_child(door)
	get_tree().root.add_child(window_prop)
	get_tree().root.add_child(bed_prop)
	await get_tree().process_frame
	_check(not door.toggle_open(npc) and not door.is_open, "NPCs must not open or close doors")
	_check(door.toggle_open(player) and door.is_open, "players must open doors")
	_check(door.toggle_open(npc) and door.is_open, "NPCs must not close doors opened by players")
	_check(not door.toggle_open(player) and not door.is_open, "players must close open doors")
	_check(not window_prop.toggle_open(npc) and not window_prop.is_open, "NPCs must not operate windows")
	_check(window_prop.toggle_open(player) and window_prop.is_open, "players must open and close windows")
	_check(is_equal_approx(absf(float(window_prop.get_node("WindowLeaf").rotation.y)), PI * 0.5), "opening a window must rotate its panel")
	_check(not window_prop.toggle_open(player) and not window_prop.is_open, "players must close windows")
	var bed_model := bed_prop.get_node_or_null("KenneySingleBed") as Node3D
	var bed_collider := bed_prop.find_child("PropCollisionShape", true, false) as CollisionShape3D
	var bed_shape := bed_collider.shape as BoxShape3D if bed_collider != null else null
	var bed_collider_size := bed_shape.size if bed_shape != null else Vector3.ZERO
	_check(bed_model != null and is_equal_approx(bed_model.scale.x, 1.75) and is_equal_approx(bed_model.scale.y, 1.75) and is_equal_approx(bed_model.scale.z, 1.75), "the single bed model must be 75% larger")
	_check(bed_shape != null and bed_collider_size.is_equal_approx(Vector3(0.98, 0.58, 1.88) * 1.75), "the enlarged bed collider must match its 1.75× visual scale (actual: %s)" % str(bed_collider_size))
	player.set_equipped_tool("espada")
	player.play_action("attack")
	await get_tree().process_frame
	var player_avatar := player.get("_avatar_instance") as ByteCrafterAvatar
	var player_animation := player_avatar.get_animation_player() if player_avatar != null else null
	var attack_swing_tween := player.get("_first_person_attack_tween") as Tween
	_check(player.get_animation_state() == "attack" and player_animation != null and player_animation.current_animation == "attack", "a player attack must activate the rigged attack clip")
	_check(attack_swing_tween != null and attack_swing_tween.is_running(), "a first-person weapon must visibly swing during an attack")
	player.queue_free()
	npc.queue_free()
	door.queue_free()
	window_prop.queue_free()
	bed_prop.queue_free()
	await get_tree().process_frame


func _test_inventory_stack() -> void:
	var inventory := ByteCrafterInventoryStack.new()
	_check(inventory.add_item(1, 70) == 0 and inventory.get_count(0) == 64 and inventory.get_count(1) == 6, "ItemStack must split a 70-block pickup into 64 + 6")
	inventory.click_slot(0, MOUSE_BUTTON_LEFT)
	_check(inventory.cursor != null and int(inventory.cursor.get("count", 0)) == 64 and inventory.get_count(0) == 0, "left click must pick up the complete source stack into the cursor")
	inventory.click_slot(1, MOUSE_BUTTON_RIGHT)
	_check(inventory.cursor != null and int(inventory.cursor.get("count", 0)) == 63 and inventory.get_count(1) == 7, "right click with a cursor stack must deposit exactly one item")
	inventory.click_slot(1, MOUSE_BUTTON_LEFT)
	_check(inventory.cursor != null and int(inventory.cursor.get("count", 0)) == 6 and inventory.get_count(1) == 64, "left click must merge equal stacks up to the 64-item limit")
	inventory.cursor = null
	inventory.set_stack(0, "frutas", 3)
	inventory.click_slot(0, MOUSE_BUTTON_RIGHT)
	_check(inventory.cursor != null and int(inventory.cursor.get("count", 0)) == 2 and inventory.get_count(0) == 1, "right click on a stack must split it approximately in half")
	inventory.cursor = null
	inventory.set_stack(0, 4, 1)
	inventory.click_slot(0, MOUSE_BUTTON_LEFT, true)
	_check(inventory.get_count(0) == 0 and inventory.get_count(9) == 1, "Shift-click must move a stack between hotbar and backpack ranges")
	inventory.set_stack(10, 5, 2)
	inventory.set_stack(11, 5, 3)
	inventory.cursor = null
	inventory.collect_matching(5)
	_check(inventory.cursor != null and int(inventory.cursor.get("count", 0)) == 5 and inventory.get_count(10) == 0 and inventory.get_count(11) == 0, "double-click collection must gather equal stacks into the cursor")


func _restore_user_files() -> void:
	for path: String in _saved_user_files:
		var original: Variant = _saved_user_files[path]
		if original == null:
			if FileAccess.file_exists(path):
				_check(DirAccess.remove_absolute(ProjectSettings.globalize_path(path)) == OK, "test save must be removed: " + path)
		else:
			var file := FileAccess.open(path, FileAccess.WRITE)
			_check(file != null, "original user file must be writable: " + path)
			if file != null:
				file.store_buffer(original)
				file.close()
				_check(FileAccess.get_file_as_bytes(path) == original, "original user file must be restored byte-for-byte: " + path)


func _test_recipe_book() -> void:
	var single_log: Array = [null, null, null, null, 4, null, null, null, null]
	var planks: Dictionary = RECIPE_BOOK.find_grid_recipe(single_log)
	_check(planks.get("id", "") == "oak_planks" and int(planks.get("item", -1)) == 7 and int(planks.get("quantity", 0)) == 4, "one log in any crafting cell must produce four planks")
	var vertical_pair: Array = [null, 7, null, null, 7, null, null, null, null]
	var sticks: Dictionary = RECIPE_BOOK.find_grid_recipe(vertical_pair)
	_check(sticks.get("id", "") == "sticks" and sticks.get("item", null) == "gravetos", "two vertically adjacent planks must produce sticks")
	var horizontal_pair: Array = [7, 7, null, null, null, null, null, null, null]
	_check(RECIPE_BOOK.find_grid_recipe(horizontal_pair).is_empty(), "horizontal planks must not match the vertical stick recipe")
	var pickaxe_pattern: Array = [7, 7, 7, null, "gravetos", null, null, "gravetos", null]
	var pickaxe: Dictionary = RECIPE_BOOK.find_grid_recipe(pickaxe_pattern)
	_check(pickaxe.get("id", "") == "wood_pickaxe" and int(pickaxe.get("max_stack", 0)) == 999, "the wooden pickaxe pattern and stack limit must come from the recipe catalog")
	var extra_item_pattern: Array = [7, 7, 7, 1, "gravetos", null, null, "gravetos", null]
	_check(RECIPE_BOOK.find_grid_recipe(extra_item_pattern).is_empty(), "an extra ingredient must invalidate an exact recipe pattern")
	_check(RECIPE_BOOK.get_quick_recipe("planks").get("id", "") == "oak_planks" and RECIPE_BOOK.get_quick_recipe("unknown").is_empty(), "quick crafting must use the same catalog and reject unknown actions")


func _test_localization() -> void:
	_check(I18n.get_locale() == "pt-BR", "the new game must stay in Brazilian Portuguese")
	_check(I18n.t("app.title") == "ByteCrafter", "the Portuguese catalog must carry the correct game title")
	_check(I18n.detect_locale("en_US") == "pt-BR", "OS language must not replace the requested game language")
	I18n.set_locale("en")
	_check(I18n.get_locale() == "pt-BR", "the single-language game must not switch to an inherited locale")


func _test_seeded_world() -> void:
	var world_a := WORLD_SCRIPT.new() as ByteCrafterWorld
	var world_b := WORLD_SCRIPT.new() as ByteCrafterWorld
	_check(ByteCrafterWorld.atlas_tile_coords(ByteCrafterWorld.BLOCK_ATLAS_TILES[1][0]) == Vector2i(0, 1), "grass sides must use tile 16 in the new atlas")
	_check(ByteCrafterWorld.atlas_tile_coords(ByteCrafterWorld.BLOCK_ATLAS_TILES[4][2]) == Vector2i(2, 1), "log tops must use tile 18 in the new atlas")
	_check(ByteCrafterWorld.atlas_tile_coords(ByteCrafterWorld.BLOCK_ATLAS_TILES[7][0]) == Vector2i(2, 1), "oak planks must use tile 18 in the new atlas")
	_check(ByteCrafterWorld.atlas_tile_coords(ByteCrafterWorld.BLOCK_ATLAS_TILES[9][0]) == Vector2i(3, 3), "cobblestone must use tile 51 in the new atlas")
	_check(int(ByteCrafterWorld.BLOCK_ATLAS_TILES[7][2]) == 18, "planks must sample the mapped oak planks tile")
	world_a.configure(120303788, [], 1)
	world_b.configure(120303788, [], 1)
	var height_a := world_a.terrain_height(17, -29)
	var height_b := world_b.terrain_height(17, -29)
	_check(height_a == height_b, "the same world seed must reproduce terrain height")
	_check(height_a > 0 and height_a < ByteCrafterWorld.WORLD_HEIGHT, "terrain must remain within the playable world bounds")
	var spawn_position: Vector3 = world_a.get_spawn_position()
	var spawn_cell := Vector3i(floori(spawn_position.x), floori(spawn_position.y), floori(spawn_position.z))
	_check(world_a.get_block_at(spawn_cell) == 0, "the selected spawn cell must remain clear of trunks and canopy")
	_check(world_a.get_block_at(spawn_cell - Vector3i.UP) > 0, "the selected spawn must have a solid support block")
	var ground_leaf_cell := spawn_cell + Vector3i.UP
	_check(world_a.get_block_at(ground_leaf_cell) != 5, "world generation must never use leaves as a ground block")
	_check(not world_a.set_block_at(ground_leaf_cell, 5), "leaves must be rejected outside generated tree crowns")
	_check(world_a.get_block_at(ground_leaf_cell) != 5, "a rejected ground leaf must remain absent")
	var surface := Vector3i(17, height_a, -29)
	var original_block := world_a.get_block_at(surface)
	_check(original_block > 0, "generated terrain must have a solid surface block")
	_check(world_a.set_block_at(surface, 0), "a surface voxel must be breakable")
	_check(world_a.get_block_at(surface) == 0, "a broken voxel must become air")
	_check(world_a.set_block_at(surface, 7), "a block can be placed back into the world")
	_check(world_a.get_block_at(surface) == 7, "the placed block must be visible in world data")
	_check(world_a.get_block_at(Vector3i(0, -1, 0)) == 0, "positions below the world must be empty")
	_check(world_a.get_block_at(Vector3i(0, ByteCrafterWorld.WORLD_HEIGHT + 1, 0)) == 0, "positions above the generated world must be empty")
	_check(not world_a.set_block_at(Vector3i(0, ByteCrafterWorld.WORLD_HEIGHT + 1, 0), 7), "placing above the generated world must be rejected")
	var loaded_chunks: Dictionary = world_a.get("_chunks")
	_check(not loaded_chunks.is_empty(), "the configured world must build its center chunk immediately")
	var collision_chunks := 0
	var valid_chunk_collisions := true
	for chunk_value: Variant in loaded_chunks.values():
		var chunk_body := chunk_value as StaticBody3D
		var chunk_collision := chunk_body.get_node_or_null("ChunkCollision") as CollisionShape3D if chunk_body != null else null
		var chunk_shape := chunk_collision.shape as ConcavePolygonShape3D if chunk_collision != null else null
		if chunk_shape != null and not chunk_shape.get_faces().is_empty():
			collision_chunks += 1
		else:
			valid_chunk_collisions = false
	_check(collision_chunks == loaded_chunks.size() and valid_chunk_collisions, "every loaded chunk must have a non-empty collision shape")
	world_a.call("_build_chunk", Vector2i(0, 0))
	world_a.call("_build_chunk", Vector2i(1, 0))
	var left_body_before := (world_a.get("_chunks") as Dictionary).get(Vector2i(0, 0)) as StaticBody3D
	var right_body_before := (world_a.get("_chunks") as Dictionary).get(Vector2i(1, 0)) as StaticBody3D
	var boundary := Vector3i(16, world_a.terrain_height(16, 0), 0)
	_check(world_a.get_block_at(boundary) > 0, "a chunk-boundary surface voxel must be solid before editing")
	_check(world_a.set_block_at(boundary, 0), "editing a boundary voxel must rebuild its owning chunk")
	var rebuilt_chunks: Dictionary = world_a.get("_chunks")
	_check(rebuilt_chunks.has(Vector2i(0, 0)) and rebuilt_chunks.has(Vector2i(1, 0)), "editing a border voxel must keep both adjacent chunks available")
	var left_body := rebuilt_chunks.get(Vector2i(0, 0)) as StaticBody3D
	var right_body := rebuilt_chunks.get(Vector2i(1, 0)) as StaticBody3D
	_check(left_body != left_body_before and right_body != right_body_before, "editing a border voxel must replace both affected chunk bodies")
	_check(left_body.get_node_or_null("ChunkCollision") != null and right_body.get_node_or_null("ChunkCollision") != null, "both chunks adjacent to an edited border must retain collision nodes")
	var tree_cell := Vector3i(999999, -1, 999999)
	for tree_x: int in range(-48, 49):
		for tree_z: int in range(-48, 49):
			var tree_ground := world_a.terrain_height(tree_x, tree_z)
			for tree_y: int in range(tree_ground + 1, tree_ground + 8):
				var candidate := Vector3i(tree_x, tree_y, tree_z)
				if world_a.get_block_at(candidate) in [4, 5]:
					tree_cell = candidate
					break
			if tree_cell.y >= 0:
				break
		if tree_cell.y >= 0:
			break
	_check(tree_cell.y >= 0, "the generated world must expose a testable tree trunk or leaf block")
	if tree_cell.y >= 0:
		var tree_kind := world_a.get_block_at(tree_cell)
		_check(tree_kind in [4, 5], "the test tree block must be a trunk or leaf")
		_check(world_a.set_block_at(tree_cell, 0), "a generated tree block must be breakable through world editing")
		_check(world_a.get_block_at(tree_cell) == 0, "a broken tree block must stay empty")
		_check(world_a.set_block_at(tree_cell, 7), "a block must be placeable in a cleared tree cell")
		_check(world_a.get_block_at(tree_cell) == 7, "a placed block must not be replaced by the procedural tree cache")
		var remaining_tree := tree_cell + Vector3i.UP
		_check(world_a.get_block_at(remaining_tree) in [0, 4, 5], "editing one tree cell must not delete neighboring tree blocks")
		world_a.update_streaming(Vector3(320.0, 0.0, 320.0))
		world_a.update_streaming(world_a.get_spawn_position())
		_check(world_a.get_block_at(tree_cell) == 7, "a placed block in a tree must survive streaming rebuilds")
	world_a.free()
	world_b.free()


## Integridade voxel (P0): malha, colisão e dados de bloco precisam concordar.
func _count_expected_faces(world: ByteCrafterWorld, coord: Vector2i) -> int:
	var faces := 0
	for local_x: int in ByteCrafterWorld.CHUNK_SIZE:
		for local_z: int in ByteCrafterWorld.CHUNK_SIZE:
			for y: int in range(0, ByteCrafterWorld.WORLD_HEIGHT + 1):
				var pos := Vector3i(coord.x * ByteCrafterWorld.CHUNK_SIZE + local_x, y, coord.y * ByteCrafterWorld.CHUNK_SIZE + local_z)
				if world.get_block_at(pos) in [0, ByteCrafterWorld.BLOCK_WATER] or ByteCrafterWorld.is_plant_block(world.get_block_at(pos)):
					continue
				for dir: Vector3i in ByteCrafterWorld.FACE_DIRS:
					if ByteCrafterWorld._face_is_exposed(world.get_block_at(pos), world.get_block_at(pos + dir)):
						faces += 1
	return faces


func _count_blocks(world: ByteCrafterWorld, coord: Vector2i, block_id: int) -> int:
	var count := 0
	for local_x: int in ByteCrafterWorld.CHUNK_SIZE:
		for local_z: int in ByteCrafterWorld.CHUNK_SIZE:
			for y: int in range(0, ByteCrafterWorld.WORLD_HEIGHT + 1):
				if world.get_block_at(Vector3i(coord.x * ByteCrafterWorld.CHUNK_SIZE + local_x, y, coord.y * ByteCrafterWorld.CHUNK_SIZE + local_z)) == block_id:
					count += 1
	return count


func _chunk_mesh_vertex_count(body: StaticBody3D) -> int:
	for child: Node in body.get_children():
		var instance := child as MeshInstance3D
		if instance != null and instance.mesh != null and instance.mesh.get_surface_count() > 0:
			return (instance.mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX] as PackedVector3Array).size()
	return -1


func _test_voxel_integrity() -> void:
	var world := WORLD_SCRIPT.new() as ByteCrafterWorld
	world.configure(120303788, [], 1)
	var chunks: Dictionary = world.get("_chunks")
	for coord: Vector2i in [Vector2i(0, 0), Vector2i(-1, 0), Vector2i(0, -1), Vector2i(-1, -1), Vector2i(1, 0)]:
		world.call("_build_chunk", coord)
		var body := chunks.get(coord) as StaticBody3D
		_check(body != null, "chunk %s must be built" % [coord])
		if body == null:
			continue
		var expected_faces := _count_expected_faces(world, coord)
		var vertex_count := _chunk_mesh_vertex_count(body)
		_check(vertex_count == expected_faces * 6, "chunk %s mesh must contain exactly the faces implied by block data (%d vs %d)" % [coord, vertex_count / 6, expected_faces])
		var collision := body.get_node_or_null("ChunkCollision") as CollisionShape3D
		var shape := collision.shape as ConcavePolygonShape3D if collision != null else null
		_check(shape != null and shape.get_faces().size() == vertex_count, "chunk %s collision triangles must match the visible mesh" % [coord])
		var trunk_colliders := 0
		for child: Node in body.get_children():
			if child.name.begins_with("TreeTrunkCollision"):
				trunk_colliders += 1
		_check(trunk_colliders == _count_blocks(world, coord, 4), "chunk %s must have one trunk collider per trunk block" % [coord])
	# Reconstruir um chunk não pode deixar corpos obsoletos nem lacunas.
	var rebuilt_coord := Vector2i(0, 0)
	var before := chunks.get(rebuilt_coord) as StaticBody3D
	world.call("_build_chunk", rebuilt_coord)
	var after := chunks.get(rebuilt_coord) as StaticBody3D
	_check(after != null and after != before, "rebuilding must install a fresh chunk body")
	_check(before != null and before.get_parent() == null, "the replaced chunk body must leave the physics tree immediately")
	var chunk_children := 0
	for child: Node in world.get_children():
		if child is StaticBody3D:
			chunk_children += 1
	_check(chunk_children == chunks.size(), "the world must keep exactly one body per loaded chunk (no stale colliders)")
	_check(ByteCrafterWorld._face_is_exposed(2, 5) and ByteCrafterWorld._face_is_exposed(4, 5) and ByteCrafterWorld._face_is_exposed(3, 0), "faces behind transparent leaves must be drawn")
	_check(not ByteCrafterWorld._face_is_exposed(5, 5) and not ByteCrafterWorld._face_is_exposed(2, 3), "leaf-to-leaf and solid-to-solid faces must stay culled")
	# Copas nunca substituem terreno sólido.
	var tree_blocks: Dictionary = world.get("_tree_blocks")
	var leaves_over_terrain := 0
	for key: Variant in tree_blocks.keys():
		var cell: Vector3i = key
		if int(tree_blocks[cell]) == 5 and int(world.call("_base_block", cell)) != 0:
			leaves_over_terrain += 1
	_check(leaves_over_terrain == 0, "tree crowns must not overwrite solid terrain")
	# Borda de chunk: remover o bloco e recolocar mantém as duas faces coerentes.
	var edge := Vector3i(15, world.terrain_height(15, 4), 4)
	var original := world.get_block_at(edge)
	_check(world.set_block_at(edge, 0), "an edge voxel must be removable")
	_check(world.set_block_at(edge, original), "an edge voxel must be restorable")
	for coord: Vector2i in [Vector2i(0, 0), Vector2i(1, 0)]:
		var edge_body := chunks.get(coord) as StaticBody3D
		if edge_body != null:
			_check(_chunk_mesh_vertex_count(edge_body) == _count_expected_faces(world, coord) * 6, "chunk %s must stay consistent after an edge edit" % [coord])
	world.free()


func _test_playable_loop() -> void:
	var harvested_fruit_cell := Vector3i.ZERO
	var game := GAME_SCENE.instantiate()
	get_tree().root.add_child(game)
	for _frame: int in 8:
		await get_tree().process_frame
	_check(str(game.get("_screen")) == "title", "the game must open on its title screen")
	_check(I18n.t("app.title") == "ByteCrafter", "the game autoloads must be available in the playable scene")
	var title_screen := game.get("_title_screen") as Control
	var menu_background := title_screen.find_child("MenuBackground", true, false) as TextureRect if title_screen != null else null
	_check(menu_background != null and menu_background.texture != null, "the title menu must show the user-provided full-screen artwork")
	var settings_store := game.get("_settings_store") as ByteCrafterSettingsStore
	var settings_panel := game.get("_settings_panel") as ByteCrafterSettingsPanel
	_check(settings_store != null and settings_panel != null, "the title menu must initialize persistent options and their panel")
	var movement_events := InputMap.action_get_events("move_up")
	var has_keyboard_binding := false
	var has_joypad_binding := false
	for movement_event: InputEvent in movement_events:
		if movement_event is InputEventKey:
			has_keyboard_binding = true
		if movement_event is InputEventJoypadMotion:
			has_joypad_binding = true
	_check(has_keyboard_binding and has_joypad_binding, "movement must have default keyboard and gamepad bindings")
	var original_save_key: InputEventKey
	for control_event: InputEvent in InputMap.action_get_events("save_game"):
		if control_event is InputEventKey:
			original_save_key = control_event.duplicate() as InputEventKey
			break
	if settings_store != null:
		game.call("_begin_binding_capture", "save_game", "keyboard")
		var remapped_key := InputEventKey.new()
		remapped_key.keycode = KEY_F6
		remapped_key.physical_keycode = KEY_F6
		remapped_key.pressed = true
		game.call("_capture_settings_binding", remapped_key)
		var found_f6 := false
		for control_event: InputEvent in InputMap.action_get_events("save_game"):
			if control_event is InputEventKey and control_event.keycode == KEY_F6:
				found_f6 = true
		_check(found_f6, "the controls menu must capture and apply a keyboard rebind")
		if original_save_key != null:
			settings_store.set_binding("save_game", "keyboard", original_save_key)
		settings_panel.open_settings(false)
		_check(settings_panel.is_settings_open(), "the title settings button must open the tabbed options panel")
		settings_panel.close_active()
		_check(not settings_panel.is_settings_open(), "the settings panel must close without entering gameplay")
		var difficulty_choices: Array[String] = []
		var difficulty_listener := func(value: String) -> void:
			difficulty_choices.append(value)
		var start_world_callable := Callable(game, "_start_new_world")
		if settings_panel.new_world_requested.is_connected(start_world_callable):
			settings_panel.new_world_requested.disconnect(start_world_callable)
		settings_panel.new_world_requested.connect(difficulty_listener)
		settings_panel.open_difficulty_selector("normal")
		settings_panel.call("_select_difficulty", "hard")
		settings_panel.call("_confirm_new_world")
		settings_panel.new_world_requested.disconnect(difficulty_listener)
		settings_panel.new_world_requested.connect(start_world_callable)
		_check(difficulty_choices == ["hard"] and not settings_panel.is_difficulty_open(), "solo world creation must emit the selected difficulty before starting")
		var continue_choices: Array[String] = []
		var continue_listener := func(value: String) -> void:
			continue_choices.append(value)
		var continue_callable := Callable(game, "_continue_with_difficulty")
		if settings_panel.continue_requested.is_connected(continue_callable):
			settings_panel.continue_requested.disconnect(continue_callable)
		settings_panel.continue_requested.connect(continue_listener)
		settings_panel.open_difficulty_selector("normal", false)
		settings_panel.call("_select_difficulty", "easy")
		settings_panel.call("_confirm_new_world")
		settings_panel.continue_requested.disconnect(continue_listener)
		settings_panel.continue_requested.connect(continue_callable)
		_check(continue_choices == ["easy"], "continuing a solo save must emit its selected session difficulty")
		settings_store.set_value("gameplay", "monsters", true, false)
		game.set("_difficulty", "normal")
	game.call("_reset_player_profile")
	game.call("_create_world", 120303788, [])
	game.call("_set_selected_avatar", "girl2")
	game.call("_enter_game")
	for _frame: int in 18:
		await get_tree().physics_frame
	var world: ByteCrafterWorld = game.get("_world") as ByteCrafterWorld
	var player: ByteCrafterPlayer = game.get("_player") as ByteCrafterPlayer
	var inventory: Dictionary = game.get("_inventory")
	var enemies: Array = game.get("_enemies")
	var gui_inventory_state := game.get("_inventory_state") as ByteCrafterInventoryStack
	var gui_hotbar_slots: Array = game.get("_inventory_hotbar_slots")
	if player != null and world != null:
		var jump_apex := ByteCrafterPlayer.JUMP_VELOCITY * ByteCrafterPlayer.JUMP_VELOCITY / (2.0 * ByteCrafterPlayer.GRAVITY)
		_check(is_equal_approx(jump_apex, 2.5) and is_equal_approx(ByteCrafterMovement.STEP_HEIGHT, 1.0), "player jump reaches 2.5 blocks and automatic step-up is capped at one block")
		_check(ByteCrafterPlayer.STEP_UP_LOCOMOTION == "run", "automatic step-up without jumping must use the running animation, not the jump clip")
		var water_surface := -INF
		var water_column := Vector3.ZERO
		for water_x: int in range(-100, 101, 4):
			for water_z: int in range(-100, 101, 4):
				var candidate := Vector3(float(water_x) + 0.5, 0.0, float(water_z) + 0.5)
				var candidate_surface := world.get_water_surface_height_at(candidate)
				var candidate_depth := candidate_surface - float(world.terrain_height(water_x, water_z) + 1)
				if is_finite(candidate_surface) and candidate_depth >= 0.45:
					water_surface = candidate_surface
					water_column = candidate
					break
			if is_finite(water_surface):
				break
		var fish_count := 0
		var fish_in_water := false
		for fish: ByteCrafterCreature in game.get("_fish"):
			fish_count += 1
			fish_in_water = fish_in_water or world.is_actor_in_water(fish.global_position, 0.4)
		_check(is_finite(water_surface) and world.is_actor_in_water(Vector3(water_column.x, water_surface - 0.2, water_column.z), 0.4), "the voxel world must recognize an actor intersecting water")
		_check(fish_count > 0 and fish_in_water, "fish must spawn and swim inside generated water columns")
		if player.can_control:
			var game_was_processing := game.is_processing()
			var game_was_physics_processing := game.is_physics_processing()
			game.set_process(false)
			game.set_physics_process(false)
			for _floor_frame: int in 30:
				if player.is_on_floor():
					break
				await get_tree().physics_frame
			player.velocity = Vector3.ZERO
			var jump_start_y := player.global_position.y
			Input.action_press("jump")
			for _jump_frame: int in 28:
				await get_tree().physics_frame
			Input.action_release("jump")
			var jump_gain := player.global_position.y - jump_start_y
			_check(jump_gain > 2.1 and jump_gain <= 2.8, "a grounded jump must physically rise close to its 2.5-block apex")
			for _land_frame: int in 48:
				if player.is_on_floor():
					break
				await get_tree().physics_frame
			var saved_player_transform := player.global_transform
			var step_x := floori(player.global_position.x) + 0.5
			var step_z := floori(player.global_position.z) + 0.5
			var step_ground := world.terrain_height(floori(step_x), floori(step_z))
			var step_wall := StaticBody3D.new()
			step_wall.name = "MovementRegressionStep"
			var step_shape := CollisionShape3D.new()
			var step_box := BoxShape3D.new()
			step_box.size = Vector3.ONE
			step_shape.shape = step_box
			step_wall.add_child(step_shape)
			get_tree().root.add_child(step_wall)
			step_wall.global_position = Vector3(step_x + 1.0, float(step_ground) + 1.5, step_z)
			player.global_transform = Transform3D(Basis.IDENTITY, Vector3(step_x, float(step_ground) + 1.03, step_z))
			player.velocity = Vector3.ZERO
			for _settle_frame: int in 10:
				await get_tree().physics_frame
				if player.is_on_floor():
					break
			var player_physics_was_enabled := player.is_physics_processing()
			player.set_physics_process(false)
			var climbed_one_block := false
			for _step_frame: int in 60:
				player.velocity.x = 4.0
				player.velocity.z = 0.0
				var stepped := ByteCrafterMovement.move_with_step(player, 1.0 / float(Engine.physics_ticks_per_second))
				if stepped and player.global_position.y > float(step_ground) + 1.65:
					climbed_one_block = true
					break
				await get_tree().physics_frame
			_check(climbed_one_block, "the player must automatically step onto a one-block obstacle without jumping")
			player.global_transform = Transform3D(Basis.IDENTITY, Vector3(step_x, float(step_ground) + 1.03, step_z))
			player.velocity = Vector3.ZERO
			for _settle_water_step: int in 10:
				await get_tree().physics_frame
			var climbed_from_water := false
			for _water_step_frame: int in 60:
				player.velocity.x = 4.0
				player.velocity.z = 0.0
				var stepped_from_water := ByteCrafterMovement.move_with_step(player, 1.0 / float(Engine.physics_ticks_per_second), true, true)
				if stepped_from_water and player.global_position.y > float(step_ground) + 1.65:
					climbed_from_water = true
					break
				await get_tree().physics_frame
			_check(climbed_from_water, "an actor leaving water must be able to step onto a one-block bank")
			step_wall.queue_free()
			player.global_transform = saved_player_transform
			player.velocity = Vector3.ZERO
			player.set_physics_process(player_physics_was_enabled)
			game.set_process(game_was_processing)
			game.set_physics_process(game_was_physics_processing)
			await get_tree().process_frame
	if gui_inventory_state != null and gui_hotbar_slots.size() == 9:
		var original_gui_slot_stack: Variant = gui_inventory_state.stack_at(0)
		gui_inventory_state.set_stack(0, "frutas", 3)
		game.call("_sync_legacy_slot_arrays_from_state")
		game.call("_refresh_hud")
		game.call("_toggle_crafting")
		await get_tree().process_frame
		var gui_test_slot := gui_hotbar_slots[0] as Control
		var click_position := gui_test_slot.get_global_rect().get_center()
		var craft_panel := game.get("_craft_panel") as Control
		_check(craft_panel != null and craft_panel.visible and gui_test_slot.visible and craft_panel.get_global_rect().has_point(click_position) and gui_test_slot.get_global_rect().has_point(click_position), "the clickable test point must be inside a visible backpack slot")
		var click_event := InputEventMouseButton.new()
		click_event.button_index = MOUSE_BUTTON_LEFT
		click_event.pressed = true
		click_event.position = click_position
		click_event.global_position = click_position
		get_viewport().push_input(click_event, true)
		await get_tree().process_frame
		var slot_click_picked_stack := gui_inventory_state.cursor != null and str(gui_inventory_state.cursor.get("item", "")) == "frutas" and int(gui_inventory_state.cursor.get("count", 0)) == 3 and gui_inventory_state.get_count(0) == 0
		_check(slot_click_picked_stack, "clicking a visible hotbar slot in the open backpack must pick its stack into the cursor (cursor=%s, slot_count=%d)" % [str(gui_inventory_state.cursor), gui_inventory_state.get_count(0)])
		var click_release := click_event.duplicate() as InputEventMouseButton
		click_release.pressed = false
		get_viewport().push_input(click_release, true)
		click_event.pressed = true
		get_viewport().push_input(click_event, true)
		await get_tree().process_frame
		_check(gui_inventory_state.cursor == null and gui_inventory_state.get_count(0) == 3, "clicking the slot again must place the cursor stack back into the slot")
		click_release = click_event.duplicate() as InputEventMouseButton
		click_release.pressed = false
		get_viewport().push_input(click_release, true)
		gui_inventory_state.cursor = null
		if original_gui_slot_stack is Dictionary:
			gui_inventory_state.set_stack(0, original_gui_slot_stack.get("item", null), int(original_gui_slot_stack.get("count", 0)))
		else:
			gui_inventory_state.clear_slot(0)
		game.call("_sync_legacy_slot_arrays_from_state")
		game.call("_refresh_hud")
		game.call("_toggle_crafting")
	if settings_store != null and player != null:
		_check(world != null and int(world.get("_stream_radius")) == int(settings_store.get_value("gameplay", "chunk_radius", 2)), "the selected chunk distance must configure the generated world")
		var initial_music_volume := float(settings_store.get_value("audio", "music", 0.85))
		var music_bus := AudioServer.get_bus_index("Music")
		settings_store.set_value("audio", "music", 0.37, false)
		game.call("_on_settings_changed", "audio", "music")
		_check(music_bus >= 0 and is_equal_approx(AudioServer.get_bus_volume_db(music_bus), linear_to_db(0.37)), "the music slider must apply to its dedicated audio bus")
		settings_store.set_value("audio", "music", initial_music_volume, false)
		game.call("_on_settings_changed", "audio", "music")
		var initial_effects_volume := float(settings_store.get_value("audio", "effects", 0.90))
		var effects_bus := AudioServer.get_bus_index("SFX")
		settings_store.set_value("audio", "effects", 0.42, false)
		game.call("_on_settings_changed", "audio", "effects")
		_check(effects_bus >= 0 and is_equal_approx(AudioServer.get_bus_volume_db(effects_bus), linear_to_db(0.42)), "the effects slider must apply to its dedicated audio bus")
		settings_store.set_value("audio", "effects", initial_effects_volume, false)
		game.call("_on_settings_changed", "audio", "effects")
		var postprocess := game.get("_postprocess_rect") as ColorRect
		settings_store.set_value("video", "shader", "retrobit", false)
		game.call("_on_settings_changed", "video", "shader")
		var retro_material := postprocess.material as ShaderMaterial if postprocess != null else null
		_check(postprocess != null and postprocess.visible and retro_material != null and retro_material.shader != null and retro_material.shader.resource_path.ends_with("bytecrafter_retrobit.gdshader"), "Retrobit must load as an active world-image filter")
		settings_store.set_value("video", "shader", "celshading", false)
		game.call("_on_settings_changed", "video", "shader")
		var cel_material := postprocess.material as ShaderMaterial if postprocess != null else null
		_check(postprocess != null and cel_material != null and cel_material.shader != null and cel_material.shader.resource_path.ends_with("bytecrafter_celshading.gdshader"), "cel shading must load its own screen-space outline filter")
		settings_store.set_value("video", "shader", "normal", false)
		game.call("_on_settings_changed", "video", "shader")
		_check(postprocess != null and not postprocess.visible and postprocess.material == null, "normal rendering must remove the post-process filter")
		var camera_fov := player.camera.fov
		settings_store.set_value("gameplay", "fov", 88.0, false)
		game.call("_on_settings_changed", "gameplay", "fov")
		_check(is_equal_approx(player.camera.fov, 88.0), "the field-of-view slider must update the active player camera")
		settings_store.set_value("gameplay", "fov", camera_fov, false)
		game.call("_on_settings_changed", "gameplay", "fov")
		var saved_difficulty := str(game.get("_difficulty"))
		var saved_health := float(game.get("_health"))
		game.set("_difficulty", "easy")
		var easy_limit := int(game.call("_active_enemy_limit"))
		game.set("_damage_invulnerability", 0.0)
		game.call("_damage_player", 1.0, "Teste")
		var easy_damage := saved_health - float(game.get("_health"))
		game.set("_health", saved_health)
		game.set("_damage_invulnerability", 0.0)
		game.set("_difficulty", "hard")
		var hard_limit := int(game.call("_active_enemy_limit"))
		game.call("_damage_player", 1.0, "Teste")
		var hard_damage := saved_health - float(game.get("_health"))
		game.set("_health", saved_health)
		game.set("_damage_invulnerability", 0.0)
		game.set("_difficulty", saved_difficulty)
		_check(easy_limit == 3 and hard_limit == 7 and hard_damage > easy_damage, "easy and hard difficulties must change enemy caps and incoming damage")
		settings_store.set_value("gameplay", "monsters", false, false)
		_check(not bool(game.call("_monsters_enabled")), "the gameplay options must expose a working hostile-monster toggle")
		settings_store.set_value("gameplay", "monsters", true, false)
	var village_system := game.get("_village_system") as ByteCrafterVillageSystem
	_check(village_system != null and village_system.get_village_count() >= 1 and village_system.get_villager_count() >= 3, "the deterministic spawn village must create its houses, market, and three villagers")
	var villager_rigs_aligned := village_system != null
	var villager_animations_ready := village_system != null
	if village_system != null:
		for village_node: Node in village_system.get_children():
			for villager_node: Node in village_node.get_children():
				if villager_node is ByteCrafterVillager:
					var villager := villager_node as ByteCrafterVillager
					var model_root := villager.get("_model_root") as Node3D
					villager_rigs_aligned = villager_rigs_aligned and model_root != null and is_equal_approx(model_root.scale.y, 0.86) and is_equal_approx(absf(model_root.rotation.y), PI)
					var controller := villager.get_node_or_null("VillagerAnimationController") as RigAnimationController
					villager_animations_ready = villager_animations_ready and controller != null and controller.has_functional_animation()
					if controller != null:
						controller.set_locomotion_state("walk")
						villager_animations_ready = villager_animations_ready and controller.get_state() == "walk"
						controller.play_action("reaction")
						villager_animations_ready = villager_animations_ready and controller.get_state() == "reaction"
	_check(villager_rigs_aligned, "male/female FBX rigs must be scaled to their collider and face the village direction")
	_check(villager_animations_ready, "villagers must use rigged locomotion and action animations")
	var merchant := village_system.get_nearest_villager(player.global_position, 500.0) if village_system != null else null
	if merchant != null:
		merchant.set_physics_process(false)
		merchant.global_position += Vector3(0.35, 0.0, 0.0)
		var saved_villager_position := merchant.global_position
		var village_snapshot: Array = village_system.serialize_state()
		var restored_system := ByteCrafterVillageSystem.new()
		get_tree().root.add_child(restored_system)
		restored_system.configure(world, world.world_seed, player.global_position, village_snapshot, bool(game.call("is_daytime")))
		var restored_villager: ByteCrafterVillager = null
		for village_node: Node in restored_system.get_children():
			for villager_node: Node in village_node.get_children():
				if villager_node is ByteCrafterVillager and (villager_node as ByteCrafterVillager).display_name == merchant.display_name:
					restored_villager = villager_node as ByteCrafterVillager
		_check(restored_villager != null and restored_villager.global_position.distance_to(saved_villager_position) < 0.001, "restoring a village snapshot must preserve a villager's saved world position")
		restored_system.free()
		merchant.set_physics_process(true)
	var player_cell := Vector3i(floori(player.global_position.x), floori(player.global_position.y), floori(player.global_position.z))
	_check(bool(game.call("_placement_overlaps_player", player_cell)), "placement validation must detect overlap with the player collider")
	_check(str(game.get("_screen")) == "game", "starting a new world must enter gameplay")
	_check(player != null and player.can_control, "the player must become controllable in a new world")
	# Hotbar de nove slots: as teclas 1–9 precisam alcançar todos os slots.
	for key_offset: int in 9:
		var hotbar_key := InputEventKey.new()
		hotbar_key.keycode = KEY_1 + key_offset
		hotbar_key.pressed = true
		game.call("_input", hotbar_key)
		_check(int(game.get("_selected_slot")) == key_offset, "hotbar key %d must select slot %d" % [key_offset + 1, key_offset])
	var saved_world_props: Array[Node3D] = game.get("_world_props")
	var isolated_world_props: Array[Node3D] = []
	var click_test_door := ByteCrafterProp.new()
	click_test_door.configure("porta", Vector3i(0, 0, 0))
	game.add_child(click_test_door)
	var camera_forward := -player.camera.global_basis.z
	camera_forward.y = 0.0
	camera_forward = camera_forward.normalized()
	click_test_door.global_position = player.camera.global_position + camera_forward * 2.0 - Vector3.UP
	click_test_door.global_rotation.y = atan2(-camera_forward.x, -camera_forward.z)
	isolated_world_props.append(click_test_door)
	game.set("_world_props", isolated_world_props)
	game.set("_village_system", null)
	await get_tree().physics_frame
	var door_hit: Dictionary = game.call("_raycast_target")
	_check(game.call("_prop_from_raycast_hit", door_hit) == click_test_door, "the crosshair ray must identify the door collider")
	var interact_key := InputEventKey.new()
	interact_key.keycode = KEY_F
	interact_key.physical_keycode = KEY_F
	interact_key.pressed = true
	game.call("_input", interact_key)
	_check(click_test_door.is_open, "pressing F while aiming near a door must open it")
	click_test_door.set_open(false)
	await get_tree().physics_frame
	var right_click := InputEventMouseButton.new()
	right_click.button_index = MOUSE_BUTTON_RIGHT
	right_click.pressed = true
	game.call("_input", right_click)
	_check(click_test_door.is_open, "right-clicking a door must open it instead of using the held item")
	click_test_door.set_open(false)
	await get_tree().physics_frame
	var left_click := InputEventMouseButton.new()
	left_click.button_index = MOUSE_BUTTON_LEFT
	left_click.pressed = true
	game.call("_input", left_click)
	_check(click_test_door.is_open, "left-clicking a door must open it instead of attacking/mining")
	game.set("_world_props", saved_world_props)
	game.set("_village_system", village_system)
	click_test_door.queue_free()
	await get_tree().physics_frame
	var no_target_interact_key := InputEventKey.new()
	no_target_interact_key.keycode = KEY_F
	no_target_interact_key.physical_keycode = KEY_F
	no_target_interact_key.pressed = true
	game.call("_input", no_target_interact_key)
	_check(not (game.get("_craft_panel") as Control).visible, "F without a target or nearby table must not open the crafting panel")
	game.call("_select_slot", 0)
	_check(world != null and world.get_chunk_count() > 0, "the open world must stream terrain chunks")
	var async_chunk_wait_frames := 0
	while world != null and int(world.get("_async_chunks_installed")) == 0 and async_chunk_wait_frames < 240:
		await get_tree().process_frame
		async_chunk_wait_frames += 1
		_check(world != null and int(world.get("_async_chunks_installed")) > 0, "surrounding chunks must be meshed by a worker and installed on the main thread")
	var voxel_material := world.get("_voxel_material") as StandardMaterial3D if world != null else null
	_check(voxel_material != null and voxel_material.cull_mode == BaseMaterial3D.CULL_DISABLED, "voxel chunks must render both sides of faces so top surfaces cannot vanish")
	var new_atlas_texture := load("res://assets/textures/voxel_atlas.png") as Texture2D
	_check(new_atlas_texture != null and new_atlas_texture.get_size() == Vector2(512, 512), "the supplied 512×512 voxel texture atlas must replace the previous atlas")
	_check(ByteCrafterWorld.ATLAS_COLUMNS == 16 and ByteCrafterWorld.ATLAS_ROWS == 16, "voxel UVs must use a 16×16 atlas grid")
	var atlas_indices_valid := true
	for tile_list_value: Variant in ByteCrafterWorld.BLOCK_ATLAS_TILES.values():
		for tile_value: Variant in tile_list_value:
			atlas_indices_valid = atlas_indices_valid and int(tile_value) >= 0 and int(tile_value) < ByteCrafterWorld.ATLAS_COLUMNS * ByteCrafterWorld.ATLAS_ROWS
	_check(atlas_indices_valid, "all block textures must reference tiles within the new atlas")
	var game_hud := game.get("_game_hud") as Control
	_check(game_hud != null and game_hud.mouse_filter == Control.MOUSE_FILTER_IGNORE, "the full-screen gameplay HUD must pass mouse events through")
	var cloud_layer := game.get("_cloud_layer") as MeshInstance3D
	_check(cloud_layer != null and cloud_layer.mesh is SphereMesh, "the cloud dome must remain visible across the sky at horizon level")
	if player != null and world != null:
		var spawn_position: Vector3 = world.get_spawn_position()
		var spawn_height := world.terrain_height(floori(spawn_position.x), floori(spawn_position.z))
		_check(player.is_on_floor() and player.global_position.y >= float(spawn_height) + 0.9, "the player must stand on solid terrain at spawn instead of falling through it")
		var creatures: Array = game.get("_creatures")
		_check(creatures.size() == 5, "a new world must populate chicken, horse, sheep and dog away from spawn")
		var creature_species: Array[String] = []
		for creature_value: Variant in creatures:
			var creature := creature_value as ByteCrafterCreature
			if creature != null:
				creature_species.append(creature.species)
				_check(float(creature.get("_size_variation")) >= 0.8 and float(creature.get("_size_variation")) <= 1.2, "animals must vary only between eighty and one hundred twenty percent of their base size")
		_check("chicken" in creature_species and "horse" in creature_species and "sheep" in creature_species and "dog" in creature_species, "the world must include all requested huntable animal species")
		var flora: Dictionary = world.get("_flora_blocks")
		var generated_plant_blocks: Array[int] = []
		for flora_value: Variant in flora.values():
			generated_plant_blocks.append(int(flora_value))
		var generated_blocks_are_plants := not generated_plant_blocks.is_empty()
		for generated_block: int in generated_plant_blocks:
				generated_blocks_are_plants = generated_blocks_are_plants and (generated_block in [27, 28, 29, 30, 31, 34, 35, 36])
		var fallen_fruit_cells: Dictionary = world.get("_fallen_fruit_cells")
		var fallen_fruit_drops: Dictionary = game.get("_fallen_fruit_drop_ids")
		_check(generated_blocks_are_plants and not fallen_fruit_cells.is_empty(), "the world must generate sparse edible plants and separate fallen-fruit cells")
		_check(not fallen_fruit_drops.is_empty(), "fallen fruit must spawn as regular touch-collected inventory drops")
		_check(game.call("_drop_item_for_block", 27) == 16 and game.call("_drop_item_for_block", 28) == 8 and game.call("_drop_item_for_block", 29) == 30 and game.call("_drop_item_for_block", 30) == 31 and game.call("_drop_item_for_block", 31) == 32 and game.call("_drop_item_for_block", 32) == 8, "breaking or harvesting a plant block must drop its matching edible item")
		_check(game.call("_drop_item_for_block", 34) == 34 and game.call("_drop_item_for_block", 35) == 35 and game.call("_drop_item_for_block", 36) == 36, "mushrooms, bamboo and flowers must each drop themselves 1:1")
		_check(float(game.call("_break_duration", 34)) <= 0.25 and float(game.call("_break_duration", 35)) <= 0.25 and float(game.call("_break_duration", 36)) <= 0.25, "new decorative flora must break quickly")
		_check(game.get("_inventory_item_ids").has(48) and game.call("_is_placeable_voxel_item", 37) and game.call("_is_placeable_voxel_item", 48), "Cube World model blocks must be valid inventory and placeable voxel items")
		var bedroll_recipe := ByteCrafterGame.RECIPE_BOOK.find_grid_recipe([14, 14, 14, 13, 13, 13, null, null, null], "inventory")
		_check(bedroll_recipe.get("item", null) == "bedroll", "portable bed recipe must use three wool over three leather")
		var fruit_drop_cells: Dictionary = game.get("_fruit_drop_cells")
		var fruit_drop_id := int(fruit_drop_cells.keys()[0])
		harvested_fruit_cell = fruit_drop_cells[fruit_drop_id]
		var fruit_count_before_touch := int(game.get("_inventory").get("frutas", 0))
		game.call("_on_drop_touched", fruit_drop_id)
		_check(int(game.get("_inventory").get("frutas", 0)) == fruit_count_before_touch + 1 and world.get_block_at(harvested_fruit_cell) == 0, "touching a fallen-fruit drop must collect one fruit and permanently remove its source")
		(game.get("_inventory") as Dictionary)["frutas"] = fruit_count_before_touch
		_check(game.get("_inventory_item_ids").has(29) and ByteCrafterDrop.DROP_MODELS.has(29), "eggs must be a collectable inventory item represented by the egg asset")
		var egg_pickup := ByteCrafterDrop.new()
		egg_pickup.configure(9001, 29, 1)
		game.add_child(egg_pickup)
		await get_tree().process_frame
		var egg_model := egg_pickup.get_node_or_null("AssetDrop") as Node3D
		var egg_bounds: AABB = egg_pickup.call("_collect_model_bounds", egg_model, Transform3D.IDENTITY) if egg_model != null else AABB()
		var egg_extent := maxf(maxf(egg_bounds.size.x, egg_bounds.size.y), egg_bounds.size.z)
		_check(egg_model != null and egg_extent <= 0.31 and egg_extent > 0.1, "egg pickup model must stay under one third of a voxel instead of scaling with source-asset units")
		egg_pickup.queue_free()
		var food_inventory: Dictionary = game.get("_inventory")
		var saved_food := float(game.get("_food"))
		var saved_fruit_count := int(food_inventory.get("frutas", 0))
		var food_hotbar: Array = game.get("_hotbar_ids")
		var saved_hotbar_item: Variant = food_hotbar[0]
		food_inventory["frutas"] = 1
		food_hotbar[0] = "frutas"
		game.set("_food", 10.0)
		_check(bool(game.call("_try_consume_selected_food")) and is_equal_approx(float(game.get("_food")), 15.0) and int(food_inventory["frutas"]) == 0, "selected fruit must be consumed and restore hunger")
		food_inventory["frutas"] = saved_fruit_count
		var saved_egg_count := int(food_inventory.get(29, 0))
		food_inventory[29] = 1
		food_hotbar[0] = 29
		game.set("_food", 10.0)
		_check(bool(game.call("_try_consume_selected_food")) and is_equal_approx(float(game.get("_food")), 13.5) and int(food_inventory[29]) == 0, "selected egg must be consumed and restore hunger")
		food_inventory[29] = saved_egg_count
		for food_item_id: int in [30, 31, 32]:
			var saved_vegetable_count := int(food_inventory.get(food_item_id, 0))
			food_inventory[food_item_id] = 1
			food_hotbar[0] = food_item_id
			game.set("_food", 10.0)
			var vegetable_eaten := bool(game.call("_try_consume_selected_food"))
			_check(vegetable_eaten and float(game.get("_food")) > 10.0 and int(food_inventory[food_item_id]) == 0, "%s must be edible and restore hunger" % ByteCrafterGame.ITEM_NAMES[food_item_id])
			food_inventory[food_item_id] = saved_vegetable_count
		var saved_food_stacks: Dictionary = {}
		for food_item_id: Variant in ByteCrafterGame.FOOD_ORDER:
			var inventory_key: Variant = game.call("_food_inventory_key", food_item_id)
			if saved_food_stacks.has(inventory_key):
				continue
			saved_food_stacks[inventory_key] = int(food_inventory.get(inventory_key, 0))
			food_inventory[inventory_key] = 0
		food_inventory["carne_cozida"] = 1
		game.set("_food", 5.0)
		game.call("_craft", "eat")
		var eat_button := game.get("_eat_food") as Button
		_check(eat_button != null and eat_button.text == "Comer" and int(food_inventory["carne_cozida"]) == 0 and float(game.get("_food")) == 12.0, "the backpack's Comer button must consume available cooked meat as well as plants and fruit")
		for inventory_key: Variant in saved_food_stacks:
			food_inventory[inventory_key] = int(saved_food_stacks[inventory_key])
		food_hotbar[0] = saved_hotbar_item
		game.set("_food", saved_food)
		_check(ByteCrafterCreature.SPECIES["horse"]["drops"] == [[12, 2], [13, 1]], "horse must provide meat and leather")
		_check(ByteCrafterCreature.SPECIES["sheep"]["drops"] == [[14, 2], [12, 1]], "sheep must provide wool and meat")
		_check(ByteCrafterCreature.SPECIES["dog"]["drops"] == [[12, 2], [15, 1]], "dog must provide meat and lard")
		_check(RECIPE_BOOK.find_grid_recipe([7, null, 7, null, null, null, 7, null, 7]).get("id", "") == "crafting_table", "four planks must craft a physical crafting table")
		_check(RECIPE_BOOK.find_grid_recipe([12, null, null, null, 15, null, null, null, null]).get("id", "") == "cooked_meat", "raw meat and lard must have a cooking recipe")
		_check(game.has_method("_place_crafting_table"), "the game must expose physical crafting table placement")
		_check(game.has_method("_break_duration"), "the game must expose tool-aware block breaking")
		_check(float(game.call("_break_duration", 3)) > 1.0, "stone must be slow without a pickaxe")
		_check(float(game.call("_break_duration", 4)) < 1.0 and float(game.call("_break_duration", 5)) < 1.0, "tree trunks and leaves must be breakable without a tool")
		_check(ByteCrafterWorld.BLOCK_NAMES[8] == "Musgo" and ByteCrafterWorld.BLOCK_NAMES[9] == "Gelo" and ByteCrafterWorld.BLOCK_NAMES[10] == "Basalto" and ByteCrafterWorld.BLOCK_NAMES[11] == "Cristal", "the world must expose the new biome block types")
		_check(world.has_method("get_biome") and world.get_biome(0, 0) in ["plains", "mossland", "frozen", "volcanic", "crystal"], "terrain generation must classify every coordinate into a known biome")
		_check(RECIPE_BOOK.find_grid_recipe([18, null, null, null, 15, null, null, null, null]).get("id", "") == "crystal_lantern", "crystal biomes must unlock a crystal lantern craft")
		_check(world.has_method("_populate_structure_cache") and world.has_method("get_biome"), "the world must expose deterministic structure and biome generation")
		var leaf_tiles: Array = ByteCrafterWorld.BLOCK_ATLAS_TILES[5]
		_check(leaf_tiles == [12, 13, 12, 14, 12, 13], "leaf side and cap faces must use their assigned tiles from the new atlas")
		_check(RECIPE_BOOK.find_grid_recipe([3, 3, null, 3, 15, null, null, null, null]).get("id", "") == "iron_ingot", "stone and lard must smelt into an iron ingot")
		_check(RECIPE_BOOK.find_grid_recipe([17, 17, 17, null, "gravetos", null, null, "gravetos", null]).get("id", "") == "iron_pickaxe", "iron pickaxe must have a complete shaped recipe")
		_check(RECIPE_BOOK.find_grid_recipe([13, 13, 13, 13, null, 13, null, null, null]).get("id", "") == "leather_helmet", "leather helmet must have a complete shaped recipe")
		_check(RECIPE_BOOK.find_grid_recipe([13, null, 13, 13, 13, 13, 13, 13, 13]).get("id", "") == "leather_chestplate", "leather chestplate must have a complete shaped recipe")
		_check(game.has_method("_armor_damage_reduction"), "leather armor must expose a damage reduction calculation")
		var armor_inventory: Dictionary = game.get("_inventory")
		armor_inventory["armadura_couro_cabeca"] = 1
		armor_inventory["armadura_couro_peito"] = 1
		_check(is_equal_approx(float(game.call("_armor_damage_reduction")), 0.30), "two leather armor pieces must reduce incoming damage by thirty percent")
		armor_inventory["armadura_couro_cabeca"] = 0
		armor_inventory["armadura_couro_peito"] = 0
		_check(enemies.size() == 2, "a new daytime world must spawn slime and zombie; ET only appears at night")
		var enemy_types: Array[String] = []
		for enemy_value: Variant in enemies:
			var enemy := enemy_value as ByteCrafterEnemy
			if enemy != null:
				enemy_types.append(enemy.enemy_type)
				_check(enemy.get_node_or_null("SlimeAnimado") == null, "the legacy 2D slime sprite must not be used by the 3D enemy models")
				var collider_name := "SlimeCollider" if enemy.enemy_type == "slime" else "EnemyCollider"
				var collider := enemy.get_node_or_null(collider_name) as CollisionShape3D
				var capsule := collider.shape as CapsuleShape3D if collider != null else null
				var expected_height := 0.92 if enemy.enemy_type == "slime" else 1.8
				_check(capsule != null and is_equal_approx(capsule.height, expected_height), "each enemy must use a floor-respecting collider sized to its visual body")
				if enemy.enemy_type != "slime":
					var rig_model := enemy.get("_model_root") as Node3D
					_check(rig_model != null and absf(rig_model.rotation.x) < 0.001, "%s must keep its Y-up rig upright" % enemy.enemy_type)
				_check(enemy.get_node_or_null("Nameplate") != null and (enemy.get_node("Nameplate") as Label3D).text != "", "each enemy must remain identifiable in the world")
				var animation_controller := enemy.get_node_or_null("RigAnimationController")
				_check((enemy.enemy_type == "slime" and animation_controller == null) or (enemy.enemy_type != "slime" and animation_controller != null and animation_controller.has_functional_animation()), "ET and zombie must retain their functional original rig animation controller: " + enemy.enemy_type)
				if enemy.enemy_type == "zombie":
					var zombie_controller := animation_controller as RigAnimationController
					var zombie_player := zombie_controller.get("_source_player") as AnimationPlayer if zombie_controller != null else null
					if zombie_player == null and zombie_controller != null:
						zombie_player = zombie_controller.get("_target_player") as AnimationPlayer
					_check(zombie_controller != null and zombie_player != null and zombie_player.has_animation("zombie_idle") and zombie_player.has_animation("zombie_walk") and zombie_player.current_animation == "zombie_idle", "zombie must use the supplied idle/walk clips")
					if zombie_controller != null:
						zombie_controller.play_action("attack")
					_check(zombie_player != null and zombie_player.current_animation == "zombie_punch", "zombie attacks must use the supplied punch animation")
					if zombie_controller != null:
						zombie_controller.stop_action()
				var health_bar := enemy.get_node_or_null("HealthBar") as Label3D
				var health_back := enemy.get_node_or_null("HealthBarBack") as Label3D
				_check(health_bar != null and health_back != null and health_bar.text.length() > 0 and health_bar.text.length() <= 8, "each living enemy must keep a visible floating health bar while sunlight can reduce zombie health")
				_check(Vector2(enemy.global_position.x - player.global_position.x, enemy.global_position.z - player.global_position.z).length() < 16.0, "enemies must spawn close enough to be seen before they attack")
		_check("slime" in enemy_types and "zombie" in enemy_types and not ("et" in enemy_types), "daytime must keep ETs out of the encounter")
		var lunar_boss_spec: Dictionary = ByteCrafterEnemy.SPECS["boss"]
		var elite_boss_spec: Dictionary = ByteCrafterEnemy.MONSTER_ARCHETYPES["boss"]
		_check(lunar_boss_spec.get("hits", 0) == 8 and float(lunar_boss_spec.get("damage", 99.0)) <= 1.6 and float(lunar_boss_spec.get("cooldown", 0.0)) >= 1.8, "the lunar boss must stay durable but deal slower, non-lethal hits")
		_check(float(elite_boss_spec.get("damage", 99.0)) * 1.25 * 1.4 < 3.0, "even on hard difficulty at night, a boss-tier hit must not be a kill shot")
		_check(float(ByteCrafterEnemy.SPECS["shooter"].get("damage", 99.0)) <= 1.6 and float(ByteCrafterEnemy.SPECS["runner"].get("damage", 99.0)) <= 1.45 and float(ByteCrafterEnemy.SPECS["zombie"].get("damage", 99.0)) <= 2.0, "lunar ranged, fast, and zombie attacks must use the rebalanced damage values")
		_check(ByteCrafterEnemy.SPECS["boss"].get("aggro_range", 0.0) > 15.0, "the lunar boss must have an extended aggro range")
		_check(is_equal_approx(float(ByteCrafterEnemy.MODEL_SCALES["et"]), float(ByteCrafterEnemy.MODEL_SCALES["zombie"])), "ET visual scale must match the normal zombie reference")
		_check(ByteCrafterEnemy.MONSTER_CATALOG.size() == 37 and ByteCrafterEnemy.is_supported_type("orc") and ByteCrafterEnemy.is_supported_type("dragon_evolved"), "the new Quaternius roster must register all 37 hostile models")
		var normal_bundle_roll := ByteCrafterEnemy.pick_monster_type(false)
		var boss_bundle_roll := ByteCrafterEnemy.pick_monster_type(true)
		_check(not normal_bundle_roll.is_empty() and str(ByteCrafterEnemy.MONSTER_CATALOG[normal_bundle_roll].get("tier", "")) != "boss", "ordinary nights must select a non-boss pack monster")
		_check(not boss_bundle_roll.is_empty() and str(ByteCrafterEnemy.MONSTER_CATALOG[boss_bundle_roll].get("tier", "")) in ["elite", "boss"], "boss nights must select an elite or boss pack monster")
		var pack_enemy := ByteCrafterEnemy.new()
		pack_enemy.configure(player, game, "orc")
		pack_enemy.set_physics_process(false)
		game.add_child(pack_enemy)
		var pack_model := pack_enemy.get_node_or_null("OrcModelo") as Node3D
		var pack_loot: Array = pack_enemy.get_loot_table()
		_check(pack_model != null and pack_enemy.get_display_name() == "Orc" and pack_enemy.is_day_sensitive(), "a bundle enemy must instantiate its named model and sunlight behavior")
		_check(not pack_loot.is_empty() and int(pack_loot[0][0]) == 33, "new hostile monsters must drop the inventory Gema Verde")
		_check((ByteCrafterEnemy.LOOT_TABLES["et"] as Array).has(["shuriken", 1]) and (ByteCrafterEnemy.LOOT_TABLES["shooter"] as Array).has(["shuriken", 1]), "ET and lunar shooter must drop an actual disposable shuriken item")
		_check(game.call("_is_valid_item_id", "shuriken") and str(game.call("_item_short_name", "shuriken")) == "Shuriken", "shuriken must have its own inventory ID and name, separate from voxel 27")
		_check(ByteCrafterDrop.DROP_MODELS.has("shuriken") and not ByteCrafterDrop.DROP_MODELS.has(27) and ByteCrafterDrop.DROP_MODELS.has(10) and ByteCrafterDrop.DROP_MODELS.has(11), "lunar fragments/cores must not use the shuriken model or legacy block ID")
		_check(is_equal_approx(ByteCrafterPlayer.TOOL_VISUAL_SCALE, 0.25), "player equipment assets must be scaled to one quarter")
		_check(RigAnimationController.ACTION_STATES.has("work") and RigAnimationController.EXTERNAL_CLIP_SCENES.has("work"), "NPC work must use the downward work clip rather than the kicking hammer clip")
		_check(ByteCrafterPlayer.IDLE_DANCE_DELAY == 300.0 and ByteCrafterAvatar.LOCOMOTION_STATES.has("swim") and ByteCrafterAvatar.EXTERNAL_CLIP_SCENES.has("float"), "player idle dance must wait five minutes and water states must use swim/float clips")
		for clip_name: String in ["sleep1", "sleep2", "sleep3", "dance1", "dance2", "pickup"]:
			_check(ByteCrafterAvatar.EXTERNAL_CLIP_SCENES.has(clip_name) and RigAnimationController.EXTERNAL_CLIP_SCENES.has(clip_name), "player and NPC rigs must expose clip " + clip_name)
		pack_enemy.queue_free()
		var campfire_test := ByteCrafterProp.new()
		campfire_test.configure("fogueira", Vector3i(9000, 0, 0))
		game.add_child(campfire_test)
		var campfire_light := campfire_test.find_child("CampfireLight", true, false) as OmniLight3D
		_check(campfire_light != null and is_equal_approx(campfire_light.omni_range, 10.0), "campfire must illuminate a ten-block radius")
		campfire_test.queue_free()
		var gem_drop := ByteCrafterDrop.new()
		gem_drop.configure(99999, 33, 1)
		gem_drop.set_process(false)
		gem_drop.set_physics_process(false)
		game.add_child(gem_drop)
		_check(gem_drop.get_node_or_null("AssetDrop") != null and str(game.call("_item_short_name", 33)) == "Gema Verde", "Gema Verde must have its supplied 3D pickup model and inventory name")
		gem_drop.queue_free()
		for rigged_type: String in ["et", "boss"]:
			var rig_enemy := ByteCrafterEnemy.new()
			rig_enemy.configure(player, game, rigged_type)
			rig_enemy.set_physics_process(false)
			game.add_child(rig_enemy)
			var rig_model := rig_enemy.get("_model_root") as Node3D
			var rig_bounds: Vector2 = rig_enemy.call("_find_rig_vertical_bounds", rig_model) if rig_model != null else Vector2.ZERO
			var scaled_rig_height := (rig_bounds.y - rig_bounds.x) * rig_model.scale.y if rig_model != null else 0.0
			var rig_collider := rig_enemy.get_node_or_null("EnemyCollider") as CollisionShape3D
			var rig_capsule := rig_collider.shape as CapsuleShape3D if rig_collider != null else null
			_check(rig_model != null and absf(rig_model.rotation.x) < 0.001 and is_equal_approx(scaled_rig_height, 1.8) and rig_capsule != null and is_equal_approx(rig_capsule.height, 1.8), "%s must be upright and limited to normal 1.8 m height" % rigged_type)
			if rigged_type == "et":
				var et_controller := rig_enemy.get("_animation_controller") as RigAnimationController
				var et_player := et_controller.get("_source_player") as AnimationPlayer if et_controller != null else null
				if et_player == null and et_controller != null:
					et_player = et_controller.get("_target_player") as AnimationPlayer
				if et_controller != null:
					et_controller.set_locomotion_state("walk")
				_check(et_player != null and et_player.has_animation("et_wheelbarrow") and et_player.current_animation == "et_wheelbarrow", "ET must use the supplied walk clip")
			rig_enemy.queue_free()
		_check((ByteCrafterEnemy.LOOT_TABLES["boss"] as Array).size() == 3, "the lunar boss must have a multi-item loot table")
		_check(game.has_method("_try_attack_enemy"), "the game must expose the shared attack action for mouse and keyboard input")

		if not enemies.is_empty():
			var slime: ByteCrafterEnemy = enemies[0] as ByteCrafterEnemy
			var attack_origin: Vector3 = player.camera.global_position
			var attack_direction: Vector3 = -player.camera.global_basis.z + Vector3.DOWN * 0.22
			slime.global_position = attack_origin + attack_direction.normalized() * 2.0 - Vector3.UP * 0.67
			slime.set_physics_process(false)
			game.set("_attack_cooldown", 0.0)
			await get_tree().physics_frame
			var health_before := slime.health
			var xp_before_enemy := int(game.get("_xp"))
			var attack_landed := bool(game.call("_try_attack_enemy"))
			_check(attack_landed and slime.health < health_before, "the player's melee ray must hit a slime in reach")
			var slime_health_bar := slime.get_node_or_null("HealthBar") as Label3D
			_check(slime_health_bar != null and slime_health_bar.text.is_empty(), "a defeated enemy health bar must empty before its death cleanup")
			_check(bool(game.call("_try_attack_enemy")) == false, "attack cooldown must prevent an immediate second hit")
			slime.take_damage(10.0)
			_check(enemies.size() == 1, "defeating a slime must remove it from the active encounter")
			_check(int(game.get("_xp")) >= xp_before_enemy + slime.get_xp_reward(), "defeating an enemy must grant its configured XP reward")
			var drop_records: Dictionary = game.get("_drop_records")
			var gel_drop_id := -1
			for drop_id: Variant in drop_records.keys():
				if int((drop_records[drop_id] as Dictionary).get("item_id", 0)) == 9:
					gel_drop_id = int(drop_id)
					break
			_check(gel_drop_id >= 0, "defeated slimes must produce a collectible gel core")
			if gel_drop_id >= 0:
				game.call("_on_drop_touched", gel_drop_id)
			_check(int(inventory.get("gelatina", 0)) == 1, "collecting the slime core must add gel to the inventory")

		for avatar_id: String in ["boy", "girl", "boy2", "girl2"]:
			player.set_avatar_id(avatar_id)
			await get_tree().process_frame
			var avatar := player.get("_avatar_instance") as ByteCrafterAvatar
			_check(avatar != null and avatar.character_id == avatar_id, "each selectable avatar must be used by the local player: " + avatar_id)
			_check(avatar != null and avatar.get_skeleton() != null and avatar.get_animation_player() != null, "each imported player rig must include its skeleton and animation player: " + avatar_id)
			var avatar_animation := avatar.get_animation_player() if avatar != null else null
			_check(avatar_animation != null and avatar_animation.has_animation("walk") and avatar_animation.has_animation("run") and avatar_animation.has_animation("jump") and avatar_animation.has_animation("mine") and avatar_animation.has_animation("attack") and avatar_animation.has_animation("death"), "each selected rig must expose movement, jump, mining, attack, and death clips: " + avatar_id)
			_check(avatar_animation != null and avatar_animation.has_animation("swim") and avatar_animation.has_animation("float") and avatar_animation.has_animation("sleep1") and avatar_animation.has_animation("sleep2") and avatar_animation.has_animation("sleep3") and avatar_animation.has_animation("dance1") and avatar_animation.has_animation("dance2") and avatar_animation.has_animation("pickup"), "each player avatar must expose the supplied water, sleep, dance, and pickup clips: " + avatar_id)
			var avatar_mesh := avatar.find_child("model", true, false) as MeshInstance3D if avatar != null else null
			var avatar_material := avatar_mesh.get_active_material(0) as StandardMaterial3D if avatar_mesh != null else null
			_check(avatar_material != null and avatar_material.albedo_texture != null, "each selected rig must keep its supplied shaded texture: " + avatar_id)
			if avatar_id in ["boy2", "girl2"] and avatar != null and avatar_animation != null:
				var skeleton := avatar.get_skeleton()
				var source_animation := avatar.get_retarget_source_animation_player()
				_check(avatar.is_retargeting() and avatar.get_retarget_mapping_count() >= 20 and source_animation != null and source_animation.has_animation("walk"), "boy2/girl2 must retain a mapped Mixamo source for retargeting")
				var thigh_index := skeleton.find_bone("mixamorig_LeftUpLeg")
				var rest_rotation := skeleton.get_bone_global_rest(thigh_index).basis.get_rotation_quaternion()
				avatar.set_locomotion_state("walk")
				await get_tree().process_frame
				var override_rotation := skeleton.get_bone_global_pose_override(thigh_index).basis.get_rotation_quaternion()
				_check(not rest_rotation.is_equal_approx(override_rotation), "the retargeted walk clip must animate the CC thigh: " + avatar_id)
		player.set_avatar_id("girl2")
		await get_tree().process_frame
		var remote_id := 321
		game.call("_register_remote_player", remote_id)
		game.call("receive_player_pose", remote_id, Vector3(2.0, 5.0, 3.0), 0.65, "girl2", "walk")
		var remote_avatars: Dictionary = game.get("_remote_avatars")
		var remote_avatar := remote_avatars.get(remote_id) as ByteCrafterAvatar
		_check(remote_avatar != null and remote_avatar.character_id == "girl2" and remote_avatar.get_animation_state() == "walk", "LAN remote avatars must synchronize the chosen rig and locomotion state")
		game.call("_remove_remote_player", remote_id)
		player.set_third_person(true)
		_check(player.third_person and player.get_node("PlayerBody").visible, "third-person mode must show the player model")
		player.set_third_person(false)
		_check(not player.third_person and not player.get_node("PlayerBody").visible, "first-person mode must hide the player model")
		var start_position := player.global_position
		var forward_key := InputEventKey.new()
		forward_key.keycode = KEY_W
		forward_key.physical_keycode = KEY_W
		forward_key.pressed = true
		Input.parse_input_event(forward_key)
		for _frame: int in 12:
			await get_tree().physics_frame
		forward_key.pressed = false
		Input.parse_input_event(forward_key)
		_check(player.global_position.distance_to(start_position) > 0.08, "a physical W key event must move the player")
		player.set_third_person(true)
		var body_mesh := player.get_node("PlayerBody") as Node3D
		var right_start := player.global_position
		var body_yaw_before := body_mesh.rotation.y
		var right_key := InputEventKey.new()
		right_key.keycode = KEY_D
		right_key.physical_keycode = KEY_D
		right_key.pressed = true
		Input.parse_input_event(right_key)
		for _frame: int in 12:
			await get_tree().physics_frame
		right_key.pressed = false
		Input.parse_input_event(right_key)
		_check(player.global_position.x > right_start.x + 0.08, "D must retain lateral player movement")
		_check(absf(wrapf(body_mesh.rotation.y - body_yaw_before, -PI, PI)) > 0.25, "A/D movement must turn the visible body toward the movement direction")
		var spring_arm := player.get("_spring_arm") as SpringArm3D
		_check(spring_arm != null and spring_arm.get_hit_length() > 3.0, "third-person camera must extend behind the player rather than hit its own collider")
		var yaw_before_mouse := player.rotation.y
		var avatar_yaw_before_mouse := body_mesh.global_rotation.y
		var mouse_event := InputEventMouseMotion.new()
		mouse_event.relative = Vector2(150.0, 0.0)
		player.call("_apply_mouse_look", mouse_event.relative)
		await get_tree().process_frame
		_check(absf(wrapf(player.rotation.y - yaw_before_mouse, -PI, PI)) > 0.05, "horizontal mouse motion must rotate the player and camera")
		_check(absf(wrapf(body_mesh.global_rotation.y - avatar_yaw_before_mouse, -PI, PI)) > 0.05, "horizontal mouse motion must rotate the visible avatar with the camera")
		var pitch_before_mouse: float = float(player.get("_pitch"))
		var pitch_event := InputEventMouseMotion.new()
		pitch_event.relative = Vector2(0.0, 100.0)
		player.call("_apply_mouse_look", pitch_event.relative)
		await get_tree().process_frame
		_check(absf(float(player.get("_pitch")) - pitch_before_mouse) > 0.05, "vertical mouse motion must tilt the camera")
		player.set_third_person(false)
	if world != null:
		var coords := Vector3i(3, world.terrain_height(3, 3), 3)
		var block_id := world.get_block_at(coords)
		game.call("_request_block_change", coords, 0, 0)
		_check(world.get_block_at(coords) == 0, "the gameplay interaction must break a world block")
		var drop_nodes: Dictionary = game.get("_drop_nodes")
		var drop_ids: Array = drop_nodes.keys()
		_check(not drop_ids.is_empty(), "mined resources must appear as 3D collectibles")
		if not drop_ids.is_empty():
			var drop_records: Dictionary = game.get("_drop_records")
			var item_id := int((drop_records[int(drop_ids[0])] as Dictionary).get("item_id", block_id))
			for _drop_frame: int in 12:
				await get_tree().physics_frame
			var drop := drop_nodes[int(drop_ids[0])] as ByteCrafterDrop
			var drop_floor := world.terrain_height(floori(drop.global_position.x), floori(drop.global_position.z)) if drop != null else -999
			_check(drop != null and drop.global_position.y >= float(drop_floor) + 0.2, "drops must remain above the effective ground after terrain edits")
			var before_count := int(inventory.get("frutas", 0)) if item_id == 8 else int(inventory.get(item_id, 0))
			game.call("_on_drop_touched", int(drop_ids[0]))
			var after_count := int(inventory.get("frutas", 0)) if item_id == 8 else int(inventory.get(item_id, 0))
			_check(after_count == before_count + 1, "collecting a drop must add its resource to inventory")
			game.call("_request_block_change", coords, 2, 0)
			_check(world.get_block_at(coords) == 2, "the gameplay interaction must place a selected block")
			var expiry_drop_id := int(game.call("_allocate_drop_id"))
			game.call("_spawn_drop_local", expiry_drop_id, 1, player.global_position + Vector3.UP)
			var expiry_drop_nodes: Dictionary = game.get("_drop_nodes")
			var expiry_drop := expiry_drop_nodes.get(expiry_drop_id) as ByteCrafterDrop
			if expiry_drop != null:
				expiry_drop.set("_elapsed", ByteCrafterDrop.DROP_LIFETIME_SECONDS - 0.01)
				expiry_drop.call("_process", 0.02)
				await get_tree().process_frame
			var expiry_drop_records: Dictionary = game.get("_drop_records")
			_check(not expiry_drop_records.has(expiry_drop_id), "uncollected drops must expire and be removed after five minutes")
		_check(game.get("_target_outline") != null and game.get("_placement_preview") != null, "block targeting must expose a 3D outline and placement preview")
		game.call("_select_slot", 0)
		var hotbar_slots: Array = game.get("_hotbar_slots")
		var has_item_icons := hotbar_slots.size() == 9
		for slot_value: Variant in hotbar_slots:
			var slot := slot_value as PanelContainer
			has_item_icons = has_item_icons and slot != null and ((slot.find_child("ItemTexture", true, false) as TextureRect) != null or (slot.find_child("ItemGlyph", true, false) as Label) != null)
		_check(has_item_icons and (game.get("_selected_item_label") as Label).text.contains("Grama"), "the hotbar must show atlas item icons and the readable selected item name")
		var backpack_slots: Array = game.get("_backpack_slots")
		_check(backpack_slots.size() == 27 and (game.get("_inventory_grid") as GridContainer).get_child_count() == 27 and (game.get("_inventory_hotbar_slots") as Array).size() == 9, "the inventory must expose 36 Minecraft slots: 27 backpack plus 9 hotbar")
		var hotbar_ids: Array = game.get("_hotbar_ids")
		_check(hotbar_ids.size() == 9 and hotbar_ids[0] == 1, "the hotbar must have nine configurable slots")
		var original_backpack_item: Variant = backpack_slots[0]
		var original_hotbar_item: Variant = hotbar_ids[0]
		var saved_drag_fruit_count := int(inventory.get("frutas", 0))
		inventory["frutas"] = maxi(1, saved_drag_fruit_count)
		backpack_slots[0] = "frutas"
		game.call("_on_slot_item_dropped", hotbar_slots[0], {"item_id": "frutas", "source_kind": "backpack", "source_index": 0})
		_check(hotbar_ids[0] == "frutas" and backpack_slots[0] == original_hotbar_item, "dragging a backpack item onto the hotbar must swap both slots")
		inventory["frutas"] = saved_drag_fruit_count
		backpack_slots[0] = original_backpack_item
		hotbar_ids[0] = original_hotbar_item
		game.call("_refresh_hud")
	game.call("_craft", "planks")
	game.call("_craft", "sticks")
	game.call("_craft", "planks")
	game.call("_craft", "pickaxe")
	var crafted_inventory: Dictionary = game.get("_inventory")
	_check(int(crafted_inventory.get("picareta", 0)) == 1, "wood, planks and sticks must craft a pickaxe")
	var inventory_state := game.get("_inventory_state") as ByteCrafterInventoryStack
	var saved_slot_stacks := inventory_state.serialize_slots()
	inventory_state.reset()
	inventory_state.set_stack(0, 4, 1)
	for full_index in range(1, ByteCrafterInventoryStack.TOTAL_SIZE):
		inventory_state.set_stack(full_index, 7, 64)
	game.call("_sync_legacy_slot_arrays_from_state")
	game.call("_craft", "planks")
	_check(inventory_state.get_count(0) == 1 and int(crafted_inventory.get(7, 0)) == 64 * 35, "quick crafting must not consume a log when its output slots are full")
	game.set("_craft_grid_items", [4, null, null, null, null, null, null, null, null])
	game.call("_craft_from_grid")
	var blocked_grid: Array = game.get("_craft_grid_items")
	_check(blocked_grid[0] == 4 and inventory_state.get_count(0) == 1, "grid crafting must preserve ingredients when the output slots are full")
	inventory_state.deserialize_slots(saved_slot_stacks)
	game.call("_sync_legacy_slot_arrays_from_state")
	game.set("_craft_grid_items", [null, null, null, null, null, null, null, null, null])
	game.call("_refresh_crafting")
	var spawn_position: Vector3 = world.get_spawn_position() if world != null else Vector3.ZERO
	game.call("_damage_player", 999.0, "Teste")
	await get_tree().process_frame
	var defeated_player: ByteCrafterPlayer = game.get("_player") as ByteCrafterPlayer
	_check(float(game.get("_health")) == 0.0 and bool(game.get("_death_in_progress")), "lethal damage must enter the explicit death state before respawn")
	_check(defeated_player != null and not defeated_player.can_control and defeated_player.get_animation_state() == "death", "death must lock controls and play the death animation")
	await get_tree().create_timer(1.35).timeout
	_check(float(game.get("_health")) == 12.0 and not bool(game.get("_death_in_progress")), "the player must respawn after the death animation window")
	_check(defeated_player != null and defeated_player.can_control and defeated_player.global_position.distance_to(spawn_position) < 0.2, "respawn must restore controls at the seeded spawn")
	if player != null:
		var visual_inventory := game.get("_inventory_state") as ByteCrafterInventoryStack
		visual_inventory.set_stack(6, "picareta", 1)
		game.call("_sync_legacy_slot_arrays_from_state")
		game.call("_select_slot", 6)
		player.set_third_person(false)
		_check((player.get("_first_person_tool") as Node3D).visible, "an equipped pickaxe must render in first person")
		player.set_third_person(true)
		_check((player.get("_third_person_tool") as Node3D).visible, "an equipped pickaxe must render in third person")
		player.set_third_person(false)
	for index: int in range(8):
		game.call("_spawn_enemy", "slime", Vector2i(20 + index, 20))
	_check(int(game.call("_active_enemy_count")) <= 5 and int(ByteCrafterGame.MAX_ACTIVE_ENEMIES) == 5, "enemy spawning must enforce a hard maximum of five active enemies")
	var flora_for_break: Dictionary = world.get("_flora_blocks") if world != null else {}
	var plant_cell_for_break := Vector3i.ZERO
	var plant_block_for_break := 0
	for cell_value: Variant in flora_for_break:
		if int(flora_for_break[cell_value]) in [27, 28, 29, 30, 31]:
			plant_cell_for_break = cell_value
			plant_block_for_break = int(flora_for_break[cell_value])
			break
	var plant_removed := plant_block_for_break > 0 and world.set_block_at(plant_cell_for_break, 0)
	_check(plant_removed and world.get_block_at(plant_cell_for_break) == 0 and int(game.call("_drop_item_for_block", plant_block_for_break)) > 0, "a generated plant must be breakable and resolve to an edible drop")
	var village_structure_cells: Dictionary = world.get("_village_structure_cells")
	var structure_cell := Vector3i.ZERO
	var structure_block := 0
	var invalid_structure_material := false
	for cell_key: Variant in village_structure_cells:
		var block_id := int(village_structure_cells[cell_key])
		if block_id <= 0:
			continue
		if not [3, 4, 7, 21].has(block_id):
			invalid_structure_material = true
		if structure_block == 0:
			structure_cell = cell_key
			structure_block = block_id
	_check(structure_block > 0 and not invalid_structure_material, "village structures must use only planks, raw wood, stone or bricks")
	if structure_block > 0:
		var structure_removed := world.set_block_at(structure_cell, 0)
		_check(structure_removed and int(game.call("_drop_item_for_block", structure_block)) == structure_block, "a broken village construction voxel must drop its own block 1:1")
		if structure_removed:
			world.set_block_at(structure_cell, structure_block)
	var broken_bed_key := ""
	var broken_bed_drop_id := -1
	var village_bed: ByteCrafterProp
	for prop_node: Node in get_tree().get_nodes_in_group("bytecrafter_props"):
		if prop_node is ByteCrafterProp and (prop_node as ByteCrafterProp).prop_id == "cama" and prop_node.has_meta("village_prop_key"):
			village_bed = prop_node as ByteCrafterProp
			break
	if village_bed != null and village_system != null:
		broken_bed_key = str(village_bed.get_meta("village_prop_key", ""))
		var bed_owner := str(village_bed.get_meta("village_owner", ""))
		game.call("_request_prop_break", village_bed)
		await get_tree().process_frame
		_check(bool(village_system.call("_is_village_prop_removed", bed_owner, broken_bed_key)), "a destroyed village bed must remain broken")
		var villager_bed_available := true
		for village_value: Variant in (village_system.get("_villages") as Dictionary).values():
			var village_node := village_value as Node3D
			for child: Node in village_node.get_children():
				if child is ByteCrafterVillager and str(child.get_meta("village_bed_prop_key", "")) == broken_bed_key:
					villager_bed_available = bool(child.get("_bed_available"))
		var bed_drop_records: Dictionary = game.get("_drop_records")
		for drop_key: Variant in bed_drop_records:
				var bed_record: Dictionary = bed_drop_records[drop_key]
				if str(bed_record.get("item_id", "")) == "cama":
					broken_bed_drop_id = int(drop_key)
					_check(int(bed_record.get("quantity", 0)) == 1, "breaking a bed must create one matching drop")
					break
		_check(not villager_bed_available, "the villager must stop using its destroyed bed")
	else:
		_check(false, "the generated village must expose a breakable bed")
	game.call("_save_game")
	var async_saver := game.get("_async_saver") as ByteCrafterAsyncSaver
	if async_saver != null:
		async_saver.wait_until_idle()
	var saved_world: Dictionary = WORLD_SCRIPT.load_from_disk()
	_check(int(saved_world.get("seed", -1)) == int(world.world_seed if world != null else -2), "the active world seed must persist")
	var removed_plant_saved := false
	var collected_fruit_saved := false
	for override_value: Variant in saved_world.get("overrides", []):
		if not override_value is Array or override_value.size() < 4 or int(override_value[3]) != 0:
			continue
		if int(override_value[0]) == plant_cell_for_break.x and int(override_value[1]) == plant_cell_for_break.y and int(override_value[2]) == plant_cell_for_break.z:
			removed_plant_saved = true
		if int(override_value[0]) == harvested_fruit_cell.x and int(override_value[1]) == harvested_fruit_cell.y and int(override_value[2]) == harvested_fruit_cell.z:
			collected_fruit_saved = true
	_check(removed_plant_saved, "a harvested wild plant must stay removed when the world is saved")
	_check(collected_fruit_saved, "a touch-collected fallen fruit must stay gone when the world is saved")
	_check(FileAccess.file_exists("user://bytecrafter_player.json"), "the player profile must be persisted")
	var player_profile := JSON.parse_string(FileAccess.get_file_as_string("user://bytecrafter_player.json")) as Dictionary
	var saved_inventory: Dictionary = player_profile.get("inventory", {}) if player_profile != null else {}
	_check(int(saved_inventory.get("gelatina", 0)) == 1, "the collected slime resource must persist in the player profile")
	var saved_avatar_id := str(player_profile.get("avatar_id", "")) if player_profile != null else ""
	_check(saved_avatar_id == "girl2", "the selected avatar, including girl2, must persist in the player profile")
	_check(str(player_profile.get("difficulty", "")) == "normal", "the selected solo difficulty must persist in the player profile")
	var saved_villages: Array = player_profile.get("villages", []) if player_profile != null else []
	_check(not saved_villages.is_empty(), "village and villager state must be written to the player profile")
	var broken_bed_saved := false
	for saved_village_value: Variant in saved_villages:
		if saved_village_value is Dictionary:
			var broken_props: Variant = saved_village_value.get("broken_props", [])
			if broken_props is Array and broken_props.has(broken_bed_key):
				broken_bed_saved = true
	var broken_bed_drop_saved := false
	for saved_drop: Variant in player_profile.get("drops", []):
		if saved_drop is Array and saved_drop.size() >= 6 and str(saved_drop[1]) == "cama" and int(saved_drop[5]) == 1:
			broken_bed_drop_saved = true
	_check(not broken_bed_key.is_empty() and broken_bed_saved and broken_bed_drop_saved, "the broken bed and its 1:1 drop must persist")
	_check(int(player_profile.get("xp", 0)) == int(game.get("_xp")) and int(player_profile.get("level", 0)) == int(game.get("_level")), "XP and level must persist in the player profile")
	if broken_bed_drop_id >= 0:
		var bed_count_before := int(inventory.get("cama", 0))
		game.call("_on_drop_touched", broken_bed_drop_id)
		_check(int(inventory.get("cama", 0)) == bed_count_before + 1, "collecting the bed drop must return one cama to inventory")
	if merchant != null:
		var trade_test_state := game.get("_inventory_state") as ByteCrafterInventoryStack
		trade_test_state.reset()
		game.call("_sync_legacy_slot_arrays_from_state")
		game.call("_open_village_shop", merchant)
		var shop_overlay := game.get("_shop_overlay") as Control
		var shop_status := game.get("_shop_status") as Label
		_check(shop_overlay != null and shop_overlay.visible and not player.can_control, "opening the merchant must show the shop and temporarily lock movement")
		game.call("_execute_village_trade", 0)
		_check(shop_status != null and shop_status.text.contains("Faltam"), "a shop trade without enough inputs must show a shortage message")
		game.call("_inventory_add", 16, 3)
		var trade_button: Button
		if shop_overlay != null:
			for button_node: Node in shop_overlay.find_children("*", "Button", true, false):
				var candidate := button_node as Button
				if candidate.text.begins_with("3 cenouras"):
					trade_button = candidate
					break
		if trade_button != null:
			trade_button.emit_signal("pressed")
			var trade_inventory: Dictionary = game.get("_inventory")
			_check(trade_button != null and int(trade_inventory.get(16, 0)) == 0 and int(trade_inventory.get(17, 0)) == 1, "clicking a connected trade button must atomically exchange carrots for iron")
			game.call("_inventory_add", 33, 1)
			var gem_trade_button: Button
			if shop_overlay != null:
				for button_node: Node in shop_overlay.find_children("*", "Button", true, false):
					var candidate := button_node as Button
					if candidate.text.begins_with("1 gema verde"):
						gem_trade_button = candidate
						break
			if gem_trade_button != null:
				gem_trade_button.emit_signal("pressed")
			trade_inventory = game.get("_inventory")
			_check(gem_trade_button != null and int(trade_inventory.get(33, 0)) == 0 and int(trade_inventory.get("fragmento_lunar", 0)) == 2, "the village must accept Gema Verde for two lunar fragments through its connected button")
			game.call("_close_village_shop")
		_check(shop_overlay != null and not shop_overlay.visible and player.can_control, "closing the shop must restore movement controls")
	game.free()
	await get_tree().process_frame
