extends Camera2D


var target = null


func _ready():
	zoom.x = Globals.camZoom
	zoom.y = Globals.camZoom


func _physics_process(delta):
	current = true
	
	if target:
		position = target.position
