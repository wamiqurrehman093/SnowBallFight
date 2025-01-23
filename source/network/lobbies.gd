extends Node2D

var lobbies_info: Dictionary = {}
var current_lobby_info: Dictionary = {}

signal lobby_created
signal lobbies_info_fetched
signal lobby_joined
signal failed_to_join_lobby

@rpc("any_peer", "call_remote", "reliable")
func create_lobby(lobby_info: Dictionary) -> void:
	rpc_id(1, "create_lobby", lobby_info)

@rpc("authority", "call_local", "reliable")
func _on_lobby_created(lobby_info: Dictionary) -> void:
	current_lobby_info = lobby_info
	lobby_created.emit(lobbies_info)

@rpc("any_peer", "call_remote", "reliable")
func fetch_lobbies_info() -> void:
	rpc_id(1, "fetch_lobbies_info")

@rpc("authority", "call_local", "reliable")
func _on_lobbies_info_fetched(lobbies_info: Dictionary) -> void:
	lobbies_info_fetched.emit(lobbies_info)

@rpc("authority", "call_local", "reliable")
func refresh_lobbies_info(lobbies_info: Dictionary) -> void:
	self.lobbies_info = lobbies_info
	lobbies_info_fetched.emit(lobbies_info)

@rpc("any_peer", "call_remote", "reliable")
func join_lobby(lobby_login_info: Dictionary) -> void:
	rpc_id(1, "join_lobby", lobby_login_info)

@rpc("authority", "call_local", "reliable")
func _on_successfully_lobby_joined(lobby_info: Dictionary) -> void:
	current_lobby_info = lobby_info
	lobby_joined.emit(lobby_info)

@rpc("authority", "call_local", "reliable")
func _on_lobby_joining_failed(lobby_info: Dictionary, reason: String) -> void:
	failed_to_join_lobby.emit(lobby_info, reason)

@rpc("authority", "call_local", "reliable")
func remove_player_from_lobby(lobby_id: int, player_id: int) -> void:
	if lobbies_info.has(lobby_id):
		lobbies_info[lobby_id]["players"].erase(player_id)
	current_lobby_info["players"].erase(player_id)

@rpc("any_peer", "call_remote", "reliable")
func leave_lobby() -> void:
	rpc_id(1, "leave_lobby", current_lobby_info["id"])
