extends Control

signal app_button_created(app_name)
signal app_button_clicked(window)

@onready var app_list = $Panel/HBoxContainer/HBoxContainer
const TASK_BUTTON_SCENE = preload("res://scenes/Taskbar/TaskButton.tscn")

@onready var start_menu = get_node("../StartMenu")

func _ready():
	# Подключаем к глобальному сигналу
	Signals.window_opened.connect(add_application)
	# И не забудь про закрытие
	Signals.window_closed.connect(_on_window_closed) 
	# Если окно было зарегистрировано ДО загрузки таскбара (редко, но бывает)
	_refresh_buttons()

func _on_window_focused(window):
	# Подсвечиваем кнопку активного окна
	for btn in app_list.get_children():
		if btn.linked_window == window:
			btn.flat = false # Нажатый вид
		else:
			btn.flat = true  # Плоский вид для неактивных
	app_button_clicked.emit(window)

func _on_window_closed(window):
	for btn in app_list.get_children():
		if btn.linked_window == window:
			# Анимация ухода вниз
			var tween = create_tween().set_parallel(true)
			tween.tween_property(btn, "position:y", btn.position.y + 50, 0.3)\
				.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
			tween.tween_property(btn, "modulate:a", 0.0, 0.2)
			
			# Ждем завершения анимации и удаляем кнопку
			tween.chain().tween_callback(btn.queue_free)


# Функция, которую вызовет WindowManager или Desktop при запуске нового приложения
func add_application(window, title: String):
	var new_btn = TASK_BUTTON_SCENE.instantiate()
	new_btn.text = title
	new_btn.linked_window = window
	
	app_list.add_child(new_btn)
	
	# Ждем один кадр, чтобы контейнер успел расставить элементы
	await get_tree().process_frame
	
	# Теперь анимируем
	var final_y = 0 # Конечная позиция внутри контейнера всегда 0
	var start_y = 40 # Смещение вниз (за пределы таскбара)
	
	new_btn.position.y = start_y
	new_btn.modulate.a = 0
	
	var tween = create_tween().set_parallel(true)
	# Возвращаем в позицию 0 (ровно в контейнер)
	tween.tween_property(new_btn, "position:y", final_y, 0.4)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(new_btn, "modulate:a", 1.0, 0.3)

	# -----------------------

	new_btn.pressed.connect(func():
		window.visible = true
		WindowManager.set_active_window(window)
	)

	app_button_created.emit(title)

func _refresh_buttons():
	for child in app_list.get_children(): child.queue_free()
	for w in WindowManager.windows:
		add_application(w, w.app_name)





func _on_start_menu_button_toggled(toggled_on: bool) -> void:
	Signals.start_menu_toggled.emit(toggled_on)
