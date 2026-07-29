`timescale 1ns / 1ps

module tb_alu_64bit;

    // Inputs
    reg [63:0] a;
    reg [63:0] b;
    reg [3:0] alu_op;

    // Outputs
    wire [63:0] result;
    wire zero;
    wire carry_out;
    wire overflow;

    // Instantiate the Unit Under Test (UUT)
    alu_64bit uut (
        .a(a), 
        .b(b), 
        .alu_op(alu_op), 
        .result(result), 
        .zero(zero), 
        .carry_out(carry_out), 
        .overflow(overflow)
    );

    initial begin
        // Initialize Inputs
        a = 0;
        b = 0;
        alu_op = 0;

        // Wait 100 ns for global reset to finish
        #100;
        
        $display("Starting Simulation...");
        $display("======================");
        $monitor("Time=%0t | a=%h | b=%h | op=%b | res=%h | z=%b | c=%b | ov=%b", $time, a, b, alu_op, result, zero, carry_out, overflow);

        // Add stimulus here
        
        // 1. ADD
        a = 64'h0000_0000_0000_0005;
        b = 64'h0000_0000_0000_000A;
        alu_op = 4'b0010;
        #10;
        if (result !== 64'h0000_0000_0000_000F) $display("Error: ADD failed!");
        else $display("PASS: ADD");
        
        // 2. SUB
        a = 64'h0000_0000_0000_000F;
        b = 64'h0000_0000_0000_0005;
        alu_op = 4'b0110;
        #10;
        if (result !== 64'h0000_0000_0000_000A) $display("Error: SUB failed!");
        else $display("PASS: SUB");

        // 3. AND
        a = 64'hFFFF_FFFF_0000_0000;
        b = 64'h0000_FFFF_FFFF_0000;
        alu_op = 4'b0000;
        #10;
        if (result !== 64'h0000_FFFF_0000_0000) $display("Error: AND failed!");
        else $display("PASS: AND");

        // 4. OR
        a = 64'h0000_0000_0000_FFFF;
        b = 64'h0000_0000_FFFF_0000;
        alu_op = 4'b0001;
        #10;
        if (result !== 64'h0000_0000_FFFF_FFFF) $display("Error: OR failed!");
        else $display("PASS: OR");

        // 5. XOR
        a = 64'hAAAA_AAAA_AAAA_AAAA;
        b = 64'h5555_5555_5555_5555;
        alu_op = 4'b1101;
        #10;
        if (result !== 64'hFFFF_FFFF_FFFF_FFFF) $display("Error: XOR failed!");
        else $display("PASS: XOR");

        // 6. SLT (Set on Less Than)
        a = 64'hFFFF_FFFF_FFFF_FFFF; // -1
        b = 64'h0000_0000_0000_0000; // 0
        alu_op = 4'b0111;
        #10;
        if (result !== 64'd1) $display("Error: SLT failed!");
        else $display("PASS: SLT");

        // 7. SLL (Shift Left Logical)
        a = 64'h0000_0000_0000_0001;
        b = 64'd4;
        alu_op = 4'b1110;
        #10;
        if (result !== 64'h0000_0000_0000_0010) $display("Error: SLL failed!");
        else $display("PASS: SLL");

        // 8. Overflow Test (Signed ADD)
        a = 64'h7FFF_FFFF_FFFF_FFFF; // Max positive 64-bit signed integer
        b = 64'h0000_0000_0000_0001;
        alu_op = 4'b0010;
        #10;
        if (!overflow) $display("Error: Overflow ADD failed!");
        else $display("PASS: Overflow ADD");
        
        // 9. Carry Out Test (Unsigned ADD)
        a = 64'hFFFF_FFFF_FFFF_FFFF; // Max unsigned 64-bit integer
        b = 64'h0000_0000_0000_0001;
        alu_op = 4'b0010;
        #10;
        if (!carry_out) $display("Error: Carry out ADD failed!");
        else $display("PASS: Carry out ADD");
        if (!zero) $display("Error: Zero flag failed!");
        else $display("PASS: Zero flag");

        // 10. SRL (Shift Right Logical)
        a = 64'hF000_0000_0000_0000;
        b = 64'd4;
        alu_op = 4'b1111;
        #10;
        if (result !== 64'h0F00_0000_0000_0000) $display("Error: SRL failed!");
        else $display("PASS: SRL");

        // 11. NOR
        a = 64'h0000_0000_0000_FFFF;
        b = 64'h0000_0000_FFFF_0000;
        alu_op = 4'b1100;
        #10;
        if (result !== 64'hFFFF_FFFF_0000_0000) $display("Error: NOR failed!");
        else $display("PASS: NOR");

        $display("======================");
        $display("Simulation Complete.");
        $finish;
    end
      
endmodule
