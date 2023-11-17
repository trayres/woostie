extends Node2D

var control_points := []
var mouse_detect_head : bool
var mouse_detect_tail : bool

var dragging_head : bool
var dragging_tail : bool
var last_mouse_pos : Vector2
var is_head_connected : bool
var is_tail_connected : bool
var connected_head_state 
var connected_tail_state 

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("transitions")
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func setup(head_glbl_pos,tail_glbl_pos):
	$Head.global_position = head_glbl_pos
	$"Head-MouseDetect".global_position = head_glbl_pos
	$Tail.global_position = tail_glbl_pos
	$"Tail-MouseDetect".global_position = tail_glbl_pos
	# TODO: Later come back and add head positioning
#	$HeadControl.global_position = head_glbl_pos + Vector2(25,0)
#	$TailControl.global_position = tail_glbl_pos + Vector2(-25,0)

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
	# Draw the line from head to tail
	draw_line(to_local($Head.global_position),to_local($Tail.global_position),Color(0.88,0.22,0.22),3)
	# Draw head if the mouse is nearby
	if mouse_detect_head and not is_head_connected:
		draw_circle(to_local($Head.global_position),8.00,Color(0,0.22,0.88))
	if mouse_detect_tail and not is_tail_connected:
		draw_circle(to_local($"Tail".global_position),8.00,Color(0,0.22,0.88))

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
		self.get_viewport().set_input_as_handled()
	if Input.is_action_just_pressed("click") and mouse_detect_tail:
		dragging_tail = true
		last_mouse_pos = get_global_mouse_position()
		self.get_viewport().set_input_as_handled()
	if Input.is_action_just_released("click"):
		dragging_head = false
		dragging_tail = false
	if event is InputEventMouseMotion and (dragging_head or dragging_tail):
		var new_mouse_pos = _mouse_moved(get_global_mouse_position())
		var offset_delta = new_mouse_pos - last_mouse_pos
		if dragging_head:
			$Head.position += offset_delta
			$"Head-MouseDetect".position = $Head.position			
		elif dragging_tail:
			$Tail.position += offset_delta
			$"Tail-MouseDetect".position = $Tail.position
		last_mouse_pos = new_mouse_pos
		self.get_viewport().set_input_as_handled()
		queue_redraw()

func _on_head_connected_state_moved(offset_delta):
	$Head.position += offset_delta
	$"Head-MouseDetect".position = $Head.position
	queue_redraw()
	
func _on_tail_connected_state_moved(offset_delta):
	$Tail.position += offset_delta
	$"Tail-MouseDetect".position = $Tail.position
	queue_redraw()	
	
func _mouse_moved(global_position : Vector2)->Vector2:
	SignalBus.mouse_pos_update.emit(global_position)
	return global_position	
