module Hazard_Detection (
  ID_EX_MemRead_i,
  ID_EX_Rt_i,
  IF_ID_Rs_i,
  IF_ID_Rt_i,
  bubble_o,
  IF_ID_Write_o,
  PC_Write_o
);
  input         ID_EX_MemRead_i;
  input [4:0]   ID_EX_Rt_i;
  input [4:0]   IF_ID_Rs_i;
  input [4:0]   IF_ID_Rt_i;
  output        bubble_o;
  output        IF_ID_Write_o;
  output        PC_Write_o;

  wire stall;

assign stall = ID_EX_MemRead_i &
               ((ID_EX_Rt_i == IF_ID_Rs_i) |
                (ID_EX_Rt_i == IF_ID_Rt_i));
assign bubble_o = stall;
assign IF_ID_Write_o = stall;
assign PC_Write_o = stall;

endmodule
