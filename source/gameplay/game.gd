extends Node3D

var kill_info_panel_scene = preload("res://source/user_interface/kill_info_panel.tscn")
var time_left_to_respawn: int = 7

@onready var health_value_label: Label = $hud/user_interface/health_panel/margin_container/health/value
@onready var death_panel: Panel = $hud/user_interface/death_panel
@onready var death_panel_label: Label = $hud/user_interface/death_panel/margin_container/content_box/label
@onready var kill_feed: VBoxContainer = $hud/user_interface/kill_feed
@onready var respawn_timer: Timer = $respawn_timer

func _ready() -> void:
	server.get_node("lobbies/games").local_player_hurt.connect(_on_local_player_hurt)
	server.get_node("lobbies/games").local_player_died.connect(_on_local_player_death)
	server.get_node("lobbies/games").network_player_died.connect(_on_network_player_death)
	server.get_node("lobbies/games").local_player_respawned.connect(_on_local_player_respawned)
	death_panel.hide()
	respawn_timer.timeout.connect(_on_respawn_timer_timeout)

func _on_local_player_hurt(new_health: int) -> void:
	health_value_label.text = str(new_health)

func _on_local_player_death(shooter_id: int) -> void:
	death_panel.show()
	var info: Dictionary = {
		"killer": shooter_id,
		"killed": multiplayer.get_unique_id()
	}
	add_player_kill_info(info)
	time_left_to_respawn = 7
	respawn_timer.start()

func _on_network_player_death(killed_id: int, killer_id: int) -> void:
	var info: Dictionary = {
		"killer": killer_id,
		"killed": killed_id
	}
	add_player_kill_info(info)

func add_player_kill_info(info: Dictionary) -> void:
	if kill_feed.get_child_count() >= 3:
		kill_feed.get_child(0).queue_free()
	var kill_info_box = kill_info_panel_scene.instantiate()
	kill_feed.add_child(kill_info_box)
	kill_info_box.set_info(info)

func _on_respawn_timer_timeout() -> void:
	time_left_to_respawn -= 1
	death_panel_label.text = "Respawning in " + str(time_left_to_respawn) + " seconds..."
	if time_left_to_respawn <= 0:
		request_respawn()

func request_respawn() -> void:
	server.get_node("lobbies/games").request_respawn()
	death_panel.hide()
	time_left_to_respawn = 7
	respawn_timer.stop()

func _on_local_player_respawned() -> void:
	health_value_label.text = "100"
