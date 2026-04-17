extends Node

signal window_focused(window)
signal window_closed(window)

var windows = []
var active_window = null

# Регистрация нового окна в системе
func register_window(window):
	if not windows.has(window):
		windows.append(window)
		# Соединяем с сигналом closed для начала анимаций
		window.closed.connect(_on_window_closed_started.bind(window))
		
		var taskbar = get_tree().root.find_child("Taskbar", true, false)
		if taskbar and taskbar.has_method("add_application"):
			taskbar.add_application(window, window.app_name)

# Новая функция: срабатывает СРАЗУ при нажатии на крестик
func _on_window_closed_started(window):
	windows.erase(window)
	window_closed.emit(window) # Этот сигнал поймает Таскбар и запустит анимацию кнопки
	if active_window == window:
		active_window = null

func set_active_window(window):
	if not window: return
	
	active_window = window
	
	# Принудительно выводим в конец списка отрисовки
	if window.get_parent():
		window.get_parent().move_child.call_deferred(window, -1)
	
	window_focused.emit(window)
	
	# Визуальное переключение
	for w in windows:
		if is_instance_valid(w) and w.has_method("set_active"):
			w.set_active(w == window)