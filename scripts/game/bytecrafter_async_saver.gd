extends RefCounted
class_name ByteCrafterAsyncSaver

const WORLD_PATH := "user://bytecrafter_world.json"
const PROFILE_PATH := "user://bytecrafter_player.json"

var _thread: Thread
var _pending_request: Dictionary = {}
var _last_error := ""


func request_save(world_snapshot: Dictionary, profile_snapshot: Dictionary) -> void:
	poll()
	var world_copy := world_snapshot.duplicate(false)
	var override_chunks: Variant = world_copy.get("override_chunks", {})
	if override_chunks is Dictionary:
		world_copy["override_chunks"] = override_chunks.duplicate(false)
	var request := {
		"world_path": ProjectSettings.globalize_path(WORLD_PATH),
		"profile_path": ProjectSettings.globalize_path(PROFILE_PATH),
		"world": world_copy,
		# The game creates a fresh profile snapshot per request. A shallow copy avoids
		# cloning large serialized plant/entity arrays on the main thread.
		"profile": profile_snapshot.duplicate(false),
	}
	if _thread != null:
		_pending_request = request
		return
	_start_request(request)


func poll() -> void:
	if _thread == null or _thread.is_alive():
		return
	var result: Variant = _thread.wait_to_finish()
	_thread = null
	if result is Dictionary and not bool(result.get("ok", false)):
		_last_error = str(result.get("error", "Falha desconhecida ao gravar o jogo."))
		push_error("ByteCrafter: " + _last_error)
	if not _pending_request.is_empty():
		var next_request := _pending_request
		_pending_request = {}
		_start_request(next_request)


func wait_until_idle() -> void:
	while _thread != null or not _pending_request.is_empty():
		if _thread == null:
			var next_request := _pending_request
			_pending_request = {}
			_start_request(next_request)
		if _thread != null and _thread.is_alive():
			OS.delay_msec(4)
		else:
			poll()


func is_busy() -> bool:
	return _thread != null or not _pending_request.is_empty()


func _start_request(request: Dictionary) -> void:
	_thread = Thread.new()
	var error := _thread.start(Callable(self, "_write_request").bind(request))
	if error != OK:
		_thread = null
		var result := _write_request(request)
		if not bool(result.get("ok", false)):
			_last_error = str(result.get("error", "Falha ao gravar o jogo."))
			push_error("ByteCrafter: " + _last_error)


func _write_request(request: Dictionary) -> Dictionary:
	var world_data: Dictionary = request.world
	var world_error := _write_world_snapshot_atomic(str(request.world_path), world_data) if world_data.has("override_chunks") else _write_json_atomic(str(request.world_path), world_data)
	if not world_error.is_empty():
		return {"ok": false, "error": "Save do mundo: " + world_error}
	var profile_data: Dictionary = request.profile
	if not profile_data.is_empty():
		var profile_error := _write_json_atomic(str(request.profile_path), profile_data)
		if not profile_error.is_empty():
			return {"ok": false, "error": "Save do jogador: " + profile_error}
	return {"ok": true}


func _write_world_snapshot_atomic(destination: String, data: Dictionary) -> String:
	var temporary := destination + ".async.tmp"
	var file := FileAccess.open(temporary, FileAccess.WRITE)
	if file == null:
		return "não foi possível abrir o arquivo temporário (%d)." % FileAccess.get_open_error()
	file.store_string("{\"version\":1,\"seed\":%d,\"overrides\":[" % int(data.get("seed", 0)))
	var first_entry := true
	var chunks: Dictionary = data.get("override_chunks", {})
	for buffer_value: Variant in chunks.values():
		if not buffer_value is PackedInt32Array:
			continue
		var buffer: PackedInt32Array = buffer_value
		var entries := PackedStringArray()
		for offset: int in range(0, buffer.size() - 3, 4):
			entries.append("[%d,%d,%d,%d]" % [buffer[offset], buffer[offset + 1], buffer[offset + 2], buffer[offset + 3]])
		if entries.is_empty():
			continue
		if not first_entry:
			file.store_string(",")
		file.store_string(",".join(entries))
		first_entry = false
	file.store_string("]}")
	file.flush()
	var write_error := file.get_error()
	file.close()
	if write_error != OK:
		return "erro durante a gravação (%d)." % write_error
	return _commit_temporary_file(temporary, destination)


func _write_json_atomic(destination: String, data: Dictionary) -> String:
	var temporary := destination + ".async.tmp"
	var file := FileAccess.open(temporary, FileAccess.WRITE)
	if file == null:
		return "não foi possível abrir o arquivo temporário (%d)." % FileAccess.get_open_error()
	file.store_string(JSON.stringify(data))
	file.flush()
	var write_error := file.get_error()
	file.close()
	if write_error != OK:
		return "erro durante a gravação (%d)." % write_error
	return _commit_temporary_file(temporary, destination)


func _commit_temporary_file(temporary: String, destination: String) -> String:
	var backup := destination + ".bak"
	var had_previous := FileAccess.file_exists(destination)
	if had_previous:
		if FileAccess.file_exists(backup):
			DirAccess.remove_absolute(backup)
		var backup_error := DirAccess.rename_absolute(destination, backup)
		if backup_error != OK:
			return "não foi possível proteger o save anterior (%d)." % backup_error
	var commit_error := DirAccess.rename_absolute(temporary, destination)
	if commit_error != OK:
		if had_previous:
			DirAccess.rename_absolute(backup, destination)
		return "falha ao finalizar o salvamento (%d)." % commit_error
	if FileAccess.file_exists(backup):
		DirAccess.remove_absolute(backup)
	return ""
