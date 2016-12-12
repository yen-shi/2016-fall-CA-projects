module Control(
    input [5:0] Op_i,
    output RegDst_o,
    output RegWrite_o,
    output MemWrite_o,
    output MemtoReg_o,
    output Branch_o,
    output Jump_o,
    output ExtOp_o,
    output ALUSrc_o,
    output [1:0] ALUOp_o
);

parameter ADD   = 2'b00;
parameter SUB   = 2'b01;
parameter OR    = 2'b10;
parameter RTYPE = 2'b11;

wire r_type, addi, lw, sw, beq, jump;

// According to pdf page 4 and hw4
// assign TYPE values for instructions
assign r_type = (Op_i == 6'b00_0000) ? 1 : 0;
assign addi   = (Op_i == 6'b00_1000) ? 1 : 0;
assign lw     = (Op_i == 6'b10_0011) ? 1 : 0;
assign sw     = (Op_i == 6'b10_1011) ? 1 : 0;
assign beq    = (Op_i == 6'b00_0100) ? 1 : 0;
assign jump   = (Op_i == 6'b00_0010) ? 1 : 0;

// assign SIGNAL values for use
assign RegDst_o   = r_type;
assign RegWrite_o = r_type | addi | lw;
assign MemWrite_o = sw;
assign MemtoReg_o = lw;
assign Branch_o   = beq;
assign Jump_o     = jump;
assign ExtOp_o    = lw | sw;
assign ALUSrc_o   = addi | lw | sw;
assign ALUOp_o    = r_type ? RTYPE :
                    addi | lw | sw ? ADD :
                    beq ? SUB : 2'b00;

endmodule
