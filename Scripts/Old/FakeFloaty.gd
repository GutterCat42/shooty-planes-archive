# THIS DOESNT WORK

extends Node2D


export(float) var up = 10
export(float) var down = 10

var normal_y


func _ready():
	normal_y = position.y


func _process(delta):
	if position.y == normal_y - up:
		position.y = lerp(position.y, normal_y + down, 0.42)
		print('down')
	else:
		position.y = lerp(position.y, normal_y - up, 0.42)
		print('up')
