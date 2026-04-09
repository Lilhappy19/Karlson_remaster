extends Control

class_name Settings_menu

@onready var player : Player = $".."
@onready var pause_menu : Pause_menu = $"../pause menu"
@onready var sensitivity_slider : HSlider = $"sensitivity slider"

func _ready() -> void:
	$"sensitivity slider/name".text = "Mouse sensitivity : " + str(round(player.camera_sensitivity * 100)) + "%"
	
	sensitivity_slider.value = player.camera_sensitivity
	sensitivity_slider.value_changed.connect(_on_slider_changed)
	$back.pressed.connect(_on_back)
	
func _on_slider_changed(value : float):
	player.camera_sensitivity = value
	$"sensitivity slider/name".text = "Mouse sensitivity : " + str(round(value * 100)) + "%"

func _on_back():
	self.visible = false
	pause_menu.visible = true
