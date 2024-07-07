extends StaticBody2D

@onready var sprite_2d = $Sprite2D
@onready var area_2d = $Area2D

signal hovering(item, isHovering)

var base_offset

var previewing: bool:
	get:
		return previewing
	set(new_value):
		previewing = new_value
		update_shader()

var can_place: bool = true:
	get:
		return can_place
	set(new_value):
		can_place = new_value
		update_shader()

var width
var height

# Called when the node enters the scene tree for the first time.
func _ready():
	base_offset = area_2d.position
	width = sprite_2d.texture.get_width()*sprite_2d.scale.x
	height = sprite_2d.texture.get_height()*sprite_2d.scale.y

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func update_shader():
	if previewing:
		if can_place:
			sprite_2d.modulate = Color(1,1,1,0.3)
			area_2d.modulate = Color(1,1,1,0.3)
		else:
			sprite_2d.modulate = Color(1,0,0,0.3)
			area_2d.modulate = Color(1,0,0,0.3)
	else:
		sprite_2d.modulate = Color(1,1,1,1)
		area_2d.modulate = Color(0,0,0,0)

func _on_area_2d_placement_eligibility_changed(eligibility):
	can_place = eligibility

func remove():
	if !previewing:
		queue_free()

func _on_area_2d_mouse_entered():
	hovering.emit(self, true)

func _on_area_2d_mouse_exited():
	hovering.emit(self, false)

func save():
	var save_dict = {
		"filename" : get_scene_file_path(),
		"parent" : get_parent().get_path(),
		"pos_x" : position.x,
		"pos_y" : position.y,
		"previewing" : previewing
	}
	return save_dict
