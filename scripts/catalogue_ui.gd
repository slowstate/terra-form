extends Control

@onready var grid_container = $GridContainer
@onready var hide_catalogue_ui_button = $HideCatalogueUiButton
@onready var polygon_2d = $Polygon2D
@onready var controls_ui = $ControlsUI

signal item_selected(item)

var catalogue_item_button_scene = preload("res://scenes/catalogue_panel.tscn")
var plant_scenes = [
	preload("res://scenes/catalogue_items/plants/sunflower_a.tscn"),
	preload("res://scenes/catalogue_items/plants/sunflower_b.tscn"),
	preload("res://scenes/catalogue_items/plants/sunflower_c.tscn"),
	preload("res://scenes/catalogue_items/plants/sunflower_d.tscn"),
	preload("res://scenes/catalogue_items/plants/rose_bush_a.tscn"),
	preload("res://scenes/catalogue_items/plants/rose_bush_b.tscn"),
	preload("res://scenes/catalogue_items/plants/rose_bush_c.tscn"),
	preload("res://scenes/catalogue_items/plants/rose_bush_d.tscn"),
	preload("res://scenes/catalogue_items/plants/bamboo_a.tscn"),
	preload("res://scenes/catalogue_items/plants/bamboo_b.tscn"),
	preload("res://scenes/catalogue_items/plants/bamboo_c.tscn"),
	preload("res://scenes/catalogue_items/plants/bamboo_d.tscn"),
	preload("res://scenes/catalogue_items/plants/monstera_a.tscn"),
	preload("res://scenes/catalogue_items/plants/monstera_b.tscn"),
	preload("res://scenes/catalogue_items/plants/monstera_c.tscn"),
	preload("res://scenes/catalogue_items/plants/monstera_d.tscn"),
]

var object_scenes = [
	preload("res://scenes/catalogue_items/objects/rock_a.tscn"),
	preload("res://scenes/catalogue_items/objects/rock_b.tscn"),
	preload("res://scenes/catalogue_items/objects/rock_d.tscn"),
	preload("res://scenes/catalogue_items/objects/rock_c.tscn"),
	preload("res://scenes/catalogue_items/objects/fence_a.tscn"),
	preload("res://scenes/catalogue_items/objects/fence_b.tscn"),
	preload("res://scenes/catalogue_items/objects/fence_c.tscn"),
	preload("res://scenes/catalogue_items/objects/fence_d.tscn"),
	preload("res://scenes/catalogue_items/objects/path_a.tscn"),
	preload("res://scenes/catalogue_items/objects/path_b.tscn"),
	preload("res://scenes/catalogue_items/objects/path_c.tscn"),
	preload("res://scenes/catalogue_items/objects/path_d.tscn"),
	preload("res://scenes/catalogue_items/objects/furniture_a.tscn"),
	preload("res://scenes/catalogue_items/objects/furniture_b.tscn"),
	preload("res://scenes/catalogue_items/objects/furniture_c.tscn"),
	preload("res://scenes/catalogue_items/objects/furniture_d.tscn"),
]

# Called when the node enters the scene tree for the first time.
func _ready():
	createButtons()
	connectButtons()

func createButtons():
	for scene in plant_scenes:
		var new_catalogue_item_button_scene = catalogue_item_button_scene.instantiate()
		var new_button_scene = scene.instantiate()

		new_catalogue_item_button_scene.add_child(new_button_scene)
		grid_container.add_child(new_catalogue_item_button_scene)
		
	for scene in object_scenes:
		var new_catalogue_item_button_scene = catalogue_item_button_scene.instantiate()
		var new_button_scene = scene.instantiate()

		new_catalogue_item_button_scene.add_child(new_button_scene)
		grid_container.add_child(new_catalogue_item_button_scene)

func connectButtons():
	var catalogue_item_buttons = grid_container.get_children()
	for catalogue_item_button in catalogue_item_buttons:
		var callable = Callable(onItemSelected)
		callable = callable.bind(catalogue_item_button)
		catalogue_item_button.pressed.connect(callable)

func onItemSelected(catalogue_item_button):
	item_selected.emit(catalogue_item_button)

func _on_hide_catalogue_ui_button_pressed():
	grid_container.visible = false
	hide_catalogue_ui_button.modulate = Color(0,0,0,0)
	polygon_2d.visible = false
	controls_ui.visible = false

func _on_hide_catalogue_ui_button_mouse_exited():
	grid_container.visible = true
	hide_catalogue_ui_button.modulate = Color(1,1,1,1)
	polygon_2d.visible = true
	controls_ui.visible = true
