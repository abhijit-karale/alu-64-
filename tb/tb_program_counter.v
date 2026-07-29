`timescale 1ns / 1ps

module tb_program_counter;

    // Inputs
    reg clk;
    reg reset;
    reg branch_en;
    reg [63:0] branch_addr;

    // Outputs
    wire [63:0] pc_out;

    // Instantiate the Unit Under Test (UUT)
    program_counter uut (
        .clk(clk), 
        .reset(reset), 
        .branch_en(branch_en), 
        .branch_addr(branch_addr), 
        .pc_out(pc_out)
    );

    // Clock generation (10ns period)
    always #5 clk = ~clk;

    initial begin
        // Initialize Inputs
        clk = 0;
        reset = 1; // Assert reset initially
        branch_en = 0;
        branch_addr = 0;

        $display("Starting Program Counter Simulation...");
        $display("========================================");
        $monitor("Time=%0t | rst=%b | br_en=%b | br_addr=%h | pc_out=%h", $time, reset, branch_en, branch_addr, pc_out);

        // Wait 20 ns, then release reset
        #20;
        reset = 0;
        #1; // Wait a tiny bit to check output
        if (pc_out !== 64'd0) $display("Error: PC not 0 after reset!");
        else $display("PASS: Reset");

        // Let it run for 3 clock cycles
        #29; 
        // At 20ns, reset released. 
        // Edge at 25ns -> pc=8. 
        // Edge at 35ns -> pc=16. 
        // Edge at 45ns -> pc=24.
        if (pc_out !== 64'd24) $display("Error: PC did not increment to 24 properly. Actual: %h", pc_out);
        else $display("PASS: Sequential increment by 8");

        // Test Branch
        @(negedge clk);
        branch_en = 1;
        branch_addr = 64'h0000_0000_0000_0100;
        
        @(negedge clk);
        branch_en = 0; // Disable branch on next cycle

        // After the clock edge where branch_en=1, pc should be 0x100
        if (pc_out !== 64'h0000_0000_0000_0100) $display("Error: Branch failed! Actual: %h", pc_out);
        else $display("PASS: Branch");

        // Check if it continues incrementing after branch
        #20;
        if (pc_out !== 64'h0000_0000_0000_0110) $display("Error: Increment after branch failed! Actual: %h", pc_out);
        else $display("PASS: Increment after branch (0x100 -> 0x108 -> 0x110)");

        $display("========================================");
        $display("Simulation Complete.");
        $finish;
    end
      
endmodule
