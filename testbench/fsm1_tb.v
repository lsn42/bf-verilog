`include "../module/fsm1.v"

`timescale 1ps/1ps

module fsm1_tb();
  reg clk, rst;
  wire q;
  fsm1 dut(.clk(clk), .rst(rst), .q(q));

  integer i;

  parameter clk_period = 10;
  initial
    clk = 0;
  always#(clk_period / 2) clk = ~clk;

  initial
    begin
      $dumpfile(".\\wave\\fsm1_tb.vcd");
      $dumpvars;
      rst = 1;
      @(posedge clk);
      rst = 0;
      for (i = 0;i < 10;i = i + 1)
        begin
          @(posedge clk);
        end
      $finish;
    end

endmodule
