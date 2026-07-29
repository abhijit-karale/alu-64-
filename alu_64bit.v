`timescale 1ns / 1ps

// Explicit Structural Datapath for Addition and Subtraction
module adder_subtractor_64bit (
    input  wire [63:0] a,
    input  wire [63:0] b,
    input  wire        sub_enable,
    output wire [63:0] result,
    output wire        carry_out,
    output wire        overflow
);
    // 2's complement logic: invert B if subtracting
    wire [63:0] b_modified = b ^ {64{sub_enable}}; 
    
    // Explicit 65-bit sum including carry-in (sub_enable)
    wire [64:0] sum = a + b_modified + sub_enable;
    
    assign result = sum[63:0];
    assign carry_out = sum[64];
    
    // Overflow: if A and B_modified have the same sign, and the Result has a different sign
    assign overflow = (a[63] == b_modified[63]) && (result[63] != a[63]);

endmodule


module alu_64bit (
    input  wire [63:0] a,
    input  wire [63:0] b,
    input  wire [3:0]  alu_op,
    output reg  [63:0] result,
    output wire        zero,
    output wire        carry_out,
    output wire        overflow
);

    reg carry_out_reg;
    reg overflow_reg;

    // Structural arithmetic datapath instantiation
    wire [63:0] add_sub_res;
    wire        add_sub_cout;
    wire        add_sub_ovf;
    wire        is_sub = (alu_op == 4'b0110) || (alu_op == 4'b0111); // SUB or SLT

    adder_subtractor_64bit add_sub_unit (
        .a(a),
        .b(b),
        .sub_enable(is_sub),
        .result(add_sub_res),
        .carry_out(add_sub_cout),
        .overflow(add_sub_ovf)
    );

    always @(*) begin
        // Default values
        carry_out_reg = 1'b0;
        overflow_reg  = 1'b0;
        result = 64'd0;

        case (alu_op)
            4'b0000: result = a & b; // AND
            4'b0001: result = a | b; // OR
            4'b0010: begin // ADD
                result = add_sub_res;
                carry_out_reg = add_sub_cout;
                overflow_reg = add_sub_ovf;
            end
            4'b0110: begin // SUB
                result = add_sub_res;
                carry_out_reg = add_sub_cout;
                overflow_reg = add_sub_ovf;
            end
            4'b0111: begin // SLT (Set on Less Than - Signed)
                // In a structural ALU, SLT is natively computed as (Sign_Result XOR Overflow)
                result = (add_sub_res[63] ^ add_sub_ovf) ? 64'd1 : 64'd0;
            end
            4'b1100: result = ~(a | b); // NOR
            4'b1101: result = a ^ b; // XOR
            4'b1110: result = a << b[5:0]; // SLL (Shift Left Logical) - lower 6 bits of B determine shift amount
            4'b1111: result = a >> b[5:0]; // SRL (Shift Right Logical)
            default: result = 64'd0;
        endcase
    end

    // Zero flag is 1 if result is all zeros
    assign zero = (result == 64'd0);
    assign carry_out = carry_out_reg;
    assign overflow = overflow_reg;

endmodule
