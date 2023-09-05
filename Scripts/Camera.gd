# Thanks to https://godotengine.org/qa/67986/how-do-i-make-camera-follow-and-zoom-to-2-players?show=68048#a68048

extends Camera2D

export(NodePath) var object1
export(NodePath) var object2
export(float) var normal_zoom = 1
export(float) var smooth_speed = 15
export(float) var margin = 400

var position_difference = Vector2()
var smoothed_velocity = Vector2()


func _ready():
	if Globals.two_player:
		$Minimap.hide()
	else:
		$Minimap.show()
	
	normal_zoom = Globals.camZoom


func _physics_process(delta):
	if Globals.two_player:
		if Globals.split_screen:
			if current:
				current = false
		else:
			if not current:
				current = true
	else:
		if not current:
			current = true
	
	var obj1 = get_node(object1)
	var obj2 = get_node(object2)
	
	if obj1 and obj2:
		var destination = (obj1.global_position + obj2.global_position) * 0.5
		position_difference = destination - position
		smoothed_velocity = position_difference * smooth_speed * delta
		position += smoothed_velocity
		
		var zoom_factor1 = abs(obj1.global_position.x-obj2.global_position.x)/(1920 - margin)
		var zoom_factor2 = abs(obj1.global_position.y-obj2.global_position.y)/(1080 - margin)
		var zoom_factor = max(max(zoom_factor1, zoom_factor2), normal_zoom)

		zoom = Vector2(zoom_factor, zoom_factor)
		obj1.zoom(zoom_factor)
		obj2.zoom(zoom_factor)
	
	elif obj1:
		var destination = (obj1.global_position + obj2.global_position) * 0.5
		position_difference = destination - position
		smoothed_velocity = position_difference * smooth_speed * delta
		position += smoothed_velocity
		
		zoom = Vector2(normal_zoom, normal_zoom)
		obj1.zoom(normal_zoom)
	
	elif obj2:
		var destination = (obj1.global_position + obj2.global_position) * 0.5
		position_difference = destination - position
		smoothed_velocity = position_difference * smooth_speed * delta
		position += smoothed_velocity
		
		zoom = Vector2(normal_zoom, normal_zoom)
		obj2.zoom(normal_zoom)
