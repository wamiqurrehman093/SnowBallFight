extends Node2D

var current_game_info: Dictionary = {}

signal a_new_game_created
signal successfully_joined_game
signal new_player_joined_game
signal network_player_character_data_updated
signal network_player_shot
signal network_player_died
signal local_player_died
signal local_player_hurt
signal local_player_successful_shot
signal network_snow_ball_hit
signal local_player_respawned
signal network_player_respawned
signal scoreboard_updated
signal player_left_game
signal new_message_received

@rpc("authority", "call_local", "reliable")
func create_a_new_game(game_info: Dictionary) -> void:
	current_game_info = game_info
	a_new_game_created.emit()

func get_player_spawn_position(player_id: int) -> int:
	return current_game_info["players"][player_id]["spawn_position"]

@rpc("authority", "call_local", "reliable")
func _on_new_player_joined_game(new_player_id: int, game_info: Dictionary) -> void:
	current_game_info = game_info
	new_player_joined_game.emit(new_player_id)

@rpc("authority", "call_local", "reliable")
func join_game(game_info: Dictionary) -> void:
	current_game_info = game_info
	successfully_joined_game.emit()

@rpc("any_peer", "call_remote", "unreliable")
func update_player_character_data(player_character_data: Dictionary) -> void:
	rpc_id(1, "update_player_character_data", current_game_info["id"], player_character_data)

@rpc("authority", "call_local", "unreliable")
func update_network_player_character_data(network_player_id: int, network_player_character_data: Dictionary) -> void:
	current_game_info["players"][network_player_id]["position"] = network_player_character_data["position"]
	current_game_info["players"][network_player_id]["rotation"] = network_player_character_data["rotation"]
	current_game_info["players"][network_player_id]["animation"] = network_player_character_data["animation"]
	network_player_character_data_updated.emit(network_player_id, network_player_character_data)

@rpc("any_peer", "call_remote", "reliable")
func local_player_shot(snow_ball_data: Dictionary) -> void:
	rpc_id(1, "local_player_shot", current_game_info["id"], snow_ball_data)

@rpc("authority", "call_local", "reliable")
func _on_network_player_shot(shooter_id, snow_ball_data) -> void:
	network_player_shot.emit(shooter_id, snow_ball_data)

@rpc("any_peer", "call_remote", "reliable")
func _on_snow_ball_hit_network_player(network_player_id: int, snow_ball_id: String) -> void:
	rpc_id(1, "_on_snow_ball_hit_network_player", current_game_info["id"], network_player_id, snow_ball_id)

@rpc("authority", "call_local", "reliable")
func _on_network_player_death(network_player_id: int, shooter_id: int) -> void:
	network_player_died.emit(network_player_id, shooter_id)

@rpc("authority", "call_local", "reliable")
func _on_player_death(shooter_id: int) -> void:
	local_player_hurt.emit(0)
	local_player_died.emit(shooter_id)

@rpc("authority", "call_local", "reliable")
func _on_player_hurt(health: int) -> void:
	local_player_hurt.emit(health)

@rpc("authority", "call_local", "reliable")
func _on_snow_ball_hit(snow_ball_id: String) -> void:
	network_snow_ball_hit.emit(snow_ball_id)

@rpc("any_peer", "call_remote", "reliable")
func _on_snow_ball_hit_static_body(snow_ball_id: String) -> void:
	rpc_id(1, "_on_snow_ball_hit_static_body", current_game_info["id"], snow_ball_id)

@rpc("any_peer", "call_remote", "reliable")
func request_respawn() -> void:
	rpc_id(1, "request_respawn", current_game_info["id"])

@rpc("authority", "call_local", "reliable")
func respawn_local_player(player_info: Dictionary) -> void:
	current_game_info["players"][player_info["id"]] = player_info
	local_player_respawned.emit()

@rpc("authority", "call_local", "reliable")
func respawn_network_player(network_player_info: Dictionary) -> void:
	current_game_info["players"][network_player_info["id"]] = network_player_info
	network_player_respawned.emit(network_player_info["id"])

@rpc("authority", "call_local", "reliable")
func update_scoreboard(players_info) -> void:
	current_game_info["players"] = players_info
	scoreboard_updated.emit()

func get_player_name(player_id: int) -> String:
	return current_game_info["players"][player_id]["name"]

@rpc("authority", "call_local", "reliable")
func remove_player_from_game(player_id: int) -> void:
	var player_name = current_game_info["players"][player_id]["name"]
	current_game_info["players"].erase(player_id)
	player_left_game.emit(player_id, player_name)

@rpc("any_peer", "call_remote", "reliable")
func send_message(new_message: String) -> void:
	rpc_id(1, "send_message", current_game_info["id"], new_message)

@rpc("authority", "call_local", "reliable")
func _on_new_message(new_message: String) -> void:
	new_message_received.emit(new_message)
