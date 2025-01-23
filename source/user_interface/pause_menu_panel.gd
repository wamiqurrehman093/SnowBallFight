extends Panel

@onready var resume_button: Button = $margin_container/menu/resume
@onready var main_menu_button: Button = $margin_container/menu/main_menu
@onready var quit_game: Button = $margin_container/menu/quit_game

func _ready() -> void:
	resume_button.pressed.connect(toggle_hide)
	main_menu_button.pressed.connect(_on_main_menu_button_pressed)
	quit_game.pressed.connect(get_tree().quit)
	toggle_hide()

func _on_main_menu_button_pressed() -> void:
	server.get_node("lobbies").leave_lobby()
	get_tree().change_scene_to_file("res://source/user_interface/main.tscn")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_on_cancel_pressed()

func _on_cancel_pressed() -> void:
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		toggle_show()
	else:
		toggle_hide()

func toggle_show() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	show()

func toggle_hide() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	hide()
