extends State

func enter():
	print("Entering the Idle state!")
	_update_statusbar_ll_label("Idle")
	
func _update_statusbar_ll_label(newstring : String):
	$"../../../ControlLayer/StatusBar-Panel/MarginContainer/Label-LL".text=newstring
	
# Called when the node enters the scene tree for the first time.
func _ready():
#	await owner.ready
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func handle_input(event):
	pass
	#print("idle state is handling event:",event)
	#self.get_viewport().set_input_as_handled()
