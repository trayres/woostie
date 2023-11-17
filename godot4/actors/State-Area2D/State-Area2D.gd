extends Area2D

var mouse_in_state : bool
var mouse_in_label : bool
var mouse_in_label_cnt : int
var mouse_in_label_timer_running : bool = false
var dragging : bool
var dragging_label : bool
var last_mouse_pos : Vector2
var connected_heads := []
var connected_tails := []
var draw_statename_line : bool = false

var mouse_in_label_timer : Timer
var idx : int
var is_reset_state : bool = false

signal state_moved(offset_delta)
#signal mouse_pos_update(global_position : Vector2)

# Called when the node enters the scene tree for the first time.
func _ready():
	# Add this object to the correct group
	add_to_group("states")
	
func setup(idx,glbl_pos):
	self.idx = idx
	global_position = glbl_pos
	$MarginContainer/StateName.text="State_"+str(idx)
	

# Attempting to use unhandled_input and set_input_as_handled
# to account for overlapping items
#func _input(event):
#	if Input.is_action_just_pressed("click") and mouse_in:
#		dragging = true
#		last_mouse_pos = get_global_mouse_position()
#	if Input.is_action_just_released("click"):
#		dragging = false	
#	if event is InputEventMouseMotion and dragging:
#		var new_mouse_pos = get_global_mouse_position()
#		var offset_delta = new_mouse_pos - last_mouse_pos
#		position += offset_delta
#		last_mouse_pos = new_mouse_pos
		
func _unhandled_input(event):
	if 	Input.is_action_just_pressed("click") and mouse_in_state and not mouse_in_label:
		dragging = true
		last_mouse_pos = get_global_mouse_position()
		# testing 20231106		
		#self.get_viewport().set_input_as_handled()
	if Input.is_action_just_released("click"):
		dragging = false
		dragging_label = false
		draw_statename_line = false
		$MarginContainer/StateName.release_focus()
		queue_redraw()
	if event is InputEventMouseMotion and dragging:
		#var new_mouse_pos = get_global_mouse_position()
		#var new_mouse_pos = _mouse_moved(get_global_mouse_position())
		var new_mouse_pos = SignalBus._mouse_moved(get_global_mouse_position())
		var offset_delta = new_mouse_pos - last_mouse_pos
		position += offset_delta
		emit_signal("state_moved",offset_delta) #anybody who is connected, better move with me!
		last_mouse_pos = new_mouse_pos
		# testing 20231106
		#self.get_viewport().set_input_as_handled()
	
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
		#last_mouse_pos = new_mouse_pos	

func _draw():
	draw_circle(Vector2(0,0),50.0,Color(0.222,0.6718,0.6757))
	#draw_arc(center: Vector2, radius: float, start_angle: float, end_angle: float, point_count: int, color: Color, width: float = -1.0, antialiased: bool = false
	draw_arc(Vector2(0,0),50.0,0,0,36,Color.BLACK,1.5,true)
	if draw_statename_line and dragging_label:
		#print("draw_statename_line",draw_statename_line)
		draw_line(to_local(self.global_position),to_local($MarginContainer/StateName.global_position),Color.BLACK,1.5,true)

func _on_mouse_entered():
	mouse_in_state = true
	SignalBus.mouse_over_state.emit(idx)
#	print("mouse_in_state:",mouse_in_state)


func _on_mouse_exited():
	mouse_in_state = false
	SignalBus.mouse_left_state.emit(idx)
#	print("mouse_in_state:",mouse_in_state)
	
#func _mouse_moved(global_position : Vector2)->Vector2:
#	SignalBus.mouse_pos_update.emit(global_position)
#	return global_position

func _on_state_name_line_edit_mouse_entered():
	mouse_in_label = true
#	print("mouse_in_label:",mouse_in_label)


func _on_state_name_line_edit_mouse_exited():
	mouse_in_label = false
#	print("mouse_in_label:",mouse_in_label)

func _on_state_name_line_edit_text_submitted(new_text):
	$MarginContainer/StateName.release_focus()


func _on_state_name_gui_input(event):
	if Input.is_action_just_pressed("click") and mouse_in_label:
		if not mouse_in_label_timer_running:
#			print("mouse_in_label_timer_running",mouse_in_label_timer_running)
			#$Timer.start(.2)
			mouse_in_label_timer = Timer.new()
			add_child(mouse_in_label_timer)
			mouse_in_label_timer.timeout.connect(mouse_label_timer_timeout)
			mouse_in_label_timer.one_shot = true
			mouse_in_label_timer_running = true
			mouse_in_label_timer.start(0.2)
			mouse_in_label_cnt = 1
		else : 
#			print("mouse_in_label_timer_running",mouse_in_label_timer_running)
			mouse_in_label_cnt += 1
	if Input.is_action_just_released("click"):
		dragging_label = false
	if event is InputEventMouseMotion and dragging_label:
		#var new_mouse_pos = _mouse_moved(get_global_mouse_position())
		var new_mouse_pos = SignalBus._mouse_moved(get_global_mouse_position())
		var offset_delta = new_mouse_pos - last_mouse_pos
		$MarginContainer/StateName.position += offset_delta
		last_mouse_pos = new_mouse_pos
		# testing 20231106
		#self.get_viewport().set_input_as_handled()

func mouse_label_timer_timeout():
#	print("TIMEOUT")
	mouse_in_label_timer_running = false
#	print("mouse_in_label_cnt",mouse_in_label_cnt)
#	print("mouse_in_label_timer_running",mouse_in_label_timer_running)

	if mouse_in_label_cnt==2:
		$MarginContainer/StateName.release_focus()
		dragging_label = true
#		print("dragging_label: ",dragging_label)
		#last_mouse_pos = _mouse_moved(get_global_mouse_position())
		last_mouse_pos = SignalBus._mouse_moved(get_global_mouse_position())
	mouse_in_label_cnt = 0
	mouse_in_label_timer.queue_free()


func _on_timer_timeout():
	if dragging_label:
		#print("timer timeout, draw_statename_line: ",draw_statename_line)
		draw_statename_line = not draw_statename_line
		queue_redraw()
	elif not dragging_label:
		draw_statename_line = false
		queue_redraw()

func get_state_name()->String:
	return $MarginContainer/StateName.text	
func get_state_idx()->int:
	return idx
