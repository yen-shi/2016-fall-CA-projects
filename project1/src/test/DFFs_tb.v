`define CYCLE_TIME 50            
`define TEST_SIZE 5

module DFFs_tb;

reg clk_i, rst_i;
reg  [`TEST_SIZE - 1:0] write_value;
wire [`TEST_SIZE - 1:0] read_value;
integer counter;

always #(`CYCLE_TIME/2) clk_i = ~clk_i;    

DFFs #(.SIZE(`TEST_SIZE)) dff4(
  .clk_i(clk_i),
  .rst_i(rst_i),
  .write_i(write_value),
  .read_o(read_value)
);

initial begin
  clk_i = 1;
  rst_i = 1;
  write_value = 0;
  counter = 32'b0;
  #(1*`CYCLE_TIME)
  rst_i = 0;
end

always@(posedge clk_i) begin
  if(counter == `TEST_SIZE * 2) $stop;

  #(`CYCLE_TIME/10)
  write_value = read_value + 1;
  counter = counter + 1;
  $display("At counter %d , get value %b from DFFs", counter, read_value);

end

endmodule
