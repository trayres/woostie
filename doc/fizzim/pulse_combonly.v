// Created by fizzim.pl version 5.20 on 2023:11:21 at 11:43:19 (www.fizzim.com)

module PULSE_COMBONLY (
  output reg PULSE,
  input wire CLK,
  input wire RSTN
);

  // state bits
  parameter 
  SIDLE  = 1'b0, 
  SPULSE = 1'b1; 

  reg state;
  reg nextstate;

  // comb always block
  always @* begin
    nextstate = 1'bx; // default to x because default_state_is_x is set
    PULSE = 0; // default
    case (state)
      SIDLE : begin
        begin
          nextstate = SPULSE;
        end
      end
      SPULSE: begin
        PULSE = 1;
        begin
          nextstate = SIDLE;
        end
      end
    endcase
  end

  // Assign reg'd outputs to state bits

  // sequential always block
  always @(posedge CLK or negedge RSTN) begin
    if (!RSTN)
      state <= SIDLE;
    else
      state <= nextstate;
  end

  // This code allows you to see state names in simulation
  `ifndef SYNTHESIS
  reg [47:0] statename;
  always @* begin
    case (state)
      SIDLE :
        statename = "SIDLE";
      SPULSE:
        statename = "SPULSE";
      default:
        statename = "XXXXXX";
    endcase
  end
  `endif

endmodule
