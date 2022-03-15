module fsm1(input clk, input rst, output q);
  parameter S0 = 2'b00;
  parameter S1 = 2'b01;
  parameter S2 = 2'b10;

  reg [1: 0] state;
  reg [1: 0] next_state;

  always@ (posedge clk, posedge rst)
    if (rst)
      begin state <= S0;
      end
    else
      begin state <= next_state;
      end

  always@(* )
    case (state)
      S0: next_state = S1;
      S1: next_state = S2;
      S2: next_state = S0;
    endcase

  assign q = (state == S0);

endmodule
