module DFFs (
  input   clk_i,
  input   rst_i,
  input   stall_i,
  input      [SIZE - 1:0] write_i,
  output reg [SIZE - 1:0] read_o
);

parameter SIZE = 1;

always@(posedge clk_i or negedge rst_i) begin
  if(~rst_i)
    read_o <= 0;
  else if(stall_i)
    read_o <= read_o;
  else
    read_o <= write_i;
end

endmodule
