module ALU_Control(
  input [5:0] funct_i,
  input [1:0] ALUOp_i,
  output [2:0] ALUCtrl_o
);
`include "./param/Control_param.v"

assign ALUCtrl_o =
  ALUOp_i == 2'b11 ?
    (
      funct_i[3:0] == 4'b0000 ? ADD :
      funct_i[3:0] == 4'b0010 ? SUB :
      funct_i[3:0] == 4'b0100 ? AND :
      funct_i[3:0] == 4'b0101 ? OR  :
      funct_i[3:0] == 4'b1010 ? SLT :
      funct_i[3:0] == 4'b1000 ? MUL : 3'b0
    ) :
    ALUOp_i == 2'b00 ? ADD :
    ALUOp_i == 2'b01 ? SUB :
    ALUOp_i == 2'b10 ? OR  : 3'b0;

endmodule
