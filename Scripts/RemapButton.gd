extends HBoxContainer


export(String) var action = "p1_up"

var can_remap = false


func _ready():
	#assert(InputMap.has_action(action))
	set_process_unhandled_key_input(false)
	display_current_key()
	"""
	var custom_map = null
	for a in Globals.user_keymaps:
		if a[0] == action:
			custom_map = a
	if custom_map != null:
		remap_action_to(custom_map[1])
	"""
	
	$Button.text = InputMap.get_action_list(action)[0].as_text()
	$Label.text = action + ": "


func _unhandled_input(event):
	# Note that you can use the _input callback instead, especially if
	# you want to work with gamepads.
	if can_remap:
		remap_action_to(event)
		$Button.pressed = false
		can_remap = false


func remap_action_to(event):
	InputMap.action_erase_events(action)
	InputMap.action_add_event(action, event)
	$Button.text = "%s Key" % event.as_text()
	"""
	Globals.user_keymaps[Globals.user_keymaps.find(action)][1] = event
	Globals.save_settings()
	"""
	$Button.release_focus()


func display_current_key():
	var current_key = InputMap.get_action_list(action)[0].as_text()
	$Button.text = "%s Key" % current_key


func _on_Button_pressed():
	$Button.text = "Please press something..."
	can_remap = true
	$Button.release_focus()


func _on_Button_toggled(button_pressed):
	set_process_unhandled_key_input(button_pressed)
	if button_pressed:
		$Button.text = "... Key"
		$Button.release_focus()
	else:
		display_current_key()
