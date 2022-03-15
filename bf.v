`include "define.v"
`include "module/ram.v"
`include "module/core.v"

module bf(
    input clk,
    input en, input rst_n,
    input [`DATA_WIDTH - 1: 0] input_data,
    output [`DATA_WIDTH - 1: 0] output_data
  );

  wire ram_en, ram_wen;
  wire [`ADDR_WIDTH - 1: 0] addr;
  wire [`DATA_WIDTH - 1: 0] ram_write;
  wire [`DATA_WIDTH - 1: 0] ram_read;

  ram ram(.clk(clk), .en(ram_en), .wen(ram_wen),
          .addr(addr), .write(ram_write), .read(ram_read));

  core core(.clk(clk), .en(en), .rst_n(rst_n),
            .ram_en(ram_en), .ram_wen(ram_wen), .addr(addr),
            .ram_write(ram_write), .ram_read(ram_read),
            .input_data(input_data), .output_data(output_data));

endmodule
