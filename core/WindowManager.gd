extends Node

signal window_focused(window)
signal window_closed(window)

var windows = []
var active_window = null

func _ready():
	# Теперь эта строка будет работать, так как функция объявлена ниже
	Signals.request_app_launch.connect(launch_app)

func launch_app(scene_path: String, app_name: String):
	# 1. Загружаем обертку окна
	var window_scene = load("res://scenes/WindowWrapper.tscn")
	var window_instance = window_scene.instantiate()
	
	# 2. Устанавливаем заголовок
	window_instance.app_name = app_name
	
	# 3. Находим, куда добавить окно в Desktop.tscn
	var windows_layer = get_tree().root.find_child("WindowsLayer", true, false)
	if windows_layer:
		windows_layer.add_child(window_instance)
		
		# 4. Загружаем само приложение (контент)
		var app_res = load(scene_path)
		if app_res:
			var app_node = app_res.instantiate()
			# Ищем узел Content внутри WindowWrapper (проверь имя узла в сцене!)
			var content_node = window_instance.find_child("Content", true, false)
			if content_node:
				content_node.add_child(app_node)
	else:
		print("Ошибка: WindowsLayer не найден!")

# Остальные твои функции без изменений...
func register_window(window):
	if not windows.has(window):
		windows.append(window)
		window.closed.connect(_on_window_closed_started.bind(window))

		# Таскбар создаст кнопку только если конфиг это разрешает
		if window.config.show_in_taskbar:
			Signals.window_opened.emit(window, window.app_name)

func _on_window_closed_started(window):
	windows.erase(window)
	window_closed.emit(window)
	if active_window == window:
		active_window = null

func set_active_window(window):
	if not window: return
	active_window = window
	if window.get_parent():
		window.get_parent().move_child.call_deferred(window, -1)
	window_focused.emit(window)
	for w in windows:
		if is_instance_valid(w) and w.has_method("set_active"):
			w.set_active(w == window)
