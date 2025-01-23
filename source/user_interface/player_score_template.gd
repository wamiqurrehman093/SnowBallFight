extends HBoxContainer

func setup(data: Dictionary) -> void:
	$number.text = str(get_index() + 1)
	$name.text = str(data["name"])
	$kills.text = str(data["kills"])
	$deaths.text = str(data["deaths"])
	$score.text = str(data["score"])

func update_field_data(field_name: String, data: String) -> void:
	get_node(field_name).text = data

func update(data: Dictionary) -> void:
	for field_name in data:
		update_field_data(str(field_name), str(data[field_name]))
