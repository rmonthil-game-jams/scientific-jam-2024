extends Control

@onready var inside_capsule = $"."
@onready var camera = $Camera2D
@onready var texture_rect_3 = $TextureRect3
@onready var texture_rect_5 = $TextureRect5

# Called when the node enters the scene tree for the first time.
func _ready():
	# fade in animation
	inside_capsule.modulate = Color.BLACK
	var tween: Tween = create_tween()
	tween.tween_property(inside_capsule, "modulate", Color.WHITE, 1.5).set_trans(Tween.TRANS_QUAD)
	var tween_cam = create_tween()
	tween_cam.tween_property(camera, "zoom", 1.1 * Vector2(1,1), 12)



func _on_timer_next_timeout():
	var tween_transition = create_tween()
	tween_transition.tween_property(inside_capsule, "modulate", Color.BLACK, 0.2).set_trans(Tween.TRANS_QUAD)
	await tween_transition.finished
	get_tree().change_scene_to_file("res://louis/capsule_wall.tscn")

func _on_timer_blur_timeout():
	var tween = create_tween()
	tween.tween_property(texture_rect_3, "modulate", Color(1,1,1,0), 0.5).set_trans(Tween.TRANS_QUAD)
	tween.set_parallel().tween_property(texture_rect_5, "modulate", Color(1,1,1,0), 0.5)
