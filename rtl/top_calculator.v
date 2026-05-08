module top_calculator(
    input clk,
    input rst_n,
    input [3:0] cols,
    output [3:0] rows,
    output [7:0] seg,
    output [3:0] dig
);

    wire [3:0] key_val;
    wire key_pressed;
    reg [7:0] op1, op2;
    reg [1:0] op_sel;
    reg [2:0] state;
    wire [15:0] alu_out;
    reg [15:0] display_value;

    // DEBOUNCE LOGIC
    reg [19:0] debounce_count;
    reg key_stable;
    reg key_pressed_reg;

    always @(posedge clk) begin
        if (key_pressed == key_stable)
            debounce_count <= 0;
        else begin
            debounce_count <= debounce_count + 20'd1;
            if (debounce_count == 20'd1_000_000) // 20ms debounce at 50MHz
                key_stable <= key_pressed;
        end
    end

    wire key_edge = (key_stable && !key_pressed_reg);

    keypad_scanner scan_inst (.clk(clk), .rst_n(rst_n), .cols(cols), .rows(rows), .out(key_val), .key_pressed(key_pressed));
    alu alu_inst (.A(op1), .B(op2), .opcode(op_sel), .result(alu_out));
    led_scanner disp_inst (.clk(clk), .rst_n(rst_n), .result(display_value), .seg(seg), .dig(dig));

    // Calculator FSM
always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= 3'd0;
            display_value <= 16'd0;
            op1 <= 8'd0; 
            op2 <= 8'd0; 
            op_sel <= 2'd0;
            key_pressed_reg <= 1'b0;
        end else begin
            key_pressed_reg <= key_stable; 

            if (key_edge) begin
                if (key_val == 4'hF) begin // Clear
                    state <= 3'd0; 
                    display_value <= 16'd0;
                    op1 <= 8'd0; op2 <= 8'd0;
                end else begin
                    case(state)
                        3'd0: begin // Input First Number
                            if(key_val < 4'hA) begin 
                                op1 <= {4'd0, key_val}; 
                                display_value <= {12'd0, key_val}; 
                                state <= 3'd1; 
                            end
                        end
                        3'd1: begin // Input Operator 
                            if(key_val >= 4'hA && key_val <= 4'hD) begin 
                                op_sel <= key_val[1:0]; 
                                state <= 3'd2; 
                            end
                        end
                        3'd2: begin // Input Second Number
                            if(key_val < 4'hA) begin 
                                op2 <= {4'd0, key_val}; 
                                state <= 3'd3; 
                            end
                        end
                        3'd3: begin 
                            // Stay here for one clock cycle to let ALU finish
                            state <= 3'd4; 
                        end
                        3'd4: begin 
                            display_value <= alu_out; 
                            state <= 3'd0; 
                        end
                        default: state <= 3'd0;
                    endcase
                end
            end
        end
    end
endmodule