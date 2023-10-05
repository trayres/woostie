@tool
extends CharacterBody2D


const SPEED = 800.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var mouse_in : bool
var dragging : bool
var last_mouse_pos : Vector2	

func _ready():
	add_to_group("states")
	
func _input(event):
	if Input.is_action_pressed("click") and mouse_in:
		dragging = true
		last_mouse_pos = get_global_mouse_position()
	if Input.is_action_just_released("click"):
		dragging = false

func _physics_process(delta):
	if dragging:
		var move_dir = last_mouse_pos - global_position
		move_dir = move_dir.normalized()
		move_and_collide(move_dir*SPEED*delta)
		last_mouse_pos = get_global_mouse_position()

func _draw():
	draw_circle(Vector2(0,0),50.0,Color(0.22,0.77,0.22))


func _on_mouse_entered():
	mouse_in = true


func _on_mouse_exited():
	mouse_in = false
