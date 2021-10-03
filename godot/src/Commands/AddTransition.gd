extends BaseCommand

var controller
var states
var transitions
var node_positions : Array # Head, HeadControl, TailControl, Tail positions by index. Index[0] is Head, etc.
var idx            : int
var created_transition

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
	# Setup the transition
	created_transition.setup(self.idx,self.node_positions)
	# Add it to the controller's transition list
	transitions.add_child(created_transition)
	# Connect the signals the transition emits
	# TODO: Finish
	var result = created_transition.connect("move_transition_anchor",controller,"transition_anchor_moved")
	
func undo():
	created_transition.queue_free()

