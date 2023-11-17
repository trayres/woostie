extends Node2D

var parent
var preload_hierstate = preload("res://actors/Hierarchical-State/Hierarchical-State.tscn")

func setup():
	pass

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_area_2d_mouse_entered():
	print("Mouse entered blue rect")


func _on_window_mouse_entered():
	print("Mouse entered window")


func _on_area_2d_2_mouse_entered():
	print("mouse in area2d anchor region")


func _on_area_2d_3_mouse_entered():
	print("mouse in rigtht area2d anchor")




func _on_button_pressed():
	var aNewHierState = preload_hierstate.instantiate()
	aNewHierState.setup(get_global_mouse_position())
	add_child(aNewHierState)
