extends Area2D
class_name State

var state_name     : String = "State"
var dragging       : bool = false
var mouse_in_state : bool = false
var selected       : bool = false
var idx            : int  = 0

# Ready
func _ready():
	add_to_group("State")
	$"Set State Name".connect("set_state_name",self,"set_name")

# Draw
func _draw():
	draw_circle(Vector2(0.0,0.0),50.0,Color(0.22,0.77,0.22))
	if selected:
		var sel_rect : Rect2
		sel_rect.position = Vector2(-50.0,-50.0)
		sel_rect.size     = Vector2(100.0,100.0)
		draw_rect(sel_rect,Color(0.22,0.22,0.88),false,2.0)

# Input Processing
func _process(delta: float) -> void:
	pass

# Setup
func setup(idx:int, pos : Vector2) -> State:
	position = pos
	state_name = "State"+str(idx)
	self.idx = idx
	$Label.text = state_name
	update()
	return self

func _on_State_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if  event is InputEventMouseButton:
		if event.button_index==BUTTON_LEFT:
			if event.is_pressed():
				selected = true
			if event.is_doubleclick():
				print("Double Click!")
				$"Set State Name".setup(state_name,idx)
				$"Set State Name".popup()
			

func set_name(name:String) -> void:
	state_name = name
	$Label.text = state_name

func _on_State_mouse_entered() -> void:
	mouse_in_state = true
	
func _on_State_mouse_exited() -> void:
	mouse_in_state = false
	
func set_selected()	-> void:
	selected = true
	update()
	
func clear_selected() -> void:
	selected = false
	update()
