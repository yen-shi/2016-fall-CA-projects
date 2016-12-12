module ALU(
    input [31:0] data1_i,
    input [31:0] data2_i,
    input [2:0]  ALUCtrl_i,
    output reg [31:0] data_o,
    output Zero_o
);
`include "./param/Control_param.v"

assign zero_o = (data1_i == data2_i) ? 1 : 0;

always@ (*) begin
  case(ALUCtrl_i)
    AND: data_o = data1_i & data2_i;
    OR : data_o = data1_i | data2_i;
    ADD: data_o = data1_i + data2_i;
    SUB: data_o = data1_i - data2_i;
    MUL: data_o = data1_i * data2_i;
    default: data_o = 32'b0;
  endcase
end

endmodule
