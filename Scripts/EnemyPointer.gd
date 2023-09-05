extends Node2D


export(NodePath) var enemy


func _process(delta):
	if is_instance_valid(get_node(enemy)):
		print("yes")
		rotation_degrees = get_parent().rotation_degrees + rad2deg(get_angle_to(get_node(enemy).position))
	else:
		print("no")
		#queue_free()
