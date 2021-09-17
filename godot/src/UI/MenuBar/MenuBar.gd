extends MarginContainer

signal copy
signal delete
signal undo
signal redo
signal add_state
signal add_transition

# The structure of this essentially just passes menu options through as signals
# to be handled in a higher level. This disconnects the HUD layer and allows it 
# to be replaced by something fancier looking, or to be replicated other ways

# Also note: A signal like "delete" obviously relies on a separate controller 
# to interpret that signal

func _ready() -> void:
	$HBoxContainer/FileMenu.get_popup().connect("id_pressed",self,"_on_FileMenu_pressed")
	$HBoxContainer/EditMenu.get_popup().connect("id_pressed",self,"_on_EditMenu_pressed")
	$HBoxContainer/ToolsMenu.get_popup().connect("id_pressed",self,"_on_ToolsMenu_pressed")
func _on_FileMenu_pressed(id) -> void:
	print("filemenu id:"+str(id))

func _on_EditMenu_pressed(id) -> void:
	print("editmenu id:"+str(id))
	if id==0:
		pass
	elif id==1:
		pass
	elif id==2:
		emit_signal("undo")
	elif id==3:
		emit_signal("redo")
	
func _on_ToolsMenu_pressed(id) -> void:
	if id==0:
		emit_signal("add_state")
	elif id==1:
		emit_signal("add_transition")
	
