extends BaseCommand

# Data needed to create state
var controller
var states
var transitions
var position
var idx : int
var created_state : KineticState

# Preloaded scene to create the state
const KineticState = preload("res://src/KineticState/Kinetic State.tscn")


func setup(controller, states, transitions,position,idx):
	self.controller=controller
	self.states=states
	self.transitions=transitions
	self.position=position
	self.idx = idx
func do():
	# create the state
	created_state = KineticState.instance()
	# Setup the state
	created_state.setup(idx,position)
	states.add_child(created_state)
	#return a_state
	# Connect signals to the controller
	var result = created_state.connect("move",controller,"_state_moved")
	result = created_state.connect("set_state_name",controller,"_set_state_name")
	
func undo():
	created_state.queue_free()
	
