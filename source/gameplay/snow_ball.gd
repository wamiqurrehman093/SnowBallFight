extends Area3D

var speed: float = 20

@onready var life_timer: Timer = $life_timer

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)
	life_timer.timeout.connect(queue_free)

func setup(snow_ball_data: Dictionary) -> void:
	name = snow_ball_data["id"]
	global_position = snow_ball_data["position"]
	global_rotation = snow_ball_data["rotation"]

func _physics_process(delta: float) -> void:
	position += transform.basis * Vector3(0, 0, -speed) * delta

func _on_area_entered(area: Area3D) -> void:
	if area.is_in_group("network_player_character_hit_box"):
		_on_network_player_character_hit(area.get_owner())

func _on_network_player_character_hit(network_player_character: Node3D) -> void:
	server.get_node("lobbies/games")._on_snow_ball_hit_network_player(
		int(str(network_player_character.name)), str(name)
	)
	_on_hit()

func _on_body_entered(body: Node3D) -> void:
	if body is StaticBody3D:
		_on_hit_static_body()

func _on_hit_static_body() -> void:
	server.get_node("lobbies/games")._on_snow_ball_hit_static_body(name)
	_on_hit()

func _on_hit() -> void:
	queue_free()
