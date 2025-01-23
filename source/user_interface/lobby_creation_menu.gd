extends Control

@onready var cancel_button: Button = $panel/margin_container/content/actions/cancel
@onready var create_button: Button = $panel/margin_container/content/actions/create
@onready var lobby_name_textbox: LineEdit = $panel/margin_container/content/lobby_info/name/line_edit
@onready var lobby_password_textbox: LineEdit = $panel/margin_container/content/lobby_info/password/line_edit
@onready var max_players_numberbox: SpinBox = $panel/margin_container/content/lobby_info/max_players/spin_box

func _ready() -> void:
	hide()
	cancel_button.pressed.connect(hide)
	create_button.pressed.connect(_on_create_button_pressed)
	server.get_node("lobbies").lobby_created.connect(_on_lobby_created)
	server.get_node("lobbies/games").a_new_game_created.connect(_on_a_new_game_created)

func _on_create_button_pressed() -> void:
	var lobby_name: String = lobby_name_textbox.text
	if lobby_name.is_empty():
		return
	var lobby_password: String = lobby_password_textbox.text
	var max_players: int = max_players_numberbox.value
	var lobby_info: Dictionary = {
		"name": lobby_name,
		"password": lobby_password,
		"max_players": max_players
	}
	server.get_node("lobbies").create_lobby(lobby_info)

func _on_lobby_created(lobby_info: Dictionary) -> void:
	print("Lobby created:")
	print(lobby_info)
	clear_inputs()
	hide()

func clear_inputs() -> void:
	lobby_name_textbox.text = "Some Lobby"
	lobby_password_textbox.text = ""
	max_players_numberbox.value = max_players_numberbox.min_value

func _on_a_new_game_created() -> void:
	get_tree().change_scene_to_file("res://source/gameplay/game.tscn")
