extends Node

# Корневая папка нашей ОС внутри пользовательских данных Godot
const ROOT_PATH = "user://vfs_root"

func _ready():
	# Создаем корневую директорию, если её еще нет
	if not DirAccess.dir_exists_absolute(ROOT_PATH):
		DirAccess.make_dir_absolute(ROOT_PATH)
		_create_default_files()

func _create_default_files():
	# Создаем стартовую структуру для примера
	create_directory("Documents")
	create_file("Documents/hello.txt", "Привет! Это реальный файл на диске.")
	create_file("readme.txt", "Добро пожаловать. Загляни в %appdata%")

func get_full_path(rel_path: String) -> String:
	if rel_path == "" or rel_path == "/":
		return ROOT_PATH
	return ROOT_PATH.path_join(rel_path)

# Получить список файлов и папок по указанному пути
func get_directory_contents(relative_path: String = ""):
	var full_path = get_full_path(relative_path)
	var contents = []
	var dir = DirAccess.open(full_path)
	
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name != "." and file_name != "..":
				var is_dir = dir.current_is_dir()
				contents.append({
					"name": file_name,
					"type": "dir" if is_dir else "file",
					"extension": file_name.get_extension(),
					# Используем path_join для корректных слэшей
					"path": relative_path.path_join(file_name) 
				})
			file_name = dir.get_next()
	return contents

func create_directory(rel_path: String):
	DirAccess.make_dir_recursive_absolute(ROOT_PATH + "/" + rel_path)

func create_file(rel_path: String, content: String):
	var file = FileAccess.open(ROOT_PATH + "/" + rel_path, FileAccess.WRITE)
	if file:
		file.store_string(content)
		file.close()

func read_file(rel_path: String) -> String:
	var path = get_full_path(rel_path)
	var file = FileAccess.open(path, FileAccess.READ)
	if file:
		var content = file.get_as_text()
		file.close()
		return content
	return "Ошибка: файл не найден"