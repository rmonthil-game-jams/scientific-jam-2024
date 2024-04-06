extends Control

signal microscope_ok
var pollen_number : int
var move_speed : int = 200
var spawn_radius_height : int = 70
var spawn_radius_width : int = 350
var move_range : int = 300
var moving_left : bool = false
var moving_right : bool = false
@onready var line_edit = $HBoxContainer/VBoxContainer/MarginContainer2/VBoxContainer/LineEdit
@onready var v_slider = $HBoxContainer/VBoxContainer/MarginContainer/VBoxContainer/HBoxContainer/VSlider
@onready var h_slider = $HBoxContainer/VBoxContainer/MarginContainer/VBoxContainer/HBoxContainer/HSlider
@onready var label_v_slider = $HBoxContainer/VBoxContainer/MarginContainer/VBoxContainer/HBoxContainer2/LabelVSlider
@onready var label_h_slider = $HBoxContainer/VBoxContainer/MarginContainer/VBoxContainer/HBoxContainer2/LabelHSlider
@onready var sample = $HBoxContainer/VBoxContainer2/HBoxContainer/SubViewportContainer/SubViewport/Sample
@onready var micro_bodies = $HBoxContainer/VBoxContainer2/HBoxContainer/SubViewportContainer/SubViewport/Sample/MicroBodies
@onready var circle_lense = $HBoxContainer/VBoxContainer2/HBoxContainer/SubViewportContainer/SubViewport/Sample/CircleLense

var pollen_scene : PackedScene = preload("res://louis/microscope_game/pollen.tscn")
var micro_plastic_scene : PackedScene = preload("res://louis/microscope_game/micro_plastic.tscn")

func _ready():
	generate_bodies()
	v_slider.value = 0
	h_slider.value = 0
	var random = RandomNumberGenerator.new()
	random.randomize()
	# fade in animation
	modulate = Color.BLACK
	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 1.0).set_trans(Tween.TRANS_QUAD)

func _process(delta):
	if moving_left:
		circle_lense.position.x -= move_speed * delta
	if moving_right:
		circle_lense.position.x += move_speed * delta
	circle_lense.position.x = clamp(-move_range, circle_lense.position.x, move_range)

#randomly generates micro bodies
func generate_bodies():
	pollen_number = randi() % 5 + 6 #entier entre 6 et 10 inclus
	var micro_plastic_number = randi() % 5 + 4 #entier entre 4 et 8 inclus
	#generate bodies
	
	for i in range(pollen_number):
		var pollen = pollen_scene.instantiate() as RigidBody2D
		pollen.position = Vector2((2*randf()-1) * spawn_radius_width, (2*randf()-1) * spawn_radius_height)
		micro_bodies.add_child(pollen)
	for i in range(micro_plastic_number):
		var micro_plastic = micro_plastic_scene.instantiate() as RigidBody2D
		micro_plastic.position = Vector2((2*randf()-1) * spawn_radius_width, (2*randf()-1) * spawn_radius_height)
		micro_bodies.add_child(micro_plastic)

func success():
	# change state of game
	LabState.microscope_done = true
	# color
	$HBoxContainer/VBoxContainer/MarginContainer2/VBoxContainer/HBoxContainer/LabelValidated.add_theme_color_override("font_color", Color.GREEN)
	$HBoxContainer/VBoxContainer/MarginContainer2/VBoxContainer/HBoxContainer/LabelValidated.text = "SUCCESS"
	await get_tree().create_timer(0.5).timeout
	# transition
	var tween_transition: Tween = create_tween()
	tween_transition.tween_property(self, "modulate", Color.BLACK, 1.0).set_trans(Tween.TRANS_QUAD)
	await tween_transition.finished
	get_tree().change_scene_to_file("res://remi/lab/lab.tscn")

func failure():
	$HBoxContainer/VBoxContainer/MarginContainer2/VBoxContainer/HBoxContainer/LabelValidated.add_theme_color_override("font_color", Color.RED)
	$HBoxContainer/VBoxContainer/MarginContainer2/VBoxContainer/HBoxContainer/LabelValidated.text = "FAILURE"



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


func _on_line_edit_text_submitted(new_text):
	_on_button_button_down()
