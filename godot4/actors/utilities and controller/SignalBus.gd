extends Node

signal mouse_pos_update(glbl_pos : Vector2)
signal update_statusbar_ll_label(newstring : String)
signal new_file
signal open_file
signal dbg_add_transition
signal dbg_add_state
signal mark_debug_state
signal mark_debug_state_finalize

signal show_dummy_state
signal hide_dummy_state
signal add_state_finalize(glbl_pos : Vector2)
signal add_transition_finalize(transition_points : Array)


signal mouse_over_state(idx)
signal mouse_left_state(idx)

signal edit_undo
signal edit_redo
signal edit_delete

signal show_fsm_settings
signal generate_code

signal transition_options(idx)

# schematic editor signals
signal dbg_draw_wire(cursor_pos)
signal cursor_moved(glbl_pos : Vector2i)
var cursor_overlapped 
signal add_wire(cursor_pos)
signal wiredatabase_add_wire


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _mouse_moved(glbl_pos : Vector2)->Vector2:
	mouse_pos_update.emit(glbl_pos)
	return glbl_pos
