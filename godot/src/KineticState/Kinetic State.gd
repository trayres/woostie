extends KinematicBody2D
class_name KineticState
var radius : float = 50.0
var state_name : String = "State"
var idx            : int  = 0
var dragging : bool = false
var selected       : bool = false
var mouse_in_state : bool = false
var transition_anchors : Array = []
var transition_anchors_head : Array = []
var transition_anchors_tail : Array = []
var start_position_of_drag : Vector2

signal move(state, start_position, final_position) # Emitted when done with a drag
signal set_state_name(state_name,idx)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("Kinetic State")

# Todo: Cleanup setup and setup_state
func setup(idx:int, pos : Vector2):
	position = pos
	state_name = "State"+str(idx)
	self.idx = idx
	setup_state(state_name)
	update()
	return self
	
func _process(delta: float) -> void:
	if (mouse_in_state && Input.is_action_just_pressed("left_click")):
		dragging = true
		selected = true
		start_position_of_drag = global_position
		update()

	if (dragging && Input.is_action_pressed("left_click")):
		#var final_pos : Vector2 = get_viewport().get_mouse_position()
		var final_pos : Vector2 = get_global_mouse_position()
		var rel_vec: Vector2 = final_pos - position
		var final_vec : Vector2 = rel_vec.normalized()*80.0
		
		# If we're not going to collide, just go there
		if not test_move(Transform2D(transform), rel_vec, true):
			set_position(final_pos)
			for anchor in transition_anchors:
				anchor.position += rel_vec
		# But if we are going to collide, let's see the collision
		else:
			#move_and_slide(final_vec)
			var collision : KinematicCollision2D = move_and_collide(rel_vec)
			#position += collision.remainder
			var collider = collision.collider
			#if collider.is_in_group("Kinetic Transition Anchor"):
			#	if not transition_anchors.has(collider):
			#		transition_anchors.append(collider)
			#		collider.attached_state = self # Tell the transition anchor the state we're attached to, so we have a reference to it.
			#		collider.update()
			#	for anchor in transition_anchors:
			#		anchor.position += collision.travel
			#		anchor.position += collision.remainder
			#	position += collision.remainder
			if collider.is_in_group("Kinetic State Anchor Head"):
				print("HIT TRANSITION HEAD")
				if not transition_anchors_head.has(collider):
					transition_anchors_head.append(collider)
					collider.attached_state = self # Tell the transition anchor the state we're attached to, so we have a reference to it.
					collider.update()
				for anchor in transition_anchors_head:
					anchor.position += collision.travel
					anchor.position += collision.remainder
				for anchor in transition_anchors_tail:
					anchor.position += collision.travel
					anchor.position += collision.remainder					
				position += collision.remainder				
			if collider.is_in_group("Kinetic State Anchor Tail"):
				print("HIT TRANSITION TAIL")
				if not transition_anchors_tail.has(collider):
					transition_anchors_tail.append(collider)
					collider.attached_state = self # Tell the transition anchor the state we're attached to, so we have a reference to it.
					collider.update()
				for anchor in transition_anchors_tail:
					anchor.position += collision.travel
					anchor.position += collision.remainder					
				for anchor in transition_anchors_head:
					anchor.position += collision.travel
					anchor.position += collision.remainder
				position += collision.remainder							
			if collider.is_in_group("Kinetic State"):
				pass
	else:
		if dragging:
			print("Emitting drag signal")
			emit_signal("move",self,start_position_of_drag,global_position)
		dragging = false	
		
		

func setup_state(state_name : String):
	self.state_name = state_name
	$Label.text=state_name
	var rect = $Label.rect_size
	var pos = -rect/2
	$Label.rect_position = pos
	
func set_selected()	-> void:
	selected = true
	update()
	
func clear_selected() -> void:
	selected = false
	update()
	

func _draw():
	draw_circle(Vector2(0.0,0.0),50.0,Color(0.22,0.77,0.22))
	if selected:
		var sel_rect : Rect2
		sel_rect.position = Vector2(-50.0,-50.0)
		sel_rect.size     = Vector2(100.0,100.0)
		draw_rect(sel_rect,Color(0.22,0.22,0.88),false,2.0)


func _on_Kinematic_State_mouse_entered() -> void:
	mouse_in_state = true
	print("mouse_in_state:true")


func _on_Kinematic_State_mouse_exited() -> void:
	mouse_in_state = false
	print("mouse_in_state:false")

func _on_Kinematic_State_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if  event is InputEventMouseButton:
		if event.button_index==BUTTON_LEFT:
			if event.is_pressed():
				selected = true
			if event.is_doubleclick():
				print("Double Click!")
				#$"Set State Name".setup(state_name,idx)
				#$"Set State Name".popup_centered()	
				emit_signal("set_state_name",state_name,idx)




func _on_GravityWell_area_shape_entered(area_id: int, area: Area2D, area_shape: int, local_shape: int) -> void:
	if area.is_in_group("GravityWell"):
		print("GRAVITY WELL")


func popup_set_state_name(name) -> void:
	setup_state(name)
