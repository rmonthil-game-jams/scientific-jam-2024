extends Control

var t : float = 0.5
var capsule_initial_y : float
@onready var main_menu = $"."
@onready var v_box_container_buttons = $HBoxContainerMain/VBoxContainerMenu/MarginContainerButtons/VBoxContainerButtons
@onready var margin_container_exit_dialog = $MarginContainerExitDialog
@onready var texture_rect_dialog = $HBoxContainerMain/VBoxContainer/MarginContainerDialog/TextureRectDialog
@onready var rich_text_label_how_to = $HBoxContainerMain/VBoxContainer/MarginContainerDialog/TextureRectDialog/MarginContainerInner/RichTextLabelHowTo
@onready var v_box_container_options = $HBoxContainerMain/VBoxContainer/MarginContainerDialog/TextureRectDialog/MarginContainerInner/VBoxContainerOptions
@onready var rich_text_label_credits = $HBoxContainerMain/VBoxContainer/MarginContainerDialog/TextureRectDialog/MarginContainerInner/RichTextLabelCredits
@onready var button_how_to = $HBoxContainerMain/VBoxContainerMenu/MarginContainerButtons/VBoxContainerButtons/MarginContainerButtonHowTo/ButtonHowTo
@onready var button_options = $HBoxContainerMain/VBoxContainerMenu/MarginContainerButtons/VBoxContainerButtons/MarginContainerButtonOptions/ButtonOptions
@onready var button_credits = $HBoxContainerMain/VBoxContainerMenu/MarginContainerButtons/VBoxContainerButtons/MarginContainerButtonCredits/ButtonCredits
@onready var h_slider_music = $HBoxContainerMain/VBoxContainer/MarginContainerDialog/TextureRectDialog/MarginContainerInner/VBoxContainerOptions/HBoxContainer/MarginContainer2/HSliderMusic
@onready var h_slider_sounds = $HBoxContainerMain/VBoxContainer/MarginContainerDialog/TextureRectDialog/MarginContainerInner/VBoxContainerOptions/HBoxContainer2/MarginContainer2/HSliderSounds
@onready var capsule = $TextureRect/Capsule
@onready var shadow = $TextureRect/Shadow
@onready var margin_container_dialog = $HBoxContainerMain/VBoxContainer/MarginContainerDialog
@onready var margin_container_button_exit = $MarginContainerButtonExit
@onready var check_button_fullscreen = $HBoxContainerMain/VBoxContainer/MarginContainerDialog/TextureRectDialog/MarginContainerInner/VBoxContainerOptions/HBoxContainer3/MarginContainer2/CheckButtonFullscreen
@onready var button_yes = $MarginContainerExitDialog/TextureRect/VBoxContainer/HBoxContainer/MarginContainerButtonYes/ButtonYes
@onready var button_no = $MarginContainerExitDialog/TextureRect/VBoxContainer/HBoxContainer/MarginContainerButtonNo/ButtonNo

# Called when the node enters the scene tree for the first time.
func _ready():
	# set up state back to zero just in case
	LabState.alexia_state = ""
	LabState.ams_done = false
	LabState.cuve_done = false
	LabState.microscope_done = false
	LabState.remaining_ice_cores_in_the_fridge = 5
	# more
	h_slider_music.set_focus_mode(Control.FOCUS_NONE)
	h_slider_sounds.set_focus_mode(Control.FOCUS_NONE)
	check_button_fullscreen.set_focus_mode(Control.FOCUS_NONE)
	button_yes.set_focus_mode(Control.FOCUS_NONE)
	button_no.set_focus_mode(Control.FOCUS_NONE)
	margin_container_exit_dialog.hide()
	shadow.modulate = Color(1,1,1,0)
	hide_dialogs()
	volume(1, h_slider_music.value)
	volume(2, h_slider_sounds.value)
	# fade in animation
	main_menu.modulate = Color.BLACK
	var tween: Tween = create_tween()
	tween.tween_property(main_menu, "modulate", Color.WHITE, 1.0).set_trans(Tween.TRANS_QUAD)
	capsule_initial_y = capsule.position.y

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	t += delta
	if 0.7*t == 2 * PI:
		t = 0
	capsule.position.y = capsule_initial_y + 7 * sin(0.7*t)


func hide_dialogs():
	texture_rect_dialog.hide()
	rich_text_label_how_to.hide()
	v_box_container_options.hide()
	rich_text_label_credits.hide()

func volume(bus_index, value):
	AudioServer.set_bus_volume_db(bus_index, 3*log(value))


func _on_button_play_button_up():
	$AudioStreamPlayerClick.play()
	var tween: Tween = create_tween()
	tween.tween_property(v_box_container_buttons, "modulate", Color(1,1,1,0), 1.0).set_trans(Tween.TRANS_QUAD)
	tween.parallel().tween_property(shadow, "modulate", Color(1,1,1,1), 1.0)
	tween.parallel().tween_property(margin_container_dialog, "modulate", Color(1,1,1,0), 1.0)
	margin_container_button_exit.hide()
	await tween.finished
	await get_tree().create_timer(1.5).timeout
	var tween_transition: Tween = create_tween()
	tween_transition.tween_property(main_menu, "modulate", Color.BLACK, 1.5).set_trans(Tween.TRANS_QUAD)
	await tween_transition.finished
	get_tree().change_scene_to_file("res://louis/close_up_capsule.tscn")


func _on_button_exit_button_up():
	$AudioStreamPlayerClick.play()
	margin_container_exit_dialog.show()

func _on_button_no_button_up():
	$AudioStreamPlayerClick.play()
	margin_container_exit_dialog.hide()

func _on_button_yes_button_up():
	$AudioStreamPlayerClick.play()
	get_tree().quit()


func _on_button_how_to_toggled(toggled_on):
	$AudioStreamPlayerClick.play()
	hide_dialogs()
	if toggled_on:
		button_options.button_pressed = false
		button_credits.button_pressed = false
		texture_rect_dialog.show()
		rich_text_label_how_to.show()
	else:
		texture_rect_dialog.hide()
		rich_text_label_how_to.hide()

func _on_button_options_toggled(toggled_on):
	$AudioStreamPlayerClick.play()
	hide_dialogs()
	if toggled_on:
		button_how_to.button_pressed = false
		button_credits.button_pressed = false
		texture_rect_dialog.show()
		v_box_container_options.show()
	else:
		texture_rect_dialog.hide()
		v_box_container_options.hide()

func _on_button_credits_toggled(toggled_on):
	$AudioStreamPlayerClick.play()
	hide_dialogs()
	if toggled_on:
		button_how_to.button_pressed = false
		button_options.button_pressed = false
		texture_rect_dialog.show()
		rich_text_label_credits.show()
	else:
		texture_rect_dialog.hide()
		rich_text_label_credits.hide()


func _on_check_button_fullscreen_toggled(toggled_on):
	$AudioStreamPlayerClick.play()
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)



func _on_h_slider_music_value_changed(value):
	$AudioStreamPlayerClick.play()
	volume(1, value)

func _on_h_slider_sounds_value_changed(value):
	$AudioStreamPlayerClick.play()
	volume(2, value)
