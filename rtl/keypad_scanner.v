module keypad_scanner(
    input clk,
    input rst_n,
    input [3:0] cols,
    output reg [3:0] rows,
    output reg [3:0] out,
    output reg key_pressed
);
    reg [19:0] clk_div;
    wire scan_en = (clk_div == 20'hFFFFF);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) clk_div <= 0;
        else clk_div <= clk_div + 1'b1;
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) rows <= 4'b1110;
        else if (scan_en) rows <= {rows[2:0], rows[3]};
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            out <= 4'h0;
            key_pressed <= 0;
        end else begin
            case ({rows, cols})
                // Row 0 (Rows = 1110)
                8'b1110_1110: begin out <= 4'h1; key_pressed <= 1; end // 1
                8'b1110_1101: begin out <= 4'h2; key_pressed <= 1; end // 2
                8'b1110_1011: begin out <= 4'h3; key_pressed <= 1; end // 3
                8'b1110_0111: begin out <= 4'hA; key_pressed <= 1; end // (+)

                // Row 1 (Rows = 1101)
                8'b1101_1110: begin out <= 4'h4; key_pressed <= 1; end // 4
                8'b1101_1101: begin out <= 4'h5; key_pressed <= 1; end // 5
                8'b1101_1011: begin out <= 4'h6; key_pressed <= 1; end // 6
                8'b1101_0111: begin out <= 4'hB; key_pressed <= 1; end // (-)

                // Row 2 (Rows = 1011)
                8'b1011_1110: begin out <= 4'h7; key_pressed <= 1; end // 7
                8'b1011_1101: begin out <= 4'h8; key_pressed <= 1; end // 8
                8'b1011_1011: begin out <= 4'h9; key_pressed <= 1; end // 9
                8'b1011_0111: begin out <= 4'hC; key_pressed <= 1; end // (*)

                // Row 3 (Rows = 0111)
                8'b0111_1110: begin out <= 4'hE; key_pressed <= 1; end // (=)
                8'b0111_1101: begin out <= 4'h0; key_pressed <= 1; end // 0
                8'b0111_1011: begin out <= 4'hF; key_pressed <= 1; end // (CLEAR/RESET)
                8'b0111_0111: begin out <= 4'hD; key_pressed <= 1; end // (/)
                
                default: if (scan_en) key_pressed <= 0; 
            endcase
        end
    end
endmodule
