# Thanks to https://kidscancode.org/godot_recipes/ai/homing_missile/ and https://godotengine.org/qa/19746/how-do-i-add-gravity-to-an-area2d-node?show=19749#a19749

extends RigidBody2D

export(float) var speed = 600
export(float) var steer_force = 400
export(float) var pitch = 0.005

export(PackedScene) var Explosion

var shot_from
var velocity = Vector2.ZERO
var acceleration = Vector2.ZERO
var target = null
var dropping = true


func _ready():
	if shot_from.is_in_group("Players"):
		Globals.missilesFired += 1


func start(_transform, _target):
	global_transform = _transform
	rotation += rand_range(-0.09, 0.09)
	velocity = transform.x * speed
	target = _target

func start_without_target(_transform):
	global_transform = _transform
	rotation += rand_range(-0.09, 0.09)
	velocity = transform.x * speed

func seek():
	var steer = Vector2.ZERO
	if is_instance_valid(target):
		var desired = (target.position - position).normalized() * speed
		steer = (desired - velocity).normalized() * steer_force
	return steer

func _physics_process(delta):
	if not dropping:
		$Exhaust.emitting = true
		acceleration += seek()
		velocity += acceleration * delta
		velocity = velocity.clamped(speed)
		rotation = velocity.angle()
		position += velocity * delta
	
		$JetSound.pitch_scale = abs(linear_velocity.rotated(-rotation).x) * pitch


func _on_Lifetime_timeout():
	explode()

	
func explode():
	var e = Explosion.instance()
	get_parent().add_child(e)
	e.transform = transform
	queue_free()


func _on_Area2D_body_entered(body):
	if is_instance_valid(body) and body.is_in_group("AIs") and shot_from.is_in_group("Players"):
		Globals.missilesHit += 1
	if body != self and not dropping:
		explode()


func _on_DropTimer_timeout():
	dropping = false
	gravity_scale = 0.5


func _on_Lifetimer_timeout():
	explode()


func _on_Area2D_area_entered(area):
	if area != self and not dropping and not area.is_in_group("Water"):
		explode()
