extends Node2D
var transition_idx  : int # The identifier for the transition
onready var curve = Curve2D.new()
onready var curve_pts
var transition_is_selected = false
onready var mouse_is_near = false

# TODO: Fill in placeholders
signal move_transition_anchor(transition_idx, node_idx, start_position, final_position)
signal change_transition_properties # Emitted on double click

func _ready():
		var p0_in = Vector2.ZERO # This isn't used for the first curve
		var p0_vertex = $Head.position # First point of first line segment
		var p0_out = $HeadControl.position - $Head.position # Second point of first line segment
		var p1_in =  $TailControl.position - $Tail.position  # First point of second line segment
		var p1_vertex =  $Tail.position # Second point of second line segment
		var p1_out = Vector2.ZERO # Not used unless another curve is added
		curve.add_point(p0_vertex, p0_in, p0_out)
		curve.add_point(p1_vertex, p1_in, p1_out)	
	
func _draw() -> void:
	if transition_is_selected == true:
		draw_line($P0.position,$P1.position,Color.black,2.0)
		draw_line($P2.position,$P3.position,Color.black,2.0)
	curve_pts = curve.tessellate()
	var line_color
	if mouse_is_near == true or transition_is_selected == true:
		line_color =  Color( 0, 0, 1, 1 )
	else:
		line_color = Color( 0, 0, 0, 1 )
	# Draw the line, using the color based on if the mouse is near
	for idx in len(curve_pts)-1:
		draw_line(curve_pts[idx],curve_pts[idx+1],line_color,5.0,true)
		
	# If the line is selected, draw its control points
	if transition_is_selected == true:
		draw_circle($Head.position,5.0,Color(1.0,0,0,1.0))
		draw_circle($HeadControl.position,5.0,Color(0,1.0,0,1.0))
		draw_circle($TailControl.position,5.0,Color(0,1.0,0,1.0))
		draw_circle($Tail.position,5.0,Color(1.0,0,0,1.0))

	draw_arrowhead(30, 30, $HeadControl.position,$Head.position) 		
func _process(delta):
	if get_distance_to_curve() < 8.0:
		mouse_is_near = true
		update()
	else:
		mouse_is_near = false
		update()

#func setup(transition_idx,head_pos,head_ctrl_pos,tail_ctrl_pos,tail_pos):
func setup(transition_idx,node_positions):
	self.transition_idx = transition_idx
	$Head.global_position = node_positions[0]
	$Head.node_idx = 0
	$HeadControl.global_position=node_positions[1]
	$HeadControl.node_idx = 1
	$TailControl.global_position=node_positions[2]
	$TailControl.node_idx = 2
	$Tail.global_position=node_positions[3]
	$Tail.node_idx = 3
	# Position the TransitionEquation on the midpoint
	$TransitionEquation.text = "A+B"
	
	# Position the PriorityLabel right where the Tail node is
	$Tail/PriorityLabel.text = str(0)
	$Tail/PriorityLabel.set_global_position(node_positions[3])
# This function is so that nodes can be moved externally (via the command pattern)
# This function is so that nodes can be moved externally (via the command pattern)
func move_node(idx,final_position)->void:
	for achild in get_children():
		if achild.idx==idx:
			achild.position = final_position




func set_force_show_transition_anchors()->void:
	pass
func clear_force_show_transition_anchors()->void:
	pass

func get_distance_to_curve():
	var curve_pts = curve.tessellate()
	var mouse_xy_current = get_global_mouse_position()
	var it = 0
	var distance
	for idx in len(curve_pts)-1:
		if it == 0:
			distance = pDistance(mouse_xy_current.x,mouse_xy_current.y,curve_pts[idx].x,curve_pts[idx].y,curve_pts[idx+1].x,curve_pts[idx+1].y)
		else:
			distance = min(distance,pDistance(mouse_xy_current.x,mouse_xy_current.y,curve_pts[idx].x,curve_pts[idx].y,curve_pts[idx+1].x,curve_pts[idx+1].y))
		it += 1
	return distance
	
# References
# http://paulbourke.net/geometry/pointlineplane/
# https://stackoverflow.com/questions/849211/shortest-distance-between-a-point-and-a-line-segment

func pDistance(x,y,x1,y1,x2,y2):
	var A = x - x1;
	var B = y - y1;
	var C = x2 - x1;
	var D = y2 - y1;

	var dot = A * C + B * D;
	var len_sq = C * C + D * D;
	var param = -1;
	if (len_sq != 0): #in case of 0 length line
		param = dot / len_sq;

	var xx
	var yy

	if (param < 0):
		xx = x1
		yy = y1
		
	elif (param > 1) :
		xx = x2
		yy = y2
	else:
		xx = x1 + param * C
		yy = y1 + param * D

	var dx = x - xx;
	var dy = y - yy;
	return sqrt(dx * dx + dy * dy)
	
func draw_arrowhead(length, width_degrees, pstart,pend):
	var ln = length*Vector2(pstart - pend).normalized()
	var pa = $Head.position + ln.rotated(deg2rad(width_degrees))
	var pb = $Head.position + ln.rotated(deg2rad(-width_degrees))
	#draw_line($P3.position,pa,Color(.7.7.7,1))
	draw_line($Head.position,pa,Color(.7,.7,.7,1),3)
	draw_line($Head.position,pb,Color(.7,.7,.7,1),3)

func update_curve():
	curve.set_point_position(0,$Head.position)
	curve.set_point_out(0,$HeadControl.position - $Head.position)
	curve.set_point_position(1,$Tail.position)
	curve.set_point_in(1,$TailControl.position - $Tail.position)	

# The 'need redraw' signals indicate something was moved via a drag
# There are 4 of them, one for each node.
func _on_Head_need_redraw() -> void:
	update_curve()
	update()
	print("Head update")
	
func _on_HeadControl_need_redraw() -> void:
	update_curve()
	update()	
	
func _on_TailControl_need_redraw() -> void:
	update_curve()
	update()
	
func _on_Tail_need_redraw() -> void:
	update_curve()
	update()
	
func _on_Head_move(node_idx, start_position_of_drag, final_position_of_drag) -> void:
	# Pass this up to the controller
	emit_signal("move_transition_anchor",transition_idx,node_idx,start_position_of_drag,final_position_of_drag)
	update_curve()
	update()

func _on_HeadControl_move(node_idx, start_position_of_drag, final_position_of_drag) -> void:
	emit_signal("move_transition_anchor",transition_idx,node_idx,start_position_of_drag,final_position_of_drag)
	update_curve()
	update()

func _on_TailControl_move(node_idx, start_position_of_drag, final_position_of_drag) -> void:
	emit_signal("move_transition_anchor",transition_idx,node_idx,start_position_of_drag,final_position_of_drag)
	update_curve()
	update()
	
func _on_Tail_move(node_idx, start_position_of_drag, final_position_of_drag) -> void:
	emit_signal("move_transition_anchor",transition_idx,node_idx,start_position_of_drag,final_position_of_drag)
	update_curve()
	update()


