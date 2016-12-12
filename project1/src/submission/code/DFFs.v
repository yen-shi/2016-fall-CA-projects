module DFFs (
  input  clk_i,
  input  rst_i,
  input      [SIZE - 1:0] write_i,
  output reg [SIZE - 1:0] read_o
);

parameter SIZE = 1;

always@(posedge clk_i or posedge rst_i) begin
  if(rst_i) begin
    read_o <= 0;
  end else begin
    read_o <= write_i;
  end
end

endmodule
