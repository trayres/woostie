extends Node2D

# The below preloads and the _ready function were taken from the previous experiment
# But the CanvasLayer with the control nodes in it is new. That should be refactored
# to a separate scene, which we'll instantiate in our final project.

# Scene Preloads
#var transition = preload("res://actors/Transition/Transition.tscn")
var transition = preload("res://actors/Transition/Transition-Mk1.tscn")
var preload_state = preload("res://actors/State-Area2D/State-Area2D.tscn")

#enum CONTROLLER_STATE{
#	IDLE,
#	ADDING_STATE,
#	ADDING_TRANSITION
#}
#var current_state : CONTROLLER_STATE  : set = _set_state, get = _get_state
#
#func _set_state(state : CONTROLLER_STATE):
#	print("setting state: ",state)
#	current_state = state
#func _get_state() -> CONTROLLER_STATE:
#	return current_state

#func transition_states(current_state,new_state):
#	if current_state==null:
#		_set_state(CONTROLLER_STATE.IDLE)	
		
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$Controller._process(delta)
	
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		_mouse_moved(get_global_mouse_position())
	$Controller._unhandled_input(event)
		
func _mouse_moved(glbl_pos : Vector2)->Vector2:
	SignalBus.mouse_pos_update.emit(glbl_pos)
	return glbl_pos		
