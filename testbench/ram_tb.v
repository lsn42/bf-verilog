`include "../define.v"
`include "../module/ram.v"

`timescale 1ps/1ps

module ram_tb();
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

  initial
    begin
      $dumpfile(".\\wave\\ram_tb.vcd");
      $dumpvars;
      en = 1;
      wen = 0;
      addr = 16'h0000;
      input_data = 8'h0;
      @(posedge clk);

      write_data(16'h0000, 8'hCA);
      write_data(16'h0001, 8'hFE);
      write_data(16'h0002, 8'hBA);
      write_data(16'h0003, 8'hBE);

      read_data(16'h0000);
      read_data(16'h0001);
      read_data(16'h0002);
      read_data(16'h0003);

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
