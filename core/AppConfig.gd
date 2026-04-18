extends Resource
class_name AppConfig

@export var app_name: String = "New App"
@export var icon: Texture2D
@export_file("*.tscn") var scene_path: String 
@export var show_in_taskbar: bool = true
@export var show_in_tray: bool = false
@export var start_minimized: bool = false
@export var default_position: Vector2 = Vector2(100, 100)
@export var default_size: Vector2 = Vector2(400, 300)
