extends Control

@onready var capsule_wall = $"."
@onready var camera = $Camera2D

# Called when the node enters the scene tree for the first time.
func _ready():
	# fade in animation
	capsule_wall.modulate = Color.BLACK
	var tween: Tween = create_tween()
	tween.tween_property(capsule_wall, "modulate", Color.WHITE, 0.2).set_trans(Tween.TRANS_QUAD)



func _on_timer_timeout():
	var tween_transition = create_tween()
	tween_transition.tween_property(capsule_wall, "modulate", Color.BLACK, 1.5).set_trans(Tween.TRANS_QUAD)
	await tween_transition.finished
	get_tree().change_scene_to_file("res://louis/intro_letter.tscn")
