extends Control
class_name BaseApp

var window_wrapper: Control # Ссылка на ту самую "рамку"
var config: AppConfig       # Ссылка на настройки

func _ready():
    # Ищем WindowWrapper среди родителей
    var p = get_parent()
    while p != null:
        if p.has_method("setup_window"): # Признак того, что это наш WindowWrapper
            window_wrapper = p
            config = p.config # Подтягиваем конфиг из рамки в приложение
            break
        p = p.get_parent()
    
    if window_wrapper:
        print("Приложение ", config.app_name, " успешно связано с окном")

func set_window_title(new_title: String):
    if window_wrapper:
        window_wrapper.title_label.text = new_title