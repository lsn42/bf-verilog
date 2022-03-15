`include "../define.v"
`include "../module/ram.v"

module core(
    input clk,
    input en, input rst_n,

    output reg ram_en, output reg ram_wen,
    output reg [`ADDR_WIDTH - 1: 0] addr,
    output reg [`DATA_WIDTH - 1: 0] ram_write,
    input [`DATA_WIDTH - 1: 0] ram_read,

    input input_en,
    input [`DATA_WIDTH - 1: 0] input_data, // currently not used
    output reg output_en,
    output reg [`DATA_WIDTH - 1: 0] output_data
  );

  reg [`ADDR_WIDTH - 1: 0] pc;
  reg [`ADDR_WIDTH - 1: 0] ptr;
  reg [`DATA_WIDTH - 1: 0] value;
  reg [`DATA_WIDTH - 1: 0] inst; // unnecessary

  reg [`ADDR_WIDTH - 1: 0] pc_temp;
  reg [`ADDR_WIDTH - 1: 0] ptr_temp;
  reg [`DATA_WIDTH - 1: 0] value_temp;

  reg [7: 0] state_c;
  reg [7: 0] state_n;

  parameter S0 = 8'h00;
  parameter S1 = 8'h01;
  parameter S2 = 8'h02;
  parameter S3 = 8'h03;
  parameter S4 = 8'h04;
  parameter S5 = 8'h05;
  parameter S6 = 8'h06;
  parameter S7 = 8'h07;
  parameter S8 = 8'h08;
  parameter S9 = 8'h09;
  parameter Sa = 8'h0a;
  parameter Sb = 8'h0b;
  parameter Sc = 8'h0c;
  parameter Sd = 8'h0d;
  parameter Se = 8'h0e;
  parameter Sf = 8'h0f;
  parameter S10 = 8'h10;
  parameter S11 = 8'h11;
  parameter S12 = 8'h12;
  parameter S13 = 8'h13;
  parameter S14 = 8'h14;
  parameter S15 = 8'h15;
  parameter S16 = 8'h16;
  parameter S17 = 8'h17;
  parameter S18 = 8'h18;
  parameter S19 = 8'h19;
  parameter S1a = 8'h1a;
  parameter S1b = 8'h1b;
  parameter S1c = 8'h1c;
  parameter S1d = 8'h1d;
  parameter S1e = 8'h1e;
  parameter S1f = 8'h1f;
  parameter S20 = 8'h20;
  parameter S21 = 8'h21;
  parameter S22 = 8'h22;
  parameter S23 = 8'h23;

  always @(posedge clk or negedge rst_n)
    begin
      if (!rst_n)
        begin
          state_c <= S0;
        end
      else if (en)
        begin state_c <= state_n;
        end
      else
        begin ;
        end
    end

  always @(* )
    begin
      case (state_c)
        S0:
          state_n <= S1;
        S1:
          state_n <= S2;
        S2:
          case (ram_read)
            `INST_LEFT:
              state_n <= S3;
            `INST_RIGHT:
              state_n <= S5;
            `INST_PLUS:
              state_n <= S7;
            `INST_MINUS:
              state_n <= Sa;
            `INST_LEFT_BRACKET:
              state_n <= Sd;
            `INST_RIGHT_BRACKET:
              state_n <= S15;
            `INST_DOT:
              state_n <= S1d;
            `INST_COMMA:
              state_n <= S20;
            `EOF:
              state_n <= S23;
            default:
              state_n <= S21;
          endcase
        // inst == <
        S3:
          state_n <= S4;
        S4:
          state_n <= S21;
        // inst == >
        S5:
          state_n <= S6;
        S6:
          state_n <= S21;
        // inst == +
        S7:
          state_n <= S8;
        S8:
          state_n <= S9;
        S9:
          state_n <= S21;
        // inst == -
        Sa:
          state_n <= Sb;
        Sb:
          state_n <= Sc;
        Sc:
          state_n <= S21;
        // inst == [
        Sd:
          state_n <= Se;
        Se:
          state_n <= Sf;
        Sf:
          if (ram_read == 0)
          begin state_n <= S10; end
          else
          begin state_n <= S21; end
        S10:
          state_n <= S11;
        S11:
          state_n <= S12;
        S12:
          if (ram_read == `INST_RIGHT_BRACKET)
          begin state_n <= S21; end
          else
          begin state_n <= S13; end
        S13:
          state_n <= S13;
        S14:
          state_n <= S10;
        // inst == ]
        S15:
          state_n <= S16;
        S16:
          state_n <= S17;
        S17:
          if (ram_read != 0)
          begin state_n <= S18; end
          else
          begin state_n <= S21; end
        S18:
          state_n <= S19;
        S19:
          state_n <= S1a;
        S1a:
          if (ram_read == `INST_LEFT_BRACKET)
          begin state_n <= S21; end
          else
          begin state_n <= S1b; end
        S1b:
          state_n <= S1c;
        S1c:
          state_n <= S18;
        // inst == .
        S1d:
          state_n <= S1e;
        S1e:
          state_n <= S1f;
        S1f:
          state_n <= S21;
        // inst == ,
        S20:
          state_n <= S21;
        // pc++
        S21:
          state_n <= S22;
        S22:
          state_n <= S0;
        S23:
          state_n <= S23;
      endcase
    end

  always @(posedge clk or negedge rst_n)
    begin
      if (!rst_n)
        begin
          pc = 0;
          ptr = 0;
          value = 0;
          inst = 0;
          output_en = 0;
          output_data = 0;
          hang_mem();
        end
      else if (state_c == S0)
        begin
          ram_en <= 1;
          ram_wen <= 0;
          addr <= pc;
          ram_write <= 0;
        end
      else if (state_c == S1)
        hang_mem();
      else if (state_c == S2)
        begin
          hang_mem();
          inst <= ram_read;
        end
      // inst == <
      else if (state_c == S3)
        begin
          hang_mem();
          ptr_temp <= ptr;
        end
      else if (state_c == S4)
        begin
          hang_mem();
          ptr <= ptr_temp - 1;
        end
      // inst == >
      else if (state_c == S5)
        begin
          hang_mem();
          ptr_temp <= ptr;
        end
      else if (state_c == S6)
        begin
          hang_mem();
          ptr <= ptr_temp + 1;
        end
      // inst == +
      else if (state_c == S7)
        begin
          ram_en <= 1;
          ram_wen <= 0;
          addr <= ptr;
          ram_write <= 0;
        end
      else if (state_c == S8)
        hang_mem();
      else if (state_c == S9)
        begin
          ram_en <= 1;
          ram_wen <= 1;
          addr <= ptr;
          ram_write <= ram_read + 1;
        end
      // inst == -
      else if (state_c == Sa)
        begin
          ram_en <= 1;
          ram_wen <= 0;
          addr <= ptr;
          ram_write <= 0;
        end
      else if (state_c == Sb)
        hang_mem();
      else if (state_c == Sc)
        begin
          ram_en <= 1;
          ram_wen <= 1;
          addr <= ptr;
          ram_write <= ram_read - 1;
        end
      // inst == [
      else if (state_c == Sd)
        begin
          ram_en <= 1;
          ram_wen <= 0;
          addr <= ptr;
          ram_write <= 0;
        end
      else if (state_c == Se)
        hang_mem();
      else if (state_c == Sf)
        hang_mem();
      else if (state_c == S10)
        begin
          ram_en <= 1;
          ram_wen <= 0;
          addr <= pc;
          ram_write <= 0;
        end
      else if (state_c == S11)
        hang_mem();
      else if (state_c == S12)
        hang_mem();
      else if (state_c == S13)
        begin
          hang_mem();
          pc_temp <= pc;
        end
      else if (state_c == S14)
        begin
          hang_mem();
          pc <= pc_temp + 1;
        end
      // inst == ]
      else if (state_c == S15)
        begin
          ram_en <= 1;
          ram_wen <= 0;
          addr <= ptr;
          ram_write <= 0;
        end
      else if (state_c == S16)
        hang_mem();
      else if (state_c == S17)
        hang_mem();
      else if (state_c == S18)
        begin
          ram_en <= 1;
          ram_wen <= 0;
          addr <= pc;
          ram_write <= 0;
        end
      else if (state_c == S19)
        hang_mem();
      else if (state_c == S1a)
        hang_mem();
      else if (state_c == S1b)
        begin
          hang_mem();
          pc_temp <= pc;
        end
      else if (state_c == S1c)
        begin
          hang_mem();
          pc <= pc_temp - 1;
        end
      // inst == .
      else if (state_c == S1d)
        begin
          ram_en <= 1;
          ram_wen <= 0;
          addr <= ptr;
          ram_write <= 0;
        end
      else if (state_c == S1e)
        begin
          hang_mem();
          output_en <= 1;
        end
      else if (state_c == S1f)
        begin
          hang_mem();
          output_data <= ram_read;
          output_en <= 0;
        end
      // inst == ,
      else if (state_c == S20)
        begin
          ram_en <= 1;
          ram_wen <= 1;
          addr <= ptr;
          ram_write <= input_data;
        end
      else if (state_c == S21)
        begin
          hang_mem();
          pc_temp <= pc;
        end
      else if (state_c == S22)
        begin
          hang_mem();
          pc <= pc_temp + 1;
        end
      else
      begin hang_mem(); end
    end

  task hang_mem();
    begin
      ram_en <= 0;
      ram_wen <= 0;
      addr <= 0;
      ram_write <= 0;
    end
  endtask

endmodule
