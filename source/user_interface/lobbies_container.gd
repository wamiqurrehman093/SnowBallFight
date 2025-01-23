extends VBoxContainer

var lobby_box_template = preload("res://source/user_interface/lobby_box_template.tscn")

func update_lobbies(lobbies_info: Dictionary) -> void:
	clear_previous_data()
	add_new_data(lobbies_info)

func clear_previous_data() -> void:
	for lobby_box in get_children():
		lobby_box.queue_free()

func add_new_data(lobbies_info: Dictionary) -> void:
	for lobby_id in lobbies_info:
		var lobby_box = lobby_box_template.instantiate()
		add_child(lobby_box)
		lobby_box.update_data(lobbies_info[lobby_id])
