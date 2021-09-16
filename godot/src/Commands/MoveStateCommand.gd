extends BaseCommand

# Data needed to move a state
var states # Reference to the States node - holder of the states
var start_position
var final_position
var state : KineticState # Direct reference to the state itself
var idx : int

func setup(states,state,start_position,final_position):
	self.states = states
	self.state = state
	self.idx = self.state.idx
	self.start_position = start_position
	self.final_position = final_position

func do():
	var astate = get_state_with_idx(self.idx)
	astate.global_position = final_position

func undo():
	var astate = get_state_with_idx(self.idx)
	astate.global_position = start_position

func get_state_with_idx(idx):
	for astate in states.get_children():
		if astate.idx==idx:
			return astate
