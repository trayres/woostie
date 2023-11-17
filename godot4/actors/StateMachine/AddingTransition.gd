extends State
class_name AddingTransition

enum AddingTransitionsProcess {IDLE, ADDING_POINTS,FINALIZE}

var command_addtransition = preload("res://actors/Commands/AddTransitionCommand.gd")
@onready var transitions = $"../../../Transitions"
var transition_idx = 0
var transition_points = []

func handle_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("click"):
		if len(transition_points) != 2:
			var clicked_pos = $"../../..".get_global_mouse_position()
			transition_points.append(clicked_pos)
		if len(transition_points) == 2:
			# do work to leave this state
			_add_transition(transition_points)
		get_viewport().set_input_as_handled()
		
	
func update(_delta:float) -> void:
	pass
	
func physics_update(_delta:float)->void:
	pass

func enter()->void:
	SignalBus.update_statusbar_ll_label.emit("Adding Transition")
	transition_points = []

func exit()->void:
	pass
func _add_transition(transition_points)->void:
	var atransition = command_addtransition.new()
	atransition.setup(transition_idx,transition_points,transitions)
	# Now that it's setup: do the command
	atransition.do()
	# Now that it's done, add it to the undo/redo stack
	$"../../UndoStack".add_child(atransition)
	# increment the transition index
	transition_idx += 1
	# then signal that we're done!
	SignalBus.add_transition_finalize.emit(transition_points)
