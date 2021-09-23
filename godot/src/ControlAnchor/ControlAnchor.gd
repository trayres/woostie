extends Area2D

var radius : float = 10.0
var mouse_in_anchor : bool = false
var idx            : int  = 0
var dragging : bool = false


func _on_ControlAnchor_mouse_entered() -> void:
	mouse_in_anchor = true
	print("Mouse in control anchor")
	
func _on_ControlAnchor_mouse_exited() -> void:
	mouse_in_anchor = false
	print("Mouse out of control anchor")
