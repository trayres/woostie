extends Camera2D

# https://godotengine.org/qa/25983/camera2d-zoom-position-towards-the-mouse

var zoom_speed = 0.5
var panning = false

func _ready() -> void:
	current=true

func _input(event):
	if event.is_action_released('zoom_in'):
		zoom_camera(-zoom_speed, event.position)
	if event.is_action_released('zoom_out'):
		zoom_camera(zoom_speed, event.position)
	if event.is_action_pressed("pan_with_mouse"):
		panning = true
	elif event.is_action_released("pan_with_mouse"):
		panning = false
	if event is InputEventMouseMotion and panning == true:
		offset -= event.relative * zoom

func zoom_camera(zoom_factor, mouse_position):
	var viewport_size = get_viewport().size
	var previous_zoom = zoom
	zoom += zoom * zoom_factor
	offset += ((viewport_size * 0.5) - mouse_position) * (zoom-previous_zoom)
