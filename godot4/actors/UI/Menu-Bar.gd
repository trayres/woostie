extends PanelContainer


# Called when the node enters the scene tree for the first time.
func _ready():
	# Hook up the menu buttons to their functions
	$MarginContainer/HBoxContainer/FileMenu.get_popup().id_pressed.connect(_on_filemenu_pressed)
	$MarginContainer/HBoxContainer/EditMenu.get_popup().id_pressed.connect(_on_editmenu_pressed)
	$MarginContainer/HBoxContainer/ToolsMenu.get_popup().id_pressed.connect(_on_toolsmenu_pressed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _on_filemenu_pressed(id:int):
	match id:
		0:
			SignalBus.new_file.emit()
		1:
			print("Something else")
		_: 
			print("Unhandled")
func _on_editmenu_pressed(id:int):
	print("Edit menu item ",id," pressed")
	match id:
		0:
			SignalBus.edit_undo.emit()
		1:
			SignalBus.edit_redo.emit()
		2:
			SignalBus.edit_delete.emit()
		_:
			print("Unhandled Edit menu item pressed!")

func _on_toolsmenu_pressed(id:int):
	print("Tools menu item ",id," pressed")	
	match id:
		0:
			print("Firing debug add transition signal")
			SignalBus.dbg_add_transition.emit()
		1:
			print("Firing debug add state signal")
			SignalBus.dbg_add_state.emit()
		2:
			print("Firing debug FSM Setup")
			SignalBus.show_fsm_settings.emit()
		3: 
			print("Firing mark debug state")
			SignalBus.mark_debug_state.emit()
		4:
			print("Generate Code")
			SignalBus.generate_code.emit()
		_:
			print("Unhandled toolsmenu ID!")
		
