extends Node

# Сигналы системы
signal start_menu_toggled(is_active: bool) # Для кнопки "Пуск"
signal request_app_launch(config: AppConfig)


# Сигналы окон (для связи окон с Таскбаром)
signal window_opened(window_ref: Control, title: String)
signal window_closed(window_ref)
signal window_focused(window_ref)

# Сигналы системных событий
signal notification_sent(message: String, type: String) # Для всплывающих уведомлений
