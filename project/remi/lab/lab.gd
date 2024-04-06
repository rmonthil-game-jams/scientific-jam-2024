extends Node

# parameters
const ALEXIA_WALKING_SPEED: float = 4e2
const ALEXIA_SWICTH_DURATION: float = 0.25

# output
var is_moving: bool = false

# internal
var tween_moving: Tween = null
var tween_switching: Tween = null

# interface
## move
func play_move_alexia_animation_to_target(global_target: Vector2):
	# switch
	if global_target.x > $World/YSort/Alexia.global_position.x:
		if $World/YSort/Alexia/Anchor.scale.x != -1.0:
			if tween_switching:
				tween_switching.stop()
			tween_switching = create_tween()
			tween_switching.tween_property($World/YSort/Alexia/Anchor, "scale:x", -1.0, ALEXIA_SWICTH_DURATION).set_trans(Tween.TRANS_QUAD)
	elif global_target.x < $World/YSort/Alexia.global_position.x:
		if $World/YSort/Alexia/Anchor.scale.x != 1.0:
			if tween_switching:
				tween_switching.stop()
			tween_switching = create_tween()
			tween_switching.tween_property($World/YSort/Alexia/Anchor, "scale:x", 1.0, ALEXIA_SWICTH_DURATION).set_trans(Tween.TRANS_QUAD)
	else:
		return
	# stop tween
	$World/YSort/Alexia.stop_walking_animation()
	if tween_moving:
		tween_moving.stop()
	# tween
	is_moving = true
	tween_moving = create_tween()
	tween_moving.tween_callback($World/YSort/Alexia.play_walking_animation)
	tween_moving.tween_property($World/YSort/Alexia, "global_position:x", global_target.x, abs($World/YSort/Alexia.global_position.x - global_target.x)/ALEXIA_WALKING_SPEED).set_trans(Tween.TRANS_QUAD) 
	tween_moving.tween_callback($World/YSort/Alexia.play_idle_animation)
	await tween_moving.finished
	is_moving = false

# internal
func _ready():
	match LabState.alexia_state:
		"ams":
			$World/YSort/Alexia.global_position.x = $World/YSort/DeskAnchor/Ams.global_position.x
		"cuve":
			$World/YSort/Alexia.global_position.x = $World/YSort/DeskAnchor/Cuve.global_position.x
		"microscope":
			$World/YSort/Alexia.global_position.x = $World/YSort/DeskAnchor/Microscope.global_position.x
	# connect
	if not LabState.ams_done:
		$World/YSort/DeskAnchor/Ams.selected.connect(_on_ams_selected.bind($World/YSort/DeskAnchor/Ams))
	else:
		$World/YSort/DeskAnchor/Ams/TextureButton.disabled = true
		$World/YSort/DeskAnchor/Ams/TextureButton.focus_mode = Control.FOCUS_NONE
	if not LabState.cuve_done:
		$World/YSort/DeskAnchor/Cuve.selected.connect(_on_cuve_selected.bind($World/YSort/DeskAnchor/Cuve))
	else:
		$World/YSort/DeskAnchor/Cuve/TextureButton.disabled = true
		$World/YSort/DeskAnchor/Cuve/TextureButton.focus_mode = Control.FOCUS_NONE
	if not LabState.microscope_done:
		$World/YSort/DeskAnchor/Microscope.selected.connect(_on_microscope_selected.bind($World/YSort/DeskAnchor/Microscope))
	else:
		$World/YSort/DeskAnchor/Microscope/TextureButton.disabled = true
		$World/YSort/DeskAnchor/Microscope/TextureButton.focus_mode = Control.FOCUS_NONE
	# fade in animation
	$World.modulate = Color.BLACK
	$Gui/TextStack.modulate = Color.BLACK
	var tween: Tween = create_tween()
	tween.tween_property($World, "modulate", Color.WHITE, 1.0).set_trans(Tween.TRANS_QUAD)
	tween.parallel().tween_property($Gui/TextStack, "modulate", Color.WHITE, 1.0).set_trans(Tween.TRANS_QUAD)
	# test text
	if not LabState.alexia_state:
		$Gui/TextStack.push_line("Test Test Test 0 !")
		await get_tree().create_timer(2.0).timeout
		$Gui/TextStack.push_line("Test Test Test 1 !")
		await get_tree().create_timer(2.0).timeout
		$Gui/TextStack.push_line("Test Test Test 2 !")

# input
func _unhandled_input(event: InputEvent):
	if event is InputEventMouseButton:
		if not event.pressed:
			play_move_alexia_animation_to_target($World.get_global_mouse_position())

# signals
func _on_ams_selected(target: Node2D):
	# wait animation end
	play_move_alexia_animation_to_target(target.global_position)
	await tween_moving.finished
	$World/YSort/Alexia.stop_idle_animation()
	await $World/YSort/Alexia.tween_idle.finished
	# set lab state
	LabState.alexia_state = "ams"
	# transition animation
	var tween_transition: Tween = create_tween()
	tween_transition.tween_property($World, "modulate", Color.BLACK, 1.0).set_trans(Tween.TRANS_QUAD)
	tween_transition.parallel().tween_property($Gui/TextStack, "modulate", Color.BLACK, 1.0).set_trans(Tween.TRANS_QUAD)
	await tween_transition.finished
	get_tree().change_scene_to_file("res://remi/ams/ams.tscn")

func _on_cuve_selected(target: Node2D):
	play_move_alexia_animation_to_target(target.global_position)
	await tween_moving.finished
	# TODO: start cuve level (with transition)

func _on_microscope_selected(target: Node2D):
	# wait animation end
	play_move_alexia_animation_to_target(target.global_position)
	await tween_moving.finished
	$World/YSort/Alexia.stop_idle_animation()
	await $World/YSort/Alexia.tween_idle.finished
	# set lab state
	LabState.alexia_state = "microscope"
	# transition animation
	var tween_transition: Tween = create_tween()
	tween_transition.tween_property($World, "modulate", Color.BLACK, 1.0).set_trans(Tween.TRANS_QUAD)
	tween_transition.parallel().tween_property($Gui/TextStack, "modulate", Color.BLACK, 1.0).set_trans(Tween.TRANS_QUAD)
	await tween_transition.finished
	# change scene
	get_tree().change_scene_to_file("res://louis/microscope_game/microscope.tscn")

# TODO: after !
func _on_equipement_selected(equipement: Node2D):
	play_move_alexia_animation_to_target(equipement.global_position)
	await tween_moving.finished
	$World/YSort/Alexia.equip(equipement)
