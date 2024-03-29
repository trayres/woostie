extends KinematicBody2D

var               node_idx : int # 0 is head, 1 is pt 1, 2 is pt 2, 3 is tail
var                 radius : float = 4.0
var               dragging : bool = false
var        mouse_in_anchor : bool = false
var     force_show_anchors : bool = false
var start_position_of_drag : Vector2

var attached_state  : KinematicBody2D = null

var get_transition_idx_ref

#########
# Signals
# Detach is issued when a transition anchor is moved in such a way as to indicate
# that the user would like to detach it from a state.
signal detach(detach_id)
signal move(node_idx,start_position_of_drag,final_position_of_drag) # This is the final "move" event
# I'm going to take a second to talk about this. We don't need every move of the transition anchors
# to be broadcast up - the user doesn't want to 'undo' moving every single pixel of something they drag.
# However, we DO need that information "higher" up the hierarchy - because that's the signal to redraw the curve.
signal need_redraw()

func _ready() -> void:
	add_to_group("Kinetic State Anchor Head")

func _draw():
	if attached_state==null:
		draw_circle(Vector2(0,0), radius, Color( 0.77, 0.22, 0.0, 1 ))
	elif  mouse_in_anchor or force_show_anchors:
		draw_circle(Vector2(0,0), radius, Color(0.22,0.77,0.22))
	else:
		pass
		
func _process(delta: float) -> void:
	if (mouse_in_anchor && Input.is_action_just_pressed("left_click")):
		dragging = true
		start_position_of_drag = self.global_position
	if (dragging && Input.is_action_pressed("left_click")):
		var final_pos : Vector2 = get_global_mouse_position()
		var rel_vec: Vector2 = final_pos - position	
		var will_collide : bool = test_move(Transform2D(transform), rel_vec, true)
		if not will_collide:
			#position += rel_vec
			move_head(rel_vec)
			emit_signal("need_redraw")
			if attached_state != null:
				attached_state.transition_anchors_head.erase(self)
				attached_state = null
				emit_signal("detach",node_idx) # send node_idx as the detach_id, must be handled by Transition object
				update()
		if will_collide and attached_state == null:
			var collision : KinematicCollision2D = move_and_collide(rel_vec)
			emit_signal("need_redraw")
			if collision != null:
				var collider = collision.collider
				if collider.is_in_group("Kinetic State"):
					attached_state = collider
					update()
					if not collider.transition_anchors_head.has(self):
						collider.transition_anchors_head.append(self)
	else:
		if dragging: # We're done dragging, so emit the final "we moved" signal
			emit_signal("move",node_idx,start_position_of_drag,self.global_position)
		dragging = false

func _on_Head_mouse_entered() -> void:
	mouse_in_anchor = true
	update()

func _on_Head_mouse_exited() -> void:
	mouse_in_anchor = false
	update()
	
func move_head(rel_vec) -> void:
	position += rel_vec
	emit_signal("need_redraw")
	get_node("../HeadControl").position += rel_vec
	update()
	
func _need_update() -> void:
	emit_signal("need_redraw")
	update()

func get_transition_idx()->int:
	return get_transition_idx_ref.call_func()
