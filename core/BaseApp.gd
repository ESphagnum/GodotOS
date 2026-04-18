extends Control
class_name BaseApp

# Каждое приложение сможет обращаться к своему окну-родителю
var window_wrapper: Control 

func _ready():
	# Ищем обертку в родителях
	var parent = get_parent()
	while parent:
		if parent.has_method("set_active"): # Признак нашего WindowWrapper
			window_wrapper = parent
			break
		parent = parent.get_parent()

# Стандартные функции, которые можно переопределить
func on_focus():
	pass

func on_close_request():
	return true # Разрешить закрытие
