// Created by fizzim.pl version 5.20 on 2023:11:20 at 09:36:32 (www.fizzim.com)

module cliff (
  output wire rd,
  output wire rs,
  input wire clk,
  input wire go,
  input wire rst_n,
  input wire ws
);

  // state bits
  parameter 
  IDLE = 4'b0000, // extra=00 rs=0 rd=0 
  DLY  = 4'b0100, // extra=01 rs=0 rd=0 
  DONE = 4'b1000, // extra=10 rs=0 rd=0 
  READ = 4'b0001; // extra=00 rs=0 rd=1 

  reg [3:0] state;
  reg [3:0] nextstate;

  // comb always block
  always @* begin
    nextstate = state; // default to hold value because implied_loopback is set
    case (state)
      IDLE: begin
        if (go) begin
          nextstate = READ;
        end
        else begin
          nextstate = IDLE;
        end
      end
      DLY : begin
        if (ws) begin
          nextstate = READ;
        end
        else begin
          nextstate = DONE;
        end
      end
      DONE: begin
        begin
          nextstate = IDLE;
        end
      end
      READ: begin
        begin
          nextstate = DLY;
        end
      end
    endcase
  end

  // Assign reg'd outputs to state bits
  assign rd = state[0];
  assign rs = state[1];

  // sequential always block
  always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
      state <= IDLE;
    else
      state <= nextstate;
  end

  // This code allows you to see state names in simulation
  `ifndef SYNTHESIS
  reg [31:0] statename;
  always @* begin
    case (state)
      IDLE:
        statename = "IDLE";
      DLY :
        statename = "DLY";
      DONE:
        statename = "DONE";
      READ:
        statename = "READ";
      default:
        statename = "XXXX";
    endcase
  end
  `endif

endmodule
