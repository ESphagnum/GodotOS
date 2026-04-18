extends Control

# Путь до сетки. Учитывая твою структуру: 
# Линия поиска -> MarginContainer -> VBoxContainer -> ScrollContainer -> AppGrid
@onready var app_grid = $"../../ScrollContainer/AppGrid"

func _on_line_edit_text_changed(new_text: String) -> void:
	var search_term = new_text.to_lower()
	
	# Перебираем все иконки в сетке
	for icon in app_grid.get_children():
		# Ищем Label внутри иконки (AppIcon_Start)
		var label = icon.find_child("Label", true, false)
		
		if label:
			var app_name = label.text.to_lower()
			# Если имя проги содержит текст из поиска или поиск пустой — показываем
			icon.visible = search_term == "" or search_term in app_name
