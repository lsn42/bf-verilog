`ifndef RAM_V
`define RAM_V
`include "../define.v"

module ram(
    input clk,
    input wire en, // enable
    input wire wen, // write enable
    input wire[`ADDR_WIDTH - 1: 0] addr, // address
    input wire[`DATA_WIDTH - 1: 0] write, // write input
    output reg[`DATA_WIDTH - 1: 0] read // read output
  );

  reg [`DATA_WIDTH - 1: 0] data[2 ** `ADDR_WIDTH - 1: 0];

  always @(posedge clk)
    begin
      if (en && wen)
        begin
          data[addr] <= write;
        end
    end
  always @(posedge clk)
    begin
      if (en)
        begin
          read <= data[addr];
        end
    end
endmodule
`endif