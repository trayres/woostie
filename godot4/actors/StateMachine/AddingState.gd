extends State
class_name AddingState

var command_addstate = preload("res://actors/Commands/AddStateCommand.gd")
@onready var states = $"../../../States"
var state_idx = 0

func handle_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("click"):
		# The below is hackyugly and not "really" needed: the Controller keeps
		# the global mouse position at all times (except if a pop up is getting 
		# mouse events, which seems fine) but the other way would "hardcode"
		# using that "path"
		_add_state_at($"../../..".get_global_mouse_position())
		get_viewport().set_input_as_handled()
		
# We shouldn't need to handle much here; global position is already reported
func update(_delta:float) -> void:
	pass
func physics_update(_delta:float)->void:
	pass

func enter()->void:
	SignalBus.update_statusbar_ll_label.emit("Adding State")
	SignalBus.show_dummy_state.emit()

func exit()->void:
	SignalBus.hide_dummy_state.emit()

func _add_state_at(glbl_pos:Vector2)->void:
	# We don't add the state directly - rather we do the work here to create 
	# and dispatch the command to do so, and add it to the undo/redo stack.
	# This allows for the undo/redo functionality
	var astate_cmd = command_addstate.new()
	astate_cmd.setup(state_idx,glbl_pos,states) 
	state_idx += 1
	astate_cmd.do()
	$"../../UndoStack".add_child(astate_cmd)
	SignalBus.add_state_finalize.emit()	
