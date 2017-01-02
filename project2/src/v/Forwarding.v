module Forwarding (
  ID_EX_Rs_i,
  ID_EX_Rt_i,
  EX_MEM_Rd_i,
  EX_MEM_RegWrite_i,
  MEM_WB_Rd_i,
  MEM_WB_RegWrite_i,
  ForwardA_o,
  ForwardB_o
);
  input   [4:0]   ID_EX_Rs_i;
  input   [4:0]   ID_EX_Rt_i;
  input   [4:0]   EX_MEM_Rd_i;
  input           EX_MEM_RegWrite_i;
  input   [4:0]   MEM_WB_Rd_i;
  input           MEM_WB_RegWrite_i;
  output  [1:0]   ForwardA_o;
  output  [1:0]   ForwardB_o;

  wire EX_Hazard, MEM_Hazard;

// the conditions are got from slides.
assign EX_Hazard  = EX_MEM_RegWrite_i & (EX_MEM_Rd_i != 0);
assign MEM_Hazard = MEM_WB_RegWrite_i & (MEM_WB_Rd_i != 0);

assign ForwardA_o = (EX_Hazard &
                     (EX_MEM_Rd_i == ID_EX_Rs_i)) ? 2'b10 :
                    (MEM_Hazard &
                     (EX_MEM_Rd_i != ID_EX_Rs_i) &
                     (MEM_WB_Rd_i == ID_EX_Rs_i)  ) ? 2'b01 : 2'b00;

assign ForwardB_o = (EX_Hazard &
                     (EX_MEM_Rd_i == ID_EX_Rt_i)) ? 2'b10 :
                    (MEM_Hazard &
                     (EX_MEM_Rd_i != ID_EX_Rt_i) &
                     (MEM_WB_Rd_i == ID_EX_Rt_i)  ) ? 2'b01 : 2'b00;

endmodule
