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

# Note: This was tested as an unhandled input to deal with 
# overlapping items receiving events. Basically we would get 
# ugly results where two overlapping objects would both receive the events.
# by handling it in the _unhandled_input event handler and then 
# telling the scene tree that the event was handled, we could ensure
# that only 1 object would "grab" the event. The other "trick" was to 
# use nodes in the scene hierarchy to contain the drawn objects - because 
# the scene is drawn from the bottom to top (the root layer is the lowest layer)
# we could ensure that transition objects are never hidden by states, ensuring that
# they receive click events directly (without goofy z-mechanics and extra tracking).

# However, because of all this, now we do not get mouse events to update the UI when
# an object is being dragged. That's not a great look! Let's get around this by 
# using an Event Bus.
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		var mouse_pos = _mouse_moved(get_global_mouse_position())
		self.get_viewport().set_input_as_handled()
		
func _mouse_moved(global_position : Vector2)->Vector2:
	SignalBus.mouse_pos_update.emit(global_position)
	return global_position		
