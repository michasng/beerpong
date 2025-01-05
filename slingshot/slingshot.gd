extends Node3D

class_name Slingshot

const ball_scene: PackedScene = preload("res://ball/ball.tscn")

@onready var camera: Camera3D = $Camera3D
@onready var planeMesh: MeshInstance3D = $Camera3D/MeshInstance3D

@export var strength: float = 100
@export var shot_angle: float = 0

const camera_distance = 1

var ball: Ball
var string: MeshInstance3D
var string_end: MeshInstance3D
var is_pulling: bool = false

func _ready():
	planeMesh.rotate_x(deg_to_rad(shot_angle + 90))
	# call_deferred("setup_corners")


func setup_corners():
	var screen_size = get_viewport().get_visible_rect().size
	point(_screen_to_world(Vector2.ZERO), 0.02)
	point(_screen_to_world(Vector2(0, screen_size.y)), 0.02)
	point(_screen_to_world(Vector2(screen_size.x, 0)), 0.02)
	point(_screen_to_world(screen_size), 0.02)
	point(_screen_to_world(Vector2(screen_size.x / 2, 0)), 0.02)
	point(_screen_to_world(Vector2(screen_size.x / 2, screen_size.y)), 0.02)
	point(_screen_to_world(Vector2(0, screen_size.y / 2)), 0.02)
	point(_screen_to_world(Vector2(screen_size.x, screen_size.y / 2)), 0.02)
	point(_screen_to_world(screen_size / 2), 0.02)


func reload():
	if ball != null:
		ball.queue_free()
	ball = ball_scene.instantiate()
	add_child(ball)
	ball.freeze = true


func _input(event: InputEvent):
	if ball == null:
		return
	
	if event is InputEventMouse:
		if string:
			string.queue_free()
			string = null
			string_end.queue_free()
			string_end = null
		var was_pulling = is_pulling
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
			is_pulling = event.pressed
		if is_pulling:
			var world_pos = _screen_to_world(event.position)
			string = line(ball.global_position, world_pos)
			string_end = point(world_pos, 0.02)
		elif was_pulling:
			_shoot(_screen_to_world(event.position))


func _shoot(pull_position: Vector3):
	ball.freeze = false
	var force = ball.global_position - pull_position
	ball.apply_force(force * strength)
	ball = null


func _screen_to_world(screen_pos: Vector2) -> Vector3:
	# print('screen_pos', screen_pos)
	var screen_size = get_viewport().get_visible_rect().size
	var projected_bottom = camera.project_position(Vector2(screen_size.x / 2, 0), camera_distance)
	var projected_top = camera.project_position(Vector2(screen_size.x / 2, screen_size.y), camera_distance)
	var projected_height = projected_bottom.distance_to(projected_top)
	# print('projected_height ', projected_height)
	var y_ratio = 1 - screen_pos.y / screen_size.y # from 0 to 1
	# print('y_ratio ', y_ratio)
	var projected_y = projected_height * y_ratio
	# print('projected_y ', projected_y)
	var slope = tan(deg_to_rad(-shot_angle))
	# print('slope ', slope)
	var distance = slope * projected_y + camera_distance - projected_height / 2 # y=mx+t
	# print('distance ', distance)

	var projected = camera.project_position(screen_pos, distance)
	# print('projected', projected)
	return projected


func line(pos1: Vector3, pos2: Vector3, color = Color.WHITE_SMOKE) -> MeshInstance3D:
	var mesh_instance := MeshInstance3D.new()
	var immediate_mesh := ImmediateMesh.new()
	var material := ORMMaterial3D.new()
	
	mesh_instance.mesh = immediate_mesh
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES, material)
	immediate_mesh.surface_add_vertex(pos1)
	immediate_mesh.surface_add_vertex(pos2)
	immediate_mesh.surface_end()
	
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = color
	
	get_tree().get_root().add_child(mesh_instance)
	
	return mesh_instance


func point(pos:Vector3, radius = 0.05, color = Color.WHITE_SMOKE) -> MeshInstance3D:
	var mesh_instance := MeshInstance3D.new()
	var sphere_mesh := SphereMesh.new()
	var material := ORMMaterial3D.new()
		
	mesh_instance.mesh = sphere_mesh
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mesh_instance.position = pos
	
	sphere_mesh.radius = radius
	sphere_mesh.height = radius*2
	sphere_mesh.material = material
	
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = color
	
	get_tree().get_root().add_child(mesh_instance)
	
	return mesh_instance
