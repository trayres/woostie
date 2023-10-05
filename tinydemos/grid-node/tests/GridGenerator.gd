extends Node2D

@export var GRID_STEP : int = 40

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

#const GRID_STEP = 40
const GRID_SIZE = 20

func _draw():
	const DELTA_RIGHT : Vector2 =  Vector2(40,0)
	const DELTA_UP : Vector2 = Vector2(0,40)	
	# Get the world coordinates we're working with
	var viewport_size = get_viewport().size
	var canvas_transform_inverse : Transform2D = get_canvas_transform().affine_inverse()
	var world_ul : Vector2 = canvas_transform_inverse*Vector2(0,0) #-global_position
	var world_ll : Vector2 = canvas_transform_inverse*Vector2(0,viewport_size.y) #-global_position
	var world_ur : Vector2 = canvas_transform_inverse*Vector2(viewport_size.x,0) # -global_position
	var world_lr : Vector2 = canvas_transform_inverse*Vector2(viewport_size.x,viewport_size.y) # -global_position
	print("world_ul:"+str(world_ul))
#	print("world_ll:"+str(world_ll))
#	print("world_ur:"+str(world_ur))
#	print("world_lr:"+str(world_lr))
	
	var world_ul_mg : Vector2 = world_ul - global_position
	var world_ll_mg : Vector2 = world_ll - global_position
	var world_ur_mg : Vector2 = world_ur - global_position
	var world_lr_mg : Vector2 = world_lr - global_position
	print("world_ul_mg:"+str(world_ul_mg))
#	print("world_ll_mg:"+str(world_ll_mg))
#	print("world_ur_mg:"+str(world_ur_mg))
#	print("world_lr_mg:"+str(world_lr_mg))
	
	#draw_line(world_ul_mg+DELTA_RIGHT,world_ll_mg+DELTA_RIGHT,Color(0.5,0.5,0.5),40)
	
	var horiz_width : Vector2 = world_ur - world_ul
	var vert_height : Vector2 = world_ll - world_ul
	print("horiz_width:"+str(horiz_width))
	print("vert_height:"+str(vert_height))	
	
	# Get number of vertical/horizontal lines
	var num_vert_lines = ceil(horiz_width.x / GRID_STEP)+1;
	var num_horiz_lines = ceil(vert_height.y / GRID_STEP)+1;	
	
	# Get the offset of the start of the grid pattern
	#var x_offset = DELTA_RIGHT - Vector2(abs(int(world_ul.x)%GRID_STEP),0);	
	#var x_offset =  Vector2(abs(int(world_ul.x)%GRID_STEP),0);
	var x_offset =  Vector2(-1*int(world_ul.x)%GRID_STEP,0);		
	#var y_offset = DELTA_UP - Vector2(0,abs(int(world_ul.y)%GRID_STEP))
	var y_offset = Vector2(0,-1*int(world_ul.y)%GRID_STEP)
	print("x_offset:"+str(x_offset))
	print("y_offset:"+str(y_offset))
	
#	if world_ul.x > 0:
#		world_ul_mg.x = -1*world_ul_mg.x
	#var x_offset =  Vector2(abs(int(world_ul.x)%GRID_STEP),0);	
	for i in range(num_vert_lines):
		draw_line(world_ul_mg+x_offset+DELTA_RIGHT*i,world_ll_mg+x_offset+DELTA_RIGHT*i,Color(0.88,0.88,0.88),2)
	for i in range(num_horiz_lines):
		draw_line(world_ul_mg+y_offset+DELTA_UP*i,world_ur_mg+y_offset+DELTA_UP*i,Color(0.88,0.88,0.88),2)
	
#	var canvas_pos = get_global_transform() * Vector2(0,0)
#	print("canvas_pos:"+str(canvas_pos))
	
	# Now we need to go back to screen coordinates
#	var canvas_ul = get_global_transform().affine_inverse() * world_ul
#	var canvas_ll = get_global_transform().affine_inverse() * world_ll
#	var screen_coord_ul = get_viewport().get_screen_transform() * get_global_transform_with_canvas() * world_ul
#	var screen_coord_ll = get_viewport().get_screen_transform() * get_global_transform_with_canvas() * world_ll
#	print("screen_coord_ul:"+str(screen_coord_ul))
#	print("screen_coord_ll:"+str(screen_coord_ll))
#	draw_line(screen_coord_ul+DELTA_RIGHT,screen_coord_ll+DELTA_RIGHT,Color(0.5,0.5,0.5),40)
	
	var grid_vert : int = viewport_size.x / GRID_STEP
	var grid_horiz : int = viewport_size.y / GRID_STEP
	print("grid_vert: "+str(grid_vert))
	print("grid_horiz: "+str(grid_horiz))
	

	

	

	#var x_offset1 = Vector2(abs(GRID_STEP -  x_offset),0);
#	print("world_ul+x_offset:"+str(world_ul)+" "+str(x_offset))
#	for i in range(2):
#		draw_line(world_ul+x_offset+DELTA_RIGHT*i,world_ll+x_offset+DELTA_RIGHT*i,Color(0.88,0.0,0.0),1)
	
#	print("world_ul:"+str(world_ul))
#	print("world_ll:"+str(world_ll))
#	print("world_ur:"+str(world_ur))
#	print("world_lr:"+str(world_lr))

	
	# Draw Vertical Grid Lines
	# This is sorta working
	#for i in range(GRID_SIZE):
	#	draw_line(world_ul+DELTA_RIGHT*i,world_ll+DELTA_RIGHT*i,Color(0.88,0.0,0.0),1)
	# Draw Horizontal Grid Lines
	# draw_line(Vector2(-640,500),Vector2(-640,0),Color(0.0,.88,0))
#	for i in range(GRID_SIZE):
#		draw_line(world_ul+DELTA_UP*i,world_ur+DELTA_UP*i,Color(0.88,0,0))
	# Draw a few test lines
#	for i in range(GRID_SIZE):
#		var apt = Vector2()
#		var bpt = Vector2()
#		apt.x = world_ul.x+GRID_SIZE*i
#		apt.y = 0
#		bpt.x = world_ll.x+GRID_SIZE*i
#		bpt.y = world_ll.y
#		draw_line(apt,bpt,Color(.88,0,0),6.0)

#	print("world_ul:"+str(world_ul))
#	print("GridGenerator global_position:"+str(global_position))
#	for i in range(GRID_SIZE):
#		var col = Color("#aaaaaa")
#		var width = 1.0
#		if i == GRID_SIZE / 2:
#			col = Color("#66cc66")
#			width = 2.0
#		draw_line(Vector2(i * GRID_STEP-global_position.x, 0-global_position.y), Vector2(i * GRID_STEP-global_position.x, GRID_SIZE * GRID_STEP - global_position.y), col, width)
#
#	for j in range(GRID_SIZE):
#		var col = Color("#aaaaaa")
#		var width = 1.0
#		if j == GRID_SIZE / 2:
#			col = Color("#cc6666")
#			width = 2.0
#		draw_line(Vector2(0-global_position.x, j * GRID_STEP - global_position.y), Vector2(GRID_SIZE * GRID_STEP - global_position.x, j * GRID_STEP - global_position.y), col, width)	
