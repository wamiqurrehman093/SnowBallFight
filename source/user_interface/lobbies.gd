extends Control

@onready var back_button: Button = $margin_container/content/back
@onready var create_button: Button = $margin_container/content/header/create
@onready var creation_menu: Control = $overlay/lobby_creation_menu
@onready var lobbies_container: VBoxContainer = $margin_container/content/lobbies_scrollbox/lobbies_container

func _ready() -> void:
	back_button.pressed.connect(_on_back_button_pressed)
	create_button.pressed.connect(_on_create_button_pressed)
	server.get_node("lobbies").lobbies_info_fetched.connect(_on_lobbies_info_fetched)
	server.get_node("lobbies").fetch_lobbies_info()
	server.get_node("lobbies").lobby_joined.connect(_on_successfully_joined_lobby)
	server.get_node("lobbies").failed_to_join_lobby.connect(_on_failed_to_join_lobby)
	server.get_node("lobbies/games").successfully_joined_game.connect(_on_successfully_joined_game)

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://source/user_interface/main.tscn")

func _on_create_button_pressed() -> void:
	creation_menu.show()

func _on_lobbies_info_fetched(lobbies_info: Dictionary) -> void:
	lobbies_container.update_lobbies(lobbies_info)
	print(lobbies_info)

func _on_successfully_joined_lobby(lobby_info: Dictionary) -> void:
	print("Successfully joined lobby:")
	print(lobby_info)

func _on_failed_to_join_lobby(lobby_info: Dictionary, reason: String) -> void:
	print("Failed to join lobby:")
	print(lobby_info)
	print("because of " + reason)

func _on_successfully_joined_game() -> void:
	get_tree().change_scene_to_file("res://source/gameplay/game.tscn")
