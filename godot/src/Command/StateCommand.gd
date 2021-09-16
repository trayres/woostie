extends Node
class_name StateCommand
const KineticState = preload("res://src/KineticState/Kinetic State.tscn")

var idx
var states_list
var transitions_list
var position : Vector2

# States_list is a reference to the $States node
# idx is created on generation and doesn't change
# Position 
func setup(states_list,transitions_list, idx,position) :
	self.states_list = states_list
	self.transitions_list = transitions_list
	self.idx = idx
	self.position = position
	
func add_state():
	var a_state : KineticState
	a_state = KineticState.instance()
	a_state.setup(idx,position)
	states_list.add_child(a_state)

func delete_state():
	for atransition in transitions_list.get_children():
		if atransition.attached_state != null:
			if atransition.attached_state.idx == self.idx:
				atransition.attached_state = null
	for astate in states_list.get_children():
		if astate.idx==idx:
			astate.queue_free()
		
