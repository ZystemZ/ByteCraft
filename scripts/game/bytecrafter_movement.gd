extends RefCounted
class_name ByteCrafterMovement

const GRAVITY := 20.0
const STEP_HEIGHT := 1.0
const STEP_CLEARANCE := 0.12
const ONE_BLOCK_JUMP_SPEED := 6.4


static func is_in_water(world: Variant, actor: Variant, actor_height: float) -> bool:
	if not is_instance_valid(world) or not is_instance_valid(actor):
		return false
	return world.is_actor_in_water(actor.global_position, actor_height)


static func apply_buoyancy(body: CharacterBody3D, world: Variant, delta: float, body_height: float, swim_up: bool = false, swim_speed: float = 4.8) -> void:
	if not is_instance_valid(body):
		return
	if not is_instance_valid(world):
		body.velocity.y -= GRAVITY * delta
		return
	var surface: float = world.get_water_surface_height_at(body.global_position)
	if not is_finite(surface):
		body.velocity.y -= GRAVITY * delta
		return
	var desired_base_y: float = surface - body_height * 0.52
	var vertical_error: float = desired_base_y - body.global_position.y
	body.velocity.y = clampf(body.velocity.y + (vertical_error * 14.0 - body.velocity.y * 6.0) * delta, -6.0, 6.0)
	if swim_up:
		body.velocity.y = maxf(body.velocity.y, swim_speed)


static func move_with_step(body: CharacterBody3D, delta: float, auto_hop: bool = false, was_in_water: bool = false, jump_speed: float = ONE_BLOCK_JUMP_SPEED) -> bool:
	var start_transform := body.global_transform
	var intended_velocity := body.velocity
	var was_grounded := body.is_on_floor()
	body.move_and_slide()
	if not body.is_on_wall():
		return false
	var horizontal_motion := Vector3(intended_velocity.x, 0.0, intended_velocity.z) * delta
	# Na água o ator pode chegar à margem antes de ser reconhecido como grounded.
	# Mantemos a checagem completa de colisão/piso antes de permitir o step-up.
	if (was_grounded or was_in_water) and _try_step_up(body, start_transform, horizontal_motion):
		body.velocity.x = intended_velocity.x
		body.velocity.z = intended_velocity.z
		body.velocity.y = maxf(0.0, intended_velocity.y)
		return true
	if auto_hop and (was_grounded or was_in_water) and intended_velocity.y <= 0.05:
		body.velocity.x = intended_velocity.x
		body.velocity.z = intended_velocity.z
		body.velocity.y = jump_speed
		return true
	return false


static func _try_step_up(body: CharacterBody3D, start_transform: Transform3D, horizontal_motion: Vector3) -> bool:
	if horizontal_motion.length_squared() < 0.000001:
		return false
	var wall_hit := KinematicCollision3D.new()
	if not body.test_move(start_transform, horizontal_motion, wall_hit) or absf(wall_hit.get_normal().y) > 0.55:
		return false
	var rise := Vector3.UP * (STEP_HEIGHT + STEP_CLEARANCE)
	if body.test_move(start_transform, rise):
		return false
	var raised_transform := start_transform.translated(rise)
	var step_motion := horizontal_motion + horizontal_motion.normalized() * STEP_CLEARANCE
	if body.test_move(raised_transform, step_motion):
		return false
	var across_transform := raised_transform.translated(step_motion)
	var floor_hit := KinematicCollision3D.new()
	if not body.test_move(across_transform, Vector3.DOWN * (STEP_HEIGHT + STEP_CLEARANCE + 0.15), floor_hit) or floor_hit.get_normal().y < 0.7:
		return false
	var destination := across_transform.translated(floor_hit.get_travel())
	if destination.origin.y <= start_transform.origin.y + 0.05 or destination.origin.y > start_transform.origin.y + STEP_HEIGHT + 0.1:
		return false
	body.global_transform = destination
	return true
