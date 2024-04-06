extends Control

signal microscope_ok
var pollen_number : int
var move_speed : int = 200
@onready var line_edit = $HBoxContainer/VBoxContainer/MarginContainer2/VBoxContainer/LineEdit
@onready var v_slider = $HBoxContainer/VBoxContainer/MarginContainer/VBoxContainer/HBoxContainer/VSlider
@onready var h_slider = $HBoxContainer/VBoxContainer/MarginContainer/VBoxContainer/HBoxContainer/HSlider
@onready var label_v_slider = $HBoxContainer/VBoxContainer/MarginContainer/VBoxContainer/HBoxContainer2/LabelVSlider
@onready var label_h_slider = $HBoxContainer/VBoxContainer/MarginContainer/VBoxContainer/HBoxContainer2/LabelHSlider
var moving_left : bool = false
var moving_right : bool = false
@onready var camera_2d = $HBoxContainer/VBoxContainer2/HBoxContainer/SubViewportContainer/SubViewport/Sample/Plate/Camera2D
@onready var sample = $HBoxContainer/VBoxContainer2/HBoxContainer/SubViewportContainer/SubViewport/Sample


func _ready():
	generate_bodies()
	v_slider.value = 0
	h_slider.value = 0


func _process(delta):
	if moving_left:
		camera_2d.position.x -= move_speed * delta
	if moving_right:
		camera_2d.position.x += move_speed * delta

#randomly generates micro bodies
func generate_bodies():
	pollen_number = 10 #todo: generate number 'around' 10
	#generate bodies

func success():
	print("success")

func failure():
	print("failure")



func _on_button_button_down():
	if line_edit.text == str(pollen_number):
		success()
		microscope_ok.emit()
	else:
		failure()


func _on_v_slider_value_changed(value):
	label_v_slider.text = str(value)

func _on_h_slider_value_changed(value):
	label_h_slider.text = str(value)




func _on_button_move_right_button_down():
	moving_right = true



func _on_button_move_left_button_down():
	moving_left = true


func _on_button_move_left_button_up():
	moving_left = false


func _on_button_move_right_button_up():
	moving_right = false
