// branch_comparator.v - Comparator for all branch types

module branch_comparator (
    input [31:0] a, b,
    input [2:0]  funct3,
    output reg   branch_taken
);

always @(*) begin
    case (funct3)
        3'b000: branch_taken = (a == b);                     // beq
        3'b001: branch_taken = (a != b);                     // bne
        3'b100: branch_taken = ($signed(a) < $signed(b));    // blt
        3'b101: branch_taken = ($signed(a) >= $signed(b));   // bge
        3'b110: branch_taken = (a < b);                      // bltu (unsigned)
        3'b111: branch_taken = (a >= b);                     // bgeu (unsigned)
        default: branch_taken = 1'b0;
    endcase
end

endmodule
