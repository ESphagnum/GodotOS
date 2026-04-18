extends PanelContainer

var target_y : float
var is_initialized = false

@onready var app_grid = $VBoxContainer/ScrollContainer/AppGrid
const APP_ICON_SCENE = preload("res://scenes/Taskbar/AppIcon_Start.tscn")

# Список ресурсов всех программ, которые должны быть в "Пуске"
@export var apps_to_pin: Array[AppConfig]

func _ready():
	Signals.start_menu_toggled.connect(_on_signals_start_toggled)
	visible = false
	render_pinned_apps()

func render_pinned_apps():
    # Очищаем сетку перед наполнением
	for child in app_grid.get_children():
		child.queue_free()
    
	for config in apps_to_pin:
		var icon = APP_ICON_SCENE.instantiate()
		app_grid.add_child(icon)
        
        # Настраиваем иконку (пути должны совпадать с твоей сценой AppIcon_Start)
		icon.get_node("TextureRect").texture = config.icon
		icon.get_node("Label").text = config.app_name
        
        # Запуск приложения
		icon.get_node("Button").pressed.connect(func():
			Signals.request_app_launch.emit(config)
			Signals.start_menu_toggled.emit(false) # Закрываем меню после клика
		)

func _initialize_position():
	# Вычисляем позицию: Низ экрана - Высота меню - Высота таскбара (примерно 50)
	var screen_height = get_viewport_rect().size.y
	target_y = screen_height - size.y - 50 
	
	position = Vector2(0, target_y)
	pivot_offset = Vector2(0, size.y)
	is_initialized = true

func _on_signals_start_toggled(is_active):
	if not is_initialized:
		_initialize_position()
	
	if is_active: _show()
	else: _hide()

func _show():
	visible = true
	# Выводим на самый передний план, чтобы окна не перекрывали
	z_index = 100 
	
	var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	
	# Сброс позиции перед анимацией (на всякий случай)
	position.y = target_y + 40
	modulate.a = 0
	scale = Vector2(0.95, 0.95)
	
	tween.tween_property(self, "position:y", target_y, 0.3)
	tween.tween_property(self, "modulate:a", 1.0, 0.2)
	tween.tween_property(self, "scale", Vector2.ONE, 0.3)


func _hide():
	var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	
	tween.tween_property(self, "position:y", target_y + 40, 0.2)
	tween.tween_property(self, "modulate:a", 0.0, 0.2)
	tween.tween_property(self, "scale", Vector2(0.95, 0.95), 0.2)
	
	tween.chain().tween_callback(func(): visible = false)


func _on_shutdown_pressed() -> void:
	var desktop = get_tree().root.find_child("Desktop", true, false)
	
	if desktop:
		var tween = create_tween()
		# Плавно уводим Desktop в черный цвет и прозрачность
		tween.tween_property(desktop, "modulate", Color(0, 0, 0, 0), 0.8)\
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		
		# После завершения анимации закрываем программу
		tween.tween_callback(get_tree().quit)
	else:
		# Если Desktop не найден (например, при тестах), просто выходим
		get_tree().quit()