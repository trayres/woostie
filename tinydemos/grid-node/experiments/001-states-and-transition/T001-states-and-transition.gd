extends Node2D

var transition = preload("res://actors/Transition/Transition.tscn")
var preload_state = preload("res://actors/State-Area2D/State-Area2D.tscn")

# Here we're instantiating the transition node in the _ready function.
func _ready():
	var atransition = transition.instantiate()
	atransition.setup(Vector2(200,200),Vector2(400,400))
	$Transitions.add_child(atransition)
	
	var astate = preload_state.instantiate()
	astate.setup(Vector2(500,500))
	$States.add_child(astate)

func _input(event):
#	if event is InputEventMouseMotion:
#		print("mouse global pos:" + str(get_global_mouse_position()))
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
