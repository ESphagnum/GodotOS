extends Control
class_name BaseApp

var window_wrapper: Control  # Ссылка на "рамку" окна
var config: AppConfig        # Ссылка на настройки этого приложения

func _ready():
	# Автоматически находим обертку, в которую нас вставили
	var parent = get_parent()
	while parent:
		if parent.has_method("setup_window"): # Признак нашего WindowWrapper
			window_wrapper = parent
			config = parent.config # Забираем конфиг из обертки
			break
		parent = parent.get_parent()

# Стандартные функции, которые можно переопределить
func on_focus():
	pass

func on_close_request():
	return true # Разрешить закрытие
