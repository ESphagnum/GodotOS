extends BaseApp

signal focused()
signal unfocused()
signal closed()
signal minimized()
signal maximized()

# Обязательное объявление переменной для хранения имени
var app_name: String = "New App" 
var config: AppConfig 

@onready var title_label = $NinePatchRect/VBoxContainer/Header_Panel/HBoxContainer/RichTextLabel
@onready var header = $NinePatchRect/VBoxContainer/Header_Panel

var dragging = false
var offset = Vector2()
var is_fullscreen = false
var old_position = Vector2()
var old_size = Vector2()

func setup_window(app_config: AppConfig):
	config = app_config
	self.app_name = config.app_name
	
	# Установка размеров и позиции из конфига
	custom_minimum_size = config.default_size
	size = config.default_size
	position = config.default_position
	
	# Если прога должна быть скрыта при старте
	if config.start_minimized:
		visible = false

func _ready():
	title_label.text = app_name
	
	# Регистрируем в системе
	WindowManager.register_window(self)
	
	# Делаем активным, только если оно не свернуто
	if visible:
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
	# Если в конфиге сказано "не закрывать, а сворачивать в трей"
	if config and config.show_in_tray and not Input.is_key_pressed(KEY_SHIFT):
		visible = false
		minimized.emit()
		return

	# Стандартная анимация закрытия
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.tween_property(self, "scale", Vector2(0.9, 0.9), 0.3)
	tween.chain().tween_callback(queue_free)
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
