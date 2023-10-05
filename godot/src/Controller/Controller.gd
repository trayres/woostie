extends Node2D
#var State = preload("res://src/State/State.tscn")
# Commands
var AddStateCommand  = preload("res://src/Commands/AddStateCommand.gd")
var MoveStateCommand = preload("res://src/Commands/MoveStateCommand.gd")
var AddTransitionCommand = preload("res://src/Commands/AddTransitionCommand.gd")
var KineticState = preload("res://src/KineticState/Kinetic State.tscn")
var KineticTransitionAnchor = preload("res://src/KineticTransitionAnchor/Kinetic Transition Anchor.tscn")
var Transition = preload("res://src/CubicBezier/CubicBezier_MK1/Transition.tscn")
var next_state_index    : int = 0 # just an upcounter
var next_transition_idx : int = 0 # just an upcounter

# Temporary Transition Anchor Points
var pts : Array 

enum SYS_STATE{
	IDLE,
	ADDING_STATE,
	ADDING_TRANSITION
}

var current_state = SYS_STATE.IDLE

var mouse_xy_current : Vector2 = Vector2.ZERO

func _ready():
	# Connect UI layer to controller
	$CanvasLayer/MenuBar.connect("undo",self,"undo")
	$CanvasLayer/MenuBar.connect("redo",self,"redo")
	$CanvasLayer/MenuBar.connect("add_state",self,"add_state_cmd")
	$CanvasLayer/MenuBar.connect("add_transition",self,"add_transition_cmd")
	$CanvasLayer/MenuBar.connect("show_transition_achors",self,"show_transition_achors_cmd")
	
	#add_state(Vector2(300,300))
	#yield(get_tree().create_timer(1.0), "timeout")
	#for astate in $States.get_children():
	#	astate.set_as_reset()
	
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
	if current_state == SYS_STATE.IDLE:
		if Input.is_action_just_pressed("left_click"):
			for astate in $States.get_children():
				if not astate.dragging:
					astate.clear_selected()
	
	if current_state == SYS_STATE.ADDING_STATE:
		if Input.is_action_just_pressed("left_click"):
			add_state(mouse_xy_current)
			change_state(SYS_STATE.IDLE)
		if Input.is_action_just_pressed("ui_cancel"):
			change_state(SYS_STATE.IDLE)
	

		

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
	
# This is the signal from a state - it fires the popup	
func _set_state_name(state_name,idx) -> void:
	$"CanvasLayer/Set State Name".setup(state_name,idx)
	$"CanvasLayer/Set State Name".popup_centered()


func _input(event):
	if event is InputEventMouseMotion:
		get_mouse_pt()
		if current_state==SYS_STATE.ADDING_STATE:
			update()
	if event is InputEventMouseButton:
		if current_state==SYS_STATE.ADDING_TRANSITION:
			if event.button_index == BUTTON_LEFT and event.pressed:
				if pts.size()==3:
					pts.append(mouse_xy_current)
					add_transition(next_transition_idx,pts)
					next_transition_idx += 1
					pts.clear()
					change_state(SYS_STATE.IDLE)
				else:
					pts.append(mouse_xy_current)
					change_state(SYS_STATE.ADDING_TRANSITION)
	
func _on_DebugTimer_timeout() -> void:
	#add_state(Vector2(50,50))
	#add_state(Vector2(250,350))
	#add_state(Vector2(550,550))
	#add_transition_anchor(Vector2(100,100))
	#var aTransition = AddTransitionCommand.new()
	#var dbg_transition_pts = [Vector2(600,600),Vector2(650,650),Vector2(700,650),Vector2(750,600)]
	#aTransition.setup(self,$States,$Transitions,dbg_transition_pts,1)
	#aTransition.do()
	pass

# This is where the "lifting" of adding a transition takes places	
func add_transition(transition_idx,node_positions)->void:
	var aTransitionCmd = AddTransitionCommand.new()	
	aTransitionCmd.setup( self, $States, $Transitions, node_positions, transition_idx)
	aTransitionCmd.do()
	# Add it to the undo stack
	$UndoStack.add_child(aTransitionCmd)
	
func add_state_cmd() -> void:
	change_state(SYS_STATE.ADDING_STATE)
	#if current_state == SYS_STATE.IDLE:
	#	current_state = SYS_STATE.ADDING_STATE

# This comes from the GUI layer - it kicks off the process of adding a transition
func add_transition_cmd() -> void:
	change_state(SYS_STATE.ADDING_TRANSITION)

func get_mouse_pt():
	mouse_xy_current = get_global_mouse_position()
	#print(str(mouse_xy_current))
	$"CanvasLayer/Status Bar".set_MousePosLabel(mouse_xy_current)
	
func _draw() -> void:
	if current_state == SYS_STATE.ADDING_STATE:
		draw_circle(mouse_xy_current,50.0,Color(0.22,0.77,0.22))
	if current_state == SYS_STATE.ADDING_TRANSITION:
		pass
		
# This is to localize secondary actions that need to take place as a result 
# of switching states - calling update() on the image, updating the statuslabel,
# things like that.		
func change_state(next_state) -> void:
	# Update the status label
	if next_state == SYS_STATE.IDLE:
		$"CanvasLayer/Status Bar".set_StatusLabel("Idle")
	elif next_state == SYS_STATE.ADDING_STATE:
		$"CanvasLayer/Status Bar".set_StatusLabel("Adding State")
	elif next_state == SYS_STATE.ADDING_TRANSITION:
		$"CanvasLayer/Status Bar".set_StatusLabel("Adding Transition Point "+str(pts.size())+" of 4")
	# Force a graphical update in a few cases
	if current_state == SYS_STATE.IDLE:
		if next_state == SYS_STATE.ADDING_STATE:
			current_state = SYS_STATE.ADDING_STATE
		if next_state == SYS_STATE.ADDING_TRANSITION:
			current_state = SYS_STATE.ADDING_TRANSITION
	if current_state == SYS_STATE.ADDING_STATE:
		if next_state == SYS_STATE.IDLE:
			current_state = SYS_STATE.IDLE
			update()
	if current_state == SYS_STATE.ADDING_TRANSITION:
		if next_state == SYS_STATE.IDLE:
			current_state = SYS_STATE.IDLE
			update()
		if next_state == SYS_STATE.ADDING_TRANSITION:
			update()

# From the UI layer's checkbox for 'Force Show Transition Anchors'
func show_transition_achors_cmd(show_transition_achors : bool)->void:
	#print("SHOW TRANSITION ANCHORS?:"+str(show_transition_achors))
	if show_transition_achors:
		for atransition in $Transitions.get_children():
			atransition.set_force_show_transition_anchors()
	else:
		for atransition in $Transitions.get_children():
			atransition.clear_force_show_transition_anchors()


# From $"Set State"'s ACCEPT button
func _on_Set_State_Name_set_state_name(idx,name) -> void:
	#print("SET IDX:"+str(idx)+" with NAME:" + name)
	for astate in $States.get_children():
		if astate.idx==idx:
			astate.setup_state(name)

func transition_anchor_moved(transition_idx, node_idx, start_position, final_position)->void:
	pass
	# TODO: Generate an event which can be undone.
	#print("Transition anchor moved event fired")
	#print("transition_idx:"+str(transition_idx))
	#print("node_idx:"+str(node_idx))
	#print("start_position:"+str(start_position))
	#print("final_position:"+str(final_position))
	
func change_transition_properties(transition_idx,priority,transition_eqn)->void:
	print("Setting up transition equation!")
	$"CanvasLayer/Set Transition Equation".setup(transition_idx,priority,transition_eqn)
	$"CanvasLayer/Set Transition Equation".popup_centered()


func _on_Set_Transition_Equation_set_transition_priority_and_eqn(transition_idx, priority, transition_eqn) -> void:
	print("_on_Set_Transition_Equation_set_transition_priority_and_eqn")
	print("transition_idx:"+str(transition_idx))
	print("priority:"+str(priority))
	print("transition_eqn:"+str(transition_eqn))
	for atransition in $Transitions.get_children():
		if atransition.transition_idx == transition_idx:
			atransition.set_priority_and_transition_eqn(priority,transition_eqn)


# This signal comes from the menubar, and indicates 
func _on_MenuBar_generate_code() -> void:
	var _str : String
	for astate in $States.get_children():
		
		_str += "State:"+astate.state_name+"\n"
		_str += "Printing transition connections to this state:\n"
		
		if astate.transition_anchors_head.size() > 0:
			for head_connection in astate.transition_anchors_head:
				_str += "State head transition index:"+str(head_connection.get_transition_idx())+"\n"
		if astate.transition_anchors_tail.size() > 0:
			for tail_connection in astate.transition_anchors_tail:
				_str += "State tail transition index:"+str(tail_connection.get_transition_idx())+"\n"
			
	print("Printing _str:\n"+_str)
	#for atransition in $Transitions.get_children():
	#	print("Transition:"+str(atransition.transition_idx))
	# TODO: Add code generation
	$CanvasLayer/CodeGen.popup_centered()

# This function scrapes all the states, transitions, and other retained data
# of the controller to generate DataObjects used to actually generate the HDL
func generate_data_object_array() ->void:
	pass
