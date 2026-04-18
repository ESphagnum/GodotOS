extends BaseApp

@onready var item_list = $VBoxContainer/ItemList
var current_path = ""

func _ready():
	super._ready()
	render_dir(VirtualFS.fs_root)

func render_dir(dir_data):
	item_list.clear()
	var content = dir_data.get("content", {})
	
	for name in content.keys():
		var item = content[name]
		var icon = get_icon_for_type(item.type)
		var idx = item_list.add_item(name, icon)
		item_list.set_item_metadata(idx, item)

func _on_item_list_item_activated(index):
	var item = item_list.get_item_metadata(index)
	var item_name = item_list.get_item_text(index)
	
	if item.type == "dir":
		render_dir(item)
	else:
		# Если это файл — просим систему его открыть!
		open_file(item)

func open_file(file_data):
	if file_data.extension == "txt":
		# Запускаем Блокнот и передаем ему данные
		var notepad_config = load("res://apps/core/Notepad/Notepad.tres")
		Signals.request_app_launch.emit(notepad_config)
		# Ждем кадра и шлем данные файла (или через глобальный сигнал)
		Signals.request_file_open.emit(file_data)

func get_icon_for_type(type):
	return load("res://assets/icons/folder.png") if type == "dir" else load("res://assets/icons/file.png")
