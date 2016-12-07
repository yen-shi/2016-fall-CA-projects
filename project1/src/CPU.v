`include "v/Adder.v"
`include "v/Control.v"
`include "v/PC.v"
`include "v/ALU_Control.v"
`include "v/Instruction_Memory.v"
`include "v/Registers.v"
`include "v/Sign_Extend.v"
`include "v/ALU.v"
`include "v/MUX.v"
`include "v/MUX2.v"
`include "v/DFFs.v"
`include "v/Hazard_Detection.v"
`include "v/Data_Memory.v"
`include "v/Forwarding.v"
`include "v/IF_ID_DFFs.v"

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

wire        Flush;

reg [1:0]  ForA, ForB;
always@(*) begin
  ForA = ForwardA_o;
  ForB = ForwardB_o;
end

wire [31:0] instr_addr, new_pc, added_pc, instr_o;
wire [31:0] mux1_o;
wire [31:0] IF_ID_PC, IF_ID_IS;
wire [31:0] branch_pc;
wire [31:0] RSdata_o, RTdata_o, extended_o;
wire [6:0]  mux8_o;
wire        RS_RT_equal, bubble_o, IF_ID_Write_o, PC_Write_o;
wire [31:0] ID_EX_RS, ID_EX_RT, ID_EX_IMMEDIATE;
wire [14:0] ID_EX_IS;
wire [6:0]  ID_EX_CONTROL;
wire [31:0] mux6_o, mux7_o, mux4_o, ALUdata_o;
wire [4:0]  mux3_o;
wire [1:0]  ForwardA_o, ForwardB_o;
wire [31:0] EX_MEM_RESULT, EX_MEM_WRDATA;
wire [4:0]  EX_MEM_REGDST;
wire [2:0]  EX_MEM_CONTROL;
wire [31:0] MEM_WB_LOAD_DATA, MEM_WB_REG_DATA;
wire [4:0]  MEM_WB_REGDST;
wire [1:0]  MEM_WB_CONTROL;
wire [31:0] MEM_WB_mux5_o;

assign Flush = Control.Jump_o | (Control.Branch_o & RS_RT_equal);

PC PC(
    .clk_i      (clk_i),
    .rst_i      (rst_i),
    .start_i    (start_i),
    .pc_i       (new_pc),
    .pc_write_i (PC_Write_o),
    .pc_o       (instr_addr)
);

Adder Add_PC(
    .data1_in   (instr_addr),
    .data2_in   (32'd4),
    .data_o     (added_pc)
);

MUX #(.SIZE(32)) MUX1(
    .data1_i(added_pc),
    .data2_i(branch_pc),
    .select_i(Control.Branch_o & RS_RT_equal),
    .data_o(mux1_o)
);

MUX #(.SIZE(32)) MUX2(
    .data1_i(mux1_o),
    .data2_i({mux1_o[31:28], IF_ID_IS[25:0], 2'b0}),
    .select_i(Control.Jump_o),
    .data_o(new_pc)
);

Instruction_Memory Instruction_Memory(
    .addr_i     (instr_addr), 
    .instr_o    (instr_o)
);

IF_ID_DFFs #(.SIZE(64)) IF_ID(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .write_i({added_pc, instr_o}),
    .stall_i(IF_ID_Write_o),
    .flush_i(Flush),
    .read_o({IF_ID_PC, IF_ID_IS})
);

Hazard_Detection HD(
  .ID_EX_MemRead_i(ID_EX_CONTROL[5]),
  .ID_EX_Rt_i(ID_EX_IS[9:5]),
  .IF_ID_Rs_i(IF_ID_IS[25:21]),
  .IF_ID_Rt_i(IF_ID_IS[20:16]),
  .bubble_o(bubble_o),
  .IF_ID_Write_o(IF_ID_Write_o),
  .PC_Write_o(PC_Write_o)
);

MUX #(.SIZE(7)) MUX8(
    .data1_i({Control.RegWrite_o, Control.MemtoReg_o, // WB
              Control.MemWrite_o,                     // M
              Control.RegDst_o, Control.ALUSrc_o, Control.ALUOp_o}), // EX
    .data2_i(7'b0),
    .select_i(bubble_o),
    .data_o(mux8_o)
);

Adder ADD(
    .data1_in   ({extended_o[29:0], 2'b0}),
    .data2_in   (IF_ID_PC),
    .data_o     (branch_pc)
);

Control Control(
    .Op_i(IF_ID_IS[31:26])
    // .RegDst_o,
    // .RegWrite_o,
    // .MemWrite_o,
    // .MemtoReg_o,
    // .Branch_o,
    // .Jump_o,
    // .ExtOp_o,
    // .ALUSrc_o,
    // .ALUOp_o
);

Registers Registers(
    .clk_i      (clk_i),
    .RSaddr_i   (IF_ID_IS[25:21]),
    .RTaddr_i   (IF_ID_IS[20:16]),
    .RDaddr_i   (MEM_WB_REGDST), 
    .RDdata_i   (MEM_WB_mux5_o),
    .RegWrite_i (MEM_WB_CONTROL[1]), 
    .RSdata_o   (RSdata_o), 
    .RTdata_o   (RTdata_o) 
);

assign RS_RT_equal = (RSdata_o == RTdata_o);

Sign_Extend Sign_Extend(
    .data_i     (IF_ID_IS[15:0]),
    .data_o     (extended_o)
    // May add Control.ExtOp_o to decide logic or sign
);

// SIZE = 7 + 32*2 + 32 + 15 = 119
DFFs #(.SIZE(118)) ID_EX(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .write_i({mux8_o, RSdata_o, RTdata_o, extended_o, IF_ID_IS[25:11]}),
    .read_o({ID_EX_CONTROL, ID_EX_RS, ID_EX_RT, ID_EX_IMMEDIATE, ID_EX_IS})
);

Forwarding FW(
  // The input is address ([4:0]) !
  .ID_EX_Rs_i(ID_EX_IS[14:10]),
  .ID_EX_Rt_i(ID_EX_IS[9:5]),
  .EX_MEM_Rd_i(EX_MEM_REGDST),
  .EX_MEM_RegWrite_i(EX_MEM_CONTROL[2]),
  .MEM_WB_Rd_i(MEM_WB_REGDST),
  .MEM_WB_RegWrite_i(MEM_WB_CONTROL[1]),
  .ForwardA_o(ForwardA_o),
  .ForwardB_o(ForwardB_o)
);

MUX2 #(.SIZE(32)) mux6(
    .data00_i(ID_EX_RS),
    .data01_i(MEM_WB_mux5_o),
    .data10_i(EX_MEM_RESULT),
    .data11_i(32'b0),
    .select_i(ForwardA_o),
    .data_o(mux6_o)
);

MUX2 #(.SIZE(32)) mux7(
    .data00_i(ID_EX_RT),
    .data01_i(MEM_WB_mux5_o),
    .data10_i(EX_MEM_RESULT),
    .data11_i(32'b0),
    .select_i(ForwardB_o),
    .data_o(mux7_o)
);

MUX #(.SIZE(32)) MUX_ALUSrc( // MUX4
    .data1_i    (mux7_o),
    .data2_i    (ID_EX_IMMEDIATE),
    .select_i   (ID_EX_CONTROL[2]),
    .data_o     (mux4_o)
);

MUX #(.SIZE(5)) MUX_RegDst( // MUX3
    .data1_i(ID_EX_IS[9:5]),
    .data2_i(ID_EX_IS[4:0]),
    .select_i(ID_EX_CONTROL[3]),
    .data_o(mux3_o)
);

ALU ALU(
    .data1_i    (mux6_o),
    .data2_i    (mux4_o),
    .ALUCtrl_i  (ALU_Control.ALUCtrl_o),
    .data_o     (ALUdata_o)
);

ALU_Control ALU_Control(
    .funct_i    (ID_EX_IMMEDIATE[5:0]),
    .ALUOp_i    (ID_EX_CONTROL[1:0])
    // .ALUCtrl_o  ()
);

// SIZE = 3 + 32 + 32 + 5 = 72
DFFs #(.SIZE(72)) EX_MEM(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .write_i({ID_EX_CONTROL[6:4], ALUdata_o, mux7_o, mux3_o}),
    .read_o({EX_MEM_CONTROL, EX_MEM_RESULT, EX_MEM_WRDATA, EX_MEM_REGDST})
);

Data_Memory Data_Memory(
    .addr_i(EX_MEM_RESULT),
    .write_data_i(EX_MEM_WRDATA),
    .memWrite_i(EX_MEM_CONTROL[0])
    // .read_data_o
    // No memRead !
);

// SIZE = 2 + 32 + 32 + 5 = 71
DFFs #(.SIZE(71)) MEM_WB(
    .clk_i(clk_i),
    .rst_i(rst_i),
    .write_i({EX_MEM_CONTROL[2:1], Data_Memory.read_data_o, EX_MEM_RESULT, EX_MEM_REGDST}),
    .read_o({MEM_WB_CONTROL, MEM_WB_LOAD_DATA, MEM_WB_REG_DATA, MEM_WB_REGDST})
);

MUX #(.SIZE(32)) MUX5(
    .data1_i    (MEM_WB_REG_DATA),
    .data2_i    (MEM_WB_LOAD_DATA),
    .select_i   (MEM_WB_CONTROL[0]),
    .data_o     (MEM_WB_mux5_o)
);

endmodule

