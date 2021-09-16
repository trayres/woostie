extends Node2D
#var State = preload("res://src/State/State.tscn")
var AddStateCommand  = preload("res://src/Commands/AddStateCommand.gd")
var MoveStateCommand = preload("res://src/Commands/MoveStateCommand.gd")
var KineticState = preload("res://src/KineticState/Kinetic State.tscn")
var KineticTransitionAnchor = preload("res://src/KineticTransitionAnchor/Kinetic Transition Anchor.tscn")
var next_state_index : int = 0 #just an upcounter

func _ready():
	# Connect UI layer to controller
	$"CanvasLayer/MenuBar".connect("undo",self,"undo")
	$"CanvasLayer/MenuBar".connect("redo",self,"redo")
	
	
	#add_state(Vector2(300,300))
	#yield(get_tree().create_timer(1.0), "timeout")
	#set_state_selected(0)
	#yield(get_tree().create_timer(1.0), "timeout")
	#clear_states_selected()
	#add_transition_anchor(Vector2(100,100))
	#yield(get_tree().create_timer(1.0), "timeout")
	#for a_command in $Commands.get_children():
	#	a_command.delete_state()
	
	
# Physics Process	
func _process(delta):
	if Input.is_action_pressed("left_click"):
		for astate in $States.get_children():
			if not astate.dragging:
				astate.clear_selected()
		

###############################################################################
#                           State Operations                                  #
###############################################################################
# Add a state
# TODO: This is being replaced by the COMMAND
# This is the original adding of a state. This has been replaced by the command 
# based invocation, to give us undo functionality.
#func add_state( pos : Vector2) -> KinematicBody2D:
#	var a_state = KineticState.instance()
#	a_state.setup(next_state_index,pos)
#	next_state_index += 1
#	$States.add_child(a_state)
#	return a_state

# Create a command, add it to the DoStack
# This is the Mk1 edition#
#func add_state(position : Vector2):	
#	var aCommand = StateCommand.new()
#	aCommand.setup($States,$Transitions,next_state_index,position)
#	aCommand.add_state()
#	$DoStack.add_child(aCommand)
#	next_state_index += 1	

# Mk2 edition, with the undo/redo based commands	
func add_state(position:Vector2):
	var aCommand = AddStateCommand.new()
	#controller, states, transitions,position,idx
	aCommand.setup(self, $States, $Transitions, position,next_state_index)
	next_state_index += 1
	aCommand.do()
	$UndoStack.add_child(aCommand)
	

# Pop a command from the DoStack to the RedoStack
# NOTE: TODO: This needs to be fixed.
func undo():
	var node_to_pop = $UndoStack.get_child($UndoStack.get_child_count()-1)
	if node_to_pop != null:
		node_to_pop.undo()
		reparent(node_to_pop,$RedoStack)
	else:
		print("Undo stack empty!")
	


# Clear redo stack when a new command is added
# Pop an action to the undo stack 
func redo():
	var node_to_pop = $RedoStack.get_child($RedoStack.get_child_count()-1)
	if node_to_pop != null:
		node_to_pop.do()
		reparent(node_to_pop,$UndoStack)
	else:
		print("Redo stack empty!")
	
func add_transition_anchor(position:Vector2) -> KinematicBody2D:
	var a_transition_anchor = KineticTransitionAnchor.instance()
	a_transition_anchor.set_position(position)
	a_transition_anchor.input_pickable=true
	a_transition_anchor.connect("detach",self,"transition_anchor_detatch")
	$Transitions.add_child(a_transition_anchor)
	return a_transition_anchor

# Set a state as selected
func set_state_selected(idx:int)->void:
	for astate in $States.get_children():
		if astate.idx == idx:
			astate.set_selected()

# Clear all selected
func clear_states_selected()->void:
	for astate in $States.get_children():
		astate.clear_selected()

func transition_anchor_detatch(a_transition_anchor):
	for astate in $States.get_children():
		astate.transition_anchors.erase(a_transition_anchor)
			
func reparent(child: Node, new_parent: Node):
	var old_parent = child.get_parent()
	old_parent.remove_child(child)
	new_parent.add_child(child)	

# This is the user action of moving a state, and should be captured in the undo stack
func _state_moved(state,start_position, final_position):
	var aCommand = MoveStateCommand.new()
	aCommand.setup($States, state,start_position,final_position)
	$UndoStack.add_child(aCommand)
	# Note: Because the node is already moved, we don't need to .do() it here.
	# It is effectively already done, but .do() and .undo() need to both exist for
	# the symmetry of implementation in the undo stack


func _on_DebugTimer_timeout() -> void:
	add_state(Vector2(50,50))
