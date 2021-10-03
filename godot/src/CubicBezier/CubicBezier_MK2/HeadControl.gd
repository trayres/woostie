extends KinematicBody2D

var transition_idx  : int # The identifier for the transition
var node_idx : int # 0 is head, 1 is pt 1, 2 is pt 2, 3 is tail
var          radius : float = 10.0
var        dragging : bool = false
var mouse_in_anchor : bool = false
var force_show_anchors : bool = false
var start_position_of_drag : Vector2

#########
# Signals
# Detach is issued when a transition anchor is moved in such a way as to indicate
# that the user would like to detach it from a state.
signal move(node_idx,start_position_of_drag,final_position_of_drag)
signal need_redraw()

func _ready() -> void:
	add_to_group("HeadControl")

func _draw():
	draw_circle(Vector2(0,0),10.0,Color(0.22,0.22,0.77))
	
func _process(delta: float) -> void:
	if (mouse_in_anchor && Input.is_action_just_pressed("left_click")):
		dragging = true
		start_position_of_drag = self.global_position	
	if (dragging && Input.is_action_pressed("left_click")):
		var final_pos : Vector2 = get_global_mouse_position()
		var rel_vec: Vector2 = final_pos - position	
		var will_collide : bool = test_move(Transform2D(transform), rel_vec, true) # was final_pos
		if not will_collide:
			position += rel_vec
			emit_signal("need_redraw")
		if will_collide:
			pass
	else:
		if dragging:
			emit_signal("move",node_idx,start_position_of_drag,self.global_position)
		dragging = false
				
func _on_HeadControl_mouse_entered() -> void:
	mouse_in_anchor = true

func _on_HeadControl_mouse_exited() -> void:
	mouse_in_anchor = false
