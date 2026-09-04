// shift_unit.v - Handle all shift operations (SLL, SRL, SRA, SLLI, SRLI, SRAI)

module shift_unit (
    input [31:0] a,           // Data to shift
    input [4:0]  shamt,       // Shift amount (5 bits for 0-31)
    input [1:0]  shift_type,  // 00=SLL, 01=SRL, 10=SRA
    output reg [31:0] result
);

always @(*) begin
    case (shift_type)
        2'b00: result = a << shamt;                    // SLL/SLLI - shift left logical
        2'b01: result = a >> shamt;                    // SRL/SRLI - shift right logical
        2'b10: result = $signed(a) >>> shamt;          // SRA/SRAI - shift right arithmetic
        default: result = a;
    endcase
end

endmodule
