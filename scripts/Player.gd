extends RigidBody3D

class_name Player

@export var health : float = 100
@export var speed : float = 10
@export var speed_M : float = 2
@export var jump_force : float = 20
@export var camera_sensitivity : float = 1

@onready var standard_collision : CollisionShape3D = $StandardCollison
@onready var standard_shape : MeshInstance3D = $StandardShape
@onready var crouch_collision : CollisionShape3D = $CrouchCollison
@onready var crouch_shape : MeshInstance3D = $CrouchShape
@onready var crouch_check : RayCast3D = $CrouchCheck
@onready var health_bar : ProgressBar = $Camera3D/HealthBar

@onready var ground_check_shape : ShapeCast3D = $ShapeCast3D
@onready var camera : Camera3D = $Camera3D

var camera_target_pos : float = 0
var camera_original_pos : float

var mouse_lock : bool = true
var look_dir : Vector2

func _ready() -> void:
	camera_original_pos = camera.position.y
	
	health_bar.value = health
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(_delta: float) -> void:
	_camera()
	if mouse_lock:
		_movement()
		_change_shape()

func _ray_update():
	ground_check_shape.force_shapecast_update()

func _movement():
	_ray_update()
	var dir : Vector3 = Vector3.ZERO
	
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
	
	if Input.is_action_pressed("Move_Crouch_Slide"):
		linear_velocity.z = dir.z * speed / speed_M
		linear_velocity.x = dir.x * speed / speed_M
	elif Input.is_action_pressed("Move_Sprint"):
		linear_velocity.z = dir.z * speed * speed_M
		linear_velocity.x = dir.x * speed * speed_M
	else:
		linear_velocity.z = dir.z * speed
		linear_velocity.x = dir.x * speed

func _camera():
	_mouse_lock()
	if mouse_lock :
		_rotate_camera()

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
