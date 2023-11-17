extends Panel

var connectors = []
var resizing : bool = false
var dragging : bool = false
var last_mouse_pos : Vector2
signal moved(delta_pos:Vector2)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func setup(glbl_pos:Vector2):
	self.position = glbl_pos


func _on_right_area_2d_area_entered(area):
	if area.is_in_group("connectors"):
		print("A CONNECTOR HIT ME")
		print(area.name)
		# The connector hit me, so sign them up to be notified when I move!
		moved.connect(area.moved)
#	if not is_head_connected and area.is_in_group("states"):
#		connected_head_state = area
#		is_head_connected = true
#		area.connect("state_moved",_on_head_connected_state_moved)

func _on_gui_input(event):
	if 	Input.is_action_just_pressed("click"):
		print("click in GUI area")
	if Input.is_action_just_released("click"):
		resizing = false
		dragging = false


func _on_resize_control_gui_input(event):
	if 	Input.is_action_just_pressed("click"):
		print("CLICK IN RESIZE CONTROL")
		resizing = true
		last_mouse_pos = get_global_mouse_position()
	if Input.is_action_just_released("click"):
		resizing = false
	if event is InputEventMouseMotion and resizing:
		var mp = get_global_mouse_position()
		var delta_size = mp - last_mouse_pos   # - self.get_rect()
		# Record the sizes of things that should not be changing
		var TopBarSize = $"Top Bar".size
		set_size(size + delta_size)
		$"Top Bar".set_size(TopBarSize)
		$"Top Bar".set_size(TopBarSize + (Vector2(1,0)*delta_size))
		$"ResizeControl".position += delta_size
#		for child in get_children():
#			if child.name=="Top Bar":
#				child.set_size(child.size + (Vector2(1,0)*delta_size)) # expand only in x
#			elif child is  Panel or child is  TextEdit :
#				child.set_size(child.size + delta_size)
#			elif child is Control:
#				child.set_position(child.position + delta_size)
		last_mouse_pos = mp
		


func _on_top_bar_gui_input(event):
	if 	Input.is_action_just_pressed("click"):
		Input.set_default_cursor_shape(Input.CURSOR_DRAG)
		last_mouse_pos = get_global_mouse_position()
		dragging = true
	if event is InputEventMouseMotion and dragging:
		var lmp = get_global_mouse_position()
		var delta = lmp - last_mouse_pos
		self.position += delta
		last_mouse_pos = lmp
		moved.emit(delta)
	if Input.is_action_just_released("click"):
		resizing = false
		dragging = false
