extends Node

# The controller acts as an intermediary between the SignalBus and the scene tree.
# It also houses the business logic - think "Controller" in the MVC pattern.
# The controller also passes through signals to the FSM so that they can be delegated
# to the current state, thus localizing the control logic.

var transition = preload("res://actors/Transition/Transition-Mk1.tscn")
var state = preload("res://actors/State-Area2D/State-Area2D.tscn")

var fsm_name : String 


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
#	# This is in case we want to filter the actions on transitions 
#	# but it doesn't look like we're using it at all.
#	# TODO: Refactor, remove totally.
#	print("new_state in change state is: ",new_state)
#	print("old_state in change state is: ",old_state)
#	match old_state:
#		"Idle":
#			match new_state:
#				"AddingState": # Idle->AddingState
#					$StateMachine.transition_to_state(new_state)
#				"AddingTransition": # Idle -> AddingTransition
#
#				_:
#					print("Idle->SOMETHING transition UNMATCHED!")
#		"AddingState":
#			match new_state:
#				"Idle": #AddingState->Idle 
#					$StateMachine.transition_to_state(new_state)
#				_:
#					print("AddingState->SOMETHING transition UNMATCHED!")
#		"AddingTransition":
#			match new_state:
#				"Idle":
#					$StateMachine.transition_to_state(new_state)
#		_:
#			print("OLD STATE UNMATCHED ERROR")					
##	if new_state is AddingState:
##		print("Idle to adding state in Controller!")
func _debug_add_state():
	change_state("AddingState",$StateMachine.curr_state.name)

# This functionality was "Localized" by connecting these UI components directly
# To the SignalBus (rather than having them run through the controller)
#func _update_statusbar_ll_label(newstring : String):
#	$"../ControlLayer/StatusBar-Panel/MarginContainer/Label-LL".text=newstring
	
func _add_state(glbl_pos : Vector2):
	var astate = state.instantiate()
	astate.setup(glbl_pos)
	$"../States".add_child(astate)
	
func _add_transition():
	#TODO Encapsulate this into a Command object and add it to the undo/redo stack
	var atransition = transition.instantiate()
	print("Adding Mk1 Transition")
	atransition.setup(Vector2(200,200),Vector2(400,400))
	$Transitions.add_child(atransition)
	
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

func get_state_array()->Array:
	# Create the state array objects
	var state_array : Array
	for child in $"../States".get_children():	
		var a_state_object = StateDataObject.new()
		a_state_object.state_name = child.get_state_name()
		a_state_object.idx = child.get_state_idx()
		if child.is_reset_state():
			a_state_object.is_reset_state = true
		else:
			a_state_object.is_reset_state = false
		state_array.append(a_state_object)
	return state_array
func _mark_debug_state():
	change_state("MarkResetState",$StateMachine.curr_state.name)
func _mark_debug_state_finalize(idx):
	print("BACK IN CONTROLLER MARKING STATE:",idx)
