extends Node2D

var local_player_name: String = ""

@rpc("any_peer", "call_remote", "reliable")
func save_player_name(player_name: String) -> void:
	rpc_id(1, "save_player_name", player_name)
	local_player_name = player_name
