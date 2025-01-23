extends Node3D

var shoot_animation_duration: float = 0.2

@onready var animation_player: AnimationPlayer = $snow_man/AnimationPlayer
@onready var chest_bone: BoneAttachment3D = $snow_man/SnowManArmature/Skeleton3D/chest_bone
@onready var animation_player_2: AnimationPlayer = $animation_player
@onready var right_shoulder_bone: BoneAttachment3D = $snow_man/SnowManArmature/Skeleton3D/right_shoulder_bone
@onready var left_shoulder_bone: BoneAttachment3D = $snow_man/SnowManArmature/Skeleton3D/left_shoulder_bone
@onready var hitbox_shape: CollisionShape3D = $hit_box/shape
@onready var player_name: Label3D = $player_name

func setup(player_id: int, spawn_position: Vector3) -> void:
	player_name.text = server.get_node("lobbies/games").get_player_name(player_id)
	name = str(player_id)
	global_position = spawn_position

func play_animation(animation_name: String) -> void:
	animation_player.play(animation_name)

func set_chest_rotation(chest_rotation: float) -> void:
	chest_bone.rotation.x = -chest_rotation

func shoot() -> void:
	animation_player_2.play("shoot")
	tween_shoulder(right_shoulder_bone)
	tween_shoulder(left_shoulder_bone)

func tween_shoulder(shoulder: BoneAttachment3D) -> void:
	var tween: Tween = create_tween()
	tween.finished.connect(_on_tween_finished.bind(tween, shoulder))
	var shoulder_rotation_degrees: Vector3 = shoulder.rotation_degrees
	shoulder.override_pose = true
	shoulder_rotation_degrees.x += 5
	tween.tween_property(
		shoulder, "rotation_degrees", shoulder_rotation_degrees, shoot_animation_duration / 2
	)
	shoulder_rotation_degrees.x -= 5
	tween.tween_property(
		shoulder, "rotation_degrees", shoulder_rotation_degrees, shoot_animation_duration / 2
	)

func _on_tween_finished(tween: Tween, shoulder: BoneAttachment3D) -> void:
	shoulder.override_pose = false
	tween.kill()

func _on_death() -> void:
	hide()
	hitbox_shape.disabled = true

func _on_respawn() -> void:
	show()
	hitbox_shape.disabled = false
