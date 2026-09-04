
// riscv_cpu.v - single-cycle RISC-V CPU Processor

module riscv_cpu #(parameter WIDTH = 32)(
    input               clk, reset,
    output [WIDTH-1: 0] PC,
    input  [WIDTH-1: 0] Instr,
    output              MemWrite,
    output [WIDTH-1: 0] DataAdr, WriteData_Positioned, // Positioned data for memory
    input  [WIDTH-1: 0] ReadData,
    output [WIDTH-1: 0] Result,
    output [3:0]        ByteEn,
    output [WIDTH-1: 0] WriteData_Reg // Original register value for testbench
);

wire        ALUSrc, RegWrite, Jump, Zero, PCSrc;
wire [1:0]  ResultSrc, ImmSrc;
wire [2:0]  ALUControl;
wire [31:0] SrcA_DP, WriteData_DP;
wire [31:0] Mem_WrAddr, Mem_WrData;
wire [1:0]  AddrOffset;

datapath    dp  (clk, reset, ResultSrc, PCSrc,
                ALUSrc, RegWrite, ImmSrc, ALUControl,
                Zero, PC, Instr, Mem_WrAddr, Mem_WrData, ReadData, Result,
                ByteEn, AddrOffset, SrcA_DP, WriteData_DP);

controller  c   (Instr[6:0], Instr[14:12], Instr[30], Zero,
                SrcA_DP, WriteData_DP,
                ResultSrc, MemWrite, PCSrc, ALUSrc, RegWrite, Jump,
                ImmSrc, ALUControl);

assign DataAdr = Mem_WrAddr;
assign WriteData_Positioned = Mem_WrData;
assign WriteData_Reg = WriteData_DP;

endmodule


