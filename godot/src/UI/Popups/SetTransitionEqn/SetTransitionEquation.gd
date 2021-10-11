extends WindowDialog

var transition_idx : int
var priority       : int
var transition_eqn : String

signal set_transition_priority_and_eqn(transition_idx,priority,transition_eqn)

func setup(transition_idx,priority,transition_eqn)->void:
	self.transition_idx=transition_idx
	self.priority=priority
	self.transition_eqn=transition_eqn
	$MarginContainer/VBoxContainer/PriorityHBox/PriorityLineEdit.text = str(priority)
	$MarginContainer/VBoxContainer/TransEqnHBox/TransitionEqnLineEdit.text=transition_eqn
	$MarginContainer/VBoxContainer/PlsValidMsg.hide()

func _on_Accept_pressed() -> void:
	# TODO: Add input sanitization
	emit_signal("set_transition_priority_and_eqn",transition_idx,int($MarginContainer/VBoxContainer/PriorityHBox/PriorityLineEdit.text),$MarginContainer/VBoxContainer/TransEqnHBox/TransitionEqnLineEdit.text)
	hide()


func _on_Cancel_pressed() -> void:
	hide()
