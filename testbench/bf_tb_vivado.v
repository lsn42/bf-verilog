`include "bf.v"

`timescale 1ps/1ps

module bf_tb_vivado();
  reg clk, en, rst_n;
  reg [7: 0] input_data;
  wire [7: 0] output_data;
  bf dut(.clk(clk), .en(en), .rst_n(rst_n), .input_data(input_data), .output_data(output_data));

  integer i;

  parameter clk_period = 10;
  initial
    clk = 0;
  always#(clk_period / 2) clk = ~clk;

  initial
    begin
      $dumpvars;
      en = 1;
      input_data = 0;
      rst_n = 0;
      #(clk_period * 2) rst_n = 1;
      $readmemh(".\\..\\..\\..\\..\\..\\data\\hex\\helloworld.hex", dut.ram.data, 0, 65535);
      dut.core.ptr = 16'h0100;
      while (dut.core.state_c != dut.core.S23)
        begin
          if (dut.core.state_c == dut.core.S20)
            begin
              input_data = $fgetc('h8000_0000);
            end
          @(posedge clk);
        end
      $finish;
    end

endmodule
