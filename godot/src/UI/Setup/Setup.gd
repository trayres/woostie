extends WindowDialog

var InputLineItem  = preload("res://src/UI/Setup/InputLineItem.tscn")

func _ready() -> void:
	# Uncomment to run standalone test
	debug_setup_0()
	
	
func debug_setup_0() -> void:	
	### State Machine Page
	# State Machine Name
	var fsm_name = "TestMachine"
	
	#TODO: Create data objects for state array
	var state_array : Array = debug_state_array_gen()
	var io_array : Array = debug_io_array_gen()
	var transition_array : Array = debug_transition_array_gen()
	#var output_array : Array = debug_output_array_gen()

	setup(fsm_name, state_array,io_array,transition_array)
	show()
	
func debug_state_array_gen() -> Array:
	var state_array : Array
	for t in range(0,3):
		var a_state_object = StateDataObject.new()
		a_state_object.state_name = "State"+String(t)
		a_state_object.idx = t
		if t == 0:
			a_state_object.is_reset_state = true
		else:
			a_state_object.is_reset_state = false
		state_array.append(a_state_object)
	return state_array
	
func debug_io_array_gen() -> Array:
	var io_array : Array
	var a_io_obj : IODataObject =  IODataObject.new()
	a_io_obj.idx = 0
	a_io_obj.is_reset_input = false
	a_io_obj.name = "A"
	a_io_obj.io_type = GLOBAL.IO_TYPES.INPUT_TYPE
	io_array.append(a_io_obj)
	var b_io_obj : IODataObject =  IODataObject.new()
	b_io_obj.idx = 1
	b_io_obj.is_reset_input = false
	b_io_obj.name = "B"
	b_io_obj.io_type = GLOBAL.IO_TYPES.INPUT_TYPE
	io_array.append(b_io_obj)	
	var c_io_obj : IODataObject =  IODataObject.new()
	c_io_obj.idx = 2
	c_io_obj.is_reset_input = false
	c_io_obj.name = "clk"
	c_io_obj.io_type = GLOBAL.IO_TYPES.INPUT_TYPE
	io_array.append(c_io_obj)
	return io_array

	

func debug_transition_array_gen():
	var transition_array : Array
	var transition_object_0 : TransitionDataObject = TransitionDataObject.new()
	transition_object_0.idx=0
	transition_object_0.head_state_idx=1
	transition_object_0.tail_state_idx=0
	transition_object_0.transition_eqn="go_1"
	transition_array.append(transition_object_0)
	var transition_object_1 : TransitionDataObject = TransitionDataObject.new()
	transition_object_1.idx=1
	transition_object_1.head_state_idx=0
	transition_object_1.tail_state_idx=1
	transition_object_1.transition_eqn=""	
	transition_array.append(transition_object_1)
	var transition_object_2 : TransitionDataObject = TransitionDataObject.new()
	transition_object_2.idx=2
	transition_object_2.head_state_idx=2
	transition_object_2.tail_state_idx=0
	transition_object_2.transition_eqn="go_2"
	transition_array.append(transition_object_2)
	var transition_object_3 : TransitionDataObject = TransitionDataObject.new()
	transition_object_3.idx=3
	transition_object_3.head_state_idx=0
	transition_object_3.tail_state_idx=2
	transition_object_3.transition_eqn=""
	transition_array.append(transition_object_3)
	var transition_object_4 : TransitionDataObject = TransitionDataObject.new()
	transition_object_4.idx=4
	transition_object_4.head_state_idx=3
	transition_object_4.tail_state_idx=0
	transition_object_4.transition_eqn="go_3"
	transition_array.append(transition_object_4)
	var transition_object_5 : TransitionDataObject = TransitionDataObject.new()
	transition_object_5.idx=5
	transition_object_5.head_state_idx=0
	transition_object_5.tail_state_idx=3
	transition_object_5.transition_eqn=""
	transition_array.append(transition_object_5)
	return transition_array
	
func setup(fsm_name : String, state_array, io_array,transition_array : Array) -> void:
	# State Machine Tab
	var reset_opt_btn = $"TabContainer/State Machine/VBoxContainer/ResetStateHBoxContainer/ResetStateOptionButton"
	var clock_opt_btn = $"TabContainer/State Machine/VBoxContainer/ClockHBoxContainer/OptionButton"

	# Fill Up the Reset Option Button
	reset_opt_btn.clear()
	for aState in state_array:
		reset_opt_btn.add_item(aState.state_name)
		
	# Fill Up the Clock Option Button
	clock_opt_btn.clear()
	for aSignal in io_array:
		clock_opt_btn.add_item(aSignal.name)


# User wants to add an input to the machine
func _on_AddInputBtn_pressed() -> void:
	var new_ila = InputLineItem.instance()
	$TabContainer/Inputs/ScrollContainer/VBoxContainer.add_child(new_ila)

# User wants to delete the box which currently has focus, need to figure that part out.
func _on_Delete_pressed() -> void:
	# Figure out which one of the items is active?
	pass # Replace with function body.
