extends Node

# Структура папок и файлов
var fs_root = {
	"Documents": {
		"type": "dir",
		"content": {
			"hello.txt": {"type": "file", "extension": "txt", "data": "Привет! Это текстовый файл."},
			"note.txt": {"type": "file", "extension": "txt", "data": "Не забыть доделать ОС."}
		}
	},
	"Music": {"type": "dir", "content": {}},
	"readme.txt": {"type": "file", "extension": "txt", "data": "Добро пожаловать в систему!"}
}
