extends Node

# The controller acts as an intermediary between the SignalBus and the scene tree.
# It also houses the business logic - think "Controller" in the MVC pattern.
# The controller also passes through signals to the FSM so that they can be delegated
# to the current state, thus localizing the control logic.

var transition = preload("res://actors/Transition/Transition-Mk1.tscn")
var state = preload("res://actors/State-Area2D/State-Area2D.tscn")

var fsm_name : String 
var io_info : Array # This needs to be saved between runs - it's information about
# the inputs that the user gives us. The state and transition info is derived
# from the "States" and "Transition" nodes
#var state_info : Array
#var transition_info : Array

var mouse_in_state = []

func _ready():
	# Connecting the signal bus to the controller
	SignalBus.connect("new_file",new_file)
	SignalBus.connect("open_file",open_file)
	SignalBus.connect("dbg_add_transition", _debug_add_transition)
	SignalBus.connect("dbg_add_state",_debug_add_state)
	SignalBus.mark_debug_state.connect(_mark_debug_state)
	SignalBus.mark_debug_state_finalize.connect(_mark_debug_state_finalize)
	SignalBus.connect("add_state_finalize",_add_state_finalize)
	SignalBus.connect("add_transition_finalize",_add_transition_finalize)
	SignalBus.connect("edit_undo",undo)
	SignalBus.connect("edit_redo",redo)
	SignalBus.mouse_over_state.connect(_mouse_over_state) # Replace with function body.
	SignalBus.mouse_left_state.connect(_mouse_left_state)
	
	# Experimental/Debug/Shim setup here
	
# The controller passes events it receives to the StateMachine, so they can be 
# delegates to the appropriate state
func _process(delta):
	$StateMachine._process(delta)
func _unhandled_input(event):
	$StateMachine._unhandled_input(event)
func _input(event):
	$StateMachine._input(event)	
#func _input(event):
#	$FSM._input(event)	
		
func update_mouse_pos(glbl_mouse_pos:Vector2):
	$"../ControlLayer/StatusBar-Panel/MarginContainer/Label-LR".text = "("+str(int(glbl_mouse_pos.x))+","+str(int(glbl_mouse_pos.y))+")"

func new_file():
	print("Controller: New File")
func open_file():
	print("Controller: Open File")
	
func mouse_moved():
	pass	
	
func add_transition():
	pass

# Entry point function from SignalBus
func _debug_add_transition():
	print("Debug Add Transition Fired!")
	change_state("AddingTransition",$StateMachine.curr_state.name)
	
func change_state(new_state,old_state):
	$StateMachine.transition_to_state(new_state)
#	
func _debug_add_state():
	change_state("AddingState",$StateMachine.curr_state.name)
	
func _add_state_finalize():
	change_state("Idle",$StateMachine.curr_state.name)
	
func _add_transition_finalize(transition_points):
	change_state("Idle",$StateMachine.curr_state.name)	
	
func undo():
	var node_to_pop = $UndoStack.get_child($UndoStack.get_child_count()-1)
	if node_to_pop != null:
		node_to_pop.undo()
		node_to_pop.reparent($RedoStack)
	else:
		print("Undo stack empty!")
	
# Clear redo stack when a new command is added
# Pop an action to the undo stack 
func redo():
	var node_to_pop = $RedoStack.get_child($RedoStack.get_child_count()-1)
	if node_to_pop != null:
		node_to_pop.do()
		node_to_pop.reparent($UndoStack)
	else:
		print("Redo stack empty!")


func _mark_debug_state():
	change_state("MarkResetState",$StateMachine.curr_state.name)
func _mark_debug_state_finalize(idx):
	for child in $"../States".get_children():
		if child.idx == idx:
			child.mark_as_reset()
		else:
			child.clear_as_reset()
	change_state("Idle",$StateMachine.curr_state.name)
	
# This information is tracked here because what if the user wants to delete a state?
# what's better is that we should have a mouse_over_transition as well. But that's a lot to track.
# Maybe we should have global unique ids, and just track those? That's much smarter.
# I'll refactor the code to add that later.
func _mouse_over_state(idx):
	if not mouse_in_state.has(idx):
		mouse_in_state.append(idx)
func _mouse_left_state(idx):
	while mouse_in_state.has(idx):
		mouse_in_state.erase(idx)
		
func get_state_info()->Array:
	# Create the state array objects
	var state_array : Array
	for child in $"../States".get_children():	
		state_array.append(child.get_state_object())
	return state_array		

# Since the IO array is built by the FSM Settings box (not yet added and extracted from the diagram)
# we'll need to build this elsewhere - the "FSM Settings" will emit a signal which will fill in that 
# data on close, at which point the user can return it from here.	
func get_io_info()->Array: 
	return self.io_info

# We should ask each transition object to return a data object that describes itself - we'll do the same 
# thing with states	
func get_transition_info()->Array:
	var io_info_array : Array
	for child in $"../Transitions".get_children():
		io_info_array.append(child.transition_info())
	return self.io_info
