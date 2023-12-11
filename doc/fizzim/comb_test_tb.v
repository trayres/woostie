`timescale 1ns / 1ps

module comb_test_tb();
 
  wire ABOUT_TO_PULSE;
  wire COMB_PULSE;
  wire LEAVING;
  reg clk = 1'b0;
  reg rstn = 1'b0;

  comb_test DUT(
  	// outputs
  	.ABOUT_TO_PULSE(ABOUT_TO_PULSE),
  	.COMB_PULSE(COMB_PULSE),
  	.LEAVING(LEAVING),
  	.clk(clk),
  	.rstn(rstn)
  );
  
  always begin
  #5 clk <= !clk;
  end

  // Wave generate
  initial begin
	repeat(5) @(posedge clk);
	rstn = 1'b1;
  end

endmodule
