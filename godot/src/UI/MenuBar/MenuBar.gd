extends MarginContainer

signal copy
signal delete
signal undo
signal redo
signal add_state
signal add_transition
var    l_show_transition_anchors : bool = false
signal show_transition_achors(l_show_transition_anchors)



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
	elif id==2:
		l_show_transition_anchors = not l_show_transition_anchors
		$HBoxContainer/ToolsMenu.get_popup().set_item_checked(2,l_show_transition_anchors)
		emit_signal("show_transition_achors",l_show_transition_anchors)

