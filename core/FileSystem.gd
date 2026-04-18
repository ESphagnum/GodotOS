extends Node

# Структура: "имя": {"type": "dir/file", "content": "...", "icon": "..."}
var fs_root = {
	"Documents": {
		"type": "dir",
		"content": {
			"hello.txt": {"type": "file", "extension": "txt", "data": "Привет из GodotOS!"},
			"secret.txt": {"type": "file", "extension": "txt", "data": "Пароль: 12345"}
		}
	},
	"Pictures": {"type": "dir", "content": {}},
	"readme.txt": {"type": "file", "extension": "txt", "data": "Это твоя новая ОС."}
}

# Функция для получения данных по пути (например, "Documents/hello.txt")
func get_file_by_path(path: String):
	var parts = path.split("/")
	var current = fs_root
	for part in parts:
		if current.has("content") and current.content.has(part):
			current = current.content[part]
		elif current.has(part):
			current = current[part]
		else:
			return null
	return current
