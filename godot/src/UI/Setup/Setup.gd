extends WindowDialog

var InputLineItem  = preload("res://src/UI/Setup/InputLineItem.tscn")

func _ready() -> void:
	
	var fsm_name = "TestMachine"
	
	var state_array : Array
	state_array.append("State0")
	state_array.append("State1")
	state_array.append("State2")
	
	var input_array : Array
	input_array.append("clk")
	input_array.append("rst_n")
	setup(fsm_name, state_array,input_array)
	show()
	
func setup(fsm_name : String, state_array : Array, input_array : Array) -> void:
	var reset_opt_btn = $"TabContainer/State Machine/VBoxContainer/ResetStateHBoxContainer/ResetStateOptionButton"
	var clock_opt_btn = $"TabContainer/State Machine/VBoxContainer/ClockHBoxContainer/OptionButton"

	reset_opt_btn.clear()
	for aState in state_array:
		reset_opt_btn.add_item(aState)
	
	clock_opt_btn.clear()
	#for aSignal in input_array:
	#	clock_opt_btn.add_item(aSignal)


# User wants to add an input to the machine
func _on_AddInputBtn_pressed() -> void:
	var new_ila = InputLineItem.instance()
	$TabContainer/Inputs/ScrollContainer/VBoxContainer.add_child(new_ila)

# User wants to delete the box which currently has focus, need to figure that part out.
func _on_Delete_pressed() -> void:
	# Figure out which one of the items is active?
	pass # Replace with function body.
