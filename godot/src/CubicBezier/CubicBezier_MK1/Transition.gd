extends Node2D

export var transition_idx : int
onready var curve = Curve2D.new()
onready var curve_pts
var pts = []
onready var mouse_xy_current

signal move_transition_node()


func _ready() -> void:
	# https://docs.godotengine.org/en/3.2/tutorials/math/beziers_and_curves.html
	var p0_in = Vector2.ZERO # This isn't used for the first curve
	var p0_vertex = $HeadAnchor.position # First point of first line segment
	var p0_out = $P1.position - $HeadAnchor.position # Second point of first line segment
	var p1_in =  $P2.position - $TailAnchor.position  # First point of second line segment
	var p1_vertex =  $TailAnchor.position # Second point of second line segment
	var p1_out = Vector2.ZERO # Not used unless another curve is added
	curve.add_point(p0_vertex, p0_in, p0_out)
	curve.add_point(p1_vertex, p1_in, p1_out)

func setup() -> void:
	pass

func pDistance(x,y,x1,y1,x2,y2):
	var A = x - x1;
	var B = y - y1;
	var C = x2 - x1;
	var D = y2 - y1;

	var dot = A * C + B * D;
	var len_sq = C * C + D * D;
	var param = -1;
	if (len_sq != 0): #in case of 0 length line
		param = dot / len_sq;

	var xx
	var yy

	if (param < 0):
		xx = x1
		yy = y1
		
	elif (param > 1) :
		xx = x2
		yy = y2
	else:
		xx = x1 + param * C
		yy = y1 + param * D

	var dx = x - xx;
	var dy = y - yy;
	return sqrt(dx * dx + dy * dy)




func _on_HeadMouseNear_mouse_entered() -> void:
	print("Head Mouse Near")

func set_force_show_transition_anchors()->void:
	$HeadAnchor.set_force_show_anchors()
	$TailAnchor.set_force_show_anchors()
func clear_force_show_transition_anchors()->void:
	$HeadAnchor.clear_force_show_anchors()
	$TailAnchor.clear_force_show_anchors()


func _on_HeadAnchor_move(idx, start_position, final_position) -> void:
	print("Head anchor moved: idx:"+str(idx)+" start_position:"+str(start_position)+" final_position:"+str(final_position))


func _on_TailAnchor_move(idx, start_position, final_position) -> void:
	print("Tail anchor moved: idx:"+str(idx)+" start_position:"+str(start_position)+" final_position:"+str(final_position))
