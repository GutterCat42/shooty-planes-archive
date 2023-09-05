class_name ShootyPlane
extends RigidBody2D

export(float) var engine_thrust = 800
export(float) var max_speed = 1500
export(float) var brake_force = 400
export(float) var brake_threshhold = 100
export(float) var lift_force = 150
export(float) var spin_thrust = 1000
export(float) var gun_speed = 24
export(float) var missile_speed = 1
export(String) var nametag = "PLAYER"
export(int) var team = 1
export(int) var health = 5
export(float) var recoil = 1200
export(float) var buoyancy = 400
export(float) var nametag_zoom = 3
export(bool) var always_show_nametags = true
export(float) var destability = 100
export(float) var randPitchLow = 0.8
export(float) var randPitchHigh = 1.2
export(float) var jetPitchLow = 0.1
export(float) var jetPitchHigh = 2
export(float) var jetPitchLerp = 0.1
export(float) var worldWidth = 30000

export(PackedScene) var Bullet = preload("res://Scenes/Bullet.tscn")
export(PackedScene) var Missile = preload("res://Scenes/Missile.tscn")
export(PackedScene) var Explosion = preload("res://Scenes/Explosion.tscn")

var thrust = Vector2()
var rot_dir = 0
var gun_cooldown = 0
var missile_cooldown = 0
var target
var missile_offset
var collider_offset
var area_offset
var in_water = false
var nametag_normal_scale

var acceleration = 0
var braking = 0
var turning = 0
var firing_gun = false
var firing_missile = false
var can_shoot = true


func _ready():
	randomize()
	missile_offset = $MissileLauncher.position.y
	collider_offset = $CollisionShape2D.position.y
	area_offset = $Area2D.position.y
	nametag_normal_scale = $Nametag.scale
	$Nametag/Label.text = nametag
	if always_show_nametags:
		$Nametag/Label.show()
	if Globals.split_screen and Globals.two_player:
		$Nametag.hide()
	
	$ShootyTimer.wait_time = 1 / gun_speed

#	$ShootSound.volume_db += Globals.sfxVolume
#	$HitSound.volume_db += Globals.sfxVolume
#	$JetSound.volume_db += Globals.sfxVolume


func _physics_process(delta):
	gun_cooldown += delta
	missile_cooldown += delta
	
	if position.x < worldWidth / -2:
		position.x = worldWidth / 2
	elif position.x > worldWidth / 2:
		position.x = worldWidth / -2
	
	if acceleration > 0 and linear_velocity.rotated(-rotation).x <= max_speed:
		thrust = Vector2(engine_thrust * acceleration, -lift_force)
		$VapourTrail.emitting = true
	else:
		thrust = Vector2()
		$VapourTrail.emitting = false
	
	$JetSound.pitch_scale = lerp($JetSound.pitch_scale, clamp((jetPitchLow + (jetPitchHigh - jetPitchLow) * (abs(linear_velocity.rotated(-rotation).x) / max_speed)) * acceleration, jetPitchLow, jetPitchHigh), jetPitchLerp)
	
	if braking > 0:
		if linear_velocity.rotated(-rotation).x > brake_threshhold:
			thrust += Vector2(-brake_force * braking, 0)
	
	if turning != 0:
		rot_dir = turning
	else:
		rot_dir = 0
	
	if rotation_degrees < -90 and rotation_degrees > -270:
		$AnimatedSprite.play("rightFlip")
		$MissileLauncher.position.y = -missile_offset
		$CollisionShape2D.scale.y = -1
		$CollisionShape2D.position.y = -collider_offset
		$Area2D.scale.y = -1
		$Area2D.position.y = -area_offset
	elif rotation_degrees > -90 and rotation_degrees < 90:
		$AnimatedSprite.play("leftFlip")
		$MissileLauncher.position.y = missile_offset
		$CollisionShape2D.scale.y = 1
		$CollisionShape2D.position.y = collider_offset
		$Area2D.scale.y = 1
		$Area2D.position.y = area_offset
	
	if firing_gun and can_shoot:
		#gun_cooldown = 0
		$ShootyTimer.start()
		can_shoot = false
		
		$MuzzleFlash/Light2D.rotation = rand_range(0, 360)
		$MuzzleFlash.show()
		
		var b = Bullet.instance()
		b.shot_from = self
		owner.add_child(b)
		b.owner = owner
		b.transform = $MuzzleFlash.global_transform
		b.rotation_degrees += rand_range(-b.inaccuracy, b.inaccuracy)
		b.speed += linear_velocity.length()
		
		if abs(linear_velocity.rotated(-rotation).x) <= max_speed:
			thrust.x = -recoil
		
		$ShootSound.pitch_scale = rand_range(randPitchLow, randPitchHigh)
		$ShootSound.play(0.0)
	
	if gun_cooldown > 0.5 / gun_speed:
		$MuzzleFlash.hide()
	
	if firing_missile and missile_cooldown > 1 / missile_speed:
		missile_cooldown = 0
		$MissileLockTimer.stop()
		var m = Missile.instance()
		m.shot_from = self
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


func _integrate_forces(_state):
	if not in_water:
		set_applied_force(thrust.rotated(rotation))
	else:
		set_applied_force(thrust.rotated(rotation) + Vector2.UP * buoyancy)
	set_applied_torque(rot_dir * spin_thrust)


func _on_Area2D_area_entered(area):
	if area.is_in_group("bullets") and area.shot_from != self:
		if is_in_group("Players"):
			Globals.bulletsHitBy += 1
		
		if health > 0:
			health -= 1
			if $Smoke.emitting == false:
				$Smoke.emitting = true
			add_torque(rand_range(-destability * area.speed, destability * area.speed))
			$HitSound.pitch_scale = rand_range(randPitchLow, randPitchHigh)
			$HitSound.play(0.0)
		else:
			if area.shot_from.is_in_group("Players"):
				Globals.kills += 1
			explode()
		
		if is_instance_valid(area.shot_from):
			if area.shot_from.is_in_group("Players") and area.shot_from != self:
				Globals.bulletsHit += 1
		area.queue_free()
	
	if area.is_in_group("missiles"):
		if is_in_group("Players"):
			Globals.missilesHitBy += 1
		
		if area.get_parent().dropping == false:
			if is_instance_valid(area.get_parent().shot_from):
				if area.get_parent().shot_from.is_in_group("Players"):
					Globals.kills += 1
			explode()
	
	if area.is_in_group("Water"):
		in_water = true
		#$Splash.emitting = true


func _on_Timer_timeout():
	$Explosion/Light2D.hide()


func explode():
	if is_in_group("Players"):
		Globals.deaths += 1
	
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
	$Nametag/Label.text = nametag
	$Nametag.scale.x = nametag_normal_scale.x * newzoom
	$Nametag.scale.y = nametag_normal_scale.y * newzoom
	if newzoom > nametag_zoom:
		if not Globals.split_screen:
			$Nametag.show()
	else:
		if not $Nametag/NameShowTimer.time_left > 0:
			$Nametag/NameShowTimer.start()
	if Globals.split_screen and Globals.two_player:
		$Nametag.scale.x = nametag_normal_scale.x
		$Nametag.scale.y = nametag_normal_scale.y


func _on_NameShowTimer_timeout():
	if not always_show_nametags:
		$Nametag.hide()


func set_nametag(nametag):
	$Nametag/Label.text = nametag


func _on_ShootyTimer_timeout():
	can_shoot = true
