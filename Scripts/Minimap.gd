extends MarginContainer

# this is the new one

export var scale = 0.02

var width
var height
var ais = []
var numAIs
var badPlanes = []


func _ready():	
	width = owner.bottomRight.x - owner.topLeft.x
	height = owner.bottomRight.y - owner.topLeft.y
	
	scale *= Globals.camZoom
	
	rect_size.x = width * scale
	rect_position.x -= rect_size.x / 2
	rect_size.y = height * scale
	rect_position.y -= rect_size.y / 2
	rect_position.y -= (1080 * Globals.camZoom) / 2 - rect_size.y / 2 # this is yucky because its temporary
	
	"""
	badPlanes.append($BadPlane)
	numAIs = owner.num_ais
	if numAIs > 1:
		while len(badPlanes) < numAIs:
			var b = $BadPlane.duplicate()
			get_parent().add_child(b)
			badPlanes.append(b)
			print("french")
	"""
	badPlanes.append($BadPlane)
	badPlanes.append($BadPlane2)
	badPlanes.append($BadPlane3)
	numAIs = owner.num_ais


func _process(delta):
	if not Globals.minimap:
		queue_free()
	
	if is_instance_valid(owner.get_node("Plane1")):
		$GoodPlane1.visible = true
		$GoodPlane1.position.x = owner.get_node("Plane1").position.x * scale + rect_size.x / 2
		$GoodPlane1.position.y = owner.get_node("Plane1").position.y * scale + rect_size.y / 2
	else:
		$GoodPlane1.visible = false
	
	if is_instance_valid(owner.get_node("Plane2")):
		$GoodPlane2.visible = true
		$GoodPlane2.position.x = owner.get_node("Plane2").position.x * scale + rect_size.x / 2
		$GoodPlane2.position.y = owner.get_node("Plane2").position.y * scale + rect_size.y / 2
	else:
		$GoodPlane2.visible = false
	
	ais = get_tree().get_nodes_in_group("AIs")
	for i in range(len(ais)):
		badPlanes[i].position.x = ais[i].position.x * scale + rect_size.x / 2
		badPlanes[i].position.y = ais[i].position.y * scale + rect_size.y / 2
