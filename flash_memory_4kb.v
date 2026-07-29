`timescale 1ns / 1ps

module flash_memory_4kb #(
    parameter DATA_WIDTH = 64,
    parameter ADDR_WIDTH = 9 // 2^9 = 512 words of 64 bits = 4KB
)(
    input  wire                  clk,
    input  wire                  cs,       // Chip select (active high)
    input  wire                  read_en,  // Read enable (active high)
    input  wire [ADDR_WIDTH-1:0] addr,
    output reg  [DATA_WIDTH-1:0] data_out
);

    // Memory array: 512 words, each 64 bits wide
    reg [DATA_WIDTH-1:0] flash_array [0:(1<<ADDR_WIDTH)-1];

    // Initialize the flash memory with a dummy hex file
    initial begin
        $readmemh("flash_init.mem", flash_array);
    end

    // Synchronous Read Operation
    always @(posedge clk) begin
        if (cs && read_en) begin
            data_out <= flash_array[addr];
        end else begin
            data_out <= {DATA_WIDTH{1'bz}}; // High-Z when not reading
        end
    end

endmodule
