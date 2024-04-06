extends VBoxContainer

# parameters
const WRITE_SPEED: float = 16.0 # character per second
const FADE_DURATION: float = 1.0

# internal
var tween_write

# interface
func push_line(text_line: String):
	var new_label: Label = preload("res://remi/text_stack/label_stack.tscn").instantiate()
	# input
	new_label.text = text_line
	# add to tree
	add_child(new_label)
	# animation
	var tween: Tween = create_tween()
	tween.tween_property(new_label, "visible_characters", text_line.length(), text_line.length()/float(WRITE_SPEED)).set_trans(Tween.TRANS_LINEAR)
	await tween.finished
	tween = create_tween()
	tween.tween_property(new_label, "modulate:a", 0.0, FADE_DURATION).set_trans(Tween.TRANS_QUAD)
	tween.tween_callback(new_label.queue_free)
