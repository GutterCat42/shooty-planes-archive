extends Control


export var gameScene = "res://Scenes/Carrier.tscn"
export var splitScreenScene = "res://Scenes/SplitScreen.tscn"


func _ready():
	$"Main/1PButton".grab_focus()
	$Options/SplitScreenButton.text = "SPLIT SCREEN: ON" if Globals.split_screen else "SPLIT SCREEN: OFF"
	$Options/NametagsButton.text = "ALWAYS SHOW NAMETAGS: ON" if Globals.always_nametags else "ALWAYS SHOW NAMETAGS: OFF"
	$Options/MinimapButton.text = "MINIMAP: ON" if Globals.minimap else "MINIMAP: OFF"
	$Options/CamZoom/CamZoomSlider.value = Globals.camZoom


func _on_1PButton_pressed():
	Globals.two_player = false
	Globals.coop = true
	get_tree().change_scene(gameScene)


func _on_2PButton_pressed():
	Globals.two_player = true
	Globals.coop = true
	get_tree().change_scene(splitScreenScene if Globals.split_screen else gameScene)


func _on_OptionsButton_pressed():
	$Main.hide()
	$TextureRect.hide()
	$Options.show()


func _on_QuitButton_pressed():
	Globals.save_stats()
	get_tree().quit()


func _on_DeathmatchButton_pressed():
	Globals.two_player = true
	Globals.coop = false
	get_tree().change_scene(splitScreenScene if Globals.split_screen else gameScene)


func _on_HelpButton_pressed():
	$Main.hide()
	$TextureRect.hide()
	$Help.show()


func _on_SplitScreenButton_pressed():
	if Globals.split_screen:
		Globals.split_screen = false
		$Options/SplitScreenButton.text = "SPLIT SCREEN: OFF"
	else:
		Globals.split_screen = true
		$Options/SplitScreenButton.text = "SPLIT SCREEN: ON"
	Globals.save_settings()


func _on_OptionsBackButton_pressed():
	$Options.hide()
	$TextureRect.show()
	$Main.show()


func _on_HelpBackButton_pressed():
	$Help.hide()
	$TextureRect.show()
	$Main.show()


func _on_NametagsButton_pressed():
	if Globals.always_nametags:
		Globals.always_nametags = false
		$Options/NametagsButton.text = "ALWAYS SHOW NAMETAGS: OFF"
	else:
		Globals.always_nametags = true
		$Options/NametagsButton.text = "ALWAYS SHOW NAMETAGS: ON"
	Globals.save_settings()


func _on_StatsButton_pressed():
	$Main.hide()
	$TextureRect.hide()
	$Stats.show()


func _on_StatsBackButton_pressed():
	$Stats.hide()
	$TextureRect.show()
	$Main.show()


func _on_RemapButton_pressed():
	$Options.hide()
	$Remap.show()


func _on_RemapBackButton_pressed():
	$Remap.hide()
	$Options.show()


func _on_MinimapButton_pressed():
	if Globals.minimap:
		Globals.minimap = false
		$Options/MinimapButton.text = "MINIMAP: OFF"
	else:
		Globals.minimap = true
		$Options/MinimapButton.text = "MINIMAP: ON"
	Globals.save_settings()


func _on_CamZoomSlider_value_changed(value):
	Globals.camZoom = value
	Globals.save_settings()
