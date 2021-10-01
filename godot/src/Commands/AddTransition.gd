extends BaseCommand

var controller
var states
var transitions
var node_positions : Array # Head, HeadControl, TailControl, Tail positions by index. Index[0] is Head, etc.
var idx            : int

# Preloaded scene to create the transition
const Transition = preload("res://src/CubicBezier/CubicBezier_MK2/Transition.tscn")

func setup(controller, states, transitions, node_positions, idx):
	self.controller=controller
	self.states=states
	self.transitions=transitions
	self.node_positions=node_positions
	self.idx = idx
func do():
	# Create the transition
	var created_transition = Transition.instance()
	
func undo():
	pass

