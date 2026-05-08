module led_scanner(
    input clk,
    input rst_n,
    input [15:0] result,
    output reg [7:0] seg,
    output reg [3:0] dig
);
    reg [16:0] count;
    wire [3:0] d1, d2, d3, d4;
    reg [3:0] cur_hex;

    wire [31:0] temp_res = {16'd0, result};

    assign d1 = temp_res % 32'd10;           // Ones
    assign d2 = (temp_res / 32'd10) % 32'd10;    // Tens
    assign d3 = (temp_res / 32'd100) % 32'd10;   // Hundreds
    assign d4 = (temp_res / 32'd1000) % 32'd10;  // Thousands

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) count <= 17'd0;
        else count <= count + 17'd1;
    end

    always @(*) begin
        case(count[16:15])
            2'b00: begin dig = 4'b1110; cur_hex = d1; end 
            2'b01: begin dig = 4'b1101; cur_hex = d2; end 
            2'b10: begin dig = 4'b1011; cur_hex = d3; end 
            2'b11: begin dig = 4'b0111; cur_hex = d4; end 
            default: begin dig = 4'b1111; cur_hex = 4'h0; end
        endcase
    end

    always @(*) begin
        case(cur_hex)
            4'h0: seg = 8'b00111111;
            4'h1: seg = 8'b00000110;
            4'h2: seg = 8'b01011011;
            4'h3: seg = 8'b01001111;
            4'h4: seg = 8'b01100110;
            4'h5: seg = 8'b01101101;
            4'h6: seg = 8'b01111101;
            4'h7: seg = 8'b00000111;
            4'h8: seg = 8'b01111111;
            4'h9: seg = 8'b01101111;
            default: seg = 8'b00000000; 
        endcase
    end
endmodule
