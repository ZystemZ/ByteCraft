extends RefCounted
class_name ByteCrafterInventoryStack

## Modelo de inventário inspirado no Container/InventoryPlayer de Minecraft.
## Os slots 0–8 são a hotbar e os slots 9–35 são a mochila principal.
## O cursor é uma pilha separada, como o ItemStack carregado pelo mouse.

const HOTBAR_SIZE := 9
const TOTAL_SIZE := 36

var slots: Array = []
var cursor: Variant = null


func _init() -> void:
	reset()


func reset() -> void:
	slots.clear()
	slots.resize(TOTAL_SIZE)
	for index in range(TOTAL_SIZE):
		slots[index] = null
	cursor = null


func is_empty_stack(stack: Variant) -> bool:
	return not (stack is Dictionary) or stack.get("item", null) == null or int(stack.get("count", 0)) <= 0


func make_stack(item_id: Variant, amount: int) -> Variant:
	if item_id == null or amount <= 0:
		return null
	return {"item": canonical_item_id(item_id), "count": amount}


func copy_stack(stack: Variant) -> Variant:
	return stack.duplicate(true) if stack is Dictionary else null


func canonical_item_id(item_id: Variant) -> Variant:
	if item_id is int:
		match int(item_id):
			8:
				return "frutas"
			9:
				return "gelatina"
			10:
				return "fragmento_lunar"
			11:
				return "nucleo_lunar"
		return item_id
	var text := str(item_id)
	return {"8": "frutas", "9": "gelatina", "10": "fragmento_lunar", "11": "nucleo_lunar"}.get(text, item_id)


func item_ids_equal(left: Variant, right: Variant) -> bool:
	var canonical_left: Variant = canonical_item_id(left)
	var canonical_right: Variant = canonical_item_id(right)
	if typeof(canonical_left) != typeof(canonical_right):
		return false
	return canonical_left == canonical_right


func max_stack_size(item_id: Variant) -> int:
	if item_id is String and item_id == "barraca":
		return 16
	if item_id is String and item_id == "cama":
		return 1
	if item_id is String and item_id == "fornalha":
		return 16
	if item_id is String and str(item_id) in [
		"picareta", "picareta_pedra", "picareta_ferro", "machado_ferro",
		"espada", "espada_pedra", "espada_ferro", "balde",
		"armadura_couro_cabeca", "armadura_couro_peito", "armadura_couro_pernas", "armadura_couro_botas"
	]:
		return 1
	return 64


func stack_at(slot_index: int) -> Variant:
	if slot_index < 0 or slot_index >= slots.size():
		return null
	return copy_stack(slots[slot_index])


func get_item(slot_index: int) -> Variant:
	var stack: Variant = stack_at(slot_index)
	return stack.get("item", null) if stack is Dictionary else null


func get_count(slot_index: int) -> int:
	var stack: Variant = stack_at(slot_index)
	return int(stack.get("count", 0)) if stack is Dictionary else 0


func set_stack(slot_index: int, item_id: Variant, amount: int) -> void:
	if slot_index < 0 or slot_index >= slots.size():
		return
	var canonical: Variant = canonical_item_id(item_id)
	var clamped_amount := clampi(amount, 0, max_stack_size(canonical))
	slots[slot_index] = make_stack(canonical, clamped_amount)


func clear_slot(slot_index: int) -> void:
	if slot_index >= 0 and slot_index < slots.size():
		slots[slot_index] = null


func _same_item(left: Variant, right: Variant) -> bool:
	if not (left is Dictionary) or not (right is Dictionary):
		return false
	return item_ids_equal(left.get("item", null), right.get("item", null))


func _slot_can_accept(slot_index: int, item_id: Variant) -> bool:
	if slot_index < 0 or slot_index >= slots.size():
		return false
	var existing: Variant = slots[slot_index]
	if existing == null:
		return true
	return item_ids_equal(existing.get("item", null), item_id) and int(existing.get("count", 0)) < max_stack_size(item_id)


func _ordered_indices(preferred_slot: int = -1) -> Array[int]:
	var result: Array[int] = []
	if preferred_slot >= 0 and preferred_slot < slots.size():
		result.append(preferred_slot)
	for index in range(slots.size()):
		if index != preferred_slot:
			result.append(index)
	return result


## Adds as much as possible, first merging equal stacks and then using empty slots.
## Returns the amount that did not fit, matching InventoryPlayer's leftover behavior.
func add_item(item_id: Variant, amount: int, preferred_slot: int = -1) -> int:
	if item_id == null or amount <= 0:
		return maxi(0, amount)
	var remaining := amount
	var order := _ordered_indices(preferred_slot)
	for index: int in order:
		var stack: Variant = slots[index]
		if stack == null or not item_ids_equal(stack.get("item", null), item_id):
			continue
		var capacity := max_stack_size(item_id) - int(stack.get("count", 0))
		if capacity <= 0:
			continue
		var moved := mini(remaining, capacity)
		stack["count"] = int(stack.get("count", 0)) + moved
		remaining -= moved
		if remaining <= 0:
			return 0
	for index: int in order:
		if slots[index] != null:
			continue
		var moved := mini(remaining, max_stack_size(item_id))
		slots[index] = make_stack(item_id, moved)
		remaining -= moved
		if remaining <= 0:
			return 0
	return remaining


## Removes up to amount from matching slots and returns the amount removed.
func remove_item(item_id: Variant, amount: int, preferred_slot: int = -1) -> int:
	if item_id == null or amount <= 0:
		return 0
	var remaining := amount
	for index: int in _ordered_indices(preferred_slot):
		var stack: Variant = slots[index]
		if stack == null or not item_ids_equal(stack.get("item", null), item_id):
			continue
		var removed := mini(remaining, int(stack.get("count", 0)))
		stack["count"] = int(stack.get("count", 0)) - removed
		remaining -= removed
		if int(stack.get("count", 0)) <= 0:
			slots[index] = null
		if remaining <= 0:
			break
	return amount - remaining


func remove_from_slot(slot_index: int, amount: int) -> Variant:
	if slot_index < 0 or slot_index >= slots.size() or amount <= 0:
		return null
	var stack: Variant = slots[slot_index]
	if stack == null:
		return null
	var removed := mini(amount, int(stack.get("count", 0)))
	var result: Variant = make_stack(stack.get("item", null), removed)
	stack["count"] = int(stack.get("count", 0)) - removed
	if int(stack.get("count", 0)) <= 0:
		slots[slot_index] = null
	return result


func _move_stack_to_range(source_index: int, target_start: int, target_end: int) -> void:
	var source: Variant = slots[source_index]
	if source == null:
		return
	var item_id: Variant = source.get("item", null)
	var remaining := int(source.get("count", 0))
	for target_index in range(target_start, target_end):
		var target: Variant = slots[target_index]
		if target == null or not item_ids_equal(target.get("item", null), item_id):
			continue
		var capacity := max_stack_size(item_id) - int(target.get("count", 0))
		var moved := mini(remaining, maxi(0, capacity))
		target["count"] = int(target.get("count", 0)) + moved
		remaining -= moved
		if remaining <= 0:
			slots[source_index] = null
			return
	for target_index in range(target_start, target_end):
		if slots[target_index] != null:
			continue
		var moved := mini(remaining, max_stack_size(item_id))
		slots[target_index] = make_stack(item_id, moved)
		remaining -= moved
		if remaining <= 0:
			slots[source_index] = null
			return
	source["count"] = remaining


func quick_move(slot_index: int) -> void:
	if slot_index < 0 or slot_index >= slots.size() or slots[slot_index] == null:
		return
	if slot_index < HOTBAR_SIZE:
		_move_stack_to_range(slot_index, HOTBAR_SIZE, TOTAL_SIZE)
	else:
		_move_stack_to_range(slot_index, 0, HOTBAR_SIZE)


## Applies Minecraft-style left/right click behavior to one slot.
## Left: pick up, place, merge, or swap the complete stack.
## Right: pick up half, place one, merge one, or swap incompatible stacks.
func click_slot(slot_index: int, button: int, shift: bool = false) -> void:
	if slot_index < 0 or slot_index >= slots.size():
		return
	if shift:
		quick_move(slot_index)
		return
	var clicked: Variant = slots[slot_index]
	if button == MOUSE_BUTTON_LEFT:
		if cursor == null:
			cursor = clicked
			slots[slot_index] = null
			return
		if clicked == null:
			var cursor_count := int(cursor.get("count", 0))
			var moved := mini(cursor_count, max_stack_size(cursor.get("item", null)))
			slots[slot_index] = make_stack(cursor.get("item", null), moved)
			cursor["count"] = cursor_count - moved
			if int(cursor.get("count", 0)) <= 0:
				cursor = null
			return
		if _same_item(clicked, cursor):
			var capacity := max_stack_size(clicked.get("item", null)) - int(clicked.get("count", 0))
			var moved := mini(int(cursor.get("count", 0)), maxi(0, capacity))
			clicked["count"] = int(clicked.get("count", 0)) + moved
			cursor["count"] = int(cursor.get("count", 0)) - moved
			if int(cursor.get("count", 0)) <= 0:
				cursor = null
			return
		var previous: Variant = clicked
		slots[slot_index] = cursor
		cursor = previous
	elif button == MOUSE_BUTTON_RIGHT:
		if cursor == null:
			if clicked == null:
				return
			var picked := ceili(float(int(clicked.get("count", 0))) / 2.0)
			cursor = make_stack(clicked.get("item", null), picked)
			clicked["count"] = int(clicked.get("count", 0)) - picked
			if int(clicked.get("count", 0)) <= 0:
				slots[slot_index] = null
			return
		if clicked == null:
			slots[slot_index] = make_stack(cursor.get("item", null), 1)
			cursor["count"] = int(cursor.get("count", 0)) - 1
			if int(cursor.get("count", 0)) <= 0:
				cursor = null
			return
		if _same_item(clicked, cursor):
			var capacity := max_stack_size(clicked.get("item", null)) - int(clicked.get("count", 0))
			if capacity > 0:
				clicked["count"] = int(clicked.get("count", 0)) + 1
				cursor["count"] = int(cursor.get("count", 0)) - 1
				if int(cursor.get("count", 0)) <= 0:
					cursor = null
				return
			var previous: Variant = clicked
			slots[slot_index] = cursor
			cursor = previous
			return
		var previous: Variant = clicked
		slots[slot_index] = cursor
		cursor = previous


## Double-click collection: fill the cursor with equal stacks throughout the inventory.
func collect_matching(item_id: Variant) -> void:
	if item_id == null:
		return
	if cursor != null and not item_ids_equal(cursor.get("item", null), item_id):
		return
	if cursor == null:
		cursor = {"item": canonical_item_id(item_id), "count": 0}
	var capacity := max_stack_size(item_id) - int(cursor.get("count", 0))
	for index in range(slots.size()):
		var stack: Variant = slots[index]
		if stack == null or not item_ids_equal(stack.get("item", null), item_id):
			continue
		var moved := mini(capacity, int(stack.get("count", 0)))
		stack["count"] = int(stack.get("count", 0)) - moved
		cursor["count"] = int(cursor.get("count", 0)) + moved
		capacity -= moved
		if int(stack.get("count", 0)) <= 0:
			slots[index] = null
		if capacity <= 0:
			break
	if int(cursor.get("count", 0)) <= 0:
		cursor = null


func serialize_slots() -> Array:
	var result: Array = []
	for stack: Variant in slots:
		result.append(copy_stack(stack))
	return result


func deserialize_slots(serialized: Variant) -> bool:
	if not serialized is Array or serialized.size() != TOTAL_SIZE:
		return false
	reset()
	for index in range(TOTAL_SIZE):
		var value: Variant = serialized[index]
		if not value is Dictionary:
			continue
		var item_id: Variant = value.get("item", null)
		var amount := clampi(int(value.get("count", 0)), 0, max_stack_size(item_id))
		set_stack(index, item_id, amount)
	return true


func aggregate_counts() -> Dictionary:
	var result: Dictionary = {}
	for stack: Variant in slots:
		if not stack is Dictionary:
			continue
		var item_id: Variant = stack.get("item", null)
		var amount := int(stack.get("count", 0))
		if item_id == null or amount <= 0:
			continue
		result[item_id] = int(result.get(item_id, 0)) + amount
	return result
