module alu(
    input [7:0] A,        
    input [7:0] B,        
    input [1:0] opcode,     // 00:+, 01:-, 10:*, 11:/
    output reg [15:0] result 
);

    always @(*) begin
        case(opcode)
            2'b00: result = A + B;       
            2'b01: result = A - B;        
            2'b10: result = A * B;         
            2'b11: begin                  
                if (B != 0) 
                    result = A / B;
                else 
                    result = 16'hEEEE;    
            end
            default: result = 16'h0000;
        endcase
    end
endmodule
