extends BaseApp

@onready var item_list = $VBoxContainer/ProcessList

func _ready():
	super._ready() # Инициализируем связь с окном через BaseApp
	
	# Подключаемся к глобальным сигналам, чтобы список обновлялся сам
	Signals.window_opened.connect(func(_w, _t): refresh_list())
	Signals.window_closed.connect(func(_w): refresh_list())
	Signals.window_focused.connect(func(_w): refresh_list())
	
	refresh_list()

func refresh_list():
	item_list.clear()
	
	for window in WindowManager.windows:
		if is_instance_valid(window) and window.config:
			var app_name = window.config.app_name
			
			# Добавляем пометку, если окно активно
			if WindowManager.active_window == window:
				app_name += " (Активно)"
			
			var idx = item_list.add_item(app_name, window.config.icon)
			item_list.set_item_metadata(idx, window)

# Функция для кнопки "Перейти" (Focus)
func _on_focus_button_pressed() -> void:
	var selected = item_list.get_selected_items()
	if selected.size() > 0:
		var window_to_focus = item_list.get_item_metadata(selected[0])
		if is_instance_valid(window_to_focus):
			window_to_focus.visible = true # На случай, если было скрыто
			WindowManager.set_active_window(window_to_focus)


func _on_end_task_button_pressed() -> void:
	var selected = item_list.get_selected_items()
	if selected.size() > 0:
		var window_to_kill = item_list.get_item_metadata(selected[0])
		if is_instance_valid(window_to_kill):
			# Вызываем закрытие через метод обертки
			window_to_kill._on_close_button_pressed()
