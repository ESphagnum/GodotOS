extends Node

signal window_focused(window)
signal window_closed(window)

var windows = []
var active_window = null

func _ready():
	# Теперь эта строка будет работать, так как функция объявлена ниже
	Signals.request_app_launch.connect(launch_app)

func launch_app(config: AppConfig):
	var window_scene = load("res://scenes/WindowWrapper.tscn")
	var window_instance = window_scene.instantiate()
	
	# 1. Передаем настройки
	window_instance.setup_window(config)
	
	# 2. РЕГИСТРИРУЕМ ВРУЧНУЮ (теперь config точно не Nil)
	register_window(window_instance)
	
	var windows_layer = get_tree().root.find_child("WindowsLayer", true, false)
	if windows_layer:
		# 3. Добавляем в дерево
		windows_layer.add_child(window_instance)
		
		# Загружаем контент проги по пути из конфига
		var app_res = load(config.scene_path)
		if app_res:
			var app_node = app_res.instantiate()
			var content_node = window_instance.find_child("Content", true, false)
			if content_node:
				content_node.add_child(app_node)
	else:
		printerr("Критическая ошибка: WindowsLayer не найден!")

# Остальные твои функции без изменений...
func register_window(window):
	# Если у окна нет конфига — игнорируем его или выводим ошибку, но не падаем
	if window.config == null:
		push_warning("Попытка зарегистрировать окно без конфига: ", window.name)
		return
	if not windows.has(window):
		windows.append(window)
		window.closed.connect(_on_window_closed_started.bind(window))
		
		# ПРОВЕРКА: Уходит ли сигнал?
		if window.config and window.config.show_in_taskbar:
			print("Отправляю сигнал window_opened для: ", window.config.app_name)
			Signals.window_opened.emit(window, window.config.app_name)
		else:
			print("Окно не должно быть в таскбаре: ", window.config.app_name)


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
