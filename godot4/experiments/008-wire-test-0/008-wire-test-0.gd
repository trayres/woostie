extends Node2D

@onready var cursor_pos : Vector2i 
var num_click : int = 0 # For experimentation only


# Called when the node enters the scene tree for the first time.
func _ready():
	#$Cursor.connect("cursor_moved",_cursor_moved)
	SignalBus.connect("cursor_moved",_cursor_moved)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _input(event):
	if event is InputEventMouseMotion:
		# This is just giving us an idea of where we are
		var mp_current = get_global_mouse_position()
		$CanvasLayer/MousePos.text = str(mp_current)
	if Input.is_action_just_released("click"):
		print("still seeing clicks")
		SignalBus.dbg_draw_wire.emit(cursor_pos)
		# The first time through the loop, let's move the randomly added point to our grid
#		num_click += 1
#		if num_click==1:
#			$Connector.move_connector(cursor_pos)
#		else:
			
		# From this point I could just distribute events to the controller
		# But am I "working against" the notion of scenes and nodes here?

func _cursor_moved(glbl_pos:Vector2i):
	cursor_pos = glbl_pos
	print("_cursor moved in 008 wire test 0 ")
	#$Connector.move_connector(glbl_pos)
		


func _on_cursor_cursor_moved(glbl_pos):
	cursor_pos = glbl_pos # Replace with function body.
	print("cursor_pos from _on_cursor_cursor_moved:",cursor_pos)
