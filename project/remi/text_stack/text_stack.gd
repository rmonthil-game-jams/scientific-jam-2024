extends CanvasLayer

# parameters
const WRITE_SPEED: float = 18.0 # character per second
const PAUSE_DURATION: float = 3.0
const FADE_DURATION: float = 1.0

# interface
func push_line(text_line: String):
	var new_label: ColorRect = preload("res://remi/text_stack/label_stack.tscn").instantiate()
	# input
	new_label.get_node("Label").text = text_line
	# add to tree
	#new_label.modulate.a = 0.0
	$VBoxContainer.add_child(new_label)
	# animation
	var tween: Tween = create_tween()
	#tween.tween_property(new_label, "modulate:a", 1.0, FADE_DURATION).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(new_label.get_node("Label"), "visible_characters", text_line.length(), text_line.length()/float(WRITE_SPEED)).set_trans(Tween.TRANS_LINEAR)
	await tween.finished
	tween = create_tween()
	tween.tween_interval(PAUSE_DURATION)
	tween.tween_property(new_label, "modulate:a", 0.0, FADE_DURATION).set_trans(Tween.TRANS_QUAD)
	tween.tween_callback(new_label.queue_free)
