extends PanelContainer
@onready var texture_rect = $TextureRect

#Triggers on click and drag
func _get_drag_data(at_position):
	set_drag_preview(get_preview())
	return texture_rect

#Triggers on hover while dragging item
func _can_drop_data(_pos, data):
	return data is TextureRect

#Triggers on dropping item
func _drop_data(_pos, data):
	texture_rect.texture = data.texture

func get_preview():
	var preview_texture = TextureRect.new()
	
	preview_texture.texture = texture_rect.texture
	preview_texture.expand_mode = 1
	preview_texture.size = Vector2(size.x, size.y)
	
	var preview = Control.new()
	preview.add_child(preview_texture)

	preview_texture.position.x -= get_viewport().size.x/2 + preview_texture.size.x/2
	preview_texture.position.y -= get_viewport().size.y/2 + preview_texture.size.y/2
	return preview
