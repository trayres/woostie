extends HBoxContainer

var idx : int = 0
var has_focus : bool = false

func setup(idx : int) -> void:
	self.idx = idx


func _on_InputLineEdit_focus_entered() -> void:
	has_focus = true
	print("InputLineEdit number:"+str(idx)+" entered")


func _on_InputLineEdit_focus_exited() -> void:
	has_focus = false
	print("InputLineEdit number:"+str(idx)+" exited")
