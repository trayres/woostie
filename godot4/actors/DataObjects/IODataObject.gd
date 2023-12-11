extends Node
class_name IODataObject
# This data object represents an input or output, and all the possible settings we
# could have for that. 
var idx            : int    = 0
var is_reset_input : bool   = false
var is_clock_input : bool   = false
var io_name        : String 
var io_type        : int    = GLOBAL.IO_TYPES.INPUT
var output_type    : int    = -1 # GLOBAL.OUTPUT_TYPE, e.g. COMB or REG
var io_width       : int    = GLOBAL.IO_WIDTH.WIRE
var io_multibit    : Vector2i = Vector2i(-1,-1) #.x is high bit, .y is low bit, eg 
var reset_polarity : int = -1 # only used for reset; io_type=RESET
var reset_type     : int = -1 # only used for reset; io_type=RESET
