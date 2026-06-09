// tests/datapath_tb.v
//
// Testbench for the Datapath Module
//
// Important:
//   This testbench writes simulation files to the out/ directory.
//   If the out/ directory does not exist, create it before compiling.
//
// To run this test on Mac/Linux:
// 1. Create output folder: mkdir -p out
// 2. Compile: iverilog -o out/datapath_tb.vvp src/register_8bit.v src/alu.v src/datapath.v tests/datapath_tb.v
// 3. Simulate: vvp out/datapath_tb.vvp
// 4. View Waveform: gtkwave out/datapath_tb.vcd
// 5. View Log File: cat out/datapath_tb.log
//
// To run this test on Windows Command Prompt:
// 1. Create output folder: if not exist out mkdir out
// 2. Compile: iverilog -o out/datapath_tb.vvp src/register_8bit.v src/alu.v src/datapath.v tests/datapath_tb.v
// 3. Simulate: vvp out/datapath_tb.vvp
// 4. View Log File: type out\datapath_tb.log
//
// To run this test on Windows PowerShell:
// 1. Create output folder: New-Item -ItemType Directory -Force out
// 2. Compile: iverilog -o out/datapath_tb.vvp src/register_8bit.v src/alu.v src/datapath.v tests/datapath_tb.v
// 3. Simulate: vvp out/datapath_tb.vvp
// 4. View Log File: Get-Content out\datapath_tb.log


/**
 * @file datapath_tb.v
 * @brief Detailed testbench for the simple CPU datapath module.
 *
 * This testbench verifies:
 *  - Register A loading through LDA-style control
 *  - Register B loading through LDB-style control
 *  - Register C loading from ALU result
 *  - ADD, SUB, AND, and CMP datapath behavior
 *  - Zero Flag update behavior
 *  - Equal Flag update behavior
 *  - Flag hold behavior when flag load signals are inactive
 *  - Reset behavior for registers and flags
 *
 * The CLI output and log file both show each test in a readable format.
 */

`timescale 1ns / 1ps

module datapath_tb;

    reg        clk;
    reg        reset;

    reg  [2:0] opcode;
    reg  [7:0] data_in;

    reg        reg_a_load;
    reg        reg_b_load;
    reg        reg_c_load;
    reg        flag_z_load;
    reg        flag_eq_load;

    wire [7:0] reg_a_out;
    wire [7:0] reg_b_out;
    wire [7:0] reg_c_out;

    wire       zero_flag;
    wire       equal_flag;

    wire [7:0] alu_result_out;

    integer test_count;
    integer pass_count;
    integer fail_count;
    integer log_file;

    parameter LDA  = 3'b000;
    parameter LDB  = 3'b001;
    parameter ADD  = 3'b010;
    parameter SUB  = 3'b011;
    parameter AND  = 3'b100;
    parameter CMP  = 3'b101;

    datapath uut (
        .clk(clk),
        .reset(reset),

        .opcode(opcode),
        .data_in(data_in),

        .reg_a_load(reg_a_load),
        .reg_b_load(reg_b_load),
        .reg_c_load(reg_c_load),
        .flag_z_load(flag_z_load),
        .flag_eq_load(flag_eq_load),

        .reg_a_out(reg_a_out),
        .reg_b_out(reg_b_out),
        .reg_c_out(reg_c_out),

        .zero_flag(zero_flag),
        .equal_flag(equal_flag),

        .alu_result_out(alu_result_out)
    );

    // Clock generation.
    // One full clock period is 10 ns.
    always #5 clk = ~clk;

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
            $display("Datapath Testbench Started");
            $fdisplay(log_file, "Datapath Testbench Started");

            $display("Log File: out/datapath_tb.log");
            $fdisplay(log_file, "Log File: out/datapath_tb.log");

            $display("VCD File: out/datapath_tb.vcd");
            $fdisplay(log_file, "VCD File: out/datapath_tb.vcd");

            print_separator;
            print_blank;
        end
    endtask

    task apply_clock;
        begin
            @(posedge clk);
            #1;
        end
    endtask

    task clear_control_signals;
        begin
            reg_a_load   = 1'b0;
            reg_b_load   = 1'b0;
            reg_c_load   = 1'b0;
            flag_z_load  = 1'b0;
            flag_eq_load = 1'b0;
        end
    endtask

    task check_datapath;
        input [5:0] test_no;
        input [120*8:1] test_name;

        input [2:0] expected_opcode;
        input [7:0] expected_data_in;

        input expected_reg_a_load;
        input expected_reg_b_load;
        input expected_reg_c_load;
        input expected_flag_z_load;
        input expected_flag_eq_load;

        input [7:0] expected_reg_a_out;
        input [7:0] expected_reg_b_out;
        input [7:0] expected_reg_c_out;
        input [7:0] expected_alu_result_out;
        input       expected_zero_flag;
        input       expected_equal_flag;

        reg passed;

        begin
            test_count = test_count + 1;

            passed = (reg_a_out      == expected_reg_a_out &&
                      reg_b_out      == expected_reg_b_out &&
                      reg_c_out      == expected_reg_c_out &&
                      alu_result_out == expected_alu_result_out &&
                      zero_flag      == expected_zero_flag &&
                      equal_flag     == expected_equal_flag);

            print_separator;
            $display("TEST %0d | %0s", test_no, test_name);
            $fdisplay(log_file, "TEST %0d | %0s", test_no, test_name);
            print_separator;

            $display("Inputs at Check Time:");
            $fdisplay(log_file, "Inputs at Check Time:");

            $display("  reset        = %b", reset);
            $fdisplay(log_file, "  reset        = %b", reset);

            $display("  opcode       = %b", opcode);
            $fdisplay(log_file, "  opcode       = %b", opcode);

            $display("  data_in      = %0d / %b", data_in, data_in);
            $fdisplay(log_file, "  data_in      = %0d / %b", data_in, data_in);

            print_blank;

            $display("Control Signals:");
            $fdisplay(log_file, "Control Signals:");

            $display("  reg_a_load   = %b", reg_a_load);
            $fdisplay(log_file, "  reg_a_load   = %b", reg_a_load);

            $display("  reg_b_load   = %b", reg_b_load);
            $fdisplay(log_file, "  reg_b_load   = %b", reg_b_load);

            $display("  reg_c_load   = %b", reg_c_load);
            $fdisplay(log_file, "  reg_c_load   = %b", reg_c_load);

            $display("  flag_z_load  = %b", flag_z_load);
            $fdisplay(log_file, "  flag_z_load  = %b", flag_z_load);

            $display("  flag_eq_load = %b", flag_eq_load);
            $fdisplay(log_file, "  flag_eq_load = %b", flag_eq_load);

            print_blank;

            $display("Expected Control/Input:");
            $fdisplay(log_file, "Expected Control/Input:");

            $display("  opcode       = %b", expected_opcode);
            $fdisplay(log_file, "  opcode       = %b", expected_opcode);

            $display("  data_in      = %0d / %b", expected_data_in, expected_data_in);
            $fdisplay(log_file, "  data_in      = %0d / %b", expected_data_in, expected_data_in);

            $display("  reg_a_load   = %b", expected_reg_a_load);
            $fdisplay(log_file, "  reg_a_load   = %b", expected_reg_a_load);

            $display("  reg_b_load   = %b", expected_reg_b_load);
            $fdisplay(log_file, "  reg_b_load   = %b", expected_reg_b_load);

            $display("  reg_c_load   = %b", expected_reg_c_load);
            $fdisplay(log_file, "  reg_c_load   = %b", expected_reg_c_load);

            $display("  flag_z_load  = %b", expected_flag_z_load);
            $fdisplay(log_file, "  flag_z_load  = %b", expected_flag_z_load);

            $display("  flag_eq_load = %b", expected_flag_eq_load);
            $fdisplay(log_file, "  flag_eq_load = %b", expected_flag_eq_load);

            print_blank;

            $display("Expected Output:");
            $fdisplay(log_file, "Expected Output:");

            $display("  reg_a_out      = %0d / %b", expected_reg_a_out, expected_reg_a_out);
            $fdisplay(log_file, "  reg_a_out      = %0d / %b", expected_reg_a_out, expected_reg_a_out);

            $display("  reg_b_out      = %0d / %b", expected_reg_b_out, expected_reg_b_out);
            $fdisplay(log_file, "  reg_b_out      = %0d / %b", expected_reg_b_out, expected_reg_b_out);

            $display("  reg_c_out      = %0d / %b", expected_reg_c_out, expected_reg_c_out);
            $fdisplay(log_file, "  reg_c_out      = %0d / %b", expected_reg_c_out, expected_reg_c_out);

            $display("  alu_result_out = %0d / %b", expected_alu_result_out, expected_alu_result_out);
            $fdisplay(log_file, "  alu_result_out = %0d / %b", expected_alu_result_out, expected_alu_result_out);

            $display("  zero_flag      = %b", expected_zero_flag);
            $fdisplay(log_file, "  zero_flag      = %b", expected_zero_flag);

            $display("  equal_flag     = %b", expected_equal_flag);
            $fdisplay(log_file, "  equal_flag     = %b", expected_equal_flag);

            print_blank;

            $display("Actual Output:");
            $fdisplay(log_file, "Actual Output:");

            $display("  reg_a_out      = %0d / %b", reg_a_out, reg_a_out);
            $fdisplay(log_file, "  reg_a_out      = %0d / %b", reg_a_out, reg_a_out);

            $display("  reg_b_out      = %0d / %b", reg_b_out, reg_b_out);
            $fdisplay(log_file, "  reg_b_out      = %0d / %b", reg_b_out, reg_b_out);

            $display("  reg_c_out      = %0d / %b", reg_c_out, reg_c_out);
            $fdisplay(log_file, "  reg_c_out      = %0d / %b", reg_c_out, reg_c_out);

            $display("  alu_result_out = %0d / %b", alu_result_out, alu_result_out);
            $fdisplay(log_file, "  alu_result_out = %0d / %b", alu_result_out, alu_result_out);

            $display("  zero_flag      = %b", zero_flag);
            $fdisplay(log_file, "  zero_flag      = %b", zero_flag);

            $display("  equal_flag     = %b", equal_flag);
            $fdisplay(log_file, "  equal_flag     = %b", equal_flag);

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
            $display("Datapath Test Summary");
            $fdisplay(log_file, "Datapath Test Summary");
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

            $display("Log Saved To: out/datapath_tb.log");
            $fdisplay(log_file, "Log Saved To: out/datapath_tb.log");

            print_separator;
        end
    endtask

    initial begin
        $dumpfile("out/datapath_tb.vcd");
        $dumpvars(0, datapath_tb);

        log_file = $fopen("out/datapath_tb.log", "w");

        if (log_file == 0) begin
            $display("[ERROR] Could not open log file.");
            $display("[ERROR] Please create the out/ directory before running the simulation.");
            $display("[ERROR] Mac/Linux: mkdir -p out");
            $display("[ERROR] Windows CMD: if not exist out mkdir out");
            $display("[ERROR] PowerShell: New-Item -ItemType Directory -Force out");
            $finish;
        end

        clk = 1'b0;
        reset = 1'b0;

        opcode = LDA;
        data_in = 8'd0;

        clear_control_signals;

        test_count = 0;
        pass_count = 0;
        fail_count = 0;

        print_header;

        // -----------------------------
        // Test 1: Reset Datapath
        // reset clears Register A, Register B, Register C, Z, and EQ.
        // -----------------------------
        reset = 1'b1;
        opcode = ADD;
        data_in = 8'd99;
        reg_a_load = 1'b1;
        reg_b_load = 1'b1;
        reg_c_load = 1'b1;
        flag_z_load = 1'b1;
        flag_eq_load = 1'b1;

        apply_clock;

        check_datapath(1, "Reset clears registers and flags",
                       ADD, 8'd99,
                       1'b1, 1'b1, 1'b1, 1'b1, 1'b1,
                       8'd0, 8'd0, 8'd0, 8'd0, 1'b0, 1'b0);

        // -----------------------------
        // Test 2: Load Register A
        // LDA-style datapath operation loads data_in into Register A.
        // -----------------------------
        reset = 1'b0;
        clear_control_signals;

        opcode = LDA;
        data_in = 8'd12;
        reg_a_load = 1'b1;

        apply_clock;

        check_datapath(2, "Load Register A with 12",
                       LDA, 8'd12,
                       1'b1, 1'b0, 1'b0, 1'b0, 1'b0,
                       8'd12, 8'd0, 8'd0, 8'd0, 1'b0, 1'b0);

        // -----------------------------
        // Test 3: Load Register B
        // LDB-style datapath operation loads data_in into Register B.
        // -----------------------------
        clear_control_signals;

        opcode = LDB;
        data_in = 8'd5;
        reg_b_load = 1'b1;

        apply_clock;

        check_datapath(3, "Load Register B with 5",
                       LDB, 8'd5,
                       1'b0, 1'b1, 1'b0, 1'b0, 1'b0,
                       8'd12, 8'd5, 8'd0, 8'd0, 1'b0, 1'b0);

        // -----------------------------
        // Test 4: ADD Operation
        // Register C receives A + B = 12 + 5 = 17.
        // Zero flag updates to 0.
        // -----------------------------
        clear_control_signals;

        opcode = ADD;
        data_in = 8'd0;
        reg_c_load = 1'b1;
        flag_z_load = 1'b1;

        apply_clock;

        check_datapath(4, "ADD stores A + B into Register C",
                       ADD, 8'd0,
                       1'b0, 1'b0, 1'b1, 1'b1, 1'b0,
                       8'd12, 8'd5, 8'd17, 8'd17, 1'b0, 1'b0);

        // -----------------------------
        // Test 5: SUB Operation
        // Register C receives A - B = 12 - 5 = 7.
        // Zero flag updates to 0.
        // -----------------------------
        clear_control_signals;

        opcode = SUB;
        data_in = 8'd0;
        reg_c_load = 1'b1;
        flag_z_load = 1'b1;

        apply_clock;

        check_datapath(5, "SUB stores A - B into Register C",
                       SUB, 8'd0,
                       1'b0, 1'b0, 1'b1, 1'b1, 1'b0,
                       8'd12, 8'd5, 8'd7, 8'd7, 1'b0, 1'b0);

        // -----------------------------
        // Test 6: AND Operation
        // Register C receives A & B = 12 & 5 = 4.
        // Zero flag updates to 0.
        // -----------------------------
        clear_control_signals;

        opcode = AND;
        data_in = 8'd0;
        reg_c_load = 1'b1;
        flag_z_load = 1'b1;

        apply_clock;

        check_datapath(6, "AND stores A & B into Register C",
                       AND, 8'd0,
                       1'b0, 1'b0, 1'b1, 1'b1, 1'b0,
                       8'd12, 8'd5, 8'd4, 8'd4, 1'b0, 1'b0);

        // -----------------------------
        // Test 7: Load Register B with Same Value as A
        // Prepare for CMP equal test: A = 12, B = 12.
        // -----------------------------
        clear_control_signals;

        opcode = LDB;
        data_in = 8'd12;
        reg_b_load = 1'b1;

        apply_clock;

        check_datapath(7, "Load Register B with 12 for CMP equal",
                       LDB, 8'd12,
                       1'b0, 1'b1, 1'b0, 1'b0, 1'b0,
                       8'd12, 8'd12, 8'd4, 8'd0, 1'b0, 1'b0);

        // -----------------------------
        // Test 8: CMP Equal Operation
        // A == B, so Register C receives 1, Z = 0, EQ = 1.
        // -----------------------------
        clear_control_signals;

        opcode = CMP;
        data_in = 8'd0;
        reg_c_load = 1'b1;
        flag_z_load = 1'b1;
        flag_eq_load = 1'b1;

        apply_clock;

        check_datapath(8, "CMP equal stores 1 and sets Equal Flag",
                       CMP, 8'd0,
                       1'b0, 1'b0, 1'b1, 1'b1, 1'b1,
                       8'd12, 8'd12, 8'd1, 8'd1, 1'b0, 1'b1);

        // -----------------------------
        // Test 9: Load Register B with Different Value
        // Prepare for CMP not equal test: A = 12, B = 3.
        // Flags should hold because flag load signals are inactive.
        // -----------------------------
        clear_control_signals;

        opcode = LDB;
        data_in = 8'd3;
        reg_b_load = 1'b1;

        apply_clock;

        check_datapath(9, "Load Register B with 3 and hold flags",
                       LDB, 8'd3,
                       1'b0, 1'b1, 1'b0, 1'b0, 1'b0,
                       8'd12, 8'd3, 8'd1, 8'd0, 1'b0, 1'b1);

        // -----------------------------
        // Test 10: CMP Not Equal Operation
        // A != B, so Register C receives 0, Z = 1, EQ = 0.
        // -----------------------------
        clear_control_signals;

        opcode = CMP;
        data_in = 8'd0;
        reg_c_load = 1'b1;
        flag_z_load = 1'b1;
        flag_eq_load = 1'b1;

        apply_clock;

        check_datapath(10, "CMP not equal stores 0 and clears Equal Flag",
                       CMP, 8'd0,
                       1'b0, 1'b0, 1'b1, 1'b1, 1'b1,
                       8'd12, 8'd3, 8'd0, 8'd0, 1'b1, 1'b0);

        // -----------------------------
        // Test 11: Flag Hold Behavior
        // Load Register A only. Flags should remain unchanged.
        // -----------------------------
        clear_control_signals;

        opcode = LDA;
        data_in = 8'd9;
        reg_a_load = 1'b1;

        apply_clock;

        check_datapath(11, "Flags hold when flag load signals are inactive",
                       LDA, 8'd9,
                       1'b1, 1'b0, 1'b0, 1'b0, 1'b0,
                       8'd9, 8'd3, 8'd0, 8'd0, 1'b1, 1'b0);

        // -----------------------------
        // Test 12: SUB Zero Result
        // Set B = 9, then SUB gives A - B = 0.
        // This confirms Zero Flag can update to 1.
        // -----------------------------
        clear_control_signals;

        opcode = LDB;
        data_in = 8'd9;
        reg_b_load = 1'b1;

        apply_clock;

        clear_control_signals;

        opcode = SUB;
        data_in = 8'd0;
        reg_c_load = 1'b1;
        flag_z_load = 1'b1;

        apply_clock;

        check_datapath(12, "SUB zero result updates Zero Flag",
                       SUB, 8'd0,
                       1'b0, 1'b0, 1'b1, 1'b1, 1'b0,
                       8'd9, 8'd9, 8'd0, 8'd0, 1'b1, 1'b0);

        // -----------------------------
        // Test 13: Final Reset
        // Confirms registers and flags clear again.
        // -----------------------------
        clear_control_signals;

        reset = 1'b1;
        opcode = ADD;
        data_in = 8'd0;

        apply_clock;

        check_datapath(13, "Final reset clears datapath state",
                       ADD, 8'd0,
                       1'b0, 1'b0, 1'b0, 1'b0, 1'b0,
                       8'd0, 8'd0, 8'd0, 8'd0, 1'b0, 1'b0);

        print_summary;

        $fclose(log_file);
        $finish;
    end

endmodule