extends KinematicBody2D

var radius : float = 10.0
var dragging : bool = false
var mouse_in_anchor : bool = false
var attached_state  : KinematicBody2D = null
var is_in_gravity_well : bool = false
var gravity_well_target_position : Vector2 = Vector2.ZERO
var gravity_well_timeout_running : bool = false

# Detach is issued when a transition anchor is moved in such a way as to indicate
# that the user would like to detach it from a state.
signal detach(detach_id)
# Set attachment is issued on collision with a state body. This allows for a 
# higher level controller to actually "hook up" the attachment, which prevents
# the issues with tracking who has what state (the previous version had some
# ugly references hanging around)
signal set_attachment(transition_anchor,attach_id)

func _ready() -> void:
	add_to_group("Kinetic Transition Anchor")
	$EnterGravityWellTimeout.set_wait_time(0.5)
	$EnterGravityWellTimeout.one_shot = true

func _draw():
	if attached_state == null:
		draw_circle(Vector2(0,0), radius, Color( 0.77, 0.22, 0.0, 1 ))
	else:
		draw_circle(Vector2(0,0), radius, Color( 0.0, 0.77, 0.22, 1 ))

func _process(delta: float) -> void:
	if (mouse_in_anchor && Input.is_action_just_pressed("left_click")):
		dragging = true	
	if (dragging && Input.is_action_pressed("left_click")):
		#var final_pos : Vector2 = get_viewport().get_mouse_position()
		var final_pos : Vector2 = get_global_mouse_position()
		var rel_vec: Vector2 = final_pos - position
		
		# We didn't hit anything...the user must have meant to unhook the bond
		if not test_move(Transform2D(transform), rel_vec, true):
			set_position(final_pos)
			if attached_state != null:
				attached_state.transition_anchors.erase(self)
				attached_state = null
				emit_signal("detach",self) # send yourself as the detach_id
				update()
		else:
			#move_and_slide(final_vec)
			var collision : KinematicCollision2D = move_and_collide(rel_vec)
			var collider = collision.collider
			if collider.is_in_group("Kinetic State"):
				attached_state = collider
				update()
				if not collider.transition_anchors.has(self):
					collider.transition_anchors.append(self)
			
	else:
		dragging = false
		if is_in_gravity_well and gravity_well_timeout_running:
			var rel_vec : Vector2 = gravity_well_target_position - global_position
			print("rel_vec:"+str(rel_vec))
			var collision : KinematicCollision2D = move_and_collide(rel_vec.normalized()*1)
			if collision != null:
				var collider = collision.collider
				if collider.is_in_group("Kinetic State"):
					attached_state = collider
					update()
					if not collider.transition_anchors.has(self):
						collider.transition_anchors.append(self)

func _on_Kinetic_Transition_Anchor_mouse_entered() -> void:
	mouse_in_anchor = true


func _on_Kinetic_Transition_Anchor_mouse_exited() -> void:
	mouse_in_anchor = false


func _on_GravityWellNotifier_area_shape_entered(area_id: int, area: Area2D, area_shape: int, local_shape: int) -> void:
	# If you're in multiple areas, we should just follow the closest one I think...
	if area.is_in_group("GravityWell"):
		print("TRANSITION ANCHOR IN GRAVITY WELL")
		is_in_gravity_well = true
		gravity_well_target_position = area.global_position
		print("gravity_well_target_position:"+str(gravity_well_target_position))
		gravity_well_timeout_running = true
		$EnterGravityWellTimeout.start(0.8)


func _on_GravityWellNotifier_area_shape_exited(area_id: int, area: Area2D, area_shape: int, local_shape: int) -> void:
	if area != null:
			if area.is_in_group("GravityWell"):
				print("TRANSITION ANCHOR IN GRAVITY WELL")
				is_in_gravity_well = false


func _on_EnterGravityWellTimeout_timeout() -> void:
	gravity_well_timeout_running = false
	print("gravity well timed out")
