extends RigidBody3D

class_name Cup

signal score(cup: Cup, ball: Ball)
signal spill(cup: Cup)

@onready var particles: CPUParticles3D = $CPUParticles3D

@export var spill_angle: float = 80
var spilled: bool = false

func _physics_process(delta):
	if linear_velocity != Vector3.ZERO:
		print(linear_velocity)


func _process(_delta):
	# print(linear_velocity)
	
	
	if not spilled and (rad_to_deg(abs(rotation.x)) > spill_angle or rad_to_deg(abs(rotation.z)) > spill_angle):
		spilled = true
		@warning_ignore(return_value_discarded)
		emit_signal('spill', self)
		particles.emitting = true


func _on_area_3d_body_entered(other: RigidBody3D):
	if other is Ball: # and other.linear_velocity.y > 0:
		@warning_ignore(return_value_discarded)
		emit_signal('score', self, other)


func _on_body_entered(body):
	if body is Ball:
		freeze = false
