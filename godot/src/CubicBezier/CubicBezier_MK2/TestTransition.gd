extends Node2D
var pl_Transition=preload("res://src/CubicBezier/CubicBezier_MK2/Transition.tscn")
var pl_State=preload("res://src/KineticState/Kinetic State.tscn")

func _ready() -> void:
	pass


func _on_DebugTimer_timeout():
	var aTransition = pl_Transition.instance()
	add_child(aTransition)
	var node_positions : Array = [Vector2(50,50),Vector2(100,100),Vector2(150,150),Vector2(200,200)]
	#aTransition.setup(0,Vector2(50,50),Vector2(100,100),Vector2(150,100),Vector2(200,200))
	aTransition.setup(0,node_positions)
	
	var aState = pl_State.instance()
	add_child(aState)
	aState.setup(0,Vector2(300,300))
	
