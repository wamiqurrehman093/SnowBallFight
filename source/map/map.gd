extends Node3D

var player_character_scene = preload("res://source/gameplay/player_character.tscn")
var network_player_character_scene = preload("res://source/gameplay/network_player_character.tscn")
var snow_ball_scene = preload("res://source/gameplay/snow_ball.tscn")
var network_snow_ball_scene = preload("res://source/gameplay/network_snow_ball.tscn")

@onready var local_player: Node3D = $players/local_player
@onready var network_players: Node3D = $players/network_players
@onready var player_spawns: Node3D = $player_spawns
@onready var local_snow_balls: Node3D = $snow_balls/local_snow_balls
@onready var network_snow_balls: Node3D = $snow_balls/network_snow_balls

func _ready() -> void:
	server.get_node("lobbies/games").new_player_joined_game.connect(_on_new_player_joined_game)
	server.get_node("lobbies/games").network_player_character_data_updated.connect(_on_network_player_character_data_updated)
	server.get_node("lobbies/games").network_player_shot.connect(_on_network_player_shot)
	server.get_node("lobbies/games").network_snow_ball_hit.connect(_on_network_snow_ball_hit)
	server.get_node("lobbies/games").network_player_died.connect(_on_network_player_death)
	server.get_node("lobbies/games").local_player_respawned.connect(_on_local_player_respawned)
	server.get_node("lobbies/games").network_player_respawned.connect(_on_network_player_respawned)
	server.get_node("lobbies/games").player_left_game.connect(_on_network_player_left_game)
	for player_id in server.get_node("lobbies/games").current_game_info["players"]:
		if player_id == multiplayer.get_unique_id():
			spawn_local_player()
			continue
		spawn_network_player(player_id)

func spawn_local_player() -> void:
	var player_character = player_character_scene.instantiate()
	local_player.add_child(player_character)
	var player_id: int = multiplayer.get_unique_id()
	var spawn_index: int = server.get_node("lobbies/games").get_player_spawn_position(player_id)
	var spawn_position: Vector3 = player_spawns.get_child(spawn_index).global_position
	player_character.global_position = spawn_position
	player_character.shot.connect(_on_local_player_shot)

func spawn_network_player(network_player_id: int) -> void:
	var network_player_character = network_player_character_scene.instantiate()
	network_players.add_child(network_player_character)
	var spawn_index: int = server.get_node("lobbies/games").get_player_spawn_position(network_player_id)
	var spawn_position: Vector3 = player_spawns.get_child(spawn_index).global_position
	network_player_character.setup(network_player_id, spawn_position)

func _on_new_player_joined_game(new_player_id: int) -> void:
	print("New player " + str(new_player_id) + " has just joined the game.")
	spawn_network_player(new_player_id)

func _on_network_player_character_data_updated(network_player_id: int, network_player_character_data: Dictionary) -> void:
	if not is_inside_tree():
		return
	network_players.get_node(str(network_player_id)).global_position = network_player_character_data["position"]
	network_players.get_node(str(network_player_id)).global_rotation = network_player_character_data["rotation"]
	network_players.get_node(str(network_player_id)).set_chest_rotation(network_player_character_data["chest_rotation"])
	network_players.get_node(str(network_player_id)).play_animation(network_player_character_data["animation"])

func _on_local_player_shot(snow_ball_data: Dictionary) -> void:
	var snow_ball = snow_ball_scene.instantiate()
	local_snow_balls.add_child(snow_ball)
	snow_ball.setup(snow_ball_data)
	server.get_node("lobbies/games").local_player_shot(snow_ball_data)

func _on_network_player_shot(shooter_id: int, snow_ball_data: Dictionary) -> void:
	network_players.get_node(str(shooter_id)).shoot()
	var snow_ball = network_snow_ball_scene.instantiate()
	network_snow_balls.add_child(snow_ball)
	snow_ball.setup(snow_ball_data)
	snow_ball.set_shooter_id(shooter_id)

func _on_network_snow_ball_hit(snow_ball_id: String) -> void:
	if network_snow_balls.has_node(snow_ball_id):
		network_snow_balls.get_node(snow_ball_id)._on_hit()

func _on_network_player_death(killed_player_id: int, killing_player_id: int) -> void:
	if network_players.has_node(str(killed_player_id)):
		network_players.get_node(str(killed_player_id))._on_death()

func _on_local_player_respawned() -> void:
	var player_character = local_player.get_child(0)
	var player_id: int = multiplayer.get_unique_id()
	var spawn_index: int = server.get_node("lobbies/games").get_player_spawn_position(player_id)
	var spawn_position: Vector3 = player_spawns.get_child(spawn_index).global_position
	player_character.global_position = spawn_position
	player_character._on_respawn()

func _on_network_player_respawned(network_player_id: int) -> void:
	if not network_players.has_node(str(network_player_id)):
		return
	var network_player_character = network_players.get_node(str(network_player_id))
	var spawn_index: int = server.get_node("lobbies/games").get_player_spawn_position(network_player_id)
	var spawn_position: Vector3 = player_spawns.get_child(spawn_index).global_position
	network_player_character.global_position = spawn_position
	network_player_character._on_respawn()

func _on_network_player_left_game(network_player_id: int, network_player_name: String) -> void:
	network_players.get_node(str(network_player_id)).queue_free()
	for network_snow_ball in network_snow_balls.get_children():
		if int(str(network_snow_ball.name.split("_")[0])) == network_player_id:
			network_snow_ball.queue_free()
