extends Node2D

onready var curve = Curve2D.new()
onready var curve_pts
var pts = []
onready var mouse_xy_current
var pt_selected = -1
onready var mouse_is_near = false
var mouse_in_priority_label = false
var mouse_in_transitionequation_label = false
var transition_is_selected = false
var drag_priority_textedit = false
var drag_transitionequation_textedit = false

var pt_selected_p0 = false
var pt_selected_p1 = false
var pt_selected_p2 = false
var pt_selected_p3 = false

func _ready():
	# https://docs.godotengine.org/en/3.2/tutorials/math/beziers_and_curves.html
	var p0_in = Vector2.ZERO # This isn't used for the first curve
	var p0_vertex = $P0.position # First point of first line segment
	var p0_out = $P1.position - $P0.position # Second point of first line segment
	var p1_in =  $P2.position - $P3.position  # First point of second line segment
	var p1_vertex =  $P3.position # Second point of second line segment
	var p1_out = Vector2.ZERO # Not used unless another curve is added
	curve.add_point(p0_vertex, p0_in, p0_out)
	curve.add_point(p1_vertex, p1_in, p1_out)
	pts.append($P0)
	pts.append($P1)
	pts.append($P2)
	pts.append($P3)
	#get_mouse_pt()
	
func _process(delta):
	#get_mouse_pt()
#	update_hud_xy_loc()
	if get_distance_to_curve() < 8.0:
		mouse_is_near = true
		update()
	else:
		mouse_is_near = false
		update()
		
func _draw():
		# If the transition is selected, draw control handle lines
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
		draw_circle($P0.position,5.0,Color(1.0,0,0,1.0))
		draw_circle($P1.position,5.0,Color(0,1.0,0,1.0))
		draw_circle($P2.position,5.0,Color(0,1.0,0,1.0))
		draw_circle($P3.position,5.0,Color(1.0,0,0,1.0))

	draw_arrowhead(30, 30, $P2.position,$P3.position) 
	
func _input(event):
	var mouse_near_pt
   # Mouse in viewport coordinates.
	if event is InputEventMouseButton:
		# print("Mouse Click/Unclick at: ", event.position)
		if event.is_pressed() and not event.doubleclick:
			if (mouse_near_pt() != -1):
				pt_selected = mouse_near_pt()
			elif get_distance_to_curve() > 8.0:
				transition_is_selected = false
			elif get_distance_to_curve() <= 8.0:
				transition_is_selected = true
				
			if not mouse_in_priority_label:
				$P0/Priority.release_focus()
				drag_priority_textedit = false
			if not mouse_in_transitionequation_label:
				drag_transitionequation_textedit = false
		elif event.doubleclick == true and  mouse_in_priority_label == false:
			drag_priority_textedit = false
			#if get_distance_to_curve() <= 8.0:
			#	transition_is_selected = true
		elif event.doubleclick == true and mouse_in_priority_label == true:
			drag_priority_textedit = true
		else:
			pt_selected = -1
			
		if event.doubleclick == true and mouse_in_transitionequation_label == true:
			drag_transitionequation_textedit = true
			
	
	elif event is InputEventMouseMotion:
		get_mouse_pt()
		set_mouse_flags()
		if pt_selected != -1: # we are dragging a point
			pts[pt_selected].set_position(mouse_xy_current)
			update_curve()
			#update_transitionequation_position()
			update_midpoint()
			update()
		if drag_priority_textedit == true:
			#$P0/Priority.rect_position = mouse_xy_current - $P0/Priority.rect_position
			$P0/Priority.rect_global_position = mouse_xy_current + Vector2(5,5)
		#else: # not dragging a point; see if we need to highlight the line
		#	get_distance_to_curve()
		
		if drag_transitionequation_textedit == true:
			$Midpoint/TransitionEquation.rect_global_position = mouse_xy_current + Vector2(5,5)
	
#	if event is InputEventKey:
#		#print(OS.get_scancode_string(event.scancode))
#		var _len = $P0/Priority.text.length()
#		if direct_keypresses_to_priority == true and event.is_pressed() == true and not event.is_echo():
#			if event.scancode == KEY_BACKSPACE:
#				$P0/Priority.text = $P0/Priority.text.substr(0,_len - 1)
#			elif event.scancode == KEY_SPACE or event.scancode == KEY_TAB or event.scancode == KEY_ENTER:
#				pass
#			else:
#				$P0/Priority.text = $P0/Priority.text + OS.get_scancode_string(event.scancode) 
#			print(OS.get_scancode_string(event.scancode))
		

func update_curve():
	curve.set_point_position(0,$P0.position)
	curve.set_point_out(0,$P1.position - $P0.position)
	curve.set_point_position(1,$P3.position)
	curve.set_point_in(1,$P2.position - $P3.position)
	
func get_mouse_pt():
	mouse_xy_current = get_global_mouse_position()
	
	
#func update_hud_xy_loc():
#	$HUD/VBoxContainer/HBoxContainer/Label.text = "("+str(mouse_xy_current.x)+", "+str(mouse_xy_current.y)+")"
	
	


func draw_arrowhead(length, width_degrees, pstart,pend):
	var ln = length*Vector2(pstart - pend).normalized()
	var pa = $P3.position + ln.rotated(deg2rad(width_degrees))
	var pb = $P3.position + ln.rotated(deg2rad(-width_degrees))
	#draw_line($P3.position,pa,Color(.7.7.7,1))
	draw_line($P3.position,pa,Color(.7,.7,.7,1),3)
	draw_line($P3.position,pb,Color(.7,.7,.7,1),3)
	
func get_distance_to_curve():
	var curve_pts = curve.tessellate()
	var it = 0
	var distance
	for idx in len(curve_pts)-1:
		if it == 0:
			distance = pDistance(mouse_xy_current.x,mouse_xy_current.y,curve_pts[idx].x,curve_pts[idx].y,curve_pts[idx+1].x,curve_pts[idx+1].y)
		else:
			distance = min(distance,pDistance(mouse_xy_current.x,mouse_xy_current.y,curve_pts[idx].x,curve_pts[idx].y,curve_pts[idx+1].x,curve_pts[idx+1].y))
		it += 1
	return distance

func mouse_near_pt():
	# If the mouse is near a control point, indicate that by returning that point's index.
	# Otherwise return -1.
	var result = -1
	var idx = 0
	for pt in pts:
		if sqrt( pow (pt.position.x - mouse_xy_current.x,2.0) + pow(pt.position.y - mouse_xy_current.y,2.0) ) <= 5:
			# print("HIT AT PT " + str(pt))
			result = idx
			break
		idx += 1
	return result
	
			

			
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


func _on_LineEdit_text_entered(new_text):
	pass # Replace with function body.


func _on_Priority_mouse_entered():
	mouse_in_priority_label = true # Replace with function body.
	print("Mouse in priority label")


func _on_Priority_mouse_exited():
	mouse_in_priority_label = false # Replace with function body.
	print("Mouse not in priority label")
	
#func update_transitionequation_position():
#	var curve_pts = curve.tessellate()
#	var curve_pts_len = len(curve_pts)
#	$Midpoint/TransitionEquation.rect_global_position = (curve_pts[curve_pts_len/2]) 
#	print(curve_pts)
	


func _on_TransitionEquation_mouse_entered():
	mouse_in_transitionequation_label = true


func _on_TransitionEquation_mouse_exited():
	mouse_in_transitionequation_label = false
	
# These flags are required by external controllers/monitors
func set_mouse_flags():
	if pt_selected == 0:
		pt_selected_p0 = true
	elif pt_selected == 1:
		pt_selected_p1 = true
	elif pt_selected == 2:
		pt_selected_p2 = true
	elif pt_selected == 3:
		pt_selected_p3 = true
	else:
		pt_selected_p0 = false
		pt_selected_p1 = false
		pt_selected_p2 = false
		pt_selected_p3 = false
		
	
func update_midpoint():
	print("Midpoint:"+str(curve_pts[(len(curve_pts)-1)/2]))
	$Midpoint/TransitionEquation.rect_global_position = curve_pts[(len(curve_pts)-1)/2]
	#rect_global_position(curve_pts[len(curve_pts)/2])
