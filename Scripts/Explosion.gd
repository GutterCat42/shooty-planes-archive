extends Particles2D


func _ready():
	randomize()
	rotation = rand_range(0, 360)
	emitting = true
	$ExplosionDebris.emitting = true
	$Light2D.show()
	$Light2D/Timer.start()
	$AudioStreamPlayer2D.pitch_scale = rand_range(0.8, 1.2)
#	$AudioStreamPlayer2D.volume_db += Globals.sfxVolume


func _on_Timer_timeout():
	$Light2D.hide()


func _on_LifeTimer_timeout():
	queue_free()
