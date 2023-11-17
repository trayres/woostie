extends Area2D

var mouse_in_hbar : bool
var mouse_in_left : bool
var mouse_in_right : bool
var dragging_h : bool # drag the whole horizontal thing
var dragging_left : bool
var dragging_right : bool
var attached_right : bool  # are we connected to anything on the right? 
var node_right 
var attached_left : bool # are we connected to anything on the right? 
var node_left
var last_mouse_pos : Vector2

# Called when the node enters the scene tree for the first time.
func _ready():
	$"Horiz Right MouseDetect/Horiz Right AreaDetect".add_to_group("connectors",true)
	$"Horiz Left MouseDetect/Horiz Left AreaDetect".add_to_group("connectors",true)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _unhandled_input(event):
	if 	Input.is_action_just_pressed("click") and mouse_in_left:
		dragging_left = true
		last_mouse_pos = get_global_mouse_position()
	if 	Input.is_action_just_pressed("click") and mouse_in_right:
		dragging_right = true
		last_mouse_pos = get_global_mouse_position()	
	if 	Input.is_action_just_pressed("click") and mouse_in_hbar:
		dragging_h = true
		last_mouse_pos = get_global_mouse_position()		
	if event is InputEventMouseMotion and dragging_left:
		Input.set_default_cursor_shape(Input.CURSOR_HSIZE)
		var new_mouse_pos = SignalBus._mouse_moved(get_global_mouse_position())
		var offset_delta = new_mouse_pos - last_mouse_pos
		offset_delta *= Vector2(1,0)	# Only the X direction	
		# Move the left side, but only by the offset amount
		$"Horiz Left MouseDetect".global_position += offset_delta
		var left_side_pos = $"Horiz Left MouseDetect/Horiz Left AreaDetect".global_position
		var right_side_pos = $"Horiz Right MouseDetect/Horiz Right AreaDetect".global_position
		# Set the size of the center
		var newRect : RectangleShape2D =  RectangleShape2D.new()
		newRect.size = Vector2(right_side_pos.x - left_side_pos.x,5)
		$CollisionShape2D.set_shape(newRect)
		# set the center in the middle of them
		$CollisionShape2D.global_position = (right_side_pos + left_side_pos) / 2.0
		
		# Remember we used the mouse pos, so let's reset that!
		last_mouse_pos = new_mouse_pos	
		queue_redraw()
	if event is InputEventMouseMotion and dragging_right:
		Input.set_default_cursor_shape(Input.CURSOR_HSIZE)
		var new_mouse_pos = SignalBus._mouse_moved(get_global_mouse_position())
		var offset_delta = new_mouse_pos - last_mouse_pos
		# Zero out the y 
		offset_delta *= Vector2(1,0)
		$"Horiz Right MouseDetect".position += offset_delta
		last_mouse_pos = new_mouse_pos
		queue_redraw()
	if event is InputEventMouseMotion and dragging_h:
		Input.set_default_cursor_shape(Input.CURSOR_DRAG)
		var new_mouse_pos = SignalBus._mouse_moved(get_global_mouse_position())
		var offset_delta = new_mouse_pos - last_mouse_pos
		$".".position += offset_delta
		last_mouse_pos = new_mouse_pos
		queue_redraw()		
	if Input.is_action_just_released("click"):
		Input.set_default_cursor_shape(Input.CURSOR_ARROW)
		dragging_left = false
		dragging_right = false
		dragging_h = false

func _draw():
	# Draw left
	var left_rect : Rect2
	left_rect = Rect2($"Horiz Left MouseDetect".position+Vector2(-4,-4),Vector2(8,8))
	draw_rect(left_rect,Color(0.88,0.33,0.33),true,1.5)
	# Draw right
	var right_rect : Rect2
	right_rect = Rect2($"Horiz Right MouseDetect".position+Vector2(-4,-4),Vector2(8,8))
	draw_rect(right_rect,Color(0.88,0.33,0.33),true,1.5)	
	# Draw bar
	draw_line($"Horiz Left MouseDetect".position,$"Horiz Right MouseDetect".position,Color(0.88,0.33,0.33),1.5)
		
func _on_horiz_left_mouse_entered():
	mouse_in_left = true
	
func _on_horiz_left_mouse_exited():
	mouse_in_left = false	


func _on_horiz_right_mouse_entered():
	mouse_in_right = true


func _on_horiz_right_mouse_exited():
	mouse_in_right = false
	


func _on_mouse_entered_hbar():
	mouse_in_hbar = true


func _on_mouse_exited_hbar():
	mouse_in_hbar = false
