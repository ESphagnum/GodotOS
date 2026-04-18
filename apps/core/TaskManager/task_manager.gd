extends BaseApp

@onready var process_list = $VBoxContainer/ProcessList
@export var app_config : AppConfig 

func _ready():
	refresh_list()
	# Обновляем список каждые 2 секунды, чтобы видеть изменения
	var timer = get_tree().create_timer(2.0)
	timer.timeout.connect(_on_timer_timeout)

func _on_timer_timeout():
	refresh_list()
	get_tree().create_timer(2.0).timeout.connect(_on_timer_timeout)

func refresh_list():
	process_list.clear()
	# Берем массив окон напрямую из нашего синглтона
	for window in WindowManager.windows:
		if is_instance_valid(window) and window.config:
			var icon = window.config.icon
			var idx = process_list.add_item(window.config.app_name, icon)
			# Сохраняем ссылку на объект окна в метаданные строки
			process_list.set_item_metadata(idx, window)

func _on_end_task_button_pressed():
	var selected = process_list.get_selected_items()
	if selected.size() > 0:
		var window_to_kill = process_list.get_item_metadata(selected[0])
		if is_instance_valid(window_to_kill):
			# Вызываем стандартную функцию закрытия окна
			window_to_kill._on_close_button_pressed()
			refresh_list()
