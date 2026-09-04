
// controller.v - controller for RISC-V CPU

module controller (
    input [6:0]  op,
    input [2:0]  funct3,
    input        funct7b5,
    input        Zero,
    input [31:0] SrcA, SrcB,        // Need actual values for branch comparator
    output       [1:0] ResultSrc,
    output       MemWrite,
    output       PCSrc, ALUSrc,
    output       RegWrite, Jump,
    output [1:0] ImmSrc,
    output [2:0] ALUControl
);

wire [1:0] ALUOp;
wire       Branch;
wire       BranchTaken;

main_decoder    md (op, ResultSrc, MemWrite, Branch,
                    ALUSrc, RegWrite, Jump, ImmSrc, ALUOp);

alu_decoder     ad (op[5], funct3, funct7b5, ALUOp, ALUControl);

// Branch comparator for all branch types
branch_comparator bc (SrcA, SrcB, funct3, BranchTaken);

// for jump and branch
assign PCSrc = (Branch & BranchTaken) | Jump;

endmodule

