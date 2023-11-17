extends Node2D



# Note that this node "hooks into" the mouse position updates that are appearing
# on the SignalBus
func _ready():
	#SignalBus.show_dummy_state.emit()
	SignalBus.connect("show_dummy_state",show_dummy_state)
	SignalBus.connect("hide_dummy_state",hide_dummy_state)
	SignalBus.connect("mouse_pos_update",mouse_pos_update)
	visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _draw():
	if visible:
		draw_circle(Vector2(0,0),50.0,Color(0.222,0.6718,0.6757))
		draw_arc(Vector2(0,0),50.0,0,0,36,Color.BLACK,1.5,true)
	
func show_dummy_state():
	visible = true
func hide_dummy_state():
	visible = false	
func mouse_pos_update(global_position : Vector2):
	if visible:
		self.global_position = global_position
