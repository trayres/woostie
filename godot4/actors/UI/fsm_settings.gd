extends Window

@export var controller : Node
# Called when the node enters the scene tree for the first time.
func _ready():
	SignalBus.connect("show_fsm_settings",_show_fsm_settings)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
func _debug_setup():
	var fsm_name : String = "myFSM"
	
func setup(fsm_name:String,state_array, io_array,transition_array : Array):
	# The setup function distributes all the objects to the UI. It assumes another function has
	# gathered all the data to present it (the _about_to_popup method)
	$"TabContainer/State Machine/VBoxContainer/Name/NameLineEdit".text = fsm_name
	
	
func _show_fsm_settings()->void:
	popup()


func _on_close_requested():
	#Save all the values back to the controller on closing
	controller.fsm_name = $"TabContainer/State Machine/VBoxContainer/Name/NameLineEdit".text
	hide()
	


func _on_about_to_popup():
	# Grab all the data from the controller
	# The FSM name we can access and store directly
	var fsm_name = controller.fsm_name
	#var state_array : Array = controller.get_state_array()
	#var io_array : Array = controller.get_io_array()
	#var transition_array : Array = controller.get_transition_array()
	setup(fsm_name,[],[],[])
	
