extends Node
class_name TransitionDataObject

var idx            : int 
var head_state_idx : int
var tail_state_idx : int
# The transition equation is the assigned transition equation, the default 
# transition equation, and the visibility setting, which is at first set
# from the FSM Settings menu but can be tweaked for each individual transition
# if the user so desires
var transition_eqn : Array = ['1','1',GLOBAL.VISIBILITY.ONLY_NON_DEFAULT] # default transition
var priority       : int = -1     # unused priority is default
var comb_outputs   : Dictionary
