extends Node2D

signal selected

func _on_texture_button_pressed():
	selected.emit()
