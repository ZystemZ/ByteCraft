extends Area3D

const MODEL := preload("res://assets/bitmal/Shuriken by iPoly3D - mrzNkmPnMo.glb")
var velocity_vector := Vector3.ZERO
var damage := 3.0
var lifetime := 2.5

func configure(origin: Vector3, direction: Vector3, amount: float) -> void:
	global_position = origin
	velocity_vector = direction.normalized() * 15.0
	damage = amount

func _ready() -> void:
	collision_layer = 0
	collision_mask = 2
	monitoring = true
	var shape := SphereShape3D.new()
	shape.radius = 0.18
	var collider := CollisionShape3D.new()
	collider.shape = shape
	add_child(collider)
	var model := MODEL.instantiate() as Node3D
	model.scale = Vector3.ONE * 0.22
	model.rotation_degrees = Vector3(90.0, 0.0, 0.0)
	add_child(model)
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	global_position += velocity_vector * delta
	rotation.z += delta * 14.0
	lifetime -= delta
	if lifetime <= 0.0:
		queue_free()

func _on_body_entered(body: Node3D) -> void:
	if body is ByteCrafterEnemy:
		(body as ByteCrafterEnemy).take_damage(damage)
		queue_free()
