extends Node
class_name Command

const KineticState = preload("res://src/KineticState/Kinetic State.tscn")

class StateCommand:
	var states_list   : Node
	var idx           : int
	var position      : Vector2
	func add_state(states_list : Node, idx : int,position:Vector2):
		self.idx=idx
		self.states_list = states_list
		var a_state : KineticState
		a_state = KineticState.instance()
		a_state.setup(idx,position)
		states_list.add_child(a_state)
		return self
	func undo_state():
		states_list.remove_state(idx)
		
