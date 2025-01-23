extends Panel

@onready var killer_name_label: Label = $hbox/killer_name
@onready var killed_name_label: Label = $hbox/killed_name
@onready var timer: Timer = $timer

func _ready() -> void:
	timer.timeout.connect(_on_timer_timeout)
	timer.start()

func set_info(info: Dictionary) -> void:
	killer_name_label.text = server.get_node("lobbies/games").get_player_name(info["killer"])
	killed_name_label.text = server.get_node("lobbies/games").get_player_name(info["killed"])
	if $hbox.size.x > custom_minimum_size.x:
		custom_minimum_size.x = $hbox.size.x

func _on_timer_timeout() -> void:
	queue_free()
