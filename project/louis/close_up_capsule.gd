extends Control

@onready var close_up_capsule = $"."
@onready var camera = $Camera2D

# Called when the node enters the scene tree for the first time.
func _ready():
	# fade in animation
	close_up_capsule.modulate = Color.BLACK
	var tween: Tween = create_tween()
	tween.tween_property(close_up_capsule, "modulate", Color.WHITE, 1.0).set_trans(Tween.TRANS_QUAD)
	tween.parallel().tween_property(camera, "zoom", 1.1 * Vector2(1,1), 7)



func _on_timer_timeout():
	var tween_transition = create_tween()
	tween_transition.tween_property(close_up_capsule, "modulate", Color.BLACK, 1).set_trans(Tween.TRANS_QUAD)
	await tween_transition.finished
	get_tree().change_scene_to_file("res://louis/inside_capsule.tscn")
