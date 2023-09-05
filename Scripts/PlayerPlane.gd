class_name PlayerPlane
extends ShootyPlane


export(int) var player_no = 1
export(PackedScene) var EnemyPointer = preload("res://Scenes/EnemyPointer.tscn")

var enemy_pointers = []
var can_play_target_sound = true


func _ready():
	"""
	if name == "Plane1":
		if player_no == -1:
			$Nametag/Label.text = "PLAYER"
		else:
			$Nametag/Label.text = "P1"
	elif name == "Plane2":
		$Nametag/Label.text = "P2"
	"""
	
#	$MissileLockSound.volume_db += Globals.tonesVolume
#	$TargetSound.volume_db += Globals.tonesVolume
#	$TargetLostSound.volume_db += Globals.tonesVolume


func pressed(button_name):
	if player_no == -1:
		return Input.is_action_pressed("p1_" + button_name) or Input.is_action_pressed("p2_" + button_name)
	else:
		if Input.is_action_pressed("p" + str(player_no) + "_" + button_name):
			return true
		else:
			return false


func new_enemy_pointer(enemy_path):
	var ep = EnemyPointer.instance()
	add_child(ep)
	ep.editor_description = enemy_path
	enemy_pointers.append(ep)


func _process(delta):
	if pressed("up"):
		acceleration = 1
	else:
		acceleration = 0
	
	if pressed("down"):
		braking = 1
	else:
		braking = 0
	
	if pressed("left"):
		turning = -1
	elif pressed("right"):
		turning = 1
	else:
		turning = 0
	
	firing_gun = pressed("gun")
	firing_missile = pressed("missile")
	
	for checkEp in enemy_pointers:
		if is_instance_valid(get_node(checkEp.editor_description)):
			checkEp.rotation_degrees = rad2deg(get_angle_to(get_node(checkEp.editor_description).position))
		else:
			checkEp.queue_free()
			enemy_pointers.erase(checkEp)
	
	if target == null:
		$LockPointer.hide()
	else:
		$LockPointer.show()
		if is_instance_valid(target):
			$LockPointer.rotation_degrees = rad2deg(get_angle_to(target.position))
		else:
			$LockPointer.hide()
	
	if $MissileLock.visible and not $MissileLockSound.playing:
		$MissileLockSound.play()
	elif not $MissileLock.visible:
		$MissileLockSound.stop()
	
	if target != null and can_play_target_sound:
		$TargetSound.play()
		can_play_target_sound = false
	
	if target == null and not can_play_target_sound:
		can_play_target_sound = true
		$TargetLostSound.play()
