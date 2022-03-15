`include "define.v"
`include "module/ram.v"
`include "module/core.v"
`include "module/uart_tx.v"
`include "module/uart_rx.v"

module bf_uart(
    input sys_clk_p,
    input sys_clk_n,

    input rst,
    input data_rx,
    output my_tx
  );

  wire ram_en, ram_wen;
  wire [`ADDR_WIDTH - 1: 0] addr;
  wire [`DATA_WIDTH - 1: 0] ram_write;
  wire [`DATA_WIDTH - 1: 0] ram_read;

  wire output_en;
  wire [`DATA_WIDTH - 1: 0] output_data;

  reg en = 1;
  reg rst_n;
  always @(* ) rst_n <= !rst;

  wire clk;
  IBUFGDS CLK(.I(sys_clk_p), .IB(sys_clk_n), .O(clk));

  ram ram(.clk(clk), .en(ram_en), .wen(ram_wen),
          .addr(addr), .write(ram_write), .read(ram_read));

  core core(.clk(clk), .en(en), .rst_n(rst_n),
            .ram_en(ram_en), .ram_wen(ram_wen), .addr(addr),
            .ram_write(ram_write), .ram_read(ram_read),
            .output_en(output_en), .output_data(output_data));

  uart_tx uart_tx(.sys_clk(clk), .sys_rst_n(rst_n),
                  .uart_tx_data(output_data), .uart_tx_en(output_en),
                  .uart_txd(my_tx));

endmodule
