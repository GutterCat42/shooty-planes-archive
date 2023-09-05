# Thanks to https://kidscancode.org/godot_recipes/2d/2d_shooting/

extends Area2D

export(float) var speed = 100
export(float) var inaccuracy = 5
export(int) var life = 10

var lifetime = 0
var shot_from


func _ready():
	if shot_from.is_in_group("Players"):
		Globals.bulletsFired += 1


func _process(delta):
	lifetime += delta
	if lifetime > life:
		queue_free()


func _physics_process(delta):
	position += Vector2(speed, 0).rotated(rotation) * delta


func _on_Area2D_body_entered(body):
	if not body.is_in_group("Planes"):
		$Particles2D.emitting = true
		owner.add_child($Particles2D)
		$Particles2D.global_transform = global_transform
		queue_free()
