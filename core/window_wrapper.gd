extends Control

var dragging = false
var offset = Vector2()

func _on_header_panel_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			dragging = event.pressed
			offset = get_global_mouse_position() - get_parent().global_position
			
			if dragging:
				get_parent().move_to_front()

	if event is InputEventMouseMotion and dragging:
		get_parent().global_position = get_global_mouse_position() - offset
