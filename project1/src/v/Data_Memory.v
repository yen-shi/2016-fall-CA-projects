module Data_Memory
(
    addr_i,
    write_data_i,
    memWrite_i,
    read_data_o
    // No memRead !
);

// Interface
input   [31:0]      addr_i;
input   [31:0]      write_data_i;
input               memWrite_i;
output  reg [31:0]  read_data_o;

// Data memory
reg     [31:0]      memory  [0:255];
integer i;

initial begin
  for(i = 0; i < 256; i++) begin
    memory[i] = 32'b0;
  end
end

always@(*) begin
  if(memWrite_i == 1) begin
    memory[addr_i] = write_data_i;
    read_data_o = 32'b0;
  end else begin
    read_data_o = memory[addr_i];
  end
end

endmodule
