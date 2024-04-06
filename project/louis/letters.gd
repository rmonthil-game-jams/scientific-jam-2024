extends Node2D

@export var target_scene : PackedScene
@onready var letters = $"."
@onready var sprite_2d = $Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready():
	# fade in animation
	letters.modulate = Color.BLACK
	var tween: Tween = create_tween()
	tween.tween_property(letters, "modulate", Color.WHITE, 0.5).set_trans(Tween.TRANS_QUAD)
	tween.parallel().tween_property(sprite_2d, "position:y", 324, 0.5).set_ease(Tween.EASE_OUT)

func _input(event):
	if event is InputEventMouseButton:
		get_tree().change_scene_to_packed(target_scene)
