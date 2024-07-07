extends Area2D

signal placement_eligibility_changed(eligibility: bool)



var placement_eligible: bool = true:
	get:
		return placement_eligible
	set(new_value):
		placement_eligible = new_value
		placement_eligibility_changed.emit(placement_eligible)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func process_collisions():
	var colliding_area = !get_overlapping_areas().filter(
		func(area: Area2D):
			return area.get_parent() != get_parent()
	).is_empty()
			
	placement_eligible = !colliding_area

func _on_area_entered(area):
	process_collisions()

func _on_area_exited(area):
	process_collisions()
