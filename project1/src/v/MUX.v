module MUX (
  input [SIZE - 1:0] data1_i,
  input [SIZE - 1:0] data2_i,
  input select_i,
  output [SIZE - 1: 0] data_o
);

parameter SIZE = 1;

assign data_o = select_i ? data2_i : data1_i;

endmodule
