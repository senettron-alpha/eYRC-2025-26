// load_extend.v - Byte/halfword extraction and extension for load instructions

module load_extend (
    input [31:0] data_in,      // Full 32-bit word from memory
    input [1:0]  addr_offset,  // Address[1:0] for byte/halfword selection
    input [2:0]  funct3,       // Determines lb/lh/lw/lbu/lhu
    output reg [31:0] data_out
);

wire [7:0]  byte_selected;
wire [15:0] half_selected;

// Select byte based on address offset
assign byte_selected = (addr_offset == 2'b00) ? data_in[7:0]   :
                       (addr_offset == 2'b01) ? data_in[15:8]  :
                       (addr_offset == 2'b10) ? data_in[23:16] :
                                                 data_in[31:24];

// Select halfword based on address offset
assign half_selected = (addr_offset[1] == 1'b0) ? data_in[15:0] : data_in[31:16];

always @(*) begin
    case (funct3)
        3'b000: data_out = {{24{byte_selected[7]}}, byte_selected};      // lb - sign extend byte
        3'b001: data_out = {{16{half_selected[15]}}, half_selected};     // lh - sign extend halfword
        3'b010: data_out = data_in;                                      // lw - full word
        3'b100: data_out = {24'b0, byte_selected};                       // lbu - zero extend byte
        3'b101: data_out = {16'b0, half_selected};                       // lhu - zero extend halfword
        default: data_out = data_in;                                     // default to full word
    endcase
end

endmodule
