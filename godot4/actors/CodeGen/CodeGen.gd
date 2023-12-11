extends Window

var state_array : Array
var io_array : Array
var transition_array : Array
# pass a reference to the controller
@export var controller : Node

var dbg_sorted : Array

# Called when the node enters the scene tree for the first time.
func _ready():
	SignalBus.generate_code.connect(_generate_code)
	print("DOING SORTING TEST")
	dbg_sorted = sort_transition_list_test0()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_about_to_popup():
	pass # Replace with function body.


func _on_close_requested():
	hide()

# This signal is called to pop up the window.
# As a side effect the code generator is run.
func _generate_code()->void:
	# This is how the data will actually be grabbed from the controller.
	# For now I'm going to shim this with debug data so that I can finish 
	# out this interface and the code generation bits.
	#var fsm_name : String = controller.fsm_name
	#var state_info : Array = controller.get_state_info()
	#var io_info : Array = controller.get_io_info()
	#var transition_info : Array = controller.get_transition_info()
	# These are for the Cliff's Classic
	## Cliff's Classic
#	var state_info : Array = debug_state_info()
#	var io_info : Array = debug_io_info()
#	var transition_info : Array = debug_transition_info()
	
	var fsm_name : String = "pulse_generator"
	var state_info : Array = debug_state_info_pulse_combonly()
	var io_info : Array = debug_io_info_pulse_combonly()
	var transition_info : Array = debug_transition_info_pulse_combonly()
	# TODO: insert checks here. For example, is the transition array valid,
	# or does it contain 
	
	var generated_code : String = ""
	var num_states = state_info.size()
	var num_statebits = ceili(log(num_states)/log(2))
	generated_code += generate_header(fsm_name,io_info)
	generated_code += generate_intro(num_statebits,state_info)
	generated_code += generate_nextstate(num_statebits,transition_info,state_info)
	generated_code += generate_seq_always_blk(io_info,state_info)
	generated_code += "endmodule"
	$VBoxContainer/TextEdit.text = generated_code
	popup()
	
func generate_header(fsm_name:String,io_info:Array)->String:
	var hdr : String = ""
	hdr += "module "+fsm_name +"(\n"
	var last_index = io_info.size()-1
	for index in io_info.size():
		var an_io_item = io_info[index]
		if (an_io_item.io_type==GLOBAL.IO_TYPES.INPUT or 
			an_io_item.io_type==GLOBAL.IO_TYPES.CLOCK_POS or
			an_io_item.io_type==GLOBAL.IO_TYPES.CLOCK_NEG or
			an_io_item.io_type==GLOBAL.IO_TYPES.RESET_POS or 
			an_io_item.io_type==GLOBAL.IO_TYPES.RESET_NEG or
			an_io_item.io_type==GLOBAL.IO_TYPES.ARESET_POS or
			an_io_item.io_type==GLOBAL.IO_TYPES.ARESET_NEG ):
			if(index==last_index):		
				hdr += "  input wire "+an_io_item.io_name
			else:
				hdr += "  input wire "+an_io_item.io_name+",\n"
		elif (an_io_item.io_type==GLOBAL.IO_TYPES.OUTPUT):
			if(index==last_index):		
				hdr += "  output reg "+an_io_item.io_name
			else:
				hdr += "  output reg "+an_io_item.io_name+",\n"			
	hdr += ");\n"
	return hdr
	
func generate_intro(num_statebits:int,state_info:Array)->String:

	var intro_s : String = ""
	intro_s += "\n"
	intro_s += "//State Bits\n"
	intro_s += "parameter\n"
	var idx : int = 0
	var last : int = len(state_info)-1
	for astate in state_info:
		if idx < last:
			intro_s += astate.state_name + " = " + str(num_statebits)+"'d"+str(idx)+",\n"
		else:
			intro_s += astate.state_name + " = " + str(num_statebits)+"'d"+str(idx)+";\n"
		idx += 1
	if num_statebits==1:
		intro_s += "reg state;\n"
		intro_s += "reg nextstate;\n"
	else:
		intro_s += "reg ["+ str(num_statebits-1)+":0]   state;\n"
		intro_s += "reg ["+ str(num_statebits-1)+":0]   nextstate;\n"
	return intro_s

func generate_nextstate(num_statebits:int,transition_info:Array,state_info:Array)->String:
	var nextstate_s : String = ""
	nextstate_s += "// comb always block\n"
	nextstate_s += "always @* begin\n"
	########################
	# Defaults
	# Because every StateDataObject contains a reference to all the combinatorial outputs,
	# WE HAVE DUPLICATION IN OUR DATA MODEL! We need to fix this representation! UGH!
	# SO UGLY! But because of this, we can just grab the default values from a single
	# state object
	var tState = state_info[0]
	var cOuts = tState.comb_outputs
	for aKey in cOuts.keys():
		nextstate_s += "  "+ aKey + " = " + cOuts[aKey][1] + ";\n"
	
	
	# nextstate
	if num_statebits==1:
		nextstate_s += "  nextstate = 1'bx;\n"
	else:
		nextstate_s += "  nextstate = "+str(num_statebits)+"'bx;\n"
	
	nextstate_s += "  case (state)\n"
	
	for astate in state_info:
		nextstate_s += "    "+astate.state_name + ": begin\n"
		nextstate_s += add_comb_outputs(astate)
		nextstate_s += add_transitions(astate,state_info,transition_info)
		nextstate_s += "    end\n"
	nextstate_s += " endcase\n"
	nextstate_s += "end\n"
	return nextstate_s
	
## Cliff's Classic Debug State Info
########################################################################
########################################################################
func debug_state_info()->Array:
	# Cliff's classic
	var dbg_state_info : Array
	## Idle State
	var s_idle : StateDataObject = StateDataObject.new()
	s_idle.state_name = "IDLE"
	s_idle.idx = 0
	s_idle.is_reset_state = true
	dbg_state_info.append(s_idle)
	## READ
	var s_read : StateDataObject = StateDataObject.new()
	s_read.state_name = "READ"
	s_read.idx = 1
	s_read.is_reset_state = false
	dbg_state_info.append(s_read)
	## DELAY (DLY)
	var s_dly : StateDataObject = StateDataObject.new()
	s_dly.state_name = "DLY"
	s_dly.idx = 2
	s_dly.is_reset_state = false
	dbg_state_info.append(s_dly)
	## DONE
	var s_done : StateDataObject = StateDataObject.new()
	s_done.state_name = "DONE"
	s_done.idx = 3
	s_done.is_reset_state = false
	dbg_state_info.append(s_done)	
	return dbg_state_info
## Cliff's Classic Debug IO Info	
func debug_io_info()->Array:
	var dbg_io_info : Array
	### Inputs
	## clk
	var i_clk : IODataObject = IODataObject.new()
	i_clk.idx = 0
	i_clk.is_reset_input = false
	i_clk.is_clock_input = true # TODO: Note: Duplication of IO_TYPES - remove?
	i_clk.io_name = "clk"
	i_clk.io_type = GLOBAL.IO_TYPES.CLOCK_POS
	i_clk.io_width = GLOBAL.IO_WIDTH.WIRE
	i_clk.io_multibit = Vector2i(-1,-1)
	i_clk.reset_polarity = -1 # only used for reset; io_type=RESET
	i_clk.reset_type     = -1 # only used for reset; io_type=RESET
	dbg_io_info.append(i_clk)
	# rst_n
	var i_rstn : IODataObject = IODataObject.new()
	i_rstn.idx = 1
	i_rstn.is_reset_input = true
	i_rstn.is_clock_input = false
	i_rstn.io_name = "rst_n"
	i_rstn.io_type = GLOBAL.IO_TYPES.RESET_NEG
	i_rstn.io_width = GLOBAL.IO_WIDTH.WIRE
	i_rstn.io_multibit = Vector2i(-1,-1) # only used for io_width=BUS
	i_rstn.reset_polarity = GLOBAL.RESET_POLARITY.NEGATIVE
	i_rstn.reset_type     = GLOBAL.RESET_TYPE.SYNC
	dbg_io_info.append(i_rstn)	
	# go
	var i_go : IODataObject = IODataObject.new()
	i_go.idx = 2
	i_go.is_reset_input = false
	i_go.is_clock_input = false
	i_go.io_name = "go"
	i_go.io_type = GLOBAL.IO_TYPES.INPUT
	i_go.output_type = -1
	i_go.io_width = GLOBAL.IO_WIDTH.WIRE
	i_go.io_multibit = Vector2i(-1,-1) # only used for io_width=BUS
	i_go.reset_polarity = -1
	i_go.reset_type     = -1
	dbg_io_info.append(i_go)		
	# ws
	var i_ws : IODataObject = IODataObject.new()
	i_ws.idx = 3
	i_ws.is_reset_input = false
	i_ws.is_clock_input = false
	i_ws.io_name = "ws"
	i_ws.io_type = GLOBAL.IO_TYPES.INPUT
	i_ws.output_type = -1
	i_ws.io_width = GLOBAL.IO_WIDTH.WIRE
	i_ws.io_multibit = Vector2i(-1,-1) # only used for io_width=BUS
	i_ws.reset_polarity = -1
	i_ws.reset_type     = -1
	dbg_io_info.append(i_ws)
	### Outputs
	# rd
	var o_rd : IODataObject = IODataObject.new()
	o_rd.idx = 4
	o_rd.is_reset_input = false
	o_rd.is_clock_input = false
	o_rd.io_name = "rd"
	o_rd.io_type = GLOBAL.IO_TYPES.OUTPUT
	o_rd.output_type = GLOBAL.OUTPUT_TYPE.COMB
	o_rd.io_width = GLOBAL.IO_WIDTH.WIRE
	o_rd.io_multibit = Vector2i(-1,-1) # only used for io_width=BUS
	o_rd.reset_polarity = -1
	o_rd.reset_type     = -1
	dbg_io_info.append(o_rd)
	# wr
	var o_wr : IODataObject = IODataObject.new()
	o_wr.idx = 5
	o_wr.is_reset_input = false
	o_wr.is_clock_input = false
	o_wr.io_name = "wr"
	o_wr.io_type = GLOBAL.IO_TYPES.OUTPUT
	o_wr.output_type = GLOBAL.OUTPUT_TYPE.COMB
	o_wr.io_width = GLOBAL.IO_WIDTH.WIRE
	o_wr.io_multibit = Vector2i(-1,-1) # only used for io_width=BUS
	o_wr.reset_polarity = -1
	o_wr.reset_type     = -1
	dbg_io_info.append(o_wr)	
	return dbg_io_info	
## Cliff's Classic Debug Transition Info	
func debug_transition_info()->Array:
	var dbg_transition_info : Array
	return dbg_transition_info
### End Cliff's Classic Debug Info Arrays	
########################################################################
########################################################################
	
## pulse_combonly Debug Info Arrays	
########################################################################
########################################################################	
func debug_state_info_pulse_combonly()->Array:
	var dbg_state_info : Array
	## Idle State
	var s_idle : StateDataObject = StateDataObject.new()
	s_idle.state_name = "IDLE"
	s_idle.idx = 0
	s_idle.is_reset_state = true
	s_idle.comb_outputs = {"PULSE_O":['0','0',GLOBAL.VISIBILITY.ONLY_NON_DEFAULT]} # comb_outputs meaning: Actual Value, Default Value, Visibility Setting
	dbg_state_info.append(s_idle)
	## READ
	var s_read : StateDataObject = StateDataObject.new()
	s_read.state_name = "PULSE"
	s_read.idx = 1
	s_read.is_reset_state = false
	s_read.comb_outputs = {"PULSE_O":['1','0',GLOBAL.VISIBILITY.ONLY_NON_DEFAULT]}	
	dbg_state_info.append(s_read)
	return dbg_state_info
	
func debug_io_info_pulse_combonly():
	var dbg_io_info : Array
	### Inputs
	## clk
	var i_clk : IODataObject = IODataObject.new()
	i_clk.idx = 0
	i_clk.is_reset_input = false
	i_clk.is_clock_input = true
	i_clk.io_name = "clk"
	i_clk.io_type = GLOBAL.IO_TYPES.CLOCK_POS
	i_clk.io_width = GLOBAL.IO_WIDTH.WIRE
	i_clk.io_multibit = Vector2i(-1,-1)
	i_clk.reset_polarity = -1 # only used for reset; io_type=RESET
	i_clk.reset_type     = -1 # only used for reset; io_type=RESET
	dbg_io_info.append(i_clk)
	# rst_n
	var i_rstn : IODataObject = IODataObject.new()
	i_rstn.idx = 1
	i_rstn.is_reset_input = true
	i_rstn.is_clock_input = false
	i_rstn.io_name = "rst_n"
	i_rstn.io_type = GLOBAL.IO_TYPES.RESET_NEG
	i_rstn.io_width = GLOBAL.IO_WIDTH.WIRE
	i_rstn.io_multibit = Vector2i(-1,-1) # only used for io_width=BUS
	i_rstn.reset_polarity = GLOBAL.RESET_POLARITY.NEGATIVE
	i_rstn.reset_type     = GLOBAL.RESET_TYPE.SYNC
	dbg_io_info.append(i_rstn)	
	# pulse output
	var o_pulse : IODataObject = IODataObject.new()
	o_pulse.idx = 2
	o_pulse.is_reset_input = false
	o_pulse.is_clock_input = false
	o_pulse.io_name = "PULSE_O"
	o_pulse.io_type = GLOBAL.IO_TYPES.OUTPUT
	o_pulse.io_width = GLOBAL.IO_WIDTH.WIRE
	o_pulse.io_multibit = Vector2i(-1,-1) # only used for io_width=BUS
	o_pulse.reset_polarity = GLOBAL.RESET_POLARITY.NEGATIVE
	o_pulse.reset_type     = GLOBAL.RESET_TYPE.SYNC
	dbg_io_info.append(o_pulse)	
	
	return dbg_io_info
	
func debug_transition_info_pulse_combonly()->Array:
	var dbg_transition_info : Array
	# Transition 0
	var transition_0 = TransitionDataObject.new()
	transition_0.idx = 0
	transition_0.head_state_idx = 1
	transition_0.tail_state_idx = 0
	transition_0.transition_eqn = ['1','1',GLOBAL.VISIBILITY.ONLY_NON_DEFAULT]
	transition_0.priority = -1
	transition_0.comb_outputs = {}
	dbg_transition_info.append(transition_0)
	var transition_1 = TransitionDataObject.new()
	transition_1.idx = 1
	transition_1.head_state_idx = 0
	transition_1.tail_state_idx = 1
	transition_1.transition_eqn = ['1','1',GLOBAL.VISIBILITY.ONLY_NON_DEFAULT]
	transition_1.priority = -1
	transition_1.comb_outputs = {}
	dbg_transition_info.append(transition_1)		
	return dbg_transition_info
## End pulse_combonly Debug Info Arrays	
########################################################################
########################################################################	
func add_comb_outputs(aState:StateDataObject)->String:
	var comb_output_s : String = ""
	for comb_out in aState.comb_outputs.keys():
		# For each combinatorial output set in a state, we need to see if that
		# output is assign a non-default value. If so, we need to output it.
		# Otherwise do nothing.
		var combOutputDictArray : Array = aState.comb_outputs[comb_out]
		if combOutputDictArray[0] != combOutputDictArray[1]:
			comb_output_s += "        "+comb_out + " = "+combOutputDictArray[0]  +";\n";
	return comb_output_s

# This generates the IF/ELSE section of next-state logic
func add_transitions(aState : StateDataObject,state_info:Array,transition_info:Array)->String:
	var transition_s : String = ""
	# Collect all the transitions start at this state (tail == the state's index)
	var transition_list : Array
	for aTransition in transition_info:
		if aState.idx == aTransition.tail_state_idx:
			transition_list.append(aTransition)
	# Now that we've collected all the transitions that "matter" to this state,
	# we need to process them.
	if len(transition_list)==1:
		transition_s = "        nextstate = " + _get_head_name(transition_list[0].head_state_idx,state_info) + ";\n" # get the head state name
	else:
		pass
		var sorted_transition_list = sort_transition_list(transition_list)
		transition_s += if_else_tree(aState,state_info,sorted_transition_list)
#		for aTransition in sorted_transition_list:
#			transition_s = "      begin\n"
#			if aTransition.transition_eqn[0]!=aTransition.transition_eqn[1]:
#				transition_s += "  if ("+aTransition.transition_eqn[0]+") begin\n"
#				transition_s =  "        nextstate = " + _get_head_name(aTransition.head_state_idx,state_info) + ";\n"
#				transition_s =  "  end\n"
#			else:
#				transition_s =  "        nextstate = " + _get_head_name(aTransition.head_state_idx,state_info) + ";\n"
	return transition_s
func _get_head_name(idx : int,state_info:Array)->String:
	for aState in state_info:
		if aState.idx==idx:
			return aState.state_name
	return "ERROR: Failed to find state with index "+str(idx)

func generate_seq_always_blk(io_info:Array,state_info:Array)->String:
	var seq_t : String = ""
	seq_t += "// sequential always block\n"
	# Figure out the name of the marked clock signal, the reset signal,
	# and the reset polarity
#	always @(SENSITIVTY_S) begin
#    if (RESET_S)
#      state <= RESET_STATE
#    else
#      state <= nextstate;
#  end
	var sensitivity_s : String = ""
	var reset_s : String = ""
	var reset_state : String 
	var reset_e    : GLOBAL.IO_TYPES = -1
	var clock_e    : GLOBAL.IO_TYPES = -1
	var clock_name : String
	var reset_name : String
	## Gather enums for reset and clock
	for an_io in io_info:
		if an_io.io_type==GLOBAL.IO_TYPES.CLOCK_POS or an_io.io_type==GLOBAL.IO_TYPES.CLOCK_NEG:
			clock_e = an_io.io_type
			clock_name = an_io.io_name
		if (an_io.io_type==GLOBAL.IO_TYPES.RESET_POS or 
		   an_io.io_type==GLOBAL.IO_TYPES.RESET_NEG or 
		   an_io.io_type==GLOBAL.IO_TYPES.ARESET_POS or
		   an_io.io_type==GLOBAL.IO_TYPES.ARESET_NEG):
			reset_e = an_io.io_type
			reset_name = an_io.io_name
	# Build sensitivity string
	# If reset is asynchronous, add it to the sensitivity string.
	# If it is synchronous, don't.
	if clock_e==GLOBAL.IO_TYPES.CLOCK_POS:
		sensitivity_s += "posedge "+clock_name
	elif clock_e== GLOBAL.IO_TYPES.CLOCK_NEG:
		sensitivity_s += "negedge "+clock_name
	
	if reset_e==GLOBAL.IO_TYPES.ARESET_POS:
		sensitivity_s += "or posedge "+reset_name
	elif reset_e==GLOBAL.IO_TYPES.ARESET_NEG:
		sensitivity_s += "or negedge "+reset_name
	## Done building sensitivity string
	
	# Build reset_s string
	# If the reset is negative edged, add ! in front of the input name
	if reset_e==GLOBAL.IO_TYPES.RESET_NEG:
		reset_s += "!"+reset_name
	elif reset_e==GLOBAL.IO_TYPES.RESET_POS:
		reset_s += reset_name
	## Done building reset_s string
	
	# Determine reset state
	# Go through the states and see which one is marked as the reset state
	# TODO: Add a check that ensures only 1 state is marked as reset
	for aState in state_info:
		if aState.is_reset_state:
			reset_state = aState.state_name
			
	## Put it all together
	seq_t += "always @("+sensitivity_s+") begin\n"
	seq_t += "  if ("+reset_s+")\n"
	seq_t += "    state <= "+reset_state+";\n"
	seq_t += "  else\n"
	seq_t += "    state <= nextstate;\n"
	seq_t += "end\n"

	return seq_t
	
# This is the function that builds the IF/ELSE tree for exiting a state.
# At this point, the list passed to it contains transitions objects that 
# all list some state as their "tail" location (I.E., these are the transitions
# that are leaving some state). So all we should have to do is put them in "some
# order".
func sort_transition_list(transition_list:Array)->Array:
	transition_list.sort_custom(PrioritySorter)
	return transition_list
func sort_transition_list_test0()->Array:
	var res_array : Array = sort_transition_list(test_transition_list_0())
	return res_array
# This is a test transition list. It's meant to be used to check out the 
# sort_transition_list method		
func test_transition_list_0()->Array:
	var dbg_transition_info : Array
	# This represents one state with three outgoing transitions
	# The first is a default transition with default priority to state idx 1
	# The second checks for the "GO" signal and transitions to state idx 2
	# The third checks for "SIGNAL1" and transitions to state idx 3
	# While the first is default priority, the second has priority 2 and 
	# the last one has priority 1. 
	# The result we are looking for is:
	# if (SIGNAL1) begin
	# nextstate = 3 (the transition array doesn't carry the name info)
	# end else if (GO) begin
	# nexstate = 2 
	# end else begin
	# nextstate = 1
	# end
	var transition_0 = TransitionDataObject.new()
	transition_0.idx = 0
	transition_0.head_state_idx = 1
	transition_0.tail_state_idx = 0 # Tail must be the same
	transition_0.transition_eqn = ['1','1',GLOBAL.VISIBILITY.ONLY_NON_DEFAULT]
	transition_0.priority = -1
	transition_0.comb_outputs = {}
	dbg_transition_info.append(transition_0)
	var transition_1 = TransitionDataObject.new()
	transition_1.idx = 1
	transition_1.head_state_idx = 2
	transition_1.tail_state_idx = 0 # Tail must be the same
	transition_1.transition_eqn = ['GO','1',GLOBAL.VISIBILITY.ONLY_NON_DEFAULT]
	transition_1.priority = 2
	transition_1.comb_outputs = {}
	dbg_transition_info.append(transition_1)
	var transition_2 = TransitionDataObject.new()
	transition_2.idx = 2
	transition_2.head_state_idx = 3 # name+1
	transition_2.tail_state_idx = 0 # Tail must be the same
	transition_2.transition_eqn = ['SIGNAL1','1',GLOBAL.VISIBILITY.ONLY_NON_DEFAULT]
	transition_2.priority = 1
	transition_2.comb_outputs = {}
	dbg_transition_info.append(transition_2)					
	return dbg_transition_info

func PrioritySorter(a,b):
	if a.priority<b.priority:
		return true
	return false		

func if_else_tree(aState,state_info,sorted_transition_list)->String:
	var if_else : String = ""
	var sidx : int = 1
	var num_transitions : int = len(sorted_transition_list)
	return if_else
