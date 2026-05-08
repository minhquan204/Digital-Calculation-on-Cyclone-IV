`timescale 1ns/1ps

module tb_alu;

    reg  [7:0]  A;
    reg  [7:0]  B;
    reg  [1:0]  opcode;
    wire [15:0] result;

    alu uut (
        .A      (A),
        .B      (B),
        .opcode (opcode),
        .result (result)
    );

    task show_result;
        input [7:0] a_in, b_in;
        input [1:0] op;
        input [15:0] res;
        reg [31:0] expected;
        reg        pass;
        begin
            case (op)
                2'b00: expected = a_in + b_in;
                2'b01: expected = $signed(a_in) - $signed(b_in);
                2'b10: expected = a_in * b_in;
                2'b11: expected = (b_in != 0) ? a_in / b_in : 32'h0000EEEE;
                default: expected = 0;
            endcase

            pass = (res == expected[15:0]);

            case (op)
                2'b00: $write("  %0d + %0d = %0d", a_in, b_in, res);
                2'b01: $write("  %0d - %0d = %0d", a_in, b_in, $signed(res));
                2'b10: $write("  %0d * %0d = %0d", a_in, b_in, res);
                2'b11: begin
                    if (b_in == 0)
                        $write("  %0d / 0  = 0xEEEE (divide 0)", a_in);
                    else
                        $write("  %0d / %0d = %0d", a_in, b_in, res);
                end
            endcase

            if (pass)
                $display("  [PASS]");
            else
                $display("  [FAIL] (expected: %0d)", expected[15:0]);
        end
    endtask

    task test_pair;
        input [7:0] a_val, b_val;
        begin
            A = a_val;
            B = b_val;
            $display("\n========================================");
            $display("  Test: A = %0d, B = %0d", a_val, b_val);
            $display("========================================");

            opcode = 2'b00; #10;
            show_result(A, B, opcode, result);

            opcode = 2'b01; #10;
            show_result(A, B, opcode, result);

            opcode = 2'b10; #10;
            show_result(A, B, opcode, result);

            opcode = 2'b11; #10;
            show_result(A, B, opcode, result);
        end
    endtask

    initial begin

        test_pair(8'd15, 8'd5);

        test_pair(8'd20, 8'd12);

        test_pair(8'd3, 8'd9);

        test_pair(8'd7, 8'd0);
        
        test_pair(8'd255, 8'd255);

        test_pair(8'd0, 8'd8);

        $finish;
    end

endmodule
