extends Node


export var settings_path = "user://settings.save"
export var keymaps_path = "user://keymaps.dat"

var two_player
var coop
var split_screen = true
var always_nametags = false
var keymaps : Dictionary


func _ready():
	for action in InputMap.get_actions():
		keymaps[action] = InputMap.get_action_list(action)[0]
	load_settings()
	print("baguette")


func load_keymap():
	print("french")
	var file := File.new()
	if not file.file_exists(keymaps_path):
		save_keymap() # There is no save file yet, so let's create one.
		return
	#warning-ignore:return_value_discarded
	file.open(keymaps_path, File.READ)
	var temp_keymap: Dictionary = file.get_var(true)
	file.close()
	# We don't just replace the keymaps dictionary, because if you
	# updated your game and removed/added keymaps, the data of this
	# save file may have invalid actions. So we check one by one to
	# make sure that the keymap dictionary really has all current actions.
	for action in keymaps.keys():
		if temp_keymap.has(action):
			keymaps[action] = temp_keymap[action]
			# Whilst setting the keymap dictionary, we also set the
			# correct InputMap event
			InputMap.action_erase_events(action)
			InputMap.action_add_event(action, keymaps[action])


func save_keymap():
	# For saving the keymap, we just save the entire dictionary as a var.
	var file := File.new()
	#warning-ignore:return_value_discarded
	file.open(keymaps_path, File.WRITE)
	file.store_var(keymaps, true)
	file.close()


func save_settings():
	var f = File.new()
	f.open(settings_path, File.WRITE)
	f.store_var(split_screen)
	f.store_var(always_nametags)
	f.close()
	save_keymap()


func load_settings():
	var f = File.new()
	if f.file_exists(settings_path):
		f.open(settings_path, File.READ)
		split_screen = f.get_var()
		always_nametags = f.get_var()
		f.close()
	load_keymap()
