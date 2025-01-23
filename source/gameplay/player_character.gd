extends CharacterBody3D

var mouse_sensitivity: float = 0.003
var vertical_limit: float = 45.0
var walk_speed: float = 7.0
var run_speed: float = 14.0
var speed: float = walk_speed
var jump_velocity: float = 7.0
var animation: String = "idle"
var snow_balls_count: int = 0
var is_dead: bool = false

@onready var head: Node3D = $head
@onready var gravity: float = ProjectSettings.get("physics/3d/default_gravity")
@onready var animation_player: AnimationPlayer = $animation_player
@onready var snow_ball_spawn: Marker3D = $head/snow_gun/snow_ball_spawn
@onready var shape: CollisionShape3D = $shape

signal shot

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	server.get_node("lobbies/games").local_player_died.connect(_on_death)

func _physics_process(delta: float) -> void:
	if is_dead:
		return
	var input: Vector2 = Vector2.ZERO
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		input = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	if input == Vector2.ZERO:
		animation = "idle"
	else:
		animation = "walk"
	var direction: Vector3 = (transform.basis * Vector3(input.x, 0, input.y)).normalized()
	if is_on_floor():
		if Input.is_action_just_pressed("jump"):
			velocity.y = jump_velocity
	else:
		velocity.y += -gravity * delta
	if Input.is_action_pressed("run"):
		speed = run_speed
	else:
		speed = walk_speed
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed
	move_and_slide()
	var player_character_data: Dictionary = {
		"position": global_position,
		"rotation": global_rotation,
		"chest_rotation": head.rotation.x,
		"animation": animation
	}
	server.get_node("lobbies/games").update_player_character_data(player_character_data)

func _input(event: InputEvent) -> void:
	if is_dead or Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
		return
	if event.is_action_pressed("shoot"):
		_on_shoot_pressed()
	if event is InputEventMouseMotion:
		_on_mouse_moved(event)

func _on_mouse_moved(event: InputEventMouseMotion) -> void:
	rotation.y += -event.relative.x * mouse_sensitivity
	head.rotation.x += -event.relative.y * mouse_sensitivity
	head.rotation_degrees.x = clamp(head.rotation_degrees.x, -vertical_limit, vertical_limit)

func _on_shoot_pressed() -> void:
	if animation_player.is_playing():
		return
	animation_player.play("shoot")
	var snow_ball_rotation: Vector3 = Vector3.ZERO
	snow_ball_rotation.x = head.rotation.x
	snow_ball_rotation.y = rotation.y
	snow_balls_count += 1
	var snow_ball_data: Dictionary = {
		"id": get_snow_ball_id(),
		"position": snow_ball_spawn.global_position,
		"rotation": snow_ball_rotation
	}
	shot.emit(snow_ball_data)

func get_snow_ball_id() -> String:
	return str(multiplayer.get_unique_id()) + "_" + str(snow_balls_count)

func _on_death(killer_id: int) -> void:
	is_dead = true
	hide()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_respawn() -> void:
	is_dead = false
	show()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
