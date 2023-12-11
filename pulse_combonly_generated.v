module pulse_generator(
input wire clk,
input wire rst_n,
output reg PULSE_O);

//State Bits
parameter
IDLE = 1'd0,
PULSE = 1'd1;
reg state;
reg nextstate;
// comb always block
always @* begin
  PULSE_O = 0;
  nextstate = 1'bx;
  case (state)
    IDLE: begin
        nextstate = PULSE;
    end
    PULSE: begin
        PULSE_O = 1;
        nextstate = IDLE;
    end
 endcase
end
// sequential always block
always @(posedge clk) begin
  if (!rst_n)
    state <= IDLE;
  else
    state <= nextstate;
end
endmodule