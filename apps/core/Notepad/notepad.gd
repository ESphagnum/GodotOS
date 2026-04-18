extends BaseApp

@onready var text_edit = $VBoxContainer/TextEdit

func _ready():
	super._ready() # Инициализируем связь с WindowWrapper
	
	# Если мы открыли Блокнот через Файловую Систему
	Signals.request_file_open.connect(_on_file_received)
	
	# Настройка заголовка по умолчанию
	if window_wrapper:
		window_wrapper.title_label.text = config.app_name + " — Без имени"

func _on_file_received(file_data: Dictionary):
	# Заполняем текст данными из виртуального файла
	text_edit.text = file_data.get("data", "")
	# Обновляем заголовок окна именем файла
	if window_wrapper:
		window_wrapper.title_label.text = config.app_name + " — " + file_data.get("name", "document.txt")

func _on_text_edit_text_changed():
	# Добавляем "звездочку" при изменении
	if window_wrapper and not window_wrapper.title_label.text.ends_with("*"):
		window_wrapper.title_label.text += "*"
