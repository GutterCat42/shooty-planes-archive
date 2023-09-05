extends Node2D


export(int) var clouds = 100
export var topLeft = Vector2(-15000, -8000)
export var bottomRight = Vector2(15000, 0)
export(bool) var enableCamera = false

export(PackedScene) var plane
export(bool) var two_player
export(bool) var coop
export(PackedScene) var ai_plane
export(int) var num_ais = 3
export(PackedScene) var cloud

var p1
var p2
var ai
var ais = []


func _ready():
	randomize()
	
	for _i in range(0, clouds):
		var c = cloud.instance()
		add_child(c)
		c.position = Vector2(rand_range(topLeft.x, bottomRight.x), rand_range(topLeft.y, bottomRight.y))
		c.get_node("Sprite").frame = rand_range(0, 4)
	
	two_player = Globals.two_player
	coop = Globals.coop
	
	$Camera2D.current = enableCamera


func _process(_delta):
	if Globals.coop:
		if len(ais) < num_ais:
			ai = ai_plane.instance()
			add_child(ai)
			ai.global_transform = $ActualCarrier2/Spawnpoint.global_transform
			ai.owner = self
			ai.z_index = -10
			ai.team = 2
			ai.home = $ActualCarrier
			ais.append(ai)
			ai.set_nametag("AI")
	
		for checkAi in ais:
			if not is_instance_valid(checkAi):
				ais.erase(checkAi)

	if not get_node("Plane1"):
		p1 = plane.instance()
		add_child(p1)
		p1.global_transform = $ActualCarrier/Spawnpoint.global_transform
		p1.name = "Plane1"
		p1.nametag = "P1" if two_player else "PLAYER"
		p1.owner = self
		p1.player_no = 1 if two_player else -1
		p1.team = 1
		p1.z_index = -10
		$Camera2D.object1 = p1.get_path()
		if get_node("Plane2"):
			$Plane2/Nametag.show()
			$Plane2/Nametag/NameShowTimer.start()
		if not two_player:
			$Camera2D.object2 = p1.get_path()
			$Plane1/Nametag/Label.text = "PLAYER"
		p1.always_show_nametags = Globals.always_nametags
	
	if two_player and not get_node("Plane2"):
		p2 = plane.instance()
		add_child(p2)
		if coop:
			p2.global_transform = $ActualCarrier/Spawnpoint.global_transform
		else:
			p2.global_transform = $ActualCarrier2/Spawnpoint.global_transform
		p2.name = "Plane2"
		p2.nametag = "P2"
		p2.owner = self
		p2.player_no = 2
		p2.team = 1 if coop else 2
		p2.z_index = -10
		$Camera2D.object2 = p2.get_path()
		if get_node("Plane1"):
			$Plane1/Nametag.show()
			$Plane1/Nametag/NameShowTimer.start()
		p2.always_show_nametags = Globals.always_nametags
	
	if Input.is_action_just_pressed("ui_select"):
		if Engine.time_scale == 1:
			Engine.time_scale = 0.2
			AudioServer.global_rate_scale = 1.8
		else:
			Engine.time_scale = 1
			AudioServer.global_rate_scale = 1.0
	
	"""
	if Input.is_action_just_pressed("ui_cancel"):
		if get_tree().paused:
			get_tree().paused = false
			$Camera2D/Label.visible = false
		else:
			get_tree().paused = true
			$Camera2D/Label.visible = true
	"""
	
	if Input.is_action_just_pressed("quit"):
		get_tree().change_scene("res://Scenes/MainMenu.tscn")
