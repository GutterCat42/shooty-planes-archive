extends RigidBody2D

export(float) var engine_thrust = 800
export(float) var fly_damp = -1
export(float) var brake_damp = 1
export(float) var lift_force = 200
export(float) var spin_thrust = 2000
export(float) var gun_speed = 24
export(float) var missile_speed = 1
export(int) var team = 2
export(int) var health = 5
export(float) var recoil = 1200
export(float) var buoyancy = 500
export(float) var nametag_zoom = 3

export(String) var ai_name = "AI"
export(float) var follow_threshold = 42
export(float) var fire_distance = 500
export(float) var missile_distance = 500

export(PackedScene) var Bullet
export(PackedScene) var Missile
export(PackedScene) var Explosion
export(PackedScene) var Flare

var thrust = Vector2()
var rot_dir = 0
var gun_cooldown = 0
var missile_cooldown = 0
var missile_target
var missile_offset
var collider_offset
var in_water = false
var nametag_normal_scale

var control = [false, false, false, false, false, false]
var current_target = null


func _ready():
	missile_offset = $MissileLauncher.position.y
	collider_offset = $CollisionShape2D.position.y
	nametag_normal_scale = $Nametag.scale
	$Nametag/Label.text = ai_name


func pressed(control_name):
	var control_index
	
	if control_name == "up":
		control_index = 0
	elif control_name == "down":
		control_index = 1
	elif control_name == "left":
		control_index = 2
	elif control_name == "right":
		 control_index = 3
	elif control_name == "gun":
		control_index = 4
	elif control_name == "missile":
		control_index = 5
	
	return control[control_index]


func set_control(option, setting):
	if option == "up":
		control[0] = setting
	elif option == "down":
		control[1] = setting
	elif option == "left":
		control[2] = setting
	elif option == "right":
		 control[3] = setting
	elif option == "gun":
		control[4] = setting
	elif option == "missile":
		control[5] = setting


func _process(delta):
	gun_cooldown += delta
	missile_cooldown += delta
	
	if current_target == null:
		if $Targeter.is_colliding():
			if is_instance_valid($Targeter.get_collider()):
				if $Targeter.get_collider().is_in_group("Players"):
					current_target = $Targeter.get_collider()
					current_target.new_enemy_pointer(get_path())
	else:
		if is_instance_valid(current_target):
			if rad2deg(get_angle_to(current_target.position)) > -follow_threshold and rad2deg(get_angle_to(current_target.position)) < follow_threshold:
				set_control("up", true)
				set_control("left", false)
				set_control("right", false)
				if position.distance_to(current_target.position) <= fire_distance:
					set_control("gun", true)
				else:
					set_control("gun", false)
				if position.distance_to(current_target.position) <= missile_distance and current_target == missile_target:
					set_control("missile", true)
				else:
					set_control("missile", false)
			else:
				set_control("up", false)
				set_control("down", true)
				if rad2deg(get_angle_to(current_target.position)) > 0:
					set_control("right", true)
					set_control("left", false)
				else:
					set_control("left", true)
					set_control("right", false)
		else:
			current_target = null
			set_control("up", false)
			set_control("left", false)
			set_control("right", false)
			set_control("gun", false)
			set_control("missile", false)
	
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
		#var enemy = get_tree().get_nodes_in_group("team_" + str(enemy_team))[0]
		var m = Missile.instance()
		owner.add_child(m)
		m.linear_velocity.x = linear_velocity.x
		m.linear_velocity.y = linear_velocity.y
		if missile_target:
			m.start($MissileLauncher.global_transform,missile_target)
		else:
			m.start_without_target($MissileLauncher.global_transform)
	
	if $MissileTargeter.is_colliding():
		if $MissileTargeter.get_collider():
			if $MissileTargeter.get_collider().is_in_group("Players"):
				$MissileTargeter.get_collider().lock_on()
				$MissileLockTimer.stop()
				$MissileLockTimer.start()
				missile_target = $MissileTargeter.get_collider()
	
	if $MissileLock.visible:
		$MissileLock.rotation_degrees = 0 - rotation_degrees
	if $Nametag.visible:
		$Nametag.rotation_degrees = 0 - rotation_degrees
		$Nametag/Pointer.rotation_degrees = rotation_degrees
	
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
		else:
			explode()
		area.queue_free()
	
	if area.is_in_group("missiles"):
		if area.get_parent().dropping == false:
			explode()
	
	if area.is_in_group("Water"):
		in_water = true


func _on_Timer_timeout():
	$Explosion/Light2D.hide()


func explode():
	var e = Explosion.instance()
	e.transform = transform
	owner.add_child(e)
	lock_off()
	if is_instance_valid(missile_target):
		missile_target.lock_off()
	queue_free()


func lock_on():
	$MissileLock.show()


func lock_off():
	$MissileLock.hide()


func _on_MissileLockTimer_timeout():
	if is_instance_valid(missile_target):
		missile_target.lock_off()
	missile_target = null
	$MissileLockTimer.stop()


func _on_Area2D_area_exited(area):
	if area.is_in_group("Water"):
		in_water = false


func zoom(newzoom):
	$Nametag/Label.text = ai_name
	$Nametag.scale.x = nametag_normal_scale.x * newzoom
	$Nametag.scale.y = nametag_normal_scale.y * newzoom
	if newzoom > nametag_zoom:
		$Nametag.show()
	else:
		if not $Nametag/NameShowTimer.time_left > 0:
			$Nametag/NameShowTimer.start()


func _on_NameShowTimer_timeout():
	$Nametag.hide()
