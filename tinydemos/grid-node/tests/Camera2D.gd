extends Camera2D

const zoom_min : int = 1
const zoom_max : int = 5
var zoom_speed = 0.5
var panning = false

var prev_mouse_pos : Vector2

signal camera_moved(global_position : Vector2)
	
func _input(event):
	if event.is_action_released("zoom_in"):
		zoom_camera(-zoom_speed, event.position)
		camera_moved.emit(global_position)
		await $Timer.timeout
	if event.is_action_released("zoom_out"):
		zoom_camera(zoom_speed,event.position)
		camera_moved.emit(global_position)
	if event.is_action_pressed("pan"):
		panning = true
		prev_mouse_pos = get_global_mouse_position()
	elif event.is_action_released("pan"):
		panning = false
	if event is InputEventMouseMotion and panning == true:
		var new_mouse_pos = get_global_mouse_position()
		var offset_delta = new_mouse_pos - prev_mouse_pos
		global_position -= offset_delta
		camera_moved.emit(global_position)

func zoom_camera(zoom_factor,mouse_position):
	var viewport_size = get_viewport().size
	var previous_zoom = zoom
	zoom = clamp(zoom+Vector2(zoom_factor,zoom_factor),Vector2(zoom_min,zoom_min),Vector2(zoom_max,zoom_max))
	global_position += (viewport_size*0.5-mouse_position) * (zoom-previous_zoom)

	
func _process(delta):
	pass


func _on_camera_moved(global_position):
#	$GridGenerator.global_position = global_position
	$GridGenerator.queue_redraw()


func _on_timer_timeout():
	$GridGenerator.queue_redraw()
