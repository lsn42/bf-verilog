`include "../define.v"
`include "../module/ram.v"

`timescale 1ps/1ps

module ram_tb_2();
  reg clk;

  reg en, wen;
  reg [`ADDR_WIDTH - 1: 0] addr;
  reg [`DATA_WIDTH - 1: 0] input_data;
  wire [`DATA_WIDTH - 1: 0] output_data;
  ram dut(.clk(clk), .en(en), .wen(wen), .addr(addr), .write(input_data), .read(output_data));

  parameter clk_period = 10;
  initial
    clk = 0;
  always#(clk_period / 2) clk = ~clk;

  integer i;

  initial
    begin
      $dumpfile(".\\wave\\ram_tb_2.vcd");
      $dumpvars;
      $readmemh(".\\data\\hex\\helloworld.hex", dut.data, 0, 9);
      en = 1;
      wen = 0;
      addr = 16'h0000;
      input_data = 8'h0;
      @(posedge clk);

      for (i = 0;i < 10; i = i + 1)
        begin
          read_data(i);
        end

      @(posedge clk);
      $finish;
    end

  task write_data(
      input [`ADDR_WIDTH - 1: 0] _addr,
      input [`DATA_WIDTH - 1: 0] _data);
    begin
      en = 1;
      wen = 1;
      addr = _addr;
      input_data = _data;
      @(posedge clk);
    end
  endtask

  task read_data(
      input [`ADDR_WIDTH - 1: 0] _addr);
    begin
      en = 1;
      wen = 0;
      addr = _addr;
      @(posedge clk);
    end
  endtask

endmodule
