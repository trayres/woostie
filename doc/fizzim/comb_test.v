// Created by fizzim.pl version 5.20 on 2023:11:21 at 10:43:33 (www.fizzim.com)

module comb_test (
  output reg ABOUT_TO_PULSE,
  output reg COMB_PULSE,
  output reg LEAVING,
  input wire clk,
  input wire rstn
);

  // state bits
  parameter 
  IDLE  = 1'b0, 
  PULSE = 1'b1; 

  reg state;
  reg nextstate;

  // comb always block
  always @* begin
    nextstate = 1'bx; // default to x because default_state_is_x is set
    ABOUT_TO_PULSE = 0; // default
    COMB_PULSE = 0; // default
    LEAVING = 1; // default
    case (state)
      IDLE : begin
        begin
          nextstate = PULSE;
        end
      end
      PULSE: begin
        COMB_PULSE = 1;
        // Warning C7: Combinational output LEAVING is assigned on transitions, but has a non-default value "0" in state PULSE 
        LEAVING = 0;
        begin
          nextstate = IDLE;
        end
      end
    endcase
  end

  // Assign reg'd outputs to state bits

  // sequential always block
  always @(posedge clk or negedge rstn) begin
    if (!rstn)
      state <= IDLE;
    else
      state <= nextstate;
  end

  // This code allows you to see state names in simulation
  `ifndef SYNTHESIS
  reg [39:0] statename;
  always @* begin
    case (state)
      IDLE :
        statename = "IDLE";
      PULSE:
        statename = "PULSE";
      default:
        statename = "XXXXX";
    endcase
  end
  `endif

endmodule
