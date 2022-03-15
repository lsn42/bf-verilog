/**
 * 回环测试
 * @author https://blog.csdn.net/wuzhikaidetb/article/details/114596930
 */
`include "module/uart_rx.v"
`include "module/uart_tx.v"
module uart_loop
#(
	parameter 			BPS		= 'd9600		,	//发送波特率
	parameter 			CLK_FRE	= 'd200_000_000		//输入时钟频率
)	
(	
//系统接口
	input 				sys_clk_p			,			//50M系统时钟
	input 				sys_clk_n			,			//50M系统时钟
	input 				sys_rst_n		,			//系统复位
//UART	
	input 				uart_rxd		,			//接收数据线
	output  			uart_txd,					//UART发送数据线
  output reg uart_rxd_led,
  output reg uart_txd_led
);
	
//wire define				
wire	[7:0]	data;								//接收到的一个BYTE数据
wire			en;									//接收有效信号，可用作发送的使能信号

wire clk;
    IBUFGDS CLK(
        .I (sys_clk_p),
        .IB(sys_clk_n),
        .O (clk)
  );

always @(*)
begin
  uart_rxd_led <= !uart_rxd;
  uart_txd_led <= !uart_txd;
end

//例化发送模块
uart_tx #(
	.BPS			(BPS		),		
	.CLK_FRE		(CLK_FRE	)		
)	
u_uart_tx(	
	.sys_clk		(clk	),		
	.sys_rst_n		(sys_rst_n	),
 
	.uart_tx_data	(data		),		
	.uart_tx_en		(en			),		
	.uart_txd		(uart_txd	)	
);
//例化接收模块
uart_rx #(
	.BPS			(BPS		),		
	.CLK_FRE		(CLK_FRE	)		
)	
u_uart_rx(	
	.sys_clk		(clk	),			
	.sys_rst_n		(sys_rst_n	),
 
	.uart_rx_data	(data		),			
	.uart_rx_done	(en			),		
	.uart_rxd		(uart_rxd	)	
);
 
endmodule