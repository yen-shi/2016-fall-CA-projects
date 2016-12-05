`include "v/Adder.v"
`include "v/Control.v"
`include "v/PC.v"
`include "v/ALU_Control.v"
`include "v/Instruction_Memory.v"
`include "v/Registers.v"
`include "v/Sign_Extend.v"
`include "v/ALU.v"
`include "v/MUX.v"

module CPU
(
    clk_i, 
    rst_i,
    start_i
);

// Ports
input               clk_i;
input               rst_i;
input               start_i;

wire [31:0] pc_w, pc_r;
wire [31:0] instr_addr, instr_o;
wire [31:0] RSdata_o, RTdata_o, ALUdata_o;
wire [31:0] added_pc, mux32_o, extended_o;
wire [4:0] mux5_o;
wire [2:0] ALUCtrl_o;
wire [1:0] ALUOp_o;
wire RegDst_o, ALUSrc_o, RegWrite_o;

Control Control(
    .Op_i       (instr_o[31:26]),
    .RegDst_o   (RegDst_o),
    .ALUOp_o    (ALUOp_o),
    .ALUSrc_o   (ALUSrc_o),
    .RegWrite_o (RegWrite_o)
);

Adder Add_PC(
    .data1_in   (instr_addr),
    .data2_in   (32'd4),
    .data_o     (added_pc)
);

PC PC(
    .clk_i      (clk_i),
    .rst_i      (rst_i),
    .start_i    (start_i),
    .pc_i       (added_pc),
    .pc_o       (instr_addr)
);

Instruction_Memory Instruction_Memory(
    .addr_i     (instr_addr), 
    .instr_o    (instr_o)
);

MUX #(.SIZE(5)) MUX_RegDst(
    .data1_i(instr_o[20:16]),
    .data2_i(instr_o[15:11]),
    .select_i(RegDst_o),
    .data_o(mux5_o)
);

Registers Registers(
    .clk_i      (clk_i),
    .RSaddr_i   (instr_o[25:21]),
    .RTaddr_i   (instr_o[20:16]),
    .RDaddr_i   (mux5_o), 
    .RDdata_i   (ALUdata_o),
    .RegWrite_i (RegWrite_o), 
    .RSdata_o   (RSdata_o), 
    .RTdata_o   (RTdata_o) 
);

MUX #(.SIZE(32)) MUX_ALUSrc(
    .data1_i    (RTdata_o),
    .data2_i    (extended_o),
    .select_i   (ALUSrc_o),
    .data_o     (mux32_o)
);

Sign_Extend Sign_Extend(
    .data_i     (instr_o[15:0]),
    .data_o     (extended_o)
);
  
ALU ALU(
    .data1_i    (RSdata_o),
    .data2_i    (mux32_o),
    .ALUCtrl_i  (ALUCtrl_o),
    .data_o     (ALUdata_o),
    .Zero_o     ()
);

ALU_Control ALU_Control(
    .funct_i    (instr_o[5:0]),
    .ALUOp_i    (ALUOp_o),
    .ALUCtrl_o  (ALUCtrl_o)
);

endmodule

