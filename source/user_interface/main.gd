extends Control

@onready var player_name_textbox: LineEdit = $menu/player_name/line_edit
@onready var play_button: Button = $menu/play
@onready var quit_button: Button = $menu/quit
@onready var connection_status: Label = $menu/connection_status

func _ready() -> void:
	connect_signals()
	check_server_connection()
	if server.get_node("players").local_player_name:
		player_name_textbox.text = server.get_node("players").local_player_name

func connect_signals() -> void:
	multiplayer.connected_to_server.connect(check_server_connection)
	multiplayer.connection_failed.connect(check_server_connection)
	multiplayer.server_disconnected.connect(check_server_connection)
	play_button.pressed.connect(_on_play_button_pressed)
	quit_button.pressed.connect(get_tree().quit)

func check_server_connection() -> void:
	if server.is_server_connected:
		play_button.disabled = false
		connection_status.text = "Connected to the server!"

func _on_play_button_pressed() -> void:
	var player_name: String = player_name_textbox.text
	if player_name.is_empty():
		return
	server.get_node("players").save_player_name(player_name_textbox.text)
	get_tree().change_scene_to_file("res://source/user_interface/lobbies.tscn")
