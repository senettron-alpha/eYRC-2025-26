
// data_mem.v - data memory with byte enable support

module data_mem #(parameter DATA_WIDTH = 32, ADDR_WIDTH = 32, MEM_SIZE = 64) (
    input       clk, wr_en,
    input       [ADDR_WIDTH-1:0] wr_addr, wr_data,
    input       [3:0] byte_en,              // Byte enable signals
    output      [DATA_WIDTH-1:0] rd_data_mem
);

// array of 64 32-bit words or data
reg [DATA_WIDTH-1:0] data_ram [0:MEM_SIZE-1];

// combinational read logic
// word-aligned memory access
assign rd_data_mem = data_ram[wr_addr[DATA_WIDTH-1:2] % 64];

// synchronous write logic with byte enables
always @(posedge clk) begin
    if (wr_en) begin
        if (byte_en[0]) data_ram[wr_addr[DATA_WIDTH-1:2] % 64][7:0]   <= wr_data[7:0];
        if (byte_en[1]) data_ram[wr_addr[DATA_WIDTH-1:2] % 64][15:8]  <= wr_data[15:8];
        if (byte_en[2]) data_ram[wr_addr[DATA_WIDTH-1:2] % 64][23:16] <= wr_data[23:16];
        if (byte_en[3]) data_ram[wr_addr[DATA_WIDTH-1:2] % 64][31:24] <= wr_data[31:24];
    end
end

endmodule

