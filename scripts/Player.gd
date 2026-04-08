extends RigidBody3D

class_name Player

var grabbable_groups : Array[String] = ["Box"]

@export var fall_off_amount : float = -3
@export var health : float = 100
@export var speed : float = 500
@export var speed_M : float = 2
@export var slide_threshold : int = 4
@export var jump_force : float = 20
@export var camera_sensitivity : float = 1
@export var strength : float = 15

@onready var standard_collision : CollisionShape3D = $StandardCollison
@onready var standard_shape : MeshInstance3D = $StandardShape
@onready var crouch_collision : CollisionShape3D = $CrouchCollison
@onready var crouch_shape : MeshInstance3D = $CrouchShape
@onready var crouch_check : RayCast3D = $CrouchCheck
@onready var wall_check : ShapeCast3D = $WallCheck
@onready var grab_ray : RayCast3D = $Camera3D/GrabCast
@onready var health_bar : ProgressBar = $Camera3D/HealthBar

@onready var ground_check_shape : ShapeCast3D = $ShapeCast3D
@onready var camera : Camera3D = $Camera3D

var camera_target_pos : float = 0
var camera_original_pos : float
const original_gravity : int = 5
const tilt_amount : float = 0.15

var can_wall_jump : bool = true
var mouse_lock : bool = true
var look_dir : Vector2

var obj_distance : float = 0.0
var grabbed_obj : RigidBody3D = null

func _ready() -> void:
	camera_original_pos = camera.position.y
	
	health_bar.value = health
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(_delta: float) -> void:
	_camera()
	if mouse_lock:
		_movement(_delta)
		_change_shape()
		_drag()

func _ray_update():
	ground_check_shape.force_shapecast_update()

func _movement(_delta : float):
	_ray_update()
	var dir : Vector3 = Vector3.ZERO
	
	if wall_check.is_colliding() and can_wall_jump:
		if Input.is_action_just_pressed("Move_Jump"):
			can_wall_jump = false
			linear_velocity.y = jump_force
	elif not wall_check.is_colliding():
		can_wall_jump = true
	
	if wall_check.is_colliding():
		linear_velocity.y = clamp(linear_velocity.y,fall_off_amount,jump_force)
	
	if ground_check_shape.is_colliding():
		if Input.is_action_just_pressed("Move_Jump"):
			linear_velocity.y = jump_force
		
	if Input.is_action_pressed("Move_Forward"):
		dir.z -= 1
	if Input.is_action_pressed("Move_Backward"):
		dir.z += 1
	if Input.is_action_pressed("Move_Left"):
		dir.x -= 1
	if Input.is_action_pressed("Move_Right"):
		dir.x += 1
		
	dir = dir.normalized().rotated(Vector3.UP,rotation.y)
	
	var momentum : int = int(Vector3(linear_velocity.x,0,linear_velocity.z).length())
	
	if Input.is_action_pressed("Move_Crouch_Slide") and ground_check_shape.is_colliding() or crouch_check.is_colliding():
		if momentum <= slide_threshold:
			linear_velocity.z = dir.z * speed / speed_M * _delta
			linear_velocity.x = dir.x * speed / speed_M * _delta
	elif Input.is_action_pressed("Move_Sprint"):
		linear_velocity.z = dir.z * speed * speed_M * _delta
		linear_velocity.x = dir.x * speed * speed_M * _delta
	else:
		linear_velocity.z = dir.z * speed * _delta
		linear_velocity.x = dir.x * speed * _delta

func _drag():
	var colider = grab_ray.get_collider()
	
	if Input.is_action_just_pressed("Input_Left_Click"):
		if grab_ray.is_colliding() :
			for i in grabbable_groups:
				if colider.is_in_group(i):
					grabbed_obj = grab_ray.get_collider()
					obj_distance = camera.global_position.distance_to(grab_ray.get_collision_point())
	if Input.is_action_pressed("Input_Left_Click") and grabbed_obj != null:
		grabbed_obj.linear_velocity =((camera.global_position + (-camera.global_basis.z * obj_distance)) - grabbed_obj.global_position) * strength
	if Input.is_action_just_released("Input_Left_Click"):
		grabbed_obj = null
		
func _camera():
	_mouse_lock()
	if mouse_lock :
		_rotate_camera()
		_camera_tilt()
		
func _camera_tilt():
	if wall_check.is_colliding():
		var wall_noramal = wall_check.get_collision_normal(0)
		camera.rotation.z = lerp(camera.rotation.z, -wall_noramal.dot(global_basis.x) * tilt_amount , 0.1)
	else :
		camera.rotation.z = lerp(camera.rotation.z, 0.0 , 0.1)

func _rotate_camera(sans_mod : float = 0.1) -> void:
	rotation.y -= look_dir.x * camera_sensitivity * sans_mod
	camera.rotation.x = clamp(camera.rotation.x - look_dir.y * camera_sensitivity * sans_mod,-1.4,1.4)
	look_dir = Vector2.ZERO
	
	rotation.y = wrapf(rotation.y, -PI, PI) 

func _mouse_lock():
	if Input.is_action_just_pressed("Input_Pause"):
		mouse_lock = !mouse_lock
		
		if mouse_lock:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _change_shape():
	if crouch_check.is_colliding() or Input.is_action_pressed("Move_Crouch_Slide"):
		camera.position.y = camera_target_pos
		
		standard_shape.visible = false
		standard_collision.disabled = true
		crouch_collision.disabled = false
		crouch_shape.visible = true
	else:
		camera.position.y = camera_original_pos
		
		standard_shape.visible = true
		standard_collision.disabled = false
		crouch_collision.disabled = true
		crouch_shape.visible = false

func _take_damage(_damage : float):
	pass

func _input(event: InputEvent) -> void:
	if mouse_lock:
		if event is InputEventMouseMotion : look_dir += event.relative * 0.1
