extends Node2D

# parameters

const WALKING_ANGLE: float = 0.0625*0.25
const WALKING_DURATION: float = 0.25

const EQUIPING_DURATION: float = 0.25

const IDLE_SCALE_OFFSET: float = 4e-3
const IDLE_SCALE_DURATION: float = 0.5

# output
var is_idling: bool = false
var is_walking: bool = false
var is_carrying: bool = false

var equipement: Node2D = null

# internal
var tween_idle: Tween = null
var tween_walking: Tween = null
var tween_equiping: Tween = null

# TODO: THERE MIGHT BE A PROBLEM WHEN EQUIP IS CALLED WHEN ALREADY EQUIPING

## grabbing
func carry_ice_core():
	is_carrying = true
	# ui
	$Anchor/Sprite2DIdleNormal/Sprite2DIdleNormal.hide()
	$Anchor/Sprite2DIdleNormal/Sprite2DIdleCarrying.show()
	$Anchor/Sprite2DIdleNormal/IceCore.show()
	$Anchor/Sprite2DIdleNormal/Hands.show()
	$Anchor/Sprite2DWalkingNormal/Sprite2DWalkingNormal.hide()
	$Anchor/Sprite2DWalkingNormal/Sprite2DWalkingCarrying.show()
	$Anchor/Sprite2DWalkingNormal/IceCore.show()
	$Anchor/Sprite2DWalkingNormal/Hands.show()

func drop_ice_core(target: Node2D, instantiate: bool = true):
	# drop
	if instantiate:
		var new_ice_core: Node2D = load("res://remi/lab/equipements/ice_core_" + str(4 - LabState.remaining_ice_cores_in_the_fridge) + ".tscn").instantiate()
		new_ice_core.position = Vector2.ZERO
		target.add_child(new_ice_core)
		new_ice_core.selected.connect(get_tree().current_scene._on_ice_core_selected.bind(new_ice_core))
	# ui
	$Anchor/Sprite2DIdleNormal/Sprite2DIdleNormal.show()
	$Anchor/Sprite2DIdleNormal/Sprite2DIdleCarrying.hide()
	$Anchor/Sprite2DIdleNormal/IceCore.hide()
	$Anchor/Sprite2DIdleNormal/Hands.hide()
	$Anchor/Sprite2DWalkingNormal/Sprite2DWalkingNormal.show()
	$Anchor/Sprite2DWalkingNormal/Sprite2DWalkingCarrying.hide()
	$Anchor/Sprite2DWalkingNormal/IceCore.hide()
	$Anchor/Sprite2DWalkingNormal/Hands.hide()
	# bool
	is_carrying = false

## walking
func play_walking_animation():
	_stop_animation()
	is_walking = true
	$Anchor/Sprite2DIdleNormal.hide()
	$Anchor/Sprite2DWalkingNormal.show()
	_play_walking_animation.call_deferred()

func _play_walking_animation():
	tween_walking = create_tween()
	tween_walking.tween_property($Anchor, "rotation", -WALKING_ANGLE*TAU, WALKING_DURATION).set_trans(Tween.TRANS_QUAD)
	tween_walking.tween_callback($AudioStreamPlayer2DStep.play)
	tween_walking.tween_property($Anchor, "rotation", WALKING_ANGLE*TAU, WALKING_DURATION).set_trans(Tween.TRANS_QUAD)
	tween_walking.tween_callback($AudioStreamPlayer2DStep.play)
	tween_walking.tween_callback(_play_walking_animation)
	await tween_walking.finished

func stop_walking_animation():
	$Anchor/Sprite2DIdleNormal.show()
	$Anchor/Sprite2DWalkingNormal.hide()
	# stop tween
	if tween_walking:
		tween_walking.stop()
	# tween
	is_walking = false
	tween_walking = create_tween()
	tween_walking.tween_property($Anchor, "rotation", 0.0, 0.5*WALKING_DURATION).set_trans(Tween.TRANS_QUAD)
	await tween_walking.finished

## idle
func play_idle_animation():
	_stop_animation()
	is_idling = true
	_play_idle_animation.call_deferred()

func _play_idle_animation():
	tween_walking = create_tween()
	tween_walking.tween_property($Anchor, "scale:y", 1.0 + IDLE_SCALE_OFFSET, IDLE_SCALE_DURATION).set_trans(Tween.TRANS_QUAD)
	tween_walking.tween_property($Anchor, "scale:y", 1.0 - IDLE_SCALE_OFFSET, IDLE_SCALE_DURATION).set_trans(Tween.TRANS_QUAD)
	tween_walking.tween_callback(_play_idle_animation)

func stop_idle_animation():
	if is_idling:
		# stop tween
		if tween_idle:
			tween_idle.stop()
		# tween
	is_idling = false
	tween_idle = create_tween()
	tween_idle.tween_property($Anchor, "scale:y", 1.0, 0.5*IDLE_SCALE_DURATION).set_trans(Tween.TRANS_QUAD)
	await tween_idle.finished

func _stop_animation():
	if is_idling:
		stop_idle_animation()
	if is_walking:
		stop_walking_animation()

# internal

func _ready():
	play_idle_animation()
