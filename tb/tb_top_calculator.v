`timescale 1ns/1ps

module tb_top_calculator();

    // Inputs
    reg clk;
    reg rst_n;
    reg [3:0] cols;

    // Outputs
    wire [3:0] rows;
    wire [7:0] seg;
    wire [3:0] dig;

    // Instantiate the Unit Under Test (UUT)
    top_calculator uut (
        .clk(clk),
        .rst_n(rst_n),
        .cols(cols),
        .rows(rows),
        .seg(seg),
        .dig(dig)
    );

    // Clock generation (50MHz -> 20ns period)
    always #10 clk = ~clk;

    // Task to simulate a keypad press by waiting for the correct row scan
    task press_key;
        input [3:0] target_row;
        input [3:0] col_value;
        begin
            wait(rows == target_row); // Wait until scanner hits the right row
            #5; 
            cols = col_value;         // Apply the column signal
            #200;                     // Hold the key
            cols = 4'b1111;           // Release
            #100;                     // Debounce gap
        end
    endtask

    initial begin
        // Initialize
        clk = 0;
        rst_n = 0;
        cols = 4'b1111;

        // Apply Reset
        #100 rst_n = 1;
        #100;

        // --- Simulate Calculation: 5 + 3 ---
        
        // 1. Press Key '5' (Row 1: 4'b1101, Col 1: 4'b1101)
        press_key(4'b1101, 4'b1101);

        // 2. Press Key '+' (Key A) (Row 0: 4'b1110, Col 3: 4'b0111)
        press_key(4'b1110, 4'b0111);

        // 3. Press Key '3' (Row 0: 4'b1110, Col 2: 4'b1011)
        press_key(4'b1110, 4'b1011);

        #1000;
        $display("Test Complete. Verify 'seg' and 'dig' outputs in Waveform.");
        $stop;
    end
endmodule

