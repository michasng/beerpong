extends Node3D

const formation_scene: PackedScene = preload("res://cup/formation.tscn")

@onready var slingshot: Slingshot = $Slingshot

@export var red_formation_position: Vector3
@export var red_formation_rotation: Vector3


func _ready():
	spawn_formation()
	slingshot.reload()


func spawn_formation():
	var formation = formation_scene.instantiate()
	formation.position = red_formation_position
	formation.rotation = Vector3(
		deg_to_rad(red_formation_rotation.x),
		deg_to_rad(red_formation_rotation.y),
		deg_to_rad(red_formation_rotation.z),
	)
	add_child(formation)
	
	for cup in formation.get_children():
		print(cup)
		@warning_ignore(return_value_discarded)
		cup.connect('score', _on_score)
		@warning_ignore(return_value_discarded)
		cup.connect('spill', _on_spill)


func _on_score(cup: Cup, ball: Ball):
	cup.freeze = true
	ball.freeze = true
	await get_tree().create_timer(1).timeout
	cup.queue_free()
	ball.queue_free()
	slingshot.reload()


func _on_spill(cup: Cup):
	print('SPLASH')
	await get_tree().create_timer(1).timeout
	if is_instance_valid(cup):
		cup.queue_free()


func _on_floor_body_entered(body: PhysicsBody3D):
	if body is Ball:
		if is_instance_valid(body):
			body.queue_free()
		slingshot.reload()
		print('Ball fell down')
	elif body is Cup:
		if is_instance_valid(body):
			body.queue_free()
		print('Cup fell down')

