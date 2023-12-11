`timescale 1ns / 1ps

module pulse_transition_tb();
  // Inputs as reg, outputs as wire
  reg CLK=1'b0;
  reg RSTN=1'b0;
  //
  wire IDLE;
  wire PRE_PULSE;
  wire PULSE;
    
  pulse_transition DUT(
  .IDLE(IDLE),
  .PRE_PULSE(PRE_PULSE),
  .PULSE(PULSE),
  .CLK(CLK),
  .RSTN(RSTN)
);

  always begin
    #5 CLK=!CLK;
  end
  // Wave gen
  initial begin
    repeat(5) @(posedge CLK);
    RSTN = 1'b1;
    
  end
   
endmodule
