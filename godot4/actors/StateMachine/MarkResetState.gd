extends State
class_name MarkResetState

var state_idx : int

# Called when the node enters the scene tree for the first time.
func enter()->void:
	SignalBus.update_statusbar_ll_label.emit("Select a reset state")
	SignalBus.mouse_over_state.connect(_mouse_over_state) # Replace with function body.
	SignalBus.mouse_left_state.connect(_mouse_left_state)

func exit()->void:
	SignalBus.mouse_over_state.disconnect(_mouse_over_state)
	SignalBus.mouse_left_state.disconnect(_mouse_left_state)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
func update(_delta:float) -> void:
	pass
func physics_update(_delta:float)->void:
	pass	
func handle_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("click"):
		SignalBus.mark_debug_state_finalize.emit(state_idx)
		print("Finalizing marking of debug state with index:",state_idx)
		get_viewport().set_input_as_handled()
	
func _mouse_over_state(idx):
	print("mouse over state from signalbus:",idx)
	state_idx = idx
func _mouse_left_state(idx):
	# I don't think we really need this. Let's just look at the most recently entered state.
	print("mouse left state from signalbus",idx)
	#state_idx = idx
