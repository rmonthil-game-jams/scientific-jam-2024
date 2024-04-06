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
var is_equiping: bool = false
var is_equiped: bool = false

var equipement: Node2D = null

# internal
var tween_idle: Tween = null
var tween_walking: Tween = null
var tween_equiping: Tween = null

# TODO: THERE MIGHT BE A PROBLEM WHEN EQUIP IS CALLED WHEN ALREADY EQUIPING

## grabbing
func equip(new_equipement: Node2D):
	var new_equipement_global_position: Vector2 = new_equipement.global_position
	# stop tween
	is_equiping = true
	tween_walking = create_tween()
	if is_equiped:
		tween_walking.parallel().tween_property(equipement, "global_position", new_equipement_global_position, EQUIPING_DURATION).set_trans(Tween.TRANS_QUAD)
	tween_walking.tween_property(new_equipement, "global_position", $Anchor/EquipementHolder.global_position, EQUIPING_DURATION).set_trans(Tween.TRANS_QUAD)
	await tween_walking.finished
	# logic
	if is_equiped:
		$Anchor/EquipementHolde.remove_child(equipement)
		equipement.global_position = new_equipement_global_position
		new_equipement.get_parent().add_child(equipement)
		equipement.get_node("TextureButton").disabled = false
	new_equipement.get_parent().remove_child(new_equipement)
	new_equipement.position = Vector2.ZERO
	$Anchor/EquipementHolder.add_child(new_equipement)
	new_equipement.get_node("TextureButton").disabled = true
	# state update
	is_equiped = true

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
	tween_walking.tween_property($Anchor, "rotation", WALKING_ANGLE*TAU, WALKING_DURATION).set_trans(Tween.TRANS_QUAD)
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
