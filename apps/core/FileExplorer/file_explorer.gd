extends BaseApp

@onready var item_list = $VBoxContainer/ItemList
var current_path = "" # Путь относительно ROOT_PATH

func _ready():
	super._ready()
	render_dir("") # Начинаем с корня

func render_dir(path: String):
	current_path = path
	item_list.clear()
	
	var items = VirtualFS.get_directory_contents(path)
	
	for item in items:
		var icon = get_icon_for_type(item.type)
		var idx = item_list.add_item(item.name, icon)
		# Сохраняем весь объект данных (путь, тип и т.д.) в метаданные
		item_list.set_item_metadata(idx, item)

func _on_item_list_item_activated(index):
	var item = item_list.get_item_metadata(index)
	
	if item.type == "dir":
		render_dir(item.path)
	else:
		# Читаем данные из VirtualFS перед отправкой в Блокнот
		item["data"] = VirtualFS.read_file(item.path)
		open_file(item)

# Добавьте эту функцию и привяжите к кнопке "Назад" в UI
func _on_back_button_pressed():
	if current_path == "" or current_path == "/":
		return
	# Получаем путь на уровень выше
	var parent_path = current_path.get_base_dir()
	if parent_path == ".": parent_path = ""
	render_dir(parent_path)

func open_file(file_data):
	if file_data.extension == "txt":
		# Запускаем Блокнот и передаем ему данные
		var notepad_config = load("res://apps/core/Notepad/Notepad.tres")
		Signals.request_app_launch.emit(notepad_config)
		# Ждем кадра и шлем данные файла (или через глобальный сигнал)
		Signals.request_file_open.emit(file_data)

func get_icon_for_type(type):
	return load("res://assets/icons/folder.svg") if type == "dir" else load("res://assets/icons/file.svg")
