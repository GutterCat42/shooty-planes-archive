extends MarginContainer


export var scale = 0.01
var mapItems = []


func addToMap(thing, good=false):
	var newIcon
	if good:
		newIcon = $ColorRect/GoodPlane.duplicate()
	else:
		newIcon = $ColorRect/BadPlane.duplicate()
	newIcon.visible = true
	mapItems.append([thing, newIcon])


func _process(delta):
	if mapItems != []:
		for item in mapItems:
			if is_instance_valid(item[0]):
				item[1].position.x = $ColorRect.rect_size.x / 2 + item[0].position.x * scale
				item[1].position.y = $ColorRect.rect_size.y / 2 - item[0].position.y * scale
			else:
				mapItems.erase(item)
