/**
 * 回环测试
 * @author https://blog.csdn.net/wuzhikaidetb/article/details/114596930
 */
`include "uart_loop.v"
`timescale 1ns/1ns	//定义时间刻度
//模块、接口定义
module tb_uart_loop();
 
reg 			sys_clk			;			
reg 			sys_rst_n		;			
reg 			uart_rxd		;
			
wire 	 		uart_txd		;
 
parameter		BPS 	= 'd230400		;			//波特率
parameter		CLK_FRE = 'd50_000_000	;			//系统频率50M
localparam		BIT_TIME = 'd1000_000_000 / BPS ;		//计算出传输每个bit所需要的时间
 
//例化环回模块
uart_loop #(
	.BPS			(BPS			),				//波特率
	.CLK_FRE		(CLK_FRE		)				//时钟频率50M	
)	
u_uart_loop(	
	.sys_clk		(sys_clk		),			
	.sys_rst_n		(sys_rst_n		),		
	.uart_rxd		(uart_rxd		),	
	.uart_txd		(uart_txd		)	
);
 
initial begin	
	//初始时刻定义
  $display("helloworld");
	sys_clk	=1'b0;	
	sys_rst_n <=1'b0;		
	uart_rxd <=1'b1;
	#20 //系统开始工作
	sys_rst_n <=1'b1;
	#3000
	rx_byte({$random} % 256);		//生成8位随机数
	rx_byte({$random} % 256);
	rx_byte({$random} % 256);
	rx_byte({$random} % 256);
	rx_byte({$random} % 256);
	rx_byte({$random} % 256);
  $finish;
end
 
//定义任务，每次发送的数据10 位(起始位1+数据位8+停止位1)
task rx_byte(
	input [7:0] data
);
	integer i; //定义一个常量
	//用 for 循环产生一帧数据，for 括号中最后执行的内容只能写 i=i+1
	for(i=0; i<10; i=i+1) begin
		case(i)
		0: uart_rxd <= 1'b0;		//起始位
		1: uart_rxd <= data[0];		//LSB
		2: uart_rxd <= data[1];
		3: uart_rxd <= data[2];
		4: uart_rxd <= data[3];
		5: uart_rxd <= data[4];
		6: uart_rxd <= data[5];
		7: uart_rxd <= data[6];
		8: uart_rxd <= data[7];		//MSB
		9: uart_rxd <= 1'b1;		//停止位
		endcase
		#BIT_TIME;					//每发送 1 位数据延时
	end		
endtask 
 
always #10 sys_clk=~sys_clk;					//时钟20ns,50M
 
endmodule