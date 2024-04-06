extends Node2D

signal selected

func _on_texture_button_pressed():
	selected.emit()

func open():
	$FrigoCarotte1.show()
	$FrigoCarotte2.show()
	$FrigoCarotte3.show()
	$FrigoCarotte4.show()
	$FrigoCarotte5.show()

func take():
	if $FrigoCarotte1.visible:
		$FrigoCarotte1.hide()
	elif $FrigoCarotte2.visible:
		$FrigoCarotte2.hide()
	elif $FrigoCarotte3.visible:
		$FrigoCarotte3.hide()
	elif $FrigoCarotte4.visible:
		$FrigoCarotte4.hide()
	elif $FrigoCarotte5.visible:
		$FrigoCarotte5.hide()
