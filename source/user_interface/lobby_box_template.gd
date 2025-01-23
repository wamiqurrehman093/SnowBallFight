extends HBoxContainer

var password: String = ""
var lobby_login_info: Dictionary = { "id": -1, "password": "" }

@onready var name_label: Label = $name
@onready var max_players_label: Label = $max_players
@onready var players_joined_label: Label = $players_joined
@onready var requires_password_label: Label = $requires_password
@onready var join_button: Button = $join

func _ready() -> void:
	join_button.pressed.connect(_on_join_button_pressed)

func update_data(lobby_info: Dictionary) -> void:
	lobby_login_info["id"] = lobby_info["id"]
	name_label.text = lobby_info["name"]
	max_players_label.text = str(lobby_info["max_players"])
	players_joined_label.text = str(lobby_info["players"].size())
	password = lobby_info["password"]
	if password.is_empty():
		requires_password_label.text = "No"
	else:
		requires_password_label.text = "Yes"

func _on_join_button_pressed() -> void:
	if password.is_empty():
		lobby_login_info["password"] = ""
		server.get_node("lobbies").join_lobby(lobby_login_info)
	else:
		pass
