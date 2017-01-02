module MUX2 (
  input [SIZE - 1:0]    data00_i,
  input [SIZE - 1:0]    data01_i,
  input [SIZE - 1:0]    data10_i,
  input [SIZE - 1:0]    data11_i,
  input [1:0]           select_i,
  output [SIZE - 1: 0]  data_o
);

parameter SIZE = 1;

assign data_o = select_i == 2'b00 ? data00_i :
                select_i == 2'b01 ? data01_i :
                select_i == 2'b10 ? data10_i :
                select_i == 2'b11 ? data11_i : 0;

endmodule

