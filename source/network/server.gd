extends Node2D

const IP_ADDRESS = "127.0.0.1"
const PORT = 3030

var is_server_connected: bool = false

func _ready() -> void:
	create_client()
	connect_signals()

func connect_signals() -> void:
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

func create_client() -> void:
	var peer = ENetMultiplayerPeer.new()
	var created_successfully = peer.create_client(IP_ADDRESS, PORT)
	if created_successfully == OK:
		print("Created client successfully.")
	else:
		print("Couldn't create the client.")
	multiplayer.multiplayer_peer = peer

func _on_connected_to_server() -> void:
	print("Successfully connected to the server.")
	is_server_connected = true

func _on_connection_failed() -> void:
	print("Couldn't connect to the server.")
	is_server_connected = false

func _on_server_disconnected() -> void:
	print("Server disconnected.")
	is_server_connected = false
