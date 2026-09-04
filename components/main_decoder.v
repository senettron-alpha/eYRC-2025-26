
// main_decoder.v - logic for main decoder

module main_decoder (
    input  [6:0] op,
    output [1:0] ResultSrc,
    output       MemWrite, Branch, ALUSrc,
    output       RegWrite, Jump,
    output [1:0] ImmSrc,
    output [1:0] ALUOp
);

reg [10:0] controls;

always @(*) begin
    case (op)
        // RegWrite_ImmSrc_ALUSrc_MemWrite_ResultSrc_Branch_ALUOp_Jump
        7'b0000011: controls = 11'b1_00_1_0_01_0_00_0; // lw, lb, lh, lbu, lhu
        7'b0100011: controls = 11'b0_01_1_1_00_0_00_0; // sw, sb, sh
        7'b0110011: controls = 11'b1_xx_0_0_00_0_10_0; // R-type
        7'b1100011: controls = 11'b0_10_0_0_00_1_01_0; // beq, bne, blt, bge, bltu, bgeu
        7'b0010011: controls = 11'b1_00_1_0_00_0_10_0; // I-type ALU (addi, slti, sltiu, xori, ori, andi, slli, srli, srai)
        7'b1101111: controls = 11'b1_11_0_0_10_0_00_1; // jal
        7'b1100111: controls = 11'b1_00_1_0_10_0_00_1; // jalr
        7'b0110111: controls = 11'b1_11_x_0_11_0_00_0; // lui (ImmSrc=11 will be handled specially)
        7'b0010111: controls = 11'b1_11_x_0_11_0_00_0; // auipc (ImmSrc=11 will be handled specially)
        default:    controls = 11'bx_xx_x_x_xx_x_xx_x; // ???
    endcase
end

assign {RegWrite, ImmSrc, ALUSrc, MemWrite, ResultSrc, Branch, ALUOp, Jump} = controls;

endmodule

