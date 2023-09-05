extends RigidBody2D


export(float) var buoyancy = 50000
export(float) var spinny = 10000

var in_water


func _integrate_forces(state):
	if in_water:
		set_applied_force(Vector2.UP * buoyancy)
	else:
		set_applied_force(Vector2.ZERO)
	
	if rotation_degrees < 0:
		set_applied_torque(spinny)
	else:
		set_applied_torque(-spinny)


func _on_Area2D_area_entered(area):
	if area.is_in_group("Water"):
		in_water = true


func _on_Area2D_area_exited(area):
	if area.is_in_group("Water"):
		in_water = false
