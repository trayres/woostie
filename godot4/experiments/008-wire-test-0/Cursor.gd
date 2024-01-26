extends Node2D

# signal cursor_moved(glbl_pos : Vector2i)
# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _input(event):
	if event is InputEventMouseMotion:
		var mp_current = get_global_mouse_position()
		SignalBus._mouse_moved(mp_current) # broadcasting this through SignalBus allows us to 
		# update the global mouse XY loc very easily
		var mp_x = mp_current.x / 40
		var mp_y = mp_current.y / 40

		var temp_pos : Vector2
		var closest_pos : Vector2
		var idx : int = 0
		for y in range(mp_y-1,mp_y+2):
			for x in range(mp_x-1,mp_x+2):
				temp_pos = Vector2(40*x,40*y)
				if(idx==0):
					closest_pos = temp_pos
				
				if(mp_current.distance_squared_to(temp_pos)< mp_current.distance_squared_to(closest_pos)):
					closest_pos = temp_pos
				idx=idx+1
		if $".".global_position != closest_pos:
			$".".global_position = closest_pos
			#cursor_moved.emit(closest_pos)
			SignalBus.cursor_moved.emit(closest_pos)
			#SignalBus.cursor_overlapped = await $"../AreaDetector".get_overlapped_items(closest_pos)
			#print("cursor moved to:",closest_pos)

# Cursor: Draw Thyself		
func _draw():
	draw_line(Vector2i(0,-40),Vector2i(0,40),Color.BLACK,1.5)
	draw_line(Vector2i(-40,0),Vector2i(40,0),Color.BLACK,1.5)
