extends Node2D

# The below preloads and the _ready function were taken from the previous experiment
# But the CanvasLayer with the control nodes in it is new. That should be refactored
# to a separate scene, which we'll instantiate in our final project.

var transition = preload("res://actors/Transition/Transition.tscn")
var preload_state = preload("res://actors/State-Area2D/State-Area2D.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	var atransition = transition.instantiate()
	atransition.setup(Vector2(200,200),Vector2(400,400))
	$Transitions.add_child(atransition)
	
	var astate = preload_state.instantiate()
	astate.setup(Vector2(500,500))
	$States.add_child(astate)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		var mouse_pos = _mouse_moved(get_global_mouse_position())
		self.get_viewport().set_input_as_handled()
		
func _mouse_moved(global_position : Vector2)->Vector2:
	SignalBus.mouse_pos_update.emit(global_position)
	return global_position		
