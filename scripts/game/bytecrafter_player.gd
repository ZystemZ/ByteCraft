extends CharacterBody3D
class_name ByteCrafterPlayer

const WALK_SPEED := 5.6
const SPRINT_SPEED := 8.2
const GRAVITY := 20.0
const STEP_UP_ANIMATION_TIME := 0.32
const STEP_UP_LOCOMOTION := "run"
const IDLE_DANCE_DELAY := 300.0
const JUMP_HEIGHT_BLOCKS := 2.5
const JUMP_VELOCITY := 10.0
const BODY_HEIGHT := 1.8
const GROUND_ACCEL := 46.0
const GROUND_DECEL := 58.0
const AIR_ACCEL := 18.0
const LOOK_SENSITIVITY := 0.0024
const AVATAR_SCRIPT := preload("res://scripts/game/bytecrafter_avatar.gd")
const MOVEMENT := preload("res://scripts/game/bytecrafter_movement.gd")
const AVATAR_IDS := ["boy", "girl", "boy2", "girl2"]
const PICKAXE_MODEL := preload("res://assets/userpack/cubeworld/Pickaxe Wood.glb")
const STONE_PICKAXE_MODEL := preload("res://assets/userpack/cubeworld/Stone Pickaxe.glb")
const DIAMOND_PICKAXE_MODEL := preload("res://assets/userpack/cubeworld/Diamond Pickaxe.glb")
const WOOD_SHOVEL_MODEL := preload("res://assets/userpack/cubeworld/Wood Shovel.glb")
const STONE_SHOVEL_MODEL := preload("res://assets/userpack/cubeworld/Stone Shovel.glb")
const DIAMOND_SHOVEL_MODEL := preload("res://assets/userpack/cubeworld/Diamond Shovel.glb")
const SWORD_MODEL := preload("res://assets/userpack/cubeworld/Wooden Sword.glb")
const STONE_SWORD_MODEL := preload("res://assets/userpack/cubeworld/Sword Stone.glb")
const DIAMOND_SWORD_MODEL := preload("res://assets/userpack/cubeworld/Sword Diamond.glb")
const AXE_MODEL := preload("res://assets/userpack/cubeworld/Diamond Axe.glb")
const SHURIKEN_MODEL := preload("res://assets/bitmal/Shuriken by iPoly3D - mrzNkmPnMo.glb")
const TOOL_VISUAL_SCALE := 0.25
const TORCH_MODEL := preload("res://assets/bitmal/Wooden Torch by Quaternius - pNsfJzhXiD.glb")
const BUCKET_MODEL := preload("res://assets/bitmal/Bucket by Quaternius - 83obI9bNun.glb")

var can_control := false
var third_person := false
var avatar_id := "boy"
var _world: ByteCrafterWorld
var camera: Camera3D
var _camera_pivot: Node3D
var _spring_arm: SpringArm3D
var _body_mesh: Node3D
var _avatar_instance: ByteCrafterAvatar
var _first_person_tool: Node3D
var _third_person_tool: Node3D
var _first_person_sword: Node3D
var _third_person_sword: Node3D
var _first_person_torch: Node3D
var _third_person_torch: Node3D
var _first_person_bucket: Node3D
var _third_person_bucket: Node3D
var _right_hand_attachment: BoneAttachment3D
var _first_person_attack_tween: Tween
var _equipped_tool := ""
var _equipped_model_key := ""
var _pitch := 0.0
var _step_up_animation_timer := 0.0
var _keyboard_idle_elapsed := 0.0
var _idle_dance_active := false


func _ready() -> void:
	name = "LocalPlayer"
	floor_snap_length = 0.32
	floor_max_angle = deg_to_rad(50.0)
	_build_collision()
	_build_visual_body()
	_build_camera()


func configure_world(world: ByteCrafterWorld) -> void:
	_world = world


func _build_collision() -> void:
	var shape := CapsuleShape3D.new()
	shape.radius = 0.34
	shape.height = 1.8
	var collider := CollisionShape3D.new()
	collider.name = "PlayerCollider"
	collider.shape = shape
	collider.position = Vector3(0.0, 0.9, 0.0)
	add_child(collider)


func _build_visual_body() -> void:
	_body_mesh = Node3D.new()
	_body_mesh.name = "PlayerBody"
	add_child(_body_mesh)
	_avatar_instance = AVATAR_SCRIPT.new() as ByteCrafterAvatar
	_avatar_instance.name = "RiggedAvatar"
	_avatar_instance.configure(avatar_id)
	_body_mesh.add_child(_avatar_instance)


func _build_camera() -> void:
	_camera_pivot = Node3D.new()
	_camera_pivot.name = "CameraPivot"
	_camera_pivot.position = Vector3(0.0, 1.57, 0.0)
	add_child(_camera_pivot)
	_spring_arm = SpringArm3D.new()
	_spring_arm.name = "SpringArm"
	_spring_arm.spring_length = 0.0
	_spring_arm.margin = 0.15
	_spring_arm.collision_mask = 1
	_spring_arm.add_excluded_object(get_rid())
	_camera_pivot.add_child(_spring_arm)
	camera = Camera3D.new()
	camera.name = "PlayerCamera"
	camera.current = true
	camera.fov = 76.0
	camera.near = 0.05
	_spring_arm.add_child(camera)
	_build_pickaxe_models()
	set_third_person(false)


func _build_pickaxe_models() -> void:
	_first_person_tool = Node3D.new()
	_first_person_tool.name = "FirstPersonTool"
	_first_person_tool.position = Vector3(0.42, -0.29, -0.58)
	_first_person_tool.rotation_degrees = Vector3(-12.0, 0.0, -18.0)
	camera.add_child(_first_person_tool)
	_attach_tool_asset(_first_person_tool, PICKAXE_MODEL, "PickaxeAsset", 1.86 * TOOL_VISUAL_SCALE)
	_third_person_tool = Node3D.new()
	_third_person_tool.name = "ThirdPersonTool"
	_third_person_tool.position = Vector3(0.0, 0.0, 0.0)
	_third_person_tool.rotation_degrees = Vector3(0.0, 0.0, 0.0)
	_attach_tool_asset(_third_person_tool, PICKAXE_MODEL, "PickaxeAsset", 1.86 * TOOL_VISUAL_SCALE)
	_first_person_sword = Node3D.new()
	_first_person_sword.name = "FirstPersonSword"
	_first_person_sword.position = Vector3(0.40, -0.30, -0.66)
	_first_person_sword.rotation_degrees = Vector3(-10.0, 0.0, -18.0)
	camera.add_child(_first_person_sword)
	_attach_tool_asset(_first_person_sword, SWORD_MODEL, "SwordAsset", 2.10 * TOOL_VISUAL_SCALE)
	_third_person_sword = Node3D.new()
	_third_person_sword.name = "ThirdPersonSword"
	_third_person_sword.position = Vector3(0.0, 0.0, 0.0)
	_third_person_sword.rotation_degrees = Vector3(0.0, 0.0, 0.0)
	_attach_tool_asset(_third_person_sword, SWORD_MODEL, "SwordAsset", 2.10 * TOOL_VISUAL_SCALE)
	_first_person_torch = Node3D.new()
	_first_person_torch.name = "FirstPersonTorch"
	_first_person_torch.position = Vector3(0.42, -0.27, -0.58)
	_first_person_torch.rotation_degrees = Vector3(-8.0, 0.0, -14.0)
	camera.add_child(_first_person_torch)
	_attach_tool_asset(_first_person_torch, TORCH_MODEL, "TorchAsset", 0.72)
	_third_person_torch = Node3D.new()
	_third_person_torch.name = "ThirdPersonTorch"
	_attach_tool_asset(_third_person_torch, TORCH_MODEL, "TorchAsset", 0.72)
	_first_person_bucket = Node3D.new()
	_first_person_bucket.name = "FirstPersonBucket"
	_first_person_bucket.position = Vector3(0.42, -0.28, -0.60)
	_first_person_bucket.rotation_degrees = Vector3(-10.0, 0.0, -16.0)
	camera.add_child(_first_person_bucket)
	_attach_tool_asset(_first_person_bucket, BUCKET_MODEL, "BucketAsset", 0.7)
	_third_person_bucket = Node3D.new()
	_third_person_bucket.name = "ThirdPersonBucket"
	_attach_tool_asset(_third_person_bucket, BUCKET_MODEL, "BucketAsset", 0.7)
	_attach_third_person_items_to_hand()
	_refresh_equipped_tool()


func _attach_third_person_items_to_hand() -> void:
	if _avatar_instance == null or _right_hand_attachment != null:
		return
	var items: Array[Node3D] = [_third_person_tool, _third_person_sword, _third_person_torch, _third_person_bucket]
	var skeleton := _avatar_instance.find_child("Skeleton3D", true, false) as Skeleton3D
	if skeleton == null:
		# Fallback seguro para avatares sem esqueleto exposto.
		for item: Node3D in items:
			_move_item_to_parent(item, _body_mesh)
		return
	var hand_bone := -1
	for bone_name: String in ["hand_r", "RightHand", "mixamorig_RightHand", "Hand.R", "hand.R"]:
		hand_bone = skeleton.find_bone(bone_name)
		if hand_bone >= 0:
			break
	if hand_bone < 0:
		for item: Node3D in items:
			_move_item_to_parent(item, _body_mesh)
		return
	_right_hand_attachment = BoneAttachment3D.new()
	_right_hand_attachment.name = "RightHandItems"
	_right_hand_attachment.bone_idx = hand_bone
	skeleton.add_child(_right_hand_attachment)
	for item: Node3D in items:
		_move_item_to_parent(item, _right_hand_attachment)


func _move_item_to_parent(item: Node3D, new_parent: Node) -> void:
	if item.get_parent() == new_parent:
		return
	if item.get_parent() == null:
		new_parent.add_child(item)
	else:
		item.reparent(new_parent, false)


func _attach_tool_asset(parent: Node3D, scene: PackedScene, node_name: String, uniform_scale: float) -> void:
	var asset := scene.instantiate() as Node3D
	asset.name = node_name
	asset.scale = Vector3.ONE * uniform_scale
	asset.rotation_degrees = Vector3(0.0, 180.0, 0.0)
	parent.add_child(asset)


func _material(color: Color) -> StandardMaterial3D:
	var result := StandardMaterial3D.new()
	result.albedo_color = color
	result.roughness = 0.92
	return result


func _add_box(parent: Node3D, part_name: String, dimensions: Vector3, offset: Vector3, material: Material) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = dimensions
	var instance := MeshInstance3D.new()
	instance.name = part_name
	instance.mesh = mesh
	instance.material_override = material
	instance.position = offset
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	parent.add_child(instance)
	return instance


func set_avatar_id(value: String) -> void:
	avatar_id = value if value in AVATAR_IDS else "boy"
	if _avatar_instance != null:
		_detach_third_person_items_from_hand()
		_avatar_instance.configure(avatar_id)
		_attach_third_person_items_to_hand()
		_refresh_equipped_tool()


func get_avatar_id() -> String:
	return avatar_id


func _detach_third_person_items_from_hand() -> void:
	for item: Node3D in [_third_person_tool, _third_person_sword, _third_person_torch, _third_person_bucket]:
		if item != null and is_instance_valid(item) and item.get_parent() != _body_mesh:
			item.reparent(_body_mesh, false)
	if _right_hand_attachment != null and is_instance_valid(_right_hand_attachment):
		_right_hand_attachment.queue_free()
	_right_hand_attachment = null


func get_avatar_yaw() -> float:
	return rotation.y + (_body_mesh.rotation.y if _body_mesh != null else 0.0)


func get_animation_state() -> String:
	return _avatar_instance.get_animation_state() if _avatar_instance != null else "idle"


func set_animation_state(state: String) -> void:
	if _avatar_instance != null:
		_avatar_instance.set_animation_state(state)


func play_action(action: String) -> void:
	if action == "attack":
		_play_first_person_attack_swing()
	if _avatar_instance != null:
		_avatar_instance.play_action(action)


func stop_action() -> void:
	if _avatar_instance != null:
		_avatar_instance.stop_action()


func _play_first_person_attack_swing() -> void:
	var swing_root: Node3D = null
	if _first_person_sword != null and _first_person_sword.visible:
		swing_root = _first_person_sword
	elif _first_person_tool != null and _first_person_tool.visible:
		swing_root = _first_person_tool
	if swing_root == null:
		return
	if _first_person_attack_tween != null:
		_first_person_attack_tween.kill()
	var rest_position := swing_root.position
	var rest_rotation := swing_root.rotation_degrees
	_first_person_attack_tween = create_tween()
	_first_person_attack_tween.tween_property(swing_root, "rotation_degrees", rest_rotation + Vector3(-24.0, 0.0, 52.0), 0.08)
	_first_person_attack_tween.parallel().tween_property(swing_root, "position", rest_position + Vector3(0.0, -0.12, 0.08), 0.08)
	_first_person_attack_tween.chain().tween_property(swing_root, "rotation_degrees", rest_rotation, 0.18)
	_first_person_attack_tween.parallel().tween_property(swing_root, "position", rest_position, 0.18)


func set_equipped_tool(tool_id: String) -> void:
	_equipped_tool = tool_id
	_refresh_equipped_tool()


func _refresh_equipped_tool() -> void:
	if _first_person_tool == null or _third_person_tool == null or _first_person_sword == null or _third_person_sword == null or _first_person_torch == null or _third_person_torch == null or _first_person_bucket == null or _third_person_bucket == null:
		return
	var has_pickaxe := _equipped_tool in ["picareta", "picareta_pedra", "picareta_ferro", "machado_ferro", "pa", "pa_pedra", "pa_ferro"]
	var has_sword := _equipped_tool in ["espada", "espada_pedra", "espada_ferro", "shuriken"]
	var has_torch := _equipped_tool == "tocha"
	var has_bucket := _equipped_tool == "balde"
	if _equipped_model_key != _equipped_tool:
		var root: Node3D = _first_person_sword if has_sword else _first_person_tool
		var third_root: Node3D = _third_person_sword if has_sword else _third_person_tool
		for old_child: Node in root.get_children():
			root.remove_child(old_child)
			old_child.queue_free()
		for old_child: Node in third_root.get_children():
			third_root.remove_child(old_child)
			old_child.queue_free()
		var model: PackedScene = null
		var model_scale := 1.86
		match _equipped_tool:
			"picareta": model = PICKAXE_MODEL
			"picareta_pedra": model = STONE_PICKAXE_MODEL
			"picareta_ferro": model = DIAMOND_PICKAXE_MODEL
			"pa":
				model = WOOD_SHOVEL_MODEL
				model_scale = 1.5
			"pa_pedra":
				model = STONE_SHOVEL_MODEL
				model_scale = 1.5
			"pa_ferro":
				model = DIAMOND_SHOVEL_MODEL
				model_scale = 1.5
			"machado_ferro":
				model = AXE_MODEL
				model_scale = 1.35
			"espada":
				model = SWORD_MODEL
				model_scale = 2.10
			"espada_pedra":
				model = STONE_SWORD_MODEL
				model_scale = 2.10
			"espada_ferro":
				model = DIAMOND_SWORD_MODEL
				model_scale = 2.10
			"shuriken":
				model = SHURIKEN_MODEL
				model_scale = 0.88
		if model != null:
			_attach_tool_asset(root, model, "EquippedCubeWorldTool", model_scale * TOOL_VISUAL_SCALE)
			_attach_tool_asset(third_root, model, "EquippedCubeWorldTool", model_scale * TOOL_VISUAL_SCALE)
		_equipped_model_key = _equipped_tool
	_first_person_tool.visible = has_pickaxe and not third_person
	_third_person_tool.visible = has_pickaxe and third_person
	_first_person_sword.visible = has_sword and not third_person
	_third_person_sword.visible = has_sword and third_person
	_first_person_torch.visible = has_torch and not third_person
	_third_person_torch.visible = has_torch and third_person
	_first_person_bucket.visible = has_bucket and not third_person
	_third_person_bucket.visible = has_bucket and third_person


func _physics_process(delta: float) -> void:
	var in_water := MOVEMENT.is_in_water(_world, self, BODY_HEIGHT)
	if not can_control:
		_keyboard_idle_elapsed = 0.0
		velocity.x = move_toward(velocity.x, 0.0, 20.0 * delta)
		velocity.z = move_toward(velocity.z, 0.0, 20.0 * delta)
		if in_water:
			MOVEMENT.apply_buoyancy(self, _world, delta, BODY_HEIGHT)
		elif not is_on_floor():
			velocity.y -= GRAVITY * delta
		MOVEMENT.move_with_step(self, delta)
		if _avatar_instance != null and _avatar_instance.get_animation_state() != "death":
			_avatar_instance.set_locomotion_state("idle")
		return
	var input_vector := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var movement := Vector3(input_vector.x, 0.0, input_vector.y)
	if movement.length_squared() > 1.0:
		movement = movement.normalized()
	var direction := (global_transform.basis * movement).normalized()
	var sprinting := Input.is_action_pressed("sprint")
	var speed := SPRINT_SPEED if sprinting else WALK_SPEED
	if in_water:
		speed *= 0.72
	# Aceleração/desaceleração suaves; no ar o controle é reduzido, mas existe.
	var target_velocity := direction * speed
	var has_input := movement.length_squared() > 0.0001
	var rate := (GROUND_ACCEL if has_input else GROUND_DECEL) if is_on_floor() else AIR_ACCEL
	if in_water:
		rate *= 0.55
	velocity.x = move_toward(velocity.x, target_velocity.x, rate * delta)
	velocity.z = move_toward(velocity.z, target_velocity.z, rate * delta)
	if in_water:
		MOVEMENT.apply_buoyancy(self, _world, delta, BODY_HEIGHT, Input.is_action_pressed("jump"), 4.8)
	elif not is_on_floor():
		velocity.y -= GRAVITY * delta
	elif Input.is_action_pressed("jump"):
		velocity.y = JUMP_VELOCITY
	_step_up_animation_timer = maxf(0.0, _step_up_animation_timer - delta)
	var stepped_up := MOVEMENT.move_with_step(self, delta)
	if stepped_up:
		_step_up_animation_timer = STEP_UP_ANIMATION_TIME
	_face_move_direction(movement, delta)
	var locomotion := "idle"
	if in_water:
		locomotion = "swim" if has_input or Input.is_action_pressed("jump") else "float"
	elif not is_on_floor():
		locomotion = "jump"
	elif input_vector.length() > 0.05:
		locomotion = "run" if sprinting else "walk"
	if _step_up_animation_timer > 0.0 and input_vector.length() > 0.05:
		locomotion = STEP_UP_LOCOMOTION
	if _avatar_instance != null:
		_avatar_instance.set_locomotion_state(locomotion)
		_keyboard_idle_elapsed += delta
		if _keyboard_idle_elapsed >= IDLE_DANCE_DELAY and is_on_floor() and not in_water and input_vector.length_squared() < 0.0025 and not _idle_dance_active:
			_idle_dance_active = true
			_avatar_instance.play_action("dance1" if randi_range(0, 1) == 0 else "dance2")


func _face_move_direction(movement: Vector3, delta: float) -> void:
	if _body_mesh == null or movement.length_squared() < 0.0001:
		return
	var target_yaw := atan2(-movement.x, -movement.z)
	_body_mesh.rotation.y = lerp_angle(_body_mesh.rotation.y, target_yaw, minf(1.0, delta * 14.0))


func _input(event: InputEvent) -> void:
	if not can_control:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		_keyboard_idle_elapsed = 0.0
		if _idle_dance_active:
			_idle_dance_active = false
			if _avatar_instance != null:
				_avatar_instance.stop_action()
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		return
	if event is InputEventMouseMotion:
		_apply_mouse_look(event.relative)


func _apply_mouse_look(relative: Vector2) -> void:
	rotate_y(-relative.x * LOOK_SENSITIVITY)
	_pitch = clampf(_pitch - relative.y * LOOK_SENSITIVITY, deg_to_rad(-88.0), deg_to_rad(88.0))
	_camera_pivot.rotation.x = _pitch


func set_third_person(enabled: bool) -> void:
	third_person = enabled
	if _spring_arm != null:
		_spring_arm.spring_length = 4.2 if enabled else 0.0
	if _body_mesh != null:
		_body_mesh.visible = enabled
	_refresh_equipped_tool()


func reset_view() -> void:
	rotation.y = 0.0
	_pitch = 0.0
	if _body_mesh != null:
		_body_mesh.rotation = Vector3.ZERO
	if _camera_pivot != null:
		_camera_pivot.rotation = Vector3.ZERO
