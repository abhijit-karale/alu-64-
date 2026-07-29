`timescale 1ns / 1ps

module program_counter (
    input  wire        clk,
    input  wire        reset,          // Active-high synchronous reset
    input  wire        branch_en,      // Branch enable
    input  wire [63:0] branch_addr,    // Target address for branch
    output reg  [63:0] pc_out
);

    always @(posedge clk) begin
        if (reset) begin
            pc_out <= 64'd0;
        end else if (branch_en) begin
            pc_out <= branch_addr;
        end else begin
            // Increment by 8 bytes (64 bits) for next instruction
            pc_out <= pc_out + 64'd8;
        end
    end

endmodule
