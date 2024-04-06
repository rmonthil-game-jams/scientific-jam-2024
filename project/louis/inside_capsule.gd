extends Control

@onready var inside_capsule = $"."
@onready var shadow = $TextureRect/Shadow
@onready var camera = $Camera2D

# Called when the node enters the scene tree for the first time.
func _ready():
	# fade in animation
	inside_capsule.modulate = Color.BLACK
	var tween: Tween = create_tween()
	tween.tween_property(inside_capsule, "modulate", Color.WHITE, 1.5).set_trans(Tween.TRANS_QUAD)
	tween.parallel().tween_property(shadow, "position:y", shadow.position.y - 10, 1.2)
	var tween_cam = create_tween()
	tween_cam.tween_property(camera, "zoom", 1.1 * Vector2(1,1), 9)
	await tween.finished
	var tween2 = create_tween()
	tween2.tween_property(shadow, "position:y", shadow.position.y + 5, 1.7)

	


func _on_timer_timeout():
	var tween_transition = create_tween()
	tween_transition.tween_property(inside_capsule, "modulate", Color.BLACK, 0.2).set_trans(Tween.TRANS_QUAD)
	await tween_transition.finished
	get_tree().change_scene_to_file("res://louis/capsule_wall.tscn")
