extends Control

signal focused()
signal unfocused()
signal closed()
signal minimized()
signal maximized()

@export var app_name: String = "New App"
@onready var title_label = $NinePatchRect/VBoxContainer/Header_Panel/HBoxContainer/RichTextLabel
@onready var header = $NinePatchRect/VBoxContainer/Header_Panel

var dragging = false
var offset = Vector2()
var is_fullscreen = false
var old_position = Vector2()
var old_size = Vector2()

func _ready():
	title_label.text = app_name
	WindowManager.register_window(self)
	WindowManager.set_active_window(self)

# Логика перемещения и фокуса
func _on_header_panel_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			dragging = event.pressed
			offset = get_global_mouse_position() - global_position
			if dragging:
				WindowManager.set_active_window(self)

	if event is InputEventMouseMotion and dragging and not is_fullscreen:
		global_position = get_global_mouse_position() - offset

# Визуальное выделение активного окна
func set_active(active: bool):
	if active:
		focused.emit()
		modulate = Color(1, 1, 1) # Яркое
	else:
		unfocused.emit()
		modulate = Color(0.8, 0.8, 0.8) # Чуть тусклое

# Кнопки управления
func _on_close_button_pressed():
	# 1. Отключаем ввод, чтобы окно не мешало кликать по другим во время исчезновения
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# 2. Создаем анимацию исчезновения (прозрачность + небольшое уменьшение)
	var tween = create_tween().set_parallel(true)
	
	# Плавное таяние (транспарант)
	tween.tween_property(self, "modulate:a", 0.0, 0.3)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	# Опционально: легкое уменьшение масштаба для красоты
	tween.tween_property(self, "scale", Vector2(0.9, 0.9), 0.3)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		
	# 3. После анимации удаляем окно
	tween.chain().tween_callback(queue_free)
	
	# Генерируем сигнал закрытия сразу (чтобы таскбар начал убирать кнопку)
	closed.emit()


func _on_fullscreen_button_pressed():
	if not is_fullscreen:
		maximized.emit()
		old_position = global_position
		old_size = size
		anchor_right = 1
		anchor_bottom = 1
		offset_right = 0
		offset_bottom = 0 # Внимание: для этого Taskbar должен быть в другом слое
		is_fullscreen = true
	else:
		minimized.emit()
		anchor_right = 0
		anchor_bottom = 0
		global_position = old_position
		size = old_size
		is_fullscreen = false

func _on_aside_button_pressed():
	visible = false # Просто скрываем, Taskbar поможет вернуть

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			# Как только нажат любой клик в области окна
			WindowManager.set_active_window(self)
			# Если хочешь, чтобы окно сразу выходило вперед:
			move_to_front.call_deferred()
