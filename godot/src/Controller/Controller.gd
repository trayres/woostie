extends Node2D
#var State = preload("res://src/State/State.tscn")
var KineticState = preload("res://src/KineticState/Kinetic State.tscn")
var KineticTransitionAnchor = preload("res://src/KineticTransitionAnchor/Kinetic Transition Anchor.tscn")
var next_state_index : int = 0 #just an upcounter

func _ready():
	# Setup the 'Commands' node
	#$Commands.setup($States)
	$"CanvasLayer/MenuBar".connect("undo",self,"undo")
	$"CanvasLayer/MenuBar".connect("redo",self,"redo")
	# Setup the command
	#$Commands.add_child(aCommand.add_state($States, next_state_index,Vector2(50,50)))
	
	add_state(Vector2(50,50))
	#add_state(Vector2(300,300))
	yield(get_tree().create_timer(1.0), "timeout")
	set_state_selected(0)
	yield(get_tree().create_timer(1.0), "timeout")
	clear_states_selected()
	add_transition_anchor(Vector2(100,100))
	yield(get_tree().create_timer(1.0), "timeout")
	for a_command in $Commands.get_children():
		a_command.delete_state()
	
	
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

# Pop a command from the DoStack to the RedoStack
func undo():
	var node_to_pop = $DoStack.get_child(0)
	if node_to_pop != null:
		if node_to_pop is StateCommand:
			node_to_pop.delete_state()
		reparent(node_to_pop,$RedoStack)
	else:
		print("Undo stack empty!")
	


# Clear redo stack when a new command is added
# Pop an action to the undo stack 
func redo():
	var node_to_pop = $RedoStack.get_child(0)
	if node_to_pop != null:
		if node_to_pop is StateCommand:
			node_to_pop.add_state()
		reparent(node_to_pop,$DoStack)
	else:
		print("Redo stack empty!")

# Create a command, add it to the DoStack
# This is the Mk1 edition#
func add_state(position : Vector2):	
	var aCommand = StateCommand.new()
	aCommand.setup($States,$Transitions,next_state_index,position)
	aCommand.add_state()
	$DoStack.add_child(aCommand)
	next_state_index += 1	
	
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
