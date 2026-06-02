// tests/alu_tb.v
//
// Testbench for the ALU Module
//
// Important:
//   This testbench writes simulation files to the out/ directory.
//   If the out/ directory does not exist, create it before compiling.
//
// To run this test on Mac/Linux:
// 1. Create output folder: mkdir -p out
// 2. Compile: iverilog -o out/alu_tb.vvp src/alu.v tests/alu_tb.v
// 3. Simulate: vvp out/alu_tb.vvp
// 4. View Waveform: gtkwave out/alu_tb.vcd
// 5. View Log File: cat out/alu_tb.log
//
// To run this test on Windows Command Prompt:
// 1. Create output folder: if not exist out mkdir out
// 2. Compile: iverilog -o out/alu_tb.vvp src/alu.v tests/alu_tb.v
// 3. Simulate: vvp out/alu_tb.vvp
// 4. View Log File: type out\alu_tb.log
//
// To run this test on Windows PowerShell:
// 1. Create output folder: New-Item -ItemType Directory -Force out
// 2. Compile: iverilog -o out/alu_tb.vvp src/alu.v tests/alu_tb.v
// 3. Simulate: vvp out/alu_tb.vvp
// 4. View Log File: Get-Content out\alu_tb.log


/**
 * @file alu_tb.v
 * @brief Detailed testbench for the simple CPU ALU module.
 *
 * This testbench verifies:
 *  - ADD operation
 *  - SUB operation
 *  - AND operation
 *  - CMP operation when A equals B
 *  - CMP operation when A does not equal B
 *  - Zero flag behavior
 *  - Equal flag behavior
 *  - Reserved opcode behavior
 *
 * The CLI output and log file both show each test in a readable format.
 */

`timescale 1ns / 1ps

module alu_tb;

    reg  [2:0] opcode;
    reg  [7:0] A_in;
    reg  [7:0] B_in;

    wire [7:0] alu_result;
    wire       zero_flag;
    wire       equal_flag;

    integer test_count;
    integer pass_count;
    integer fail_count;
    integer log_file;

    // Opcode definitions based on the 6-instruction ISA.
    parameter LDA  = 3'b000;
    parameter LDB  = 3'b001;
    parameter ADD  = 3'b010;
    parameter SUB  = 3'b011;
    parameter AND  = 3'b100;
    parameter CMP  = 3'b101;
    parameter NOP1 = 3'b110;
    parameter NOP2 = 3'b111;

    alu uut (
        .opcode(opcode),
        .A_in(A_in),
        .B_in(B_in),

        .alu_result(alu_result),
        .zero_flag(zero_flag),
        .equal_flag(equal_flag)
    );

    task print_separator;
        begin
            $display("==================================================");
            $fdisplay(log_file, "==================================================");
        end
    endtask

    task print_blank;
        begin
            $display("");
            $fdisplay(log_file, "");
        end
    endtask

    task print_header;
        begin
            print_separator;
            $display("ALU Testbench Started");
            $fdisplay(log_file, "ALU Testbench Started");

            $display("Log File: out/alu_tb.log");
            $fdisplay(log_file, "Log File: out/alu_tb.log");

            $display("VCD File: out/alu_tb.vcd");
            $fdisplay(log_file, "VCD File: out/alu_tb.vcd");

            print_separator;
            print_blank;
        end
    endtask

    task check_alu;
        input [5:0] test_no;
        input [120*8:1] test_name;
        input [2:0] test_opcode;
        input [7:0] test_A;
        input [7:0] test_B;
        input [7:0] expected_result;
        input       expected_zero;
        input       expected_equal;

        reg passed;

        begin
            opcode = test_opcode;
            A_in   = test_A;
            B_in   = test_B;

            #10;

            test_count = test_count + 1;

            passed = (alu_result == expected_result &&
                      zero_flag  == expected_zero &&
                      equal_flag == expected_equal);

            print_separator;
            $display("TEST %0d | %0s", test_no, test_name);
            $fdisplay(log_file, "TEST %0d | %0s", test_no, test_name);
            print_separator;

            $display("Inputs:");
            $fdisplay(log_file, "Inputs:");

            $display("  Opcode = %b", opcode);
            $fdisplay(log_file, "  Opcode = %b", opcode);

            $display("  A_in   = %0d / %b", A_in, A_in);
            $fdisplay(log_file, "  A_in   = %0d / %b", A_in, A_in);

            $display("  B_in   = %0d / %b", B_in, B_in);
            $fdisplay(log_file, "  B_in   = %0d / %b", B_in, B_in);

            print_blank;

            $display("Expected:");
            $fdisplay(log_file, "Expected:");

            $display("  alu_result = %0d / %b", expected_result, expected_result);
            $fdisplay(log_file, "  alu_result = %0d / %b", expected_result, expected_result);

            $display("  zero_flag  = %b", expected_zero);
            $fdisplay(log_file, "  zero_flag  = %b", expected_zero);

            $display("  equal_flag = %b", expected_equal);
            $fdisplay(log_file, "  equal_flag = %b", expected_equal);

            print_blank;

            $display("Actual:");
            $fdisplay(log_file, "Actual:");

            $display("  alu_result = %0d / %b", alu_result, alu_result);
            $fdisplay(log_file, "  alu_result = %0d / %b", alu_result, alu_result);

            $display("  zero_flag  = %b", zero_flag);
            $fdisplay(log_file, "  zero_flag  = %b", zero_flag);

            $display("  equal_flag = %b", equal_flag);
            $fdisplay(log_file, "  equal_flag = %b", equal_flag);

            print_blank;

            if (passed) begin
                pass_count = pass_count + 1;
                $display("Status: PASS");
                $fdisplay(log_file, "Status: PASS");
            end
            else begin
                fail_count = fail_count + 1;
                $display("Status: FAIL");
                $fdisplay(log_file, "Status: FAIL");
            end

            print_blank;
        end
    endtask

    task print_summary;
        begin
            print_separator;
            $display("ALU Test Summary");
            $fdisplay(log_file, "ALU Test Summary");
            print_separator;

            $display("Total Tests : %0d", test_count);
            $fdisplay(log_file, "Total Tests : %0d", test_count);

            $display("Passed      : %0d", pass_count);
            $fdisplay(log_file, "Passed      : %0d", pass_count);

            $display("Failed      : %0d", fail_count);
            $fdisplay(log_file, "Failed      : %0d", fail_count);

            if (fail_count == 0) begin
                $display("Final Result: ALL TESTS PASSED");
                $fdisplay(log_file, "Final Result: ALL TESTS PASSED");
            end
            else begin
                $display("Final Result: SOME TESTS FAILED");
                $fdisplay(log_file, "Final Result: SOME TESTS FAILED");
            end

            $display("Log Saved To: out/alu_tb.log");
            $fdisplay(log_file, "Log Saved To: out/alu_tb.log");

            print_separator;
        end
    endtask

    initial begin
        $dumpfile("out/alu_tb.vcd");
        $dumpvars(0, alu_tb);

        log_file = $fopen("out/alu_tb.log", "w");

        if (log_file == 0) begin
            $display("[ERROR] Could not open log file.");
            $display("[ERROR] Please create the out/ directory before running the simulation.");
            $display("[ERROR] Mac/Linux: mkdir -p out");
            $display("[ERROR] Windows CMD: if not exist out mkdir out");
            $display("[ERROR] PowerShell: New-Item -ItemType Directory -Force out");
            $finish;
        end

        test_count = 0;
        pass_count = 0;
        fail_count = 0;

        opcode = 3'b000;
        A_in   = 8'd0;
        B_in   = 8'd0;

        print_header;

        // -----------------------------
        // Test 1: ADD Operation
        // A = 10, B = 5
        // Expected result = 15
        // -----------------------------
        check_alu(1, "ADD operation: 10 + 5",
                  ADD, 8'd10, 8'd5, 8'd15, 1'b0, 1'b0);

        // -----------------------------
        // Test 2: ADD Operation with Zero Result by Overflow
        // A = 255, B = 1
        // 8-bit result wraps to 0
        // Expected result = 0, Z = 1
        // -----------------------------
        check_alu(2, "ADD overflow wrap: 255 + 1",
                  ADD, 8'd255, 8'd1, 8'd0, 1'b1, 1'b0);

        // -----------------------------
        // Test 3: SUB Operation
        // A = 20, B = 8
        // Expected result = 12
        // -----------------------------
        check_alu(3, "SUB operation: 20 - 8",
                  SUB, 8'd20, 8'd8, 8'd12, 1'b0, 1'b0);

        // -----------------------------
        // Test 4: SUB Operation with Zero Result
        // A = 9, B = 9
        // Expected result = 0, Z = 1
        // -----------------------------
        check_alu(4, "SUB zero result: 9 - 9",
                  SUB, 8'd9, 8'd9, 8'd0, 1'b1, 1'b0);

        // -----------------------------
        // Test 5: SUB Operation with 8-bit Underflow
        // A = 5, B = 10
        // 8-bit result = 251
        // -----------------------------
        check_alu(5, "SUB underflow wrap: 5 - 10",
                  SUB, 8'd5, 8'd10, 8'd251, 1'b0, 1'b0);

        // -----------------------------
        // Test 6: AND Operation
        // A = 11001100
        // B = 10101010
        // Expected result = 10001000
        // -----------------------------
        check_alu(6, "AND operation: 11001100 & 10101010",
                  AND, 8'b11001100, 8'b10101010, 8'b10001000, 1'b0, 1'b0);

        // -----------------------------
        // Test 7: AND Operation with Zero Result
        // A = 11110000
        // B = 00001111
        // Expected result = 00000000, Z = 1
        // -----------------------------
        check_alu(7, "AND zero result: 11110000 & 00001111",
                  AND, 8'b11110000, 8'b00001111, 8'b00000000, 1'b1, 1'b0);

        // -----------------------------
        // Test 8: CMP Equal
        // A = 33, B = 33
        // Expected result = 1, EQ = 1
        // -----------------------------
        check_alu(8, "CMP equal: 33 == 33",
                  CMP, 8'd33, 8'd33, 8'd1, 1'b0, 1'b1);

        // -----------------------------
        // Test 9: CMP Not Equal
        // A = 33, B = 44
        // Expected result = 0, Z = 1, EQ = 0
        // -----------------------------
        check_alu(9, "CMP not equal: 33 != 44",
                  CMP, 8'd33, 8'd44, 8'd0, 1'b1, 1'b0);

        // -----------------------------
        // Test 10: LDA Opcode
        // LDA does not perform ALU computation.
        // Expected result = 0, Z = 1
        // -----------------------------
        check_alu(10, "LDA opcode: no ALU operation",
                  LDA, 8'd15, 8'd20, 8'd0, 1'b1, 1'b0);

        // -----------------------------
        // Test 11: LDB Opcode
        // LDB does not perform ALU computation.
        // Expected result = 0, Z = 1
        // -----------------------------
        check_alu(11, "LDB opcode: no ALU operation",
                  LDB, 8'd15, 8'd20, 8'd0, 1'b1, 1'b0);

        // -----------------------------
        // Test 12: Reserved Opcode 110
        // Reserved opcode is treated as no operation.
        // Expected result = 0, Z = 1
        // -----------------------------
        check_alu(12, "Reserved opcode 110: NOP behavior",
                  NOP1, 8'd99, 8'd88, 8'd0, 1'b1, 1'b0);

        // -----------------------------
        // Test 13: Reserved Opcode 111
        // Reserved opcode is treated as no operation.
        // Expected result = 0, Z = 1
        // -----------------------------
        check_alu(13, "Reserved opcode 111: NOP behavior",
                  NOP2, 8'd99, 8'd88, 8'd0, 1'b1, 1'b0);

        print_summary;

        $fclose(log_file);
        $finish;
    end

endmodule