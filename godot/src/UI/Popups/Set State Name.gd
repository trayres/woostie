extends WindowDialog

signal set_state_name(name)

func setup(name:String,idx:int)->void:
	$MarginContainer/VBoxContainer/SelectedStateName.text=name
	
func _on_Accept_pressed() -> void:
	emit_signal("set_state_name",$"MarginContainer/VBoxContainer/SelectedStateName".text)
	hide()

func _on_Cancel_pressed() -> void:
	hide()
