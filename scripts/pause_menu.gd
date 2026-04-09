extends Control

class_name Pause_menu

@onready var player : Player = $"../Player"
@onready var settings_menu : Settings_menu = $"../settings_menu"

func _ready() -> void:
	$"Resume button".pressed.connect(_on_resume)
	$"Restart button".pressed.connect(_on_restart)
	$"Quit button".pressed.connect(_on_quit)
	$"Settings button".pressed.connect(_on_settings)
	
func _on_resume():
	player.mouse_lock = true
	self.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _on_restart():
	get_tree().reload_current_scene()
	
func _on_quit():
	get_tree().quit()
	
func _on_settings():
	self.visible = false
	settings_menu.visible = true
