extends Control


func _process(_delta):
	if Input.is_action_just_pressed("ui_accept"):
		get_tree().change_scene("res://Scenes/Carrier.tscn")
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
