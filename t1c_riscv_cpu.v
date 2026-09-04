
// t1c_riscv_cpu.v - Top Module to test riscv_cpu

module t1c_riscv_cpu (
    input         clk, reset,
    input         Ext_MemWrite,
    input  [31:0] Ext_WriteData, Ext_DataAdr,
    output        MemWrite,
    output [31:0] WriteData, DataAdr, ReadData,
    output [31:0] PC, Result
);

wire [31:0] Instr;
wire [31:0] DataAdr_rv32, WriteData_rv32, WriteData_Positioned;
wire        MemWrite_rv32;
wire [3:0]  ByteEn_rv32;

// instantiate processor and memories
// CPU core: outputs both positioned data (for memory) and original register value (for testbench)
riscv_cpu rvcpu    (clk, reset, PC, Instr,
                    MemWrite_rv32, DataAdr_rv32,
                    WriteData_Positioned, ReadData, Result, ByteEn_rv32, WriteData_rv32);
instr_mem instrmem (PC, Instr);
// Memory always receives positioned data for correct byte/halfword writes
data_mem  datamem  (clk, MemWrite, DataAdr, WriteData_Positioned, 
                    (Ext_MemWrite && reset) ? 4'b1111 : ByteEn_rv32, ReadData);

// Testbench expects original register value for WriteData output
assign MemWrite  = (Ext_MemWrite && reset) ? 1 : MemWrite_rv32;
assign WriteData = (Ext_MemWrite && reset) ? Ext_WriteData : WriteData_rv32;  // For testbench verification only
assign DataAdr   = reset ? Ext_DataAdr : DataAdr_rv32;

endmodule

