extends VBoxContainer


export var globalsProperty = "sfx"
export var labelText = "SFX Volume:"


func _ready():
	$Label.text = labelText
	$HBoxContainer/VolumeSlider.value = db2linear(Globals.get(globalsProperty + "Volume"))
	$HBoxContainer/MuteButton.text = "Mute" if not Globals.get(globalsProperty + "Mute") else "Unmute"


func _on_VolumeSlider_value_changed(value):
	Globals.set(globalsProperty + "Volume", linear2db(value))
	Globals.save_settings()


func _on_MuteButton_pressed():
	if Globals.get(globalsProperty + "Mute"):
		Globals.set(globalsProperty + "Mute", false)
		$HBoxContainer/MuteButton.text = "Mute"
	else:
		Globals.set(globalsProperty + "Mute", true)
		$HBoxContainer/MuteButton.text = "Unmute"
	Globals.save_settings()
