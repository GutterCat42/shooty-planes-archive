extends Node


export var settings_path = "user://settings.sav"

var two_player
var coop
var split_screen = true
var always_nametags = false
var keymap = []


func _ready():
	load_settings()
	if keymap == []:
		for a in InputMap.get_actions():
			keymap.append([a, InputMap.get_action_list(a)])

func save_settings():
	var f = File.new()
	f.open(settings_path, File.WRITE)
	f.store_var(split_screen)
	f.store_var(always_nametags)
	f.store_var(keymap)
	f.close()


func load_settings():
	var f = File.new()
	if f.file_exists(settings_path):
		f.open(settings_path, File.READ)
		split_screen = f.get_var()
		always_nametags = f.get_var()
		keymap = f.get_var()
		set_inputmap()
		f.close()


func set_inputmap():
	for a in InputMap.get_actions():
		InputMap.action_erase_events(a)
	for a in keymap:
		for e in a[1]:
			InputMap.action_add_event(a[0], e)
	print(InputMap.get_actions())
