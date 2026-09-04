// store_unit.v - Byte enable generation and data positioning for store instructions

module store_unit (
    input [31:0] write_data,   // Data to write from register
    input [1:0]  addr_offset,  // Address[1:0]
    input [2:0]  funct3,       // Determines sb/sh/sw
    output reg [3:0]  byte_en, // Byte enable signals
    output reg [31:0] data_out // Positioned data for memory
);

always @(*) begin
    case (funct3)
        3'b000: begin // sb - store byte
            case (addr_offset)
                2'b00: begin
                    byte_en = 4'b0001;
                    data_out = {24'b0, write_data[7:0]};
                end
                2'b01: begin
                    byte_en = 4'b0010;
                    data_out = {16'b0, write_data[7:0], 8'b0};
                end
                2'b10: begin
                    byte_en = 4'b0100;
                    data_out = {8'b0, write_data[7:0], 16'b0};
                end
                2'b11: begin
                    byte_en = 4'b1000;
                    data_out = {write_data[7:0], 24'b0};
                end
            endcase
        end
        
        3'b001: begin // sh - store halfword
            if (addr_offset[1] == 1'b0) begin
                byte_en = 4'b0011;
                data_out = {16'b0, write_data[15:0]};
            end else begin
                byte_en = 4'b1100;
                data_out = {write_data[15:0], 16'b0};
            end
        end
        
        3'b010: begin // sw - store word
            byte_en = 4'b1111;
            data_out = write_data;
        end
        
        default: begin
            byte_en = 4'b1111;
            data_out = write_data;
        end
    endcase
end

endmodule
