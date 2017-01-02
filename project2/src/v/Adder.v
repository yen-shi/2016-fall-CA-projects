module Adder(
  input [SIZE - 1:0] data1_in,
  input [SIZE - 1:0] data2_in,
  output [SIZE - 1:0] data_o
);

parameter SIZE = 32;

assign data_o = data1_in + data2_in;

endmodule
