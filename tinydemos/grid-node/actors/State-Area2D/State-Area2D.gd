extends Area2D

var mouse_in : bool
var dragging : bool
var last_mouse_pos : Vector2
var connected_heads := []
var connected_tails := []

signal state_moved(offset_delta)

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("states")
	
func setup(glbl_pos):
	global_position = glbl_pos

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
	if 	Input.is_action_just_pressed("click") and mouse_in:
		dragging = true
		last_mouse_pos = get_global_mouse_position()
		self.get_viewport().set_input_as_handled()
	if Input.is_action_just_released("click"):
		dragging = false	
	if event is InputEventMouseMotion and dragging:
		var new_mouse_pos = get_global_mouse_position()
		var offset_delta = new_mouse_pos - last_mouse_pos
		position += offset_delta
		emit_signal("state_moved",offset_delta) #anybody who is connected, better move with me!
		last_mouse_pos = new_mouse_pos
		self.get_viewport().set_input_as_handled()
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
		#last_mouse_pos = new_mouse_pos	

func _draw():
	draw_circle(Vector2(0,0),50.0,Color(0.22,0.88,0.22))


func _on_mouse_entered():
	mouse_in = true


func _on_mouse_exited():
	mouse_in = false
