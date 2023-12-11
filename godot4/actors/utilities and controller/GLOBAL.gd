extends Node

enum IO_TYPES {INPUT, OUTPUT, INOUT,CLOCK_POS,CLOCK_NEG,RESET_POS,RESET_NEG,ARESET_POS,ARESET_NEG} # General IO type
# Note that this now includes the various polarity and synchronicity (?) options for clocks and resets
enum OUTPUT_TYPE {COMB,REG} # TODO: Add Statebit, Flag
enum IO_WIDTH {WIRE,BUS} # Is it a wire or a bus
enum RESET_POLARITY {POSITIVE,NEGATIVE} # Reset Polarity
enum RESET_TYPE {SYNC,ASYNC} # Reset clock edge sensitivity
enum VISIBILITY {YES,NO,ONLY_NON_DEFAULT}
