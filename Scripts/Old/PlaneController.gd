extends RigidBody2D

export(float) var engine_thrust = 800
export(float) var fly_damp = -1
export(float) var brake_damp = 1
export(float) var lift_force = 200
export(float) var spin_thrust = 2000
export(float) var gun_speed = 24
export(float) var missile_speed = 1
export(int) var player_no = 1
export(int) var team = 1
export(int) var health = 5
export(float) var recoil = 1200
export(float) var buoyancy = 500
export(float) var nametag_zoom = 3
export(bool) var always_show_nametags = true
export(float) var destability = 100

export(PackedScene) var Bullet = preload("res://Scenes/Bullet.tscn")
export(PackedScene) var Missile = preload("res://Scenes/Missile.tscn")
export(PackedScene) var Explosion = preload("res://Scenes/Explosion.tscn")
export(PackedScene) var EnemyPointer = preload("res://Scenes/EnemyPointer.tscn")

var thrust = Vector2()
var rot_dir = 0
var gun_cooldown = 0
var missile_cooldown = 0
var target
var missile_offset
var collider_offset
var in_water = false
var nametag_normal_scale
var enemy_pointers = []


func _ready():
	randomize()
	missile_offset = $MissileLauncher.position.y
	collider_offset = $CollisionShape2D.position.y
	nametag_normal_scale = $Nametag.scale
	#$Nametag/Label.text = "P" + str(player_no) if player_no != -1 else "PLAYER"
	if name == "Plane1":
		if player_no == -1:
			$Nametag/Label.text = "PLAYER"
		else:
			$Nametag/Label.text = "P1"
	elif name == "Plane2":
		$Nametag/Label.text = "P2"
	if always_show_nametags:
		$Nametag/Label.show()


func pressed(button_name):
	if player_no == -1:
		return Input.is_action_pressed("p1_" + button_name) or Input.is_action_pressed("p2_" + button_name)
	else:
		if Input.is_action_pressed("p" + str(player_no) + "_" + button_name):
			return true
		else:
			return false


func _process(delta):
	gun_cooldown += delta
	missile_cooldown += delta
	
	if pressed("up"):
		thrust = Vector2(engine_thrust, -lift_force)
		$VapourTrail.emitting = true
	else:
		thrust = Vector2()
		$VapourTrail.emitting = false
	
	if pressed("down"):
		linear_damp = brake_damp;
	else:
		linear_damp = fly_damp;
	
	if pressed("left"):
		rot_dir = -1
	elif pressed("right"):
		rot_dir = 1
	else:
		rot_dir = 0
	
	if rotation_degrees < -90 and rotation_degrees > -270:
		$AnimatedSprite.play("rightFlip")
		$MissileLauncher.position.y = -missile_offset
		$CollisionShape2D.scale.y = -1
		$CollisionShape2D.position.y = -collider_offset
	elif rotation_degrees > -90 and rotation_degrees < 90:
		$AnimatedSprite.play("leftFlip")
		$MissileLauncher.position.y = missile_offset
		$CollisionShape2D.scale.y = 1
		$CollisionShape2D.position.y = collider_offset
	
	if pressed("gun") and gun_cooldown > 1 / gun_speed:
		gun_cooldown = 0
		$MuzzleFlash/Light2D.rotation = rand_range(0, 360)
		$MuzzleFlash.show()
		
		var b = Bullet.instance()
		owner.add_child(b)
		b.transform = $MuzzleFlash.global_transform
		b.shot_from = self
		b.rotation_degrees += rand_range(-b.inaccuracy, b.inaccuracy)
		
		thrust.x = -recoil
	
	if gun_cooldown > 0.5 / gun_speed:
		$MuzzleFlash.hide()
	
	if pressed("missile") and missile_cooldown > 1 / missile_speed:
		missile_cooldown = 0
		$MissileLockTimer.stop()
		var m = Missile.instance()
		owner.add_child(m)
		m.linear_velocity.x = linear_velocity.x
		m.linear_velocity.y = linear_velocity.y
		if target:
			m.start($MissileLauncher.global_transform, target)
		else:
			m.start_without_target($MissileLauncher.global_transform)
	
	if $MissileTargeter.is_colliding():
		if $MissileTargeter.get_collider():
			if $MissileTargeter.get_collider().is_in_group("Targets") and $MissileTargeter.get_collider().team != team:
				$MissileTargeter.get_collider().lock_on()
				$MissileLockTimer.stop()
				$MissileLockTimer.start()
				target = $MissileTargeter.get_collider()
	
	if $MissileLock.visible:
		$MissileLock.rotation_degrees = 0 - rotation_degrees
	if $Nametag.visible:
		$Nametag.rotation_degrees = 0 - rotation_degrees
		$Nametag/Pointer.rotation_degrees = rotation_degrees
	
	for checkEp in enemy_pointers:
		if is_instance_valid(get_node(checkEp.editor_description)):
			checkEp.rotation_degrees = rad2deg(get_angle_to(get_node(checkEp.editor_description).position))
		else:
			checkEp.queue_free()
			enemy_pointers.erase(checkEp)
	
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().reload_current_scene()


func _integrate_forces(_state):
	if not in_water:
		set_applied_force(thrust.rotated(rotation))
	else:
		set_applied_force(thrust.rotated(rotation) + Vector2.UP * buoyancy)
	set_applied_torque(rot_dir * spin_thrust)


func _on_Area2D_area_entered(area):
	if area.is_in_group("bullets") and area.shot_from != self:
		if health > 0:
			health -= 1
			if $Smoke.emitting == false:
				$Smoke.emitting = true
			add_torque(rand_range(-destability * area.speed, destability * area.speed))
		else:
			explode()
		area.queue_free()
	
	if area.is_in_group("missiles"):
		if area.get_parent().dropping == false:
			explode()
	
	if area.is_in_group("Water"):
		in_water = true
		#$Splash.emitting = true


func _on_Timer_timeout():
	$Explosion/Light2D.hide()


func explode():
	var e = Explosion.instance()
	e.transform = transform
	owner.add_child(e)
	lock_off()
	if is_instance_valid(target):
		target.lock_off()
	queue_free()


func lock_on():
	$MissileLock.show()


func lock_off():
	$MissileLock.hide()


func _on_MissileLockTimer_timeout():
	if is_instance_valid(target):
		target.lock_off()
	target = null
	$MissileLockTimer.stop()


func _on_Area2D_area_exited(area):
	if area.is_in_group("Water"):
		in_water = false
		#$Splash.emitting = false


func zoom(newzoom):
	$Nametag.scale.x = nametag_normal_scale.x * newzoom
	$Nametag.scale.y = nametag_normal_scale.y * newzoom
	if newzoom > nametag_zoom:
		$Nametag.show()
	else:
		if not $Nametag/NameShowTimer.time_left > 0:
			$Nametag/NameShowTimer.start()


func _on_NameShowTimer_timeout():
	if not always_show_nametags:
		$Nametag.hide()


func new_enemy_pointer(enemy_path):
	var ep = EnemyPointer.instance()
	add_child(ep)
	ep.editor_description = enemy_path
	enemy_pointers.append(ep)
