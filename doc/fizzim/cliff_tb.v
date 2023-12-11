`timescale 1ns/1ns

module cliff_tb;
  // Outputs as wires, inputs a regs
  reg clk = 1'b0;
  reg go = 1'b0;
  reg rst_n = 1'b0;
  reg ws = 1'b0;
  wire rd;
  wire rs;

  cliff DUT(
  	// outputs
    .rd(rd),
    .rs(rs),
    // inputs
    .clk(clk),
    .go(go),
    .rst_n(rst_n),
    .ws(ws)
  );
  
  always begin
  #5 clk <= !clk;
  end
    // Monitor
  always @(posedge clk) begin
    $display("Time=%t, State=%s, rd=%b, rs=%b", $time, DUT.statename, rd, rs);
  end
  // Wave generate
  initial begin
	repeat(5) @(posedge clk);
	rst_n = 1'b1;
	repeat(5) @(posedge clk);
	go = 1'b1;
	@(posedge clk);
	ws = 1'b1;
	repeat(5) @(posedge clk);
	ws = 1'b0;
  end

endmodule