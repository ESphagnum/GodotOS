extends Control

var dragging = false
var offset = Vector2()

func _on_header_panel_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			dragging = event.pressed
			offset = get_global_mouse_position() - global_position
			
			if dragging:
				move_to_front()

	if event is InputEventMouseMotion and dragging:
		global_position = get_global_mouse_position() - offset


func _on_close_button_pressed() -> void:
	queue_free()
