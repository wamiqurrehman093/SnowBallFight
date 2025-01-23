extends Panel

var player_score_template_scene = preload("res://source/user_interface/player_score_template.tscn")

@onready var players_scores: VBoxContainer = $margin_container/content/players_scores_container/players_scores


func _ready() -> void:
	hide()
	server.get_node("lobbies/games").new_player_joined_game.connect(spawn_score_box)
	server.get_node("lobbies/games").scoreboard_updated.connect(update_score_boxes)
	spawn_score_boxes()

func spawn_score_boxes() -> void:
	for player_id in server.get_node("lobbies/games").current_game_info["players"]:
		spawn_score_box(player_id)

func spawn_score_box(player_id) -> void:
		var player_score_box = player_score_template_scene.instantiate()
		players_scores.add_child(player_score_box)
		var player_data: Dictionary = server.get_node("lobbies/games").current_game_info["players"][player_id]
		var data: Dictionary = {
			"name": player_data["name"],
			"kills": player_data["kills"],
			"deaths": player_data["deaths"],
			"score": player_data["score"]
		}
		player_score_box.setup(data)
		player_score_box.name = str(player_id)

func update_score_boxes() -> void:
	for player_id in server.get_node("lobbies/games").current_game_info["players"]:
		update_score_box(player_id)

func update_score_box(player_id: int) -> void:
	var player_score_box = players_scores.get_node(str(player_id))
	var player_data: Dictionary = server.get_node("lobbies/games").current_game_info["players"][player_id]
	var data: Dictionary = {
		"kills": player_data["kills"],
		"deaths": player_data["deaths"],
		"score": player_data["score"]
	}
	player_score_box.update(data)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_score_panel"):
		show()
	if event.is_action_released("toggle_score_panel"):
		hide()
