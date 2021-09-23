extends MarginContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_MousePosLabel(Vector2(1000,1000))

func set_MousePosLabel(position : Vector2) -> void:
	var x_str : String = "%*.*f" % [8,2,position.x]
	var y_str : String = "%*.*f" % [8,2,position.y]
	$VBoxContainer/HBoxContainer/MousePosLabel.text = "("+x_str+", "+y_str+")"

func set_StatusLabel(aString : String):
	$VBoxContainer/HBoxContainer/StatusLabel.text = aString
	
