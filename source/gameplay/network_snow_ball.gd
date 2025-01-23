extends Area3D

var shooter_id: int
var speed: float = 20

@onready var life_timer: Timer = $life_timer

func _ready() -> void:
	life_timer.timeout.connect(queue_free)

func set_shooter_id(id: int) -> void:
	shooter_id = id

func get_shooter_id() -> int:
	return shooter_id

func setup(snow_ball_data: Dictionary) -> void:
	name = snow_ball_data["id"]
	global_position = snow_ball_data["position"]
	global_position.y += 0.1
	global_rotation = snow_ball_data["rotation"]

func _physics_process(delta: float) -> void:
	position += transform.basis * Vector3(0, 0, -speed) * delta

func _on_hit() -> void:
	queue_free()
