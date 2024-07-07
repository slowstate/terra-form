extends Node2D

@onready var map = $CanvasLayer/Map

var hovered_item

var selected_item:
	get:
		return selected_item
	set(new_item):
		selected_item = new_item
		create_placement_preview()
		
var preview_instance

# Called when the node enters the scene tree for the first time.
func _ready():
	load_game()
	#select_map("forest_shrine")

func _physics_process(delta):
	if preview_instance != null:
		var mouse_position = get_global_mouse_position()
		var rounded_position = Vector2(int(round(mouse_position.x)), int(round(mouse_position.y))) - preview_instance.base_offset #sprite size offset
		preview_instance.global_position = rounded_position
		preview_instance.z_index = rounded_position.x + rounded_position.y

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

#func select_map(selected_map):
	#match selected_map:
		#"forest_shrine":
			#map.setup(20, 16, -get_viewport().size.x*2/9, -get_viewport().size.y*1/5)
			#map.setInvisible(false)

func _input(event):
	if event.is_action_pressed("select"):
		place_item()
		save_game()
	if event.is_action("remove"):
		if hovered_item != null:
			hovered_item.remove()
			save_game()

func _on_catalogue_ui_item_selected(item):
	selected_item = item

func create_placement_preview():
	if selected_item != null:
		var preview_scene = load(selected_item.get_item_scene_path())
		preview_instance = preview_scene.instantiate()
		map.add_child(preview_instance)
		preview_instance.previewing = true

func place_item():
	if preview_instance != null && preview_instance.can_place:
		preview_instance.previewing = false
		preview_instance.hovering.connect(_on_hovering)
		preview_instance.add_to_group("Persist")
		preview_instance = null
		selected_item = null
	
func _on_hovering(item, isHovering):
	if isHovering:
		hovered_item = item
	if item == hovered_item && !isHovering:
		hovered_item = null
	
func save_game():
	if DirAccess.dir_exists_absolute("user://savegame.backup") && !DirAccess.dir_exists_absolute("user://savegame.save"):
		printerr("Save game backup already exists but save game does not, please check your backup or it will be overwritten")
		return

	if DirAccess.dir_exists_absolute("user://savegame.backup") && DirAccess.dir_exists_absolute("user://savegame.save"):
		DirAccess.remove_absolute("user://savegame.backup")
	
	# Back up current save game
	DirAccess.rename_absolute("user://savegame.save", "user://savegame.backup")
	var save_game = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	var save_nodes = get_tree().get_nodes_in_group("Persist")
	for node in save_nodes:
		# Check the node is an instanced scene so it can be instanced again during load.
		if node.scene_file_path.is_empty():
			print("persistent node '%s' is not an instanced scene, skipped" % node.name)
			continue

		# Check the node has a save function.
		if !node.has_method("save"):
			print("persistent node '%s' is missing a save() function, skipped" % node.name)
			continue

		# Call the node's save function.
		var node_data = node.call("save")

		# JSON provides a static method to serialized JSON string.
		var json_string = JSON.stringify(node_data)

		# Store the save dictionary as a new line in the save file.
		save_game.store_line(json_string)

func load_game():
	if not FileAccess.file_exists("user://savegame.save"):
		return # Error! We don't have a save to load.
	
	# We need to revert the game state so we're not cloning objects
	# during loading. This will vary wildly depending on the needs of a
	# project, so take care with this step.
	# For our example, we will accomplish this by deleting saveable objects.
	var save_nodes = get_tree().get_nodes_in_group("Persist")
	for i in save_nodes:
		i.queue_free()
	
	# Load the file line by line and process that dictionary to restore
	# the object it represents.
	var save_game = FileAccess.open("user://savegame.save", FileAccess.READ)
	while save_game.get_position() < save_game.get_length():
		var json_string = save_game.get_line()

		# Creates the helper class to interact with JSON
		var json = JSON.new()

		# Check if there is any error while parsing the JSON string, skip in case of failure
		var parse_result = json.parse(json_string)
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue

		# Get the data from the JSON object
		var node_data = json.get_data()

		# Firstly, we need to create the object and add it to the tree and set its position.
		var new_object = load(node_data["filename"]).instantiate()
		get_node(node_data["parent"]).add_child(new_object)
		new_object.position = Vector2(node_data["pos_x"], node_data["pos_y"])
		new_object.add_to_group("Persist")
		new_object.hovering.connect(_on_hovering)

		# Now we set the remaining variables.
		for i in node_data.keys():
			if i == "filename" or i == "parent" or i == "pos_x" or i == "pos_y":
				continue
			new_object.set(i, node_data[i])

