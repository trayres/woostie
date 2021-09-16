extends Node

var states : Node # Reference to the states

func _ready() -> void:
	pass

func setup(States : Node):
	self.states = States
		
	
func remove_state(idx: int):
	for state in states.get_children():
		if state.idx==idx:
			state.queue_free()
