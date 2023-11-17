class_name StateMachine
extends Node


# This state machine hold all substates in its hierarchy, and passes through
# signals for handling to the substates. Although we don't really need substate
# handling of things like physics process ticks and events, we could!
# I'm still working it out.

signal transitioned(state_name)

@export var initial_state := NodePath()
@onready var curr_state : State = get_node(initial_state)
var states : Dictionary = {}
var prev_state

# Called when the node enters the scene tree for the first time.
func _ready():
	#await owner.ready
	for child in get_children():
		if child is State:
			states[child.name] = child # add to the states dictionary

	# Setup various child state variables
	$AddingState.states = $"../../States"
	# Finally, go to the initial state
	curr_state.enter()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if curr_state:
		curr_state.update(delta)
	
func _physics_process(delta):
	if curr_state:
		curr_state.physics_update(delta)

func _unhandled_input(event):
	if curr_state:
		curr_state.handle_input(event)
func _input(event):
	if curr_state:
		curr_state.handle_input(event)	

func transition_to_state(new_state):
	print("calling curr_state.exit on state:",curr_state.name)
	curr_state.exit()
	prev_state = curr_state.name
	curr_state = states[new_state]
	print("entering new state:",curr_state)
	curr_state.enter()
			
#func _input(event):
#	if curr_state:
#		curr_state.handle_input(event)		
