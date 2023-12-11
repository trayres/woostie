extends Node2D

@onready var curve_points
var mouse_detect_head : bool
var mouse_detect_headcontrol : bool
var mouse_detect_tail : bool
var mouse_detect_tailcontrol : bool
var dragging_head : bool
var dragging_headcontrol : bool
var dragging_tail : bool
var dragging_tailcontrol : bool
var dragging_prioritylabel : bool = false
var mouse_in_prioritylabel : bool
var last_mouse_pos : Vector2
var last_head_rotation
var last_tail_rotation
var is_head_connected : bool
var is_tail_connected : bool
var connected_head_state 
var connected_tail_state
var head_rotated : bool = false
var tail_rotated : bool = false
@onready var mouse_is_near = false
@onready var curve = Curve2D.new()

var transition_is_selected : bool = false
var mouse_in_prioritylabel_timer_running : bool
var mouse_in_prioritylabel_timer : Timer
var mouse_in_prioritylabel_cnt : int

# The below group is put together to make the transitiondataobject
var priority : int = 0
var transition_eqn : String = "1"
var default_transition_eqn : String = "1"
var transition_eqn_visibility : int = GLOBAL.VISIBILITY.ONLY_NON_DEFAULT
var transition_idx : int = 0

func _ready():
	add_to_group("transitions")
	var p0_in = Vector2.ZERO # This isn't used for the first curve
	var p0_vertex = $Head.global_position # First point of first line segment
	var p0_out = $Head/HeadControl.global_position - $Head.global_position # Second point of first line segment
	var p1_in =  $Tail/TailControl.global_position - $Tail.global_position  # First point of second line segment
	var p1_vertex =  $Tail.global_position # Second point of second line segment
	var p1_out = Vector2.ZERO # Not used unless another curve is added
	curve.add_point(p0_vertex, p0_in, p0_out)
	curve.add_point(p1_vertex, p1_in, p1_out)	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if get_distance_to_curve() < 8.0:
		mouse_is_near = true
		queue_redraw()
	else:
		mouse_is_near = false
		queue_redraw()

func setup(idx,head_glbl_pos,tail_glbl_pos):
	self.transition_idx = idx
	$Head.global_position = head_glbl_pos
	$"Head-MouseDetect".global_position = head_glbl_pos
	$"Head/HeadControl".global_position = head_glbl_pos + Vector2(0,-40)
	#$"Head/HeadControl".global_position +=  Vector2(0,-40)
#	print("head rotation:",$Head.rotation)
#	$Head.rotation = PI/2
#	print("head rotation 1:",$Head.rotation)
	
	$Tail.global_position = tail_glbl_pos
	$"Tail-MouseDetect".global_position = tail_glbl_pos
	$"Tail/TailControl".global_position = tail_glbl_pos + Vector2(0,-40)
	# TODO: Later come back and add head positioning
#	$HeadControl.global_position = head_glbl_pos + Vector2(25,0)
#	$TailControl.global_position = tail_glbl_pos + Vector2(-25,0)

	# Position the priority label
	$PriorityMarginContainer.global_position = tail_glbl_pos + Vector2(10,0)
	
	# Setup the visibility of the priority label
	if is_priority_visible():
		$PriorityMarginContainer.visible = true
	else:
		$PriorityMarginContainer.visible = false
#	$PriorityMarginContainer/Priority
func _on_head_mouse_detect_mouse_entered():
	mouse_detect_head = true
	print("mouse_detect_head true")
	queue_redraw()


func _on_head_mouse_detect_mouse_exited():
	mouse_detect_head = false
	print("mouse_detect_head false")
	queue_redraw()
	
func _on_tail_mouse_detect_mouse_entered():
	mouse_detect_tail = true
	queue_redraw()

func _on_tail_mouse_detect_mouse_exited():
	mouse_detect_tail = false
	queue_redraw()

func _on_head_area_entered(area):
	if not is_head_connected and area.is_in_group("states"):
		connected_head_state = area
		is_head_connected = true
		area.connect("state_moved",_on_head_connected_state_moved)

func _on_head_area_exited(area):
	if is_head_connected and area==connected_head_state:
		is_head_connected = false
		#area.disconnect(area)
		area.state_moved.disconnect(_on_head_connected_state_moved)

func _on_tail_area_entered(area):
	if not is_tail_connected and area.is_in_group("states"):
		connected_tail_state = area
		is_tail_connected = true
		area.connect("state_moved",_on_tail_connected_state_moved)


func _on_tail_area_exited(area):
	if is_tail_connected and area==connected_tail_state:
		is_tail_connected = false
		area.state_moved.disconnect(_on_tail_connected_state_moved)

func _draw():
#	# Draw the line from head to tail
#	draw_line(to_local($Head.global_position),to_local($Tail.global_position),Color(0.88,0.22,0.22),3)
	# Draw head if the mouse is nearby
	if mouse_detect_head and not is_head_connected:
		draw_circle(to_local($Head.global_position),8.00,Color(0,0.22,0.88))
	if mouse_detect_tail and not is_tail_connected:
		draw_circle(to_local($"Tail".global_position),8.00,Color(0,0.22,0.88))
	
	# TODO: This looks tacky; redo this. Good enough placeholder though
	if transition_is_selected:
		draw_circle(to_local($Head/HeadControl.global_position),8.00,Color(.88,.22,.22))
		draw_circle(to_local($Tail/TailControl.global_position),8.00,Color(.88,.88,.88))
	curve_points = curve.tessellate()
	var line_color
	if mouse_is_near or transition_is_selected:
		line_color =  Color( 0, 0, 1, 1 )
	else:
		line_color = Color( 0, 0, 0, 1 )
	# Draw the line, using the color based on if the mouse is near
	for idx in len(curve_points)-1:
		draw_line(curve_points[idx],curve_points[idx+1],line_color,2.5,true)	
		
	draw_arrowhead(16, 30, $Head/HeadControl.global_position,$Head.global_position)		
#	if mouse_detect_headcontrol:
#		draw_circle(to_local($HeadControl.global_position),8.00,Color(.88,.22,.22))
#	if mouse_detect_tailcontrol:
#		draw_circle(to_local($TailControl.global_position),8.00,Color(.88,.88,.88))
#func _input(event):
#	if Input.is_action_just_pressed("click") and mouse_detect_head:
#		dragging_head = true
#		last_mouse_pos = get_global_mouse_position()
#	if Input.is_action_just_pressed("click") and mouse_detect_tail:
#		dragging_tail = true
#		last_mouse_pos = get_global_mouse_position()		
#	if Input.is_action_just_released("click"):
#		dragging_head = false
#		dragging_tail = false
#	if event is InputEventMouseMotion and (dragging_head or dragging_tail):
#		var new_mouse_pos = get_global_mouse_position()
#		var offset_delta = new_mouse_pos - last_mouse_pos
#		if dragging_head:
#			$Head.position += offset_delta
#			$"Head-MouseDetect".position = $Head.position			
#		elif dragging_tail:
#			$Tail.position += offset_delta
#			$"Tail-MouseDetect".position = $Tail.position
#		last_mouse_pos = new_mouse_pos
#		queue_redraw()			

func _unhandled_input(event):
	if Input.is_action_just_pressed("click") and mouse_detect_head:
		dragging_head = true
		last_mouse_pos = get_global_mouse_position()
		# testing 20231106
		self.get_viewport().set_input_as_handled()
		
	if Input.is_action_just_pressed("click") and mouse_detect_headcontrol:
		if !head_rotated:
			last_head_rotation = -PI/2
			head_rotated = true
		dragging_headcontrol = true
		last_mouse_pos = get_global_mouse_position()
		# testing 20231106
		self.get_viewport().set_input_as_handled()
	if Input.is_action_just_pressed("click") and mouse_detect_tailcontrol:
		if !tail_rotated:
			last_tail_rotation = -PI/2
			tail_rotated = true
		dragging_tailcontrol = true
		last_mouse_pos = get_global_mouse_position()
		# testing 20231106
		self.get_viewport().set_input_as_handled()		
		#print("dragging_tailcontrol true")
	if Input.is_action_just_pressed("click") and mouse_detect_tail:
		dragging_tail = true
		last_mouse_pos = get_global_mouse_position()
		# testing 20231106
		self.get_viewport().set_input_as_handled()
	if Input.is_action_just_pressed("click") and mouse_detect_tailcontrol:
		dragging_tailcontrol = true
		last_mouse_pos = get_global_mouse_position()
		# testing 20231106
		self.get_viewport().set_input_as_handled()	
		#print("dragging_tailcontrol true")
	if Input.is_action_just_pressed("click") and mouse_is_near and not transition_is_selected:
		transition_is_selected = true
		#print("transition_is_selected true _unhandled_input")
		# testing 20231106
		self.get_viewport().set_input_as_handled()
	if Input.is_action_just_pressed("click") and not mouse_is_near and transition_is_selected and not (dragging_head or dragging_tail or dragging_headcontrol or dragging_tailcontrol):
		transition_is_selected = false
		#print("transition_is_selected false _unhandled_input")
		# testing 20231106
		#self.get_viewport().set_input_as_handled()
#	if Input.is_action_just_pressed("click") and transition_is_selected and mouse_is_near and event.double_click():
#		print("DOUBLE CLICK")
	if event is InputEventMouseButton and transition_is_selected and mouse_is_near:
		if event.double_click:
			SignalBus.transition_options.emit(transition_idx)
	if Input.is_action_just_released("click"):
		dragging_head = false
		dragging_headcontrol = false
		dragging_tail = false
		dragging_tailcontrol = false
	if event is InputEventMouseMotion and (dragging_head or dragging_tail or dragging_headcontrol or dragging_tailcontrol):
		#var new_mouse_pos = _mouse_moved(get_global_mouse_position())
		var new_mouse_pos = SignalBus._mouse_moved(get_global_mouse_position())
		var offset_delta = new_mouse_pos - last_mouse_pos
		if dragging_head:
			$Head.position += offset_delta
			$"Head-MouseDetect".position = $Head.position
			update_curve()
			#$HeadControl.position = $Head.position + Vector2(0,-40)
		elif dragging_tail:
			$Tail.position += offset_delta
			$"Tail-MouseDetect".position = $Tail.position
			$PriorityMarginContainer.position += offset_delta
			update_curve()
			#$TailControl.position = $Tail.position + Vector2(0,-40)
		elif dragging_headcontrol:
			#var rotation = get_global_mouse_position().angle_to_point($Head.position)
			var new_rotation = (get_global_mouse_position()-$Head.global_position).angle()
			var rotation_delta = new_rotation - last_head_rotation
			$Head.rotation += rotation_delta 
			last_head_rotation = new_rotation
			update_curve()
			#$Head.set_rotation(rotation)
			# TODO: Rotation mechanics
			#print("rotation_delta:",rotation_delta)
		elif dragging_tailcontrol:
			var new_rotation = (get_global_mouse_position()-$Tail.global_position).angle()
			var rotation_delta = new_rotation - last_tail_rotation
			$Tail.rotation += rotation_delta 
			last_tail_rotation = new_rotation
			update_curve()
		last_mouse_pos = new_mouse_pos
		# testing 20231106
		self.get_viewport().set_input_as_handled()
		queue_redraw()

func _on_head_connected_state_moved(offset_delta):
	$Head.position += offset_delta
	$"Head-MouseDetect".position = $Head.position
	update_curve()
	queue_redraw()
	
func _on_tail_connected_state_moved(offset_delta):
	$Tail.position += offset_delta
	$"Tail-MouseDetect".position = $Tail.position
	$PriorityMarginContainer.position += offset_delta
	update_curve()
	queue_redraw()	
	
#func _mouse_moved(global_position : Vector2)->Vector2:
#	SignalBus.mouse_pos_update.emit(global_position)
#	return global_position	


func _on_head_control_mouse_entered():
	mouse_detect_headcontrol = true
	print("mouse_detect_headcontrol true")


func _on_head_control_mouse_exited():
	mouse_detect_headcontrol = false
	print("mouse_detect_headcontrol false")


func _on_tail_control_mouse_entered():
	mouse_detect_tailcontrol = true
	print("mouse_detect_tailcontrol true")
	queue_redraw()	


func _on_tail_control_mouse_exited():
	mouse_detect_tailcontrol = false
	print("mouse_detect_tailcontrol false")
	queue_redraw()	

func draw_arrowhead(length, width_degrees, pstart,pend):
	var ln = length*Vector2(pstart - pend).normalized()
	var pa = $Head.position + ln.rotated(deg_to_rad(width_degrees))
	var pb = $Head.position + ln.rotated(deg_to_rad(-width_degrees))
	#draw_line($P3.position,pa,Color(.7.7.7,1))
	draw_line($Head.position,pa,Color(.7,.7,.7,1),3)
	draw_line($Head.position,pb,Color(.7,.7,.7,1),3)

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

func get_distance_to_curve():
	#var curve_pts = curve.tessellate()
	var mouse_xy_current = get_global_mouse_position()
	var it = 0
	var distance
	for idx in len(curve_points)-1:
		if it == 0:
			distance = pDistance(mouse_xy_current.x,mouse_xy_current.y,curve_points[idx].x,curve_points[idx].y,curve_points[idx+1].x,curve_points[idx+1].y)
		else:
			distance = min(distance,pDistance(mouse_xy_current.x,mouse_xy_current.y,curve_points[idx].x,curve_points[idx].y,curve_points[idx+1].x,curve_points[idx+1].y))
		it += 1
	return distance
func update_curve():
	curve.set_point_position(0,$Head.global_position)
	curve.set_point_out(0,$Head/HeadControl.global_position - $Head.global_position)
	curve.set_point_position(1,$Tail.global_position)
	curve.set_point_in(1,$Tail/TailControl.global_position - $Tail.global_position)
	curve_points = curve.tessellate()
	queue_redraw()
			
func mouse_prioritylabel_timer_timeout():
	print("mouse_prioritylabel_timer_timeout was fired")
	mouse_in_prioritylabel_timer_running = false
	if mouse_in_prioritylabel_cnt==2:
		$PriorityMarginContainer/Priority.release_focus()
		dragging_prioritylabel = true
		last_mouse_pos = SignalBus._mouse_moved(get_global_mouse_position())
	mouse_in_prioritylabel_cnt = 0
	mouse_in_prioritylabel_timer.queue_free()


func _on_priority_mouse_entered():
	print("mouse_in_prioritylabel: ",mouse_in_prioritylabel)
	mouse_in_prioritylabel = true


func _on_priority_mouse_exited():
	print("mouse_in_prioritylabel: ",mouse_in_prioritylabel)
	mouse_in_prioritylabel = false


func _on_priority_gui_input(event):
	if Input.is_action_just_pressed("click") and mouse_in_prioritylabel:
		print("Input.is_action_just_pressed TEST TEST")
		if not mouse_in_prioritylabel_timer_running:
			mouse_in_prioritylabel_timer = Timer.new()
			add_child(mouse_in_prioritylabel_timer)
			mouse_in_prioritylabel_timer.timeout.connect(mouse_prioritylabel_timer_timeout)
			mouse_in_prioritylabel_timer.one_shot = true
			mouse_in_prioritylabel_timer_running = true
			mouse_in_prioritylabel_timer.start(0.2)
			mouse_in_prioritylabel_cnt = 1
		else: 
			mouse_in_prioritylabel_cnt += 1
	if Input.is_action_just_released("click"):
		dragging_prioritylabel = false
	if event is InputEventMouseMotion and dragging_prioritylabel:		
		var new_mouse_pos = SignalBus._mouse_moved(get_global_mouse_position())
		var offset_delta = new_mouse_pos - last_mouse_pos
		$PriorityMarginContainer/Priority.position += offset_delta
		last_mouse_pos = new_mouse_pos
		# testing 20231106
		#self.get_viewport().set_input_as_handled()		
func get_transition_object()->TransitionDataObject:
	var transition_info : TransitionDataObject = TransitionDataObject.new()
	transition_info.idx = self.idx
	if is_head_connected:
		transition_info.head_state_idx = connected_head_state.idx
	else:
		transition_info.head_state_idx = -1
	if is_tail_connected:
		transition_info.tail_state_idx = connected_tail_state.idx
	else:
		transition_info.tail_state_idx = -1
	transition_info.transition_eqn = [transition_eqn,default_transition_eqn,transition_eqn_visibility]
	return transition_info

func is_priority_visible()->bool:
	var isVisible : bool
	if transition_eqn_visibility==GLOBAL.VISIBILITY.ONLY_NON_DEFAULT and transition_eqn!=default_transition_eqn:
		isVisible = true
	elif transition_eqn_visibility==GLOBAL.VISIBILITY.YES:
		isVisible = true
	elif transition_eqn_visibility==GLOBAL.VISIBILITY.NO:
		isVisible = false
	return isVisible
