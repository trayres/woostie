extends Node2D


# Called when the node enters the scene tree for the first time.
#func _ready():
#	pass # Replace with function body.
#
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func _ready():
	print("Started")
	await try_await()
	print("Done")

func try_await():
	await get_tree().create_timer(1.0).timeout
	print("After timout")
	try_await()
