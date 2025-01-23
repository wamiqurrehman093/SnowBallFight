extends VBoxContainer

@onready var messages: VBoxContainer = $messages_panel/margin_container/messages_scrollbox/messages
@onready var new_massage_textbox: LineEdit = $new_message_box/new_message
@onready var submit_button: Button = $new_message_box/submit

func _ready() -> void:
	hide()
	server.get_node("lobbies/games").player_left_game.connect(_on_player_left_game)
	server.get_node("lobbies/games").new_player_joined_game.connect(_on_new_player_joined_game)
	server.get_node("lobbies/games").new_message_received.connect(add_message)
	new_massage_textbox.text_submitted.connect(_on_new_message_submitted)
	submit_button.pressed.connect(_on_new_message_submitted)

func _on_player_left_game(player_id: int, player_name: String) -> void:
	add_message(player_name + " has left the game.")

func _on_new_player_joined_game(player_id: int) -> void:
	var player_name = server.get_node("lobbies/games").get_player_name(player_id)
	add_message(player_name + " has joined the game.")

func add_message(message_text: String) -> void:
	var message: Label = Label.new()
	messages.add_child(message)
	message.custom_minimum_size = Vector2(344, 23)
	message.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	message.text = message_text
	message.focus_mode = Control.FOCUS_NONE

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_messages"):
		if visible:
			hide()
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			show()
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			new_massage_textbox.grab_focus()

func _on_new_message_submitted(new_message: String = "") -> void:
	if new_message == "":
		new_message = new_massage_textbox.text
	var player_id: int = multiplayer.get_unique_id()
	var player_name: String = server.get_node("lobbies/games").get_player_name(player_id)
	new_message = player_name + ": " + new_message
	add_message(new_message)
	server.get_node("lobbies/games").send_message(new_message)
	new_massage_textbox.text = ""
	new_massage_textbox.grab_focus()
