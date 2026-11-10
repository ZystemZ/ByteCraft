extends Node3D
class_name ByteCrafterAvatar

const AVATAR_IDS := ["boy", "girl", "boy2", "girl2"]
const MODELS := {
	"boy": preload("res://assets/models/players/rigged_player_boy.fbx"),
	"girl": preload("res://assets/models/players/rigged_player_girl.fbx"),
	"boy2": preload("res://assets/userpack/characters/PLAYER_BOY2_RIGGED.fbx"),
	"girl2": preload("res://assets/userpack/characters/PLAYER_GIRL2_RIGGED.fbx"),
}
const TEXTURES := {
	"boy": preload("res://assets/models/players/boy_shaded.png"),
	"girl": preload("res://assets/models/players/girl_shaded.png"),
	"boy2": preload("res://assets/userpack/characters/PLAYER_BOY2_RIGGED_0.png"),
	"girl2": preload("res://assets/userpack/characters/PLAYER_GIRL2_RIGGED_0.png"),
}
const CLIPS := {
	"walk": preload("res://assets/models/animations/walk.tres"),
	"run": preload("res://assets/models/animations/run.tres"),
	"jump": preload("res://assets/models/animations/jump.tres"),
	"mine": preload("res://assets/models/animations/mine.tres"),
	"attack": preload("res://assets/models/animations/attack.tres"),
	"death": preload("res://assets/models/animations/death.tres"),
}
const EXTERNAL_CLIP_SCENES := {
	"walk": preload("res://assets/userpack/animations/Walking (1).fbx"),
	"run": preload("res://assets/userpack/animations/Running.fbx"),
	"jump": preload("res://assets/userpack/animations_extra/Jumping Up_FAST.fbx"),
	"mine": preload("res://assets/userpack/animations/Martelo 2.fbx"),
	"attack": preload("res://assets/userpack/animations/Standing Melee Attack Horizontal.fbx"),
	"death": preload("res://assets/userpack/animations/Dying.fbx"),
	"door": preload("res://assets/userpack/animations_extra/Opening door.fbx"),
	"jump_down": preload("res://assets/userpack/animations/Jumping Down.fbx"),
	"fast_run": preload("res://assets/userpack/animations/Fast Run.fbx"),
	"walk_back": preload("res://assets/userpack/animations/Walking Backwards.fbx"),
	"run_back": preload("res://assets/userpack/animations/Running Backward.fbx"),
	"punch": preload("res://assets/userpack/animations/Punching.fbx"),
	"cross_punch": preload("res://assets/userpack/animations/Cross Punch.fbx"),
	"attack_down": preload("res://assets/userpack/animations/Standing Melee Attack Downward.fbx"),
	"combo_attack": preload("res://assets/userpack/animations/Standing Melee Combo Attack Ver. 3.fbx"),
	"reaction": preload("res://assets/userpack/animations/Reaction.fbx"),
	"stunned": preload("res://assets/userpack/animations/Stunned.fbx"),
	"fireball": preload("res://assets/userpack/animations/Fireball.fbx"),
	"climb": preload("res://assets/userpack/animations/Freehang Climb.fbx"),
	"sleep1": preload("res://assets/userpack/animations_extra/dormindo.fbx"),
	"sleep2": preload("res://assets/userpack/animations_extra/dormindo1 Idle.fbx"),
	"sleep3": preload("res://assets/userpack/animations_extra/Dormindo 2 Idle.fbx"),
	"swim": preload("res://assets/userpack/animations_extra/Swimming.fbx"),
	"float": preload("res://assets/userpack/animations_extra/Floating.fbx"),
	"dance1": preload("res://assets/userpack/animations_extra/Silly Dancing.fbx"),
	"dance2": preload("res://assets/userpack/animations_extra/Jazz Dancing.fbx"),
	"pickup": preload("res://assets/userpack/animations_extra/Picking Up.fbx"),
}
const LOOPING_CLIPS := ["sleep1", "sleep2", "sleep3", "swim", "float", "dance1", "dance2"]
const LOCOMOTION_STATES := ["idle", "walk", "run", "jump", "swim", "float", "sleep1", "sleep2", "sleep3"]
const ACTION_STATES := ["mine", "attack", "death", "door", "jump_down", "fast_run", "walk_back", "run_back", "punch", "cross_punch", "attack_down", "combo_attack", "reaction", "stunned", "fireball", "climb", "pickup", "sleep1", "sleep2", "sleep3", "dance1", "dance2"]
const CC_AVATARS := ["boy2", "girl2"]
const MIXAMO_TO_TARGET := {
	"mixamorig_Hips": "mixamorig_Hips",
	"mixamorig_Spine": "mixamorig_Spine",
	"mixamorig_Spine1": "mixamorig_Spine1",
	"mixamorig_Spine2": "mixamorig_Spine2",
	"mixamorig_Neck": "mixamorig_Neck",
	"mixamorig_Head": "mixamorig_Head",
	"mixamorig_LeftShoulder": "mixamorig_LeftShoulder",
	"mixamorig_LeftArm": "mixamorig_LeftArm",
	"mixamorig_LeftForeArm": "mixamorig_LeftForeArm",
	"mixamorig_LeftHand": "mixamorig_LeftHand",
	"mixamorig_RightShoulder": "mixamorig_RightShoulder",
	"mixamorig_RightArm": "mixamorig_RightArm",
	"mixamorig_RightForeArm": "mixamorig_RightForeArm",
	"mixamorig_RightHand": "mixamorig_RightHand",
	"mixamorig_LeftUpLeg": "mixamorig_LeftUpLeg",
	"mixamorig_LeftLeg": "mixamorig_LeftLeg",
	"mixamorig_LeftFoot": "mixamorig_LeftFoot",
	"mixamorig_LeftToeBase": "mixamorig_LeftToeBase",
	"mixamorig_RightUpLeg": "mixamorig_RightUpLeg",
	"mixamorig_RightLeg": "mixamorig_RightLeg",
	"mixamorig_RightFoot": "mixamorig_RightFoot",
	"mixamorig_RightToeBase": "mixamorig_RightToeBase",
}

var character_id := "boy"
var _model_root: Node3D
var _animation_player: AnimationPlayer
var _retarget_source_root: Node3D
var _retarget_source_skeleton: Skeleton3D
var _retarget_source_player: AnimationPlayer
var _retarget_bone_pairs: Array[Vector2i] = []
var _current_animation := ""
var _desired_locomotion := "idle"
var _active_action := ""
var _retarget_dirty := true


static func is_supported_id(value: String) -> bool:
	return value in AVATAR_IDS


func configure(id: String) -> void:
	var normalized := id if is_supported_id(id) else "boy"
	if character_id == normalized and _model_root != null:
		return
	character_id = normalized
	if is_inside_tree():
		_build_model()


func _ready() -> void:
	_build_model()


func _process(_delta: float) -> void:
	if _retarget_source_player != null and (_retarget_dirty or _retarget_source_player.is_playing()):
		_apply_retarget_overrides()
		_retarget_dirty = false


func _build_model() -> void:
	_release_retarget_source()
	if _model_root != null and is_instance_valid(_model_root):
		remove_child(_model_root)
		_model_root.queue_free()
	_model_root = (MODELS[character_id] as PackedScene).instantiate() as Node3D
	_model_root.name = "RiggedCharacter"
	# A pose de repouso importada já está em Y; o avatar vira para acompanhar o controlador em -Z.
	_model_root.rotation = Vector3(0.0, PI, 0.0)
	add_child(_model_root)
	_animation_player = _model_root.find_child("AnimationPlayer", true, false) as AnimationPlayer
	_apply_texture()
	_install_game_clips()
	_active_action = ""
	_current_animation = ""
	if _animation_player != null and not _animation_player.animation_finished.is_connected(_on_animation_finished):
		_animation_player.animation_finished.connect(_on_animation_finished)
	set_locomotion_state(_desired_locomotion)
	_apply_retarget_overrides()


func _apply_texture() -> void:
	if _model_root == null:
		return
	var mesh := _model_root.find_child("model", true, false) as MeshInstance3D
	if mesh == null:
		mesh = _find_first_mesh(_model_root)
	if mesh == null:
		push_warning("Rigged avatar has no MeshInstance3D: " + character_id)
		return
	var source_material := mesh.get_active_material(0) as StandardMaterial3D
	var material := source_material.duplicate(true) as StandardMaterial3D if source_material != null else StandardMaterial3D.new()
	material.albedo_texture = TEXTURES[character_id] as Texture2D
	material.albedo_color = Color.WHITE
	material.roughness = 0.82
	mesh.material_override = material
	mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON


func _find_first_mesh(parent: Node) -> MeshInstance3D:
	for child: Node in parent.get_children():
		if child is MeshInstance3D:
			return child as MeshInstance3D
		var nested := _find_first_mesh(child)
		if nested != null:
			return nested
	return null


func _install_game_clips() -> void:
	if _animation_player == null:
		push_warning("Rigged avatar has no AnimationPlayer: " + character_id)
		return
	var library := _animation_player.get_animation_library("")
	if library == null:
		library = AnimationLibrary.new()
		_animation_player.add_animation_library("", library)
	if character_id in CC_AVATARS:
		_prepare_retarget_source()
	for clip_name: String in CLIPS:
		if library.has_animation(clip_name):
			library.remove_animation(clip_name)
		var external_clip := _load_external_clip(clip_name)
		var fallback_clip := CLIPS[clip_name] as Animation
		var clip := _make_placeholder_clip(external_clip) if character_id in CC_AVATARS and external_clip != null else ((external_clip if external_clip != null else fallback_clip).duplicate(true) as Animation)
		library.add_animation(clip_name, clip)
	for external_clip_name: String in EXTERNAL_CLIP_SCENES:
		if CLIPS.has(external_clip_name) or library.has_animation(external_clip_name):
			continue
		var external_clip := _load_external_clip(external_clip_name)
		if external_clip != null:
			if external_clip_name in LOOPING_CLIPS:
				external_clip.loop_mode = Animation.LOOP_LINEAR
			library.add_animation(external_clip_name, _make_placeholder_clip(external_clip) if character_id in CC_AVATARS else external_clip)


func _load_external_clip(clip_name: String) -> Animation:
	var scene := EXTERNAL_CLIP_SCENES.get(clip_name) as PackedScene
	if scene == null:
		return null
	var source_root := scene.instantiate()
	var source_player := source_root.find_child("AnimationPlayer", true, false) as AnimationPlayer
	if source_player == null:
		source_root.free()
		return null
	var library: AnimationLibrary = null
	var libraries := source_player.get_animation_library_list()
	if libraries.has(&"mixamo_com"):
		library = source_player.get_animation_library(&"mixamo_com")
	elif not libraries.is_empty():
		library = source_player.get_animation_library(libraries[0])
	if library == null:
		source_root.free()
		return null
	var animations := library.get_animation_list()
	if animations.is_empty():
		source_root.free()
		return null
	var result := library.get_animation(animations[0]).duplicate(true) as Animation
	source_root.free()
	return result


func _make_placeholder_clip(source: Animation) -> Animation:
	var placeholder := Animation.new()
	placeholder.length = source.length
	placeholder.loop_mode = source.loop_mode
	return placeholder


func _prepare_retarget_source() -> void:
	_retarget_source_root = (MODELS["boy"] as PackedScene).instantiate() as Node3D
	_retarget_source_root.name = "MixamoRetargetSource"
	_retarget_source_root.visible = false
	add_child(_retarget_source_root)
	_retarget_source_skeleton = _retarget_source_root.find_child("Skeleton3D", true, false) as Skeleton3D
	_retarget_source_player = _retarget_source_root.find_child("AnimationPlayer", true, false) as AnimationPlayer
	if _retarget_source_skeleton == null or _retarget_source_player == null:
		push_warning("Unable to create the hidden Mixamo retarget source")
		return
	var library := _retarget_source_player.get_animation_library("")
	if library == null:
		library = AnimationLibrary.new()
		_retarget_source_player.add_animation_library("", library)
	for clip_name: String in CLIPS:
		if library.has_animation(clip_name):
			library.remove_animation(clip_name)
		var external_clip := _load_external_clip(clip_name)
		library.add_animation(clip_name, (external_clip if external_clip != null else CLIPS[clip_name] as Animation).duplicate(true))
	for external_clip_name: String in EXTERNAL_CLIP_SCENES:
		if CLIPS.has(external_clip_name):
			continue
		var external_clip := _load_external_clip(external_clip_name)
		if external_clip != null:
			if external_clip_name in LOOPING_CLIPS:
				external_clip.loop_mode = Animation.LOOP_LINEAR
			library.add_animation(external_clip_name, external_clip)


func _play_retarget_source(clip_name: String, paused := false) -> void:
	if _retarget_source_player == null or not _retarget_source_player.has_animation(clip_name):
		return
	_retarget_dirty = true
	_retarget_source_player.speed_scale = 1.0
	_retarget_source_player.play(clip_name, 0.08)
	if paused:
		_retarget_source_player.seek(0.0, true)
		_retarget_source_player.pause()


func _apply_retarget_overrides() -> void:
	if _retarget_source_skeleton == null:
		return
	var target_skeleton := get_skeleton()
	if target_skeleton == null:
		return
	if _retarget_bone_pairs.is_empty():
		for source_bone: String in MIXAMO_TO_TARGET:
			var target_bone := str(MIXAMO_TO_TARGET[source_bone])
			var source_bone_index := _retarget_source_skeleton.find_bone(source_bone)
			var target_bone_index := target_skeleton.find_bone(target_bone)
			if source_bone_index >= 0 and target_bone_index >= 0:
				_retarget_bone_pairs.append(Vector2i(source_bone_index, target_bone_index))
	for pair: Vector2i in _retarget_bone_pairs:
		var source_delta := _retarget_source_skeleton.get_bone_global_rest(pair.x).affine_inverse() * _retarget_source_skeleton.get_bone_global_pose(pair.x)
		var target_pose := target_skeleton.get_bone_global_rest(pair.y)
		target_pose.basis = target_pose.basis * source_delta.basis
		target_skeleton.set_bone_global_pose_override(pair.y, target_pose, 1.0, true)


func _release_retarget_source() -> void:
	var target_skeleton := get_skeleton()
	if target_skeleton != null:
		target_skeleton.clear_bones_global_pose_override()
	if _retarget_source_root != null and is_instance_valid(_retarget_source_root):
		remove_child(_retarget_source_root)
		_retarget_source_root.queue_free()
	_retarget_source_root = null
	_retarget_source_skeleton = null
	_retarget_source_player = null
	_retarget_bone_pairs.clear()


func set_locomotion_state(state: String) -> void:
	var normalized := state if LOCOMOTION_STATES.has(state) else "idle"
	_desired_locomotion = normalized
	if not _active_action.is_empty() or _animation_player == null:
		return
	if normalized == "idle":
		if _current_animation != "idle":
			_animation_player.speed_scale = 1.0
			_animation_player.play("walk", 0.12)
			_animation_player.seek(0.0, true)
			_animation_player.pause()
			_play_retarget_source("walk", true)
			_current_animation = "idle"
		return
	if _current_animation == normalized and _animation_player.is_playing():
		return
	_current_animation = normalized
	_animation_player.speed_scale = 1.0
	_animation_player.play(normalized, 0.12)
	_play_retarget_source(normalized)


func set_animation_state(state: String) -> void:
	if ACTION_STATES.has(state):
		if _active_action != state:
			play_action(state)
		return
	set_locomotion_state(state)


func play_action(action: String) -> void:
	if not ACTION_STATES.has(action) or _animation_player == null or not _animation_player.has_animation(action):
		return
	if _active_action == action and _animation_player.is_playing():
		return
	_active_action = action
	_current_animation = action
	_animation_player.speed_scale = 1.0
	_animation_player.play(action, 0.08)
	_play_retarget_source(action)


func stop_action() -> void:
	if _active_action.is_empty() or _active_action == "death":
		return
	_active_action = ""
	_current_animation = ""
	if _animation_player != null:
		_animation_player.stop()
	if _retarget_source_player != null:
		_retarget_source_player.stop()
	set_locomotion_state(_desired_locomotion)


func _on_animation_finished(animation_name: StringName) -> void:
	var finished := str(animation_name)
	if finished != _active_action or finished == "death":
		return
	_active_action = ""
	_current_animation = ""
	set_locomotion_state(_desired_locomotion)


func get_animation_state() -> String:
	return _active_action if not _active_action.is_empty() else _desired_locomotion


func get_skeleton() -> Skeleton3D:
	return _model_root.find_child("Skeleton3D", true, false) as Skeleton3D if _model_root != null else null


func get_animation_player() -> AnimationPlayer:
	return _animation_player


func is_retargeting() -> bool:
	return _retarget_source_skeleton != null and _retarget_source_player != null


func get_retarget_source_animation_player() -> AnimationPlayer:
	return _retarget_source_player


func get_retarget_mapping_count() -> int:
	return _retarget_bone_pairs.size() if is_retargeting() else 0


func get_retargeted_track_count(clip_name: String) -> int:
	if _animation_player == null or not _animation_player.has_animation(clip_name):
		return 0
	return _animation_player.get_animation(clip_name).get_track_count()
