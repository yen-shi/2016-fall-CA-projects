module Data_Memory_tb;

reg  [31:0]       addr_i;
reg  [31:0]       write_data_i;
reg  memWrite_i;
wire [31:0]       read_data_o;

Data_Memory dm0
(
    .addr_i(addr_i),
    .write_data_i(write_data_i),
    .memWrite_i(memWrite_i),
    .read_data_o(read_data_o)
);

initial begin
  #1
  addr_i = 32'b0;
  write_data_i = 32'h0000_0001;
  memWrite_i = 1;
  #1
  $display("Address %d , memWrite_i = %b, write_data = %d, read_data = %d", addr_i, memWrite_i, write_data_i, read_data_o);
  #1
  addr_i = 32'b1;
  write_data_i = 32'h0000_0001;
  memWrite_i = 0;
  #1
  $display("Address %d , memWrite_i = %b, write_data = %d, read_data = %d", addr_i, memWrite_i, write_data_i, read_data_o);
  #1
  addr_i = 32'b10;
  write_data_i = 32'h0000_0002;
  memWrite_i = 1;
  #1
  $display("Address %d , memWrite_i = %b, write_data = %d, read_data = %d", addr_i, memWrite_i, write_data_i, read_data_o);
  #1
  addr_i = 32'b10;
  write_data_i = 32'h0000_0002;
  memWrite_i = 0;
  #1
  $display("Address %d , memWrite_i = %b, write_data = %d, read_data = %d", addr_i, memWrite_i, write_data_i, read_data_o);
  $display("In memory Address %d, get %d", 8'b0, dm0.memory[8'b0]);
  $display("In memory Address %d, get %d", 8'b1, dm0.memory[8'b1]);
  $display("In memory Address %d, get %d", 8'b10, dm0.memory[8'b10]);
end

endmodule
