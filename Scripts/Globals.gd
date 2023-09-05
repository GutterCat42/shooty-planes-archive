extends Node


export var settings_path = "user://settings.sav"
export var stats_path = "user://stats.sav"

var two_player
var coop

var split_screen = true
var always_nametags = false
var sfxVolume = 0
var sfxMute = false
var tonesVolume = 0
var tonesMute = false
var minimap = true
var camZoom = 1

var stats_save_interval = 60

var playtime = 0
var bulletsFired = 0
var bulletsHit = 0
var missilesFired = 0
var missilesHit = 0
var kills = 0
var deaths = 0
var missilesShot = 0
var bulletsHitBy = 0
var missilesHitBy = 0

var lastStatSave = 0


func _ready():
	load_settings()
	load_stats()


func save_settings():
	var f = File.new()
	f.open(settings_path, File.WRITE)
	f.store_var(split_screen)
	f.store_var(always_nametags)
	f.store_var(sfxVolume)
	f.store_var(sfxMute)
	f.store_var(tonesVolume)
	f.store_var(tonesMute)
	f.store_var(minimap)
	f.store_var(camZoom)
	f.close()
	load_sound_settings()


func load_settings():
	var f = File.new()
	if f.file_exists(settings_path):
		f.open(settings_path, File.READ)
		split_screen = f.get_var()
		always_nametags = f.get_var()
		sfxVolume = f.get_var()
		sfxMute = f.get_var()
		tonesVolume = f.get_var()
		tonesMute = f.get_var()
		minimap = f.get_var()
		camZoom = f.get_var()
		f.close()
		load_sound_settings()


func load_sound_settings():
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), sfxVolume)
	AudioServer.set_bus_mute(AudioServer.get_bus_index("SFX"), sfxMute)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Tones"), tonesVolume)
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Tones"), tonesMute)


func save_stats():
	var f = File.new()
	f.open(stats_path, File.WRITE)
	f.store_var(playtime)
	f.store_var(bulletsFired)
	f.store_var(bulletsHit)
	f.store_var(missilesFired)
	f.store_var(missilesHit)
	f.store_var(kills)
	f.store_var(deaths)
	f.store_var(missilesShot)
	f.store_var(bulletsHitBy)
	f.store_var(missilesHitBy)
	f.close()


func load_stats():
	var f = File.new()
	if f.file_exists(stats_path):
		f.open(stats_path, File.READ)
		playtime = f.get_var()
		bulletsFired = f.get_var()
		bulletsHit = f.get_var()
		missilesFired = f.get_var()
		missilesHit = f.get_var()
		kills = f.get_var()
		deaths = f.get_var()
		missilesShot = f.get_var()
		bulletsHitBy = f.get_var()
		missilesHitBy = f.get_var()
		f.close()


func _process(delta):
	playtime += delta
	if playtime >= lastStatSave + stats_save_interval:
		save_stats()
		lastStatSave = playtime
