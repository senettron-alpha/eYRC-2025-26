
// datapath.v
module datapath (
    input         clk, reset,
    input [1:0]   ResultSrc,
    input         PCSrc, ALUSrc,
    input         RegWrite,
    input [1:0]   ImmSrc,
    input [2:0]   ALUControl,
    output        Zero,
    output [31:0] PC,
    input  [31:0] Instr,
    output [31:0] Mem_WrAddr, Mem_WrData,
    input  [31:0] ReadData,
    output [31:0] Result,
    output [3:0]  ByteEn,      // Byte enable for store operations
    output [1:0]  AddrOffset,  // Address offset for load/store byte/halfword
    output [31:0] SrcA_Out,    // For branch comparator
    output [31:0] WriteData_Out // For branch comparator
);

wire [31:0] PCNext, PCPlus4, PCTarget, PCTargetJALR, PCNext_Target;
wire [31:0] ImmExt, SrcA, SrcB, WriteData, ALUResult, ALUResult_Final;
wire [31:0] ReadData_Extended, PC_ImmExt;
wire [31:0] StoreData_Positioned;
wire [31:0] ShiftResult;
wire [4:0]  ShiftAmount;
wire [1:0]  ShiftType;
wire        IsShift, IsShiftRight;

// next PC logic
reset_ff #(32) pcreg(clk, reset, PCNext, PC);
adder          pcadd4(PC, 32'd4, PCPlus4);
adder          pcaddbranch(PC, ImmExt, PCTarget);

// JALR: PC = ALUResult & ~1, else normal branch target
assign PCTargetJALR = {ALUResult[31:1], 1'b0};
// Select between normal branch/jal target or jalr target
mux2 #(32)     pctargetmux(PCTarget, PCTargetJALR, (Instr[6:0] == 7'b1100111), PCNext_Target);
mux2 #(32)     pcmux(PCPlus4, PCNext_Target, PCSrc, PCNext);

// register file logic
reg_file       rf (clk, RegWrite, Instr[19:15], Instr[24:20], Instr[11:7], Result, SrcA, WriteData);
imm_extend     ext (Instr, ImmSrc, ImmExt);

// Detect shift operations
assign IsShift = (Instr[6:0] == 7'b0010011 && (Instr[14:12] == 3'b001 || Instr[14:12] == 3'b101)) ||  // I-type shifts
                 (Instr[6:0] == 7'b0110011 && (Instr[14:12] == 3'b001 || Instr[14:12] == 3'b101));    // R-type shifts

assign IsShiftRight = (Instr[14:12] == 3'b101);  // SRL/SRLI or SRA/SRAI
assign ShiftAmount = (Instr[6:0] == 7'b0010011) ? Instr[24:20] : SrcB[4:0];  // I-type uses imm, R-type uses rs2
assign ShiftType = (Instr[14:12] == 3'b001) ? 2'b00 :        // SLL/SLLI
                   (Instr[30] == 1'b0) ? 2'b01 :              // SRL/SRLI (funct7[5]=0)
                                         2'b10;                // SRA/SRAI (funct7[5]=1)

// Shift unit
shift_unit shifter (SrcA, ShiftAmount, ShiftType, ShiftResult);

// ALU logic
mux2 #(32)     srcbmux(WriteData, ImmExt, ALUSrc, SrcB);
alu            alu_inst (SrcA, SrcB, ALUControl, ALUResult, Zero);

// Select between ALU result and shift result
assign ALUResult_Final = IsShift ? ShiftResult : ALUResult;

// Load extension for byte/halfword loads
load_extend    load_ext (ReadData, ALUResult_Final[1:0], Instr[14:12], ReadData_Extended);

// Store unit for byte/halfword stores
store_unit     store_u (WriteData, ALUResult_Final[1:0], Instr[14:12], ByteEn, StoreData_Positioned);

// PC + ImmExt for AUIPC
adder          pcaddimm(PC, ImmExt, PC_ImmExt);

// Result mux: 00=ALU, 01=ReadData(extended), 10=PC+4, 11=ImmExt(LUI) or PC+ImmExt(AUIPC)
wire [31:0] Result_UType;
assign Result_UType = (Instr[6:0] == 7'b0010111) ? PC_ImmExt : ImmExt;  // AUIPC vs LUI

mux4 #(32)     resultmux(ALUResult_Final, ReadData_Extended, PCPlus4, Result_UType, ResultSrc, Result);

assign Mem_WrData = StoreData_Positioned;
assign Mem_WrAddr = ALUResult_Final;
assign AddrOffset = ALUResult_Final[1:0];
assign SrcA_Out = SrcA;
assign WriteData_Out = WriteData;

endmodule

