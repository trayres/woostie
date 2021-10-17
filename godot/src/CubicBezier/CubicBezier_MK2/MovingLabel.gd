extends Label

var mouse_in_label=false
var dragging : bool = false

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if (mouse_in_label && Input.is_action_just_pressed("left_click")):
		dragging = true	
		
	if (dragging && Input.is_action_pressed("left_click")):
		var final_pos : Vector2 = get_global_mouse_position()
		var rel_vec: Vector2 = final_pos -  rect_global_position
		rect_global_position += rel_vec
	else:
		if dragging:
			print("Emitting drag signal of label")
			#emit_signal("move",self,start_position_of_drag,global_position)
		dragging = false			


func _on_Label_mouse_entered() -> void:
	mouse_in_label = true
	print("Mouse in label")

func _on_Label_mouse_exited() -> void:
	mouse_in_label = false
	print("Mouse exit label")
