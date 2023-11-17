extends PanelContainer


# Called when the node enters the scene tree for the first time.
func _ready():
	SignalBus.connect("mouse_pos_update",update_mouse_pos)
	SignalBus.connect("update_statusbar_ll_label",update_statusbar_ll_label)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# Update signals - meant to be called from the SignalBus
func update_mouse_pos(glbl_mouse_pos:Vector2):
	$"MarginContainer/Label-LR".text = "("+str(int(glbl_mouse_pos.x))+","+str(int(glbl_mouse_pos.y))+")"
func update_statusbar_ll_label(newstring : String): 
	$"MarginContainer/Label-LL".text=newstring
