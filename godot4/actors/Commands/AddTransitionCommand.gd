extends BaseCommand

var transition = preload("res://actors/Transition/Transition-Mk1.tscn")
var created_transition
var transition_idx
var transition_points
var transitions


func setup(transition_idx,transition_points,transitions):
	self.transitions = transitions
	self.transition_idx = transition_idx
	self.transition_points = transition_points
func do():
	created_transition = transition.instantiate()
	created_transition.setup(transition_points[1],transition_points[0])
	transitions.add_child(created_transition)
	
func undo():
	created_transition.queue_free()
