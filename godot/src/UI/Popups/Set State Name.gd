extends WindowDialog

signal set_state_name(idx, name)
var idx : int

func setup(name:String,idx:int)->void:
	$MarginContainer/VBoxContainer/SelectedStateName.text=name
	self.idx = idx
	
func _on_Accept_pressed() -> void:
	emit_signal("set_state_name",idx,$"MarginContainer/VBoxContainer/SelectedStateName".text)
	hide()

func _on_Cancel_pressed() -> void:
	hide()
