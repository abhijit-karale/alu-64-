`timescale 1ns / 1ps

module tb_flash_memory;

    // Parameters
    parameter DATA_WIDTH = 64;
    parameter ADDR_WIDTH = 9;

    // Inputs
    reg clk;
    reg cs;
    reg read_en;
    reg [ADDR_WIDTH-1:0] addr;

    // Outputs
    wire [DATA_WIDTH-1:0] data_out;

    // Instantiate the Unit Under Test (UUT)
    flash_memory_4kb #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) uut (
        .clk(clk), 
        .cs(cs), 
        .read_en(read_en), 
        .addr(addr), 
        .data_out(data_out)
    );

    // Clock generation
    always #5 clk = ~clk;

    initial begin
        // Initialize Inputs
        clk = 0;
        cs = 0;
        read_en = 0;
        addr = 0;

        // Wait 100 ns for global reset to finish
        #100;
        
        $display("Starting Flash Memory Simulation...");
        $monitor("Time=%0t | cs=%b | read_en=%b | addr=%h | data_out=%h", $time, cs, read_en, addr, data_out);

        // Test 1: Try reading without Chip Select
        addr = 9'h000;
        read_en = 1;
        cs = 0;
        #10;
        if (data_out !== 64'hz) $display("Error: Data should be High-Z when cs=0");

        // Test 2: Read first few addresses with CS and Read Enable
        cs = 1;
        read_en = 1;
        
        addr = 9'h000; #10;
        if (data_out !== 64'h1111111111111111) $display("Error: Address 0 mismatch!");
        else $display("PASS: Addr 0");

        addr = 9'h001; #10;
        if (data_out !== 64'h2222222222222222) $display("Error: Address 1 mismatch!");
        else $display("PASS: Addr 1");

        addr = 9'h009; #10;
        if (data_out !== 64'hAAAAAAAAAAAAAAAA) $display("Error: Address 9 mismatch!");
        else $display("PASS: Addr 9");

        addr = 9'h00F; #10;
        if (data_out !== 64'h0000000000000000) $display("Error: Address F mismatch!");
        else $display("PASS: Addr F");

        // Test 3: Disable Read Enable
        read_en = 0; #10;
        if (data_out !== 64'hz) $display("Error: Data should be High-Z when read_en=0");
        else $display("PASS: High-Z output");

        $display("Simulation Complete.");
        $finish;
    end
      
endmodule
