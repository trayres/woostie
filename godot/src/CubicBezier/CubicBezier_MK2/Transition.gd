extends Node2D
var transition_idx  : int # The identifier for the transition
onready var curve = Curve2D.new()

# TODO: Fill in placeholders
signal move_transition_anchor(transition_idx, node_idx, start_position, final_position)
signal change_transition_properties # Emitted on double click

func _ready():
	pass
	
func _draw() -> void:
	pass
	
func _process(delta):
	pass

#func setup(transition_idx,head_pos,head_ctrl_pos,tail_ctrl_pos,tail_pos):
func setup(transition_idx,node_positions):
	self.transition_idx = transition_idx
	$Head.global_position = node_positions[0]
	$Head.node_idx = 0
	$HeadControl.global_position=node_positions[1]
	$HeadControl.node_idx = 1
	$TailControl.global_position=node_positions[2]
	$TailControl.node_idx = 2
	$Tail.global_position=node_positions[3]
	$Tail.node_idx = 3
	# Position the TransitionEquation on the midpoint
	$TransitionEquation.text = "A+B"
	
	# Position the PriorityLabel right where the Tail node is
	$PriorityLabel.text = str(0)
	$PriorityLabel.set_global_position(node_positions[3])
# This function is so that nodes can be moved externally (via the command pattern)
func move_node(idx,final_position)->void:
	for achild in get_children():
		if achild.idx==idx:
			achild.position = final_position


func _on_Head_move(node_idx, start_position_of_drag, final_position_of_drag) -> void:
	# Pass this up to the controller
	emit_signal("move_transition_anchor",transition_idx,node_idx,start_position_of_drag,final_position_of_drag)

func set_force_show_transition_anchors()->void:
	pass
func clear_force_show_transition_anchors()->void:
	pass
