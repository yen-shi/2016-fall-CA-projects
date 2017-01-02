module IF_ID_DFFs(
  input  clk_i,
  input  rst_i,
  input      [SIZE - 1:0] write_i,
  input                   stall_i,
  input                   flush_i,
  output reg [SIZE - 1:0] read_o
);

parameter SIZE = 1;

always@(posedge clk_i or negedge rst_i) begin
  if(~rst_i) begin
    read_o <= 0;
  end else begin
    if(stall_i) begin
      read_o <= read_o;
    end else if(flush_i) begin
      read_o <= 32'b000000_00000_00000_00000_00000_100000;
      // need to give right pc, instruction for flush
    end else begin
      read_o <= write_i;
    end
  end
end

endmodule

