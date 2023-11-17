extends BaseCommand

var state = preload("res://actors/State-Area2D/State-Area2D.tscn")
var created_state
var glbl_pos
var idx
var states

func setup(idx,glbl_pos,states):
	self.idx = idx
	self.glbl_pos = glbl_pos
	self.states = states

func do():
	created_state = state.instantiate()
	created_state.setup(idx,glbl_pos)
	states.add_child(created_state)
	
func undo():
	created_state.queue_free()
