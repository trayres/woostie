extends Node2D

var has_cursor : bool
enum WIRE_STATES {IDLE,SETTING_DIRECTION,ADDING_TEMP, ADDING_FINISHED,SELECT_BRANCH,DRAG}
var state : WIRE_STATES = WIRE_STATES.IDLE
var segment_start : Vector2i
var dir_set : bool = false
var dir    : Vector2i
var cursor_pos : Vector2i
var segments : Array
# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("connectors") # Replace with function body.
	#TODO: Just for the first time through
	global_position = Vector2i(200,200)
	# Here we'll insert a command from the signal bus to begin drawing
	# and other operations
	# Start the command from the SignalBus
	# That disconnects it so we can run the control through a controlling machine
	SignalBus.dbg_draw_wire.connect(_dbg_draw_wire)
	SignalBus.connect("cursor_moved",_on_cursor_cursor_moved)
func _input(event):
	if event is InputEventMouseButton:
		if event.double_click:
			state = WIRE_STATES.IDLE
	match state:
		WIRE_STATES.IDLE:
			if Input.is_action_just_pressed("click") and has_cursor:
				state = WIRE_STATES.SETTING_DIRECTION
				segment_start = cursor_pos # Change this to be a signal we emit which
				# is processed by a controller for the Connector? Or is that overwrought? 
		WIRE_STATES.SETTING_DIRECTION:
			var vector_from_start : Vector2i
			var mp : Vector2i = get_global_mouse_position()
			vector_from_start = mp - segment_start
			print("vector_from_start:",vector_from_start)
			if sqrt(vector_from_start.x*vector_from_start.x+vector_from_start.y*vector_from_start.y)<sqrt(2)*20:
				print("RESETTING DIRECTION VALUE")
				dir_set = false
			if sqrt(vector_from_start.x*vector_from_start.x+vector_from_start.y*vector_from_start.y)>sqrt(2)*20:
				print("SETTING DIRECTION")
				dir_set = true
				# First look at the magnitudes: if x>y, it's horizontal, else it's vertical
				if vector_from_start.x*vector_from_start.x > vector_from_start.y*vector_from_start.y:
					if vector_from_start.x >0:
						dir = Vector2i(1,0)
					else:
						dir = Vector2i(-1,0)
				else:
					if vector_from_start.y > 0:
						dir = Vector2i(0,-1) # - direction is up. Don't blame me blame history.
					else:
						dir = Vector2i(0,1)
				state = WIRE_STATES.ADDING_TEMP
		WIRE_STATES.ADDING_TEMP:
			var vector_from_start : Vector2i
			var mp : Vector2i = get_global_mouse_position()
			vector_from_start = mp - segment_start			
			if sqrt(vector_from_start.x*vector_from_start.x+vector_from_start.y*vector_from_start.y)<sqrt(2)*20:
				print("RESETTING DIRECTION VALUE")
				dir_set = false
				state = WIRE_STATES.SETTING_DIRECTION			
			# If horizontal, draw horizontal first
			# else draw vertical first
			if Input.is_action_just_pressed("click"):
				segments.append(segment_start)
				
				if dir == Vector2i(-1,0) or dir==Vector2i(1,0):
					var temp_pt = calculate_temp_point(segment_start,cursor_pos,0)
					segments.append(temp_pt)
					segments.append(cursor_pos)
				else:
					var temp_pt = calculate_temp_point(segment_start,cursor_pos,1)
					segments.append(temp_pt)
					segments.append(cursor_pos)		
				segment_start = cursor_pos	
				state = WIRE_STATES.SETTING_DIRECTION		
						

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _draw():
	# Top of box
	draw_line(Vector2(-15,15),Vector2(15,15),Color.AQUAMARINE,1.5)
	# Left side
	draw_line(Vector2(-15,15),Vector2(-15,-15),Color.AQUAMARINE,1.5)
	# Right side
	draw_line(Vector2(15,15),Vector2(15,-15),Color.AQUAMARINE,1.5)
	# Bottom of box
	draw_line(Vector2(-15,-15),Vector2(15,-15),Color.AQUAMARINE,1.5)
	if state==WIRE_STATES.ADDING_TEMP and dir_set:
		if dir==Vector2i(1,0) or dir==Vector2i(-1,0): # horizontal first
			# Get the local x value 
			var x_cursor = cursor_pos.x - global_position.x
			#draw_line(to_local(global_position),to_local(Vector2(cursor_pos.x,global_position.y)),Color.GREEN,4)
			#draw_line(to_local(Vector2(cursor_pos.x,global_position.y)),to_local(Vector2(cursor_pos.x,cursor_pos.y)),Color.CRIMSON,4)
			var temp_pt = calculate_temp_point(segment_start,cursor_pos,0)
			draw_line(to_local(segment_start),to_local(temp_pt),Color.GREEN,4)
			draw_line(to_local(temp_pt),to_local(cursor_pos),Color.CRIMSON,4)
			#draw_line(to_local(global_position),to_local(cursor_pos),Color.BLUE,4)
		elif dir==Vector2i(0,1) or dir==Vector2i(0,-1):
			#draw_line(to_local(global_position),to_local(Vector2(global_position.x,cursor_pos.y)),Color.BLUE,4)
			#draw_line(to_local(Vector2(global_position.x,cursor_pos.y)),to_local(cursor_pos),Color.YELLOW,4)
			var temp_pt = calculate_temp_point(segment_start,cursor_pos,1)
			draw_line(to_local(segment_start),to_local(temp_pt),Color.BLUE,4)
			draw_line(to_local(temp_pt),to_local(cursor_pos),Color.YELLOW,4)
	for i in range(segments.size()-1):
		draw_line(to_local(segments[i]),to_local(segments[i+1]),Color.GOLD,4)
					

func move_connector(glbl_pos:Vector2i):
	global_position = glbl_pos

func _on_area_2d_area_entered(area):
	print(area.name)
	if area.name=="CursorArea":
		has_cursor = true


func _on_area_2d_area_exited(area):
	if area.name=="CursorArea":
		has_cursor = false
func start_wiring():
	pass
func end_wiring():
	pass
func _dbg_draw_wire(cursor_pos):
	print("debug draw wire in connector:",cursor_pos)


func _on_cursor_cursor_moved(glbl_pos):
	cursor_pos = glbl_pos # Replace with function body.
	queue_redraw()
	
func calculate_temp_point(start_pos : Vector2i,cursor_pos : Vector2i,direction : int)->Vector2i:
	var temp_point : Vector2i
	if direction==0: # horizontal direction
		temp_point = Vector2i(cursor_pos.x,start_pos.y)
	else: # vertical direction
		temp_point = Vector2i(start_pos.x,cursor_pos.y)
	return temp_point
