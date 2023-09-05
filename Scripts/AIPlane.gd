class_name AIPlane
extends ShootyPlane


export(String) var ai_name = "AI"
export(float) var follow_threshold = 42
export(float) var fire_distance = 500
export(float) var missile_distance = 500
export onready var home = get_node("Carrier")

var current_target = null


func _ready():
	randomize()
	nametag = ai_name


func _process(delta):
	if current_target == null:
		if $Targeter.is_colliding():
			if is_instance_valid($Targeter.get_collider()):
				if $Targeter.get_collider().is_in_group("Players"):
					current_target = $Targeter.get_collider()
					current_target.new_enemy_pointer(get_path())
		
		else:
			if rad2deg(get_angle_to(home.position)) > -follow_threshold and rad2deg(get_angle_to(home.position)) < follow_threshold:
				acceleration = 1
				turning = 0
				
				if rad2deg(get_angle_to(home.position)) > 0:
					turning = 1
				else:
					turning = -1
			else:
				acceleration = 0
				braking = 1
				if rad2deg(get_angle_to(home.position)) > 0:
					turning = 1
				else:
					turning = -1
	
	else:
		if is_instance_valid(current_target):
			if rad2deg(get_angle_to(current_target.position)) > -follow_threshold and rad2deg(get_angle_to(current_target.position)) < follow_threshold:
				acceleration = 1
				turning = 0
				
				firing_gun = true if position.distance_to(current_target.position) <= fire_distance else false
				firing_missile = true if position.distance_to(current_target.position) <= missile_distance and current_target == target else false
				
				if rad2deg(get_angle_to(current_target.position)) > 0:
					turning = 1
				else:
					turning = -1
			
			else:
				acceleration = 0
				braking = 1
				if rad2deg(get_angle_to(current_target.position)) > 0:
					turning = 1
				else:
					turning = -1
		else:
			current_target = null
			acceleration = 0
			braking = 0
			turning = 0
			firing_gun = false
			firing_missile = false
