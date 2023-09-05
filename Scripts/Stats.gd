extends Label


func get_time():
	var seconds = int(Globals.playtime) % 60
	var minutes = (int(Globals.playtime) / 60) % 60
	var hours = (int(Globals.playtime) / 60) / 60
	
	return "%02d:%02d:%02d" % [hours, minutes, seconds]


func greatestCommonFactor(a, b):
	return a if b == 0.0 else greatestCommonFactor(b, a % b)


func get_kdr(kills, deaths):
	var gcf = greatestCommonFactor(kills, deaths)
	if gcf != 0:
		return str(kills / gcf) + ":" + str(deaths / gcf)
	else:
		return "..."


func get_acc(fired, hit):
	if fired == 0:
		return "..."
	else:
		return str(float(hit) / float(fired) * 100.0) + "%"


func _process(delta):
	get_parent().rect_position.y = 1080 / 2 - get_parent().rect_size.y * 1.5
	
	text = "Stats:" \
	+ "\nPlaytime: " + get_time() \
	+ "\nBullets fired: " + str(Globals.bulletsFired) \
	+ "\nBullets hit: " + str(Globals.bulletsHit) \
	+ "\nBullet accuracy: " + get_acc(Globals.bulletsFired, Globals.bulletsHit) \
	+ "\nMissiles fired: " + str(Globals.missilesFired) \
	+ "\nMissiles hit: " + str(Globals.missilesHit) \
	+ "\nMissile accuracy: " + get_acc(Globals.missilesFired, Globals.missilesHit) \
	+ "\nTotal kills: " + str(Globals.kills) \
	+ "\nTotal deaths: " + str(Globals.deaths) \
	+ "\nKill:Death ratio: " + get_kdr(Globals.kills, Globals.deaths) \
	+ "\nMissiles shot down: " + str(Globals.missilesShot) \
	+ "\nBullets hit by: " + str(Globals.bulletsHitBy) \
	+ "\nMissiles hit by: " + str(Globals.missilesHitBy)
