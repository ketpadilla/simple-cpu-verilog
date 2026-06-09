// tests/program_counter_tb.v
//
// Testbench for the Program Counter Module
//
// Important:
//   This testbench writes simulation files to the out/ directory.
//   If the out/ directory does not exist, create it before compiling.
//
// To run this test on Mac/Linux:
// 1. Create output folder: mkdir -p out
// 2. Compile: iverilog -o out/program_counter_tb.vvp src/program_counter.v tests/program_counter_tb.v
// 3. Simulate: vvp out/program_counter_tb.vvp
// 4. View Waveform: gtkwave out/program_counter_tb.vcd
// 5. View Log File: cat out/program_counter_tb.log
//
// To run this test on Windows Command Prompt:
// 1. Create output folder: if not exist out mkdir out
// 2. Compile: iverilog -o out/program_counter_tb.vvp src/program_counter.v tests/program_counter_tb.v
// 3. Simulate: vvp out/program_counter_tb.vvp
// 4. View Log File: type out\program_counter_tb.log
//
// To run this test on Windows PowerShell:
// 1. Create output folder: New-Item -ItemType Directory -Force out
// 2. Compile: iverilog -o out/program_counter_tb.vvp src/program_counter.v tests/program_counter_tb.v
// 3. Simulate: vvp out/program_counter_tb.vvp
// 4. View Log File: Get-Content out\program_counter_tb.log


/**
 * @file program_counter_tb.v
 * @brief Detailed testbench for the 4-bit Program Counter module.
 *
 * This testbench verifies:
 *  - Global reset operation
 *  - PC reset operation
 *  - PC increment operation
 *  - Hold operation when no control signal is active
 *  - Reset priority over pc_reset and pc_increment
 *  - PC reset priority over pc_increment
 *  - 4-bit wrap-around behavior from 15 back to 0
 *
 * The CLI output and log file both show each test in a readable format.
 */

`timescale 1ns / 1ps

module program_counter_tb;

    reg clk;
    reg reset;
    reg pc_reset;
    reg pc_increment;

    wire [3:0] pc_out;

    integer test_count;
    integer pass_count;
    integer fail_count;
    integer log_file;

    program_counter uut (
        .clk(clk),
        .reset(reset),
        .pc_reset(pc_reset),
        .pc_increment(pc_increment),

        .pc_out(pc_out)
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
            $display("Program Counter Testbench Started");
            $fdisplay(log_file, "Program Counter Testbench Started");

            $display("Log File: out/program_counter_tb.log");
            $fdisplay(log_file, "Log File: out/program_counter_tb.log");

            $display("VCD File: out/program_counter_tb.vcd");
            $fdisplay(log_file, "VCD File: out/program_counter_tb.vcd");

            print_separator;
            print_blank;
        end
    endtask

    task check_program_counter;
        input [5:0] test_no;
        input [120*8:1] test_name;
        input expected_reset;
        input expected_pc_reset;
        input expected_pc_increment;
        input [3:0] expected_pc_out;

        reg passed;

        begin
            test_count = test_count + 1;

            passed = (pc_out == expected_pc_out);

            print_separator;
            $display("TEST %0d | %0s", test_no, test_name);
            $fdisplay(log_file, "TEST %0d | %0s", test_no, test_name);
            print_separator;

            $display("Inputs at Check Time:");
            $fdisplay(log_file, "Inputs at Check Time:");

            $display("  reset        = %b", reset);
            $fdisplay(log_file, "  reset        = %b", reset);

            $display("  pc_reset     = %b", pc_reset);
            $fdisplay(log_file, "  pc_reset     = %b", pc_reset);

            $display("  pc_increment = %b", pc_increment);
            $fdisplay(log_file, "  pc_increment = %b", pc_increment);

            print_blank;

            $display("Expected Control/Input:");
            $fdisplay(log_file, "Expected Control/Input:");

            $display("  reset        = %b", expected_reset);
            $fdisplay(log_file, "  reset        = %b", expected_reset);

            $display("  pc_reset     = %b", expected_pc_reset);
            $fdisplay(log_file, "  pc_reset     = %b", expected_pc_reset);

            $display("  pc_increment = %b", expected_pc_increment);
            $fdisplay(log_file, "  pc_increment = %b", expected_pc_increment);

            print_blank;

            $display("Expected Output:");
            $fdisplay(log_file, "Expected Output:");

            $display("  pc_out = %0d / %b", expected_pc_out, expected_pc_out);
            $fdisplay(log_file, "  pc_out = %0d / %b", expected_pc_out, expected_pc_out);

            print_blank;

            $display("Actual Output:");
            $fdisplay(log_file, "Actual Output:");

            $display("  pc_out = %0d / %b", pc_out, pc_out);
            $fdisplay(log_file, "  pc_out = %0d / %b", pc_out, pc_out);

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
            $display("Program Counter Test Summary");
            $fdisplay(log_file, "Program Counter Test Summary");
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

            $display("Log Saved To: out/program_counter_tb.log");
            $fdisplay(log_file, "Log Saved To: out/program_counter_tb.log");

            print_separator;
        end
    endtask

    initial begin
        $dumpfile("out/program_counter_tb.vcd");
        $dumpvars(0, program_counter_tb);

        log_file = $fopen("out/program_counter_tb.log", "w");

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
        pc_reset = 1'b0;
        pc_increment = 1'b0;

        test_count = 0;
        pass_count = 0;
        fail_count = 0;

        print_header;

        // -----------------------------
        // Test 1: Global Reset Operation
        // reset = 1 clears the Program Counter to 0.
        // -----------------------------
        reset = 1'b1;
        pc_reset = 1'b0;
        pc_increment = 1'b0;

        @(posedge clk);
        #1;

        check_program_counter(1, "Global reset clears Program Counter",
                              1'b1, 1'b0, 1'b0, 4'd0);

        // -----------------------------
        // Test 2: First Increment
        // pc_increment = 1 increases PC from 0 to 1.
        // -----------------------------
        reset = 1'b0;
        pc_reset = 1'b0;
        pc_increment = 1'b1;

        @(posedge clk);
        #1;

        check_program_counter(2, "Increment Program Counter from 0 to 1",
                              1'b0, 1'b0, 1'b1, 4'd1);

        // -----------------------------
        // Test 3: Second Increment
        // pc_increment = 1 increases PC from 1 to 2.
        // -----------------------------
        reset = 1'b0;
        pc_reset = 1'b0;
        pc_increment = 1'b1;

        @(posedge clk);
        #1;

        check_program_counter(3, "Increment Program Counter from 1 to 2",
                              1'b0, 1'b0, 1'b1, 4'd2);

        // -----------------------------
        // Test 4: Hold Operation
        // pc_increment = 0 keeps the current PC value.
        // -----------------------------
        reset = 1'b0;
        pc_reset = 1'b0;
        pc_increment = 1'b0;

        @(posedge clk);
        #1;

        check_program_counter(4, "Hold current Program Counter value",
                              1'b0, 1'b0, 1'b0, 4'd2);

        // -----------------------------
        // Test 5: PC Reset Operation
        // pc_reset = 1 clears PC to 0 without using global reset.
        // -----------------------------
        reset = 1'b0;
        pc_reset = 1'b1;
        pc_increment = 1'b0;

        @(posedge clk);
        #1;

        check_program_counter(5, "PC reset clears Program Counter",
                              1'b0, 1'b1, 1'b0, 4'd0);

        // -----------------------------
        // Test 6: Increment After PC Reset
        // Confirms PC can increment normally after pc_reset is cleared.
        // -----------------------------
        reset = 1'b0;
        pc_reset = 1'b0;
        pc_increment = 1'b1;

        @(posedge clk);
        #1;

        check_program_counter(6, "Increment after PC reset is cleared",
                              1'b0, 1'b0, 1'b1, 4'd1);

        // -----------------------------
        // Test 7: PC Reset Priority Over Increment
        // If pc_reset and pc_increment are both active, PC should reset.
        // -----------------------------
        reset = 1'b0;
        pc_reset = 1'b1;
        pc_increment = 1'b1;

        @(posedge clk);
        #1;

        check_program_counter(7, "PC reset has priority over increment",
                              1'b0, 1'b1, 1'b1, 4'd0);

        // -----------------------------
        // Test 8: Global Reset Priority Over PC Reset and Increment
        // If reset, pc_reset, and pc_increment are active, global reset wins.
        // -----------------------------
        reset = 1'b1;
        pc_reset = 1'b1;
        pc_increment = 1'b1;

        @(posedge clk);
        #1;

        check_program_counter(8, "Global reset has highest priority",
                              1'b1, 1'b1, 1'b1, 4'd0);

        // -----------------------------
        // Test 9: Sequential Increment to 5
        // Confirms the PC can count through multiple addresses.
        // Starting from 0 after reset, five increments should produce 5.
        // -----------------------------
        reset = 1'b0;
        pc_reset = 1'b0;
        pc_increment = 1'b1;

        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        #1;

        check_program_counter(9, "Sequential increment reaches address 5",
                              1'b0, 1'b0, 1'b1, 4'd5);

        // -----------------------------
        // Test 10: Hold Address 5
        // Confirms the PC holds address 5 when increment is inactive.
        // -----------------------------
        reset = 1'b0;
        pc_reset = 1'b0;
        pc_increment = 1'b0;

        @(posedge clk);
        #1;

        check_program_counter(10, "Hold Program Counter at address 5",
                              1'b0, 1'b0, 1'b0, 4'd5);

        // -----------------------------
        // Test 11: 4-Bit Wrap-Around
        // Starting from 5, eleven increments should wrap from 15 to 0.
        // 5 + 11 = 16, and 4-bit PC wraps to 0.
        // -----------------------------
        reset = 1'b0;
        pc_reset = 1'b0;
        pc_increment = 1'b1;

        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        @(posedge clk);
        #1;

        check_program_counter(11, "4-bit Program Counter wraps from 15 back to 0",
                              1'b0, 1'b0, 1'b1, 4'd0);

        print_summary;

        $fclose(log_file);
        $finish;
    end

endmodule