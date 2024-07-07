extends Button

func get_item_scene_path():
	if get_children().size() > 0:
		return get_child(0).scene_file_path
