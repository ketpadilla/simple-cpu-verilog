// tests/register_8bit_tb.v
//
// Testbench for the 8-Bit Register Module
//
// Important:
//   This testbench writes simulation files to the out/ directory.
//   If the out/ directory does not exist, create it before compiling.
//
// To run this test on Mac/Linux:
// 1. Create output folder: mkdir -p out
// 2. Compile: iverilog -o out/register_8bit_tb.vvp src/register_8bit.v tests/register_8bit_tb.v
// 3. Simulate: vvp out/register_8bit_tb.vvp
// 4. View Waveform: gtkwave out/register_8bit_tb.vcd
// 5. View Log File: cat out/register_8bit_tb.log
//
// To run this test on Windows Command Prompt:
// 1. Create output folder: if not exist out mkdir out
// 2. Compile: iverilog -o out/register_8bit_tb.vvp src/register_8bit.v tests/register_8bit_tb.v
// 3. Simulate: vvp out/register_8bit_tb.vvp
// 4. View Log File: type out\register_8bit_tb.log
//
// To run this test on Windows PowerShell:
// 1. Create output folder: New-Item -ItemType Directory -Force out
// 2. Compile: iverilog -o out/register_8bit_tb.vvp src/register_8bit.v tests/register_8bit_tb.v
// 3. Simulate: vvp out/register_8bit_tb.vvp
// 4. View Log File: Get-Content out\register_8bit_tb.log


/**
 * @file register_8bit_tb.v
 * @brief Detailed testbench for the reusable 8-bit register module.
 *
 * This testbench verifies:
 *  - Initial register output behavior
 *  - Reset operation
 *  - Load operation
 *  - Hold operation when load is inactive
 *  - Reset priority over load
 *  - Multiple sequential load operations
 *
 * The CLI output and log file both show each test in a readable format.
 */

`timescale 1ns / 1ps

module register_8bit_tb;

    reg        clk;
    reg        reset;
    reg        load;
    reg  [7:0] data_in;

    wire [7:0] data_out;

    integer test_count;
    integer pass_count;
    integer fail_count;
    integer log_file;

    register_8bit uut (
        .clk(clk),
        .reset(reset),
        .load(load),
        .data_in(data_in),

        .data_out(data_out)
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
            $display("8-Bit Register Testbench Started");
            $fdisplay(log_file, "8-Bit Register Testbench Started");

            $display("Log File: out/register_8bit_tb.log");
            $fdisplay(log_file, "Log File: out/register_8bit_tb.log");

            $display("VCD File: out/register_8bit_tb.vcd");
            $fdisplay(log_file, "VCD File: out/register_8bit_tb.vcd");

            print_separator;
            print_blank;
        end
    endtask

    task check_register;
        input [5:0] test_no;
        input [120*8:1] test_name;
        input expected_reset;
        input expected_load;
        input [7:0] expected_data_in;
        input [7:0] expected_data_out;

        reg passed;

        begin
            test_count = test_count + 1;

            passed = (data_out == expected_data_out);

            print_separator;
            $display("TEST %0d | %0s", test_no, test_name);
            $fdisplay(log_file, "TEST %0d | %0s", test_no, test_name);
            print_separator;

            $display("Inputs at Check Time:");
            $fdisplay(log_file, "Inputs at Check Time:");

            $display("  reset  = %b", reset);
            $fdisplay(log_file, "  reset  = %b", reset);

            $display("  load   = %b", load);
            $fdisplay(log_file, "  load   = %b", load);

            $display("  data_in = %0d / %b", data_in, data_in);
            $fdisplay(log_file, "  data_in = %0d / %b", data_in, data_in);

            print_blank;

            $display("Expected Control/Input:");
            $fdisplay(log_file, "Expected Control/Input:");

            $display("  reset  = %b", expected_reset);
            $fdisplay(log_file, "  reset  = %b", expected_reset);

            $display("  load   = %b", expected_load);
            $fdisplay(log_file, "  load   = %b", expected_load);

            $display("  data_in = %0d / %b", expected_data_in, expected_data_in);
            $fdisplay(log_file, "  data_in = %0d / %b", expected_data_in, expected_data_in);

            print_blank;

            $display("Expected Output:");
            $fdisplay(log_file, "Expected Output:");

            $display("  data_out = %0d / %b", expected_data_out, expected_data_out);
            $fdisplay(log_file, "  data_out = %0d / %b", expected_data_out, expected_data_out);

            print_blank;

            $display("Actual Output:");
            $fdisplay(log_file, "Actual Output:");

            $display("  data_out = %0d / %b", data_out, data_out);
            $fdisplay(log_file, "  data_out = %0d / %b", data_out, data_out);

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
            $display("8-Bit Register Test Summary");
            $fdisplay(log_file, "8-Bit Register Test Summary");
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

            $display("Log Saved To: out/register_8bit_tb.log");
            $fdisplay(log_file, "Log Saved To: out/register_8bit_tb.log");

            print_separator;
        end
    endtask

    initial begin
        $dumpfile("out/register_8bit_tb.vcd");
        $dumpvars(0, register_8bit_tb);

        log_file = $fopen("out/register_8bit_tb.log", "w");

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
        load = 1'b0;
        data_in = 8'b00000000;

        test_count = 0;
        pass_count = 0;
        fail_count = 0;

        print_header;

        // -----------------------------
        // Test 1: Reset Operation
        // reset = 1 clears the register output to 0.
        // -----------------------------
        reset = 1'b1;
        load = 1'b0;
        data_in = 8'd55;

        @(posedge clk);
        #1;

        check_register(1, "Reset clears register output",
                       1'b1, 1'b0, 8'd55, 8'd0);

        // -----------------------------
        // Test 2: Load Operation
        // reset = 0 and load = 1 stores data_in.
        // -----------------------------
        reset = 1'b0;
        load = 1'b1;
        data_in = 8'd25;

        @(posedge clk);
        #1;

        check_register(2, "Load stores data_in value 25",
                       1'b0, 1'b1, 8'd25, 8'd25);

        // -----------------------------
        // Test 3: Hold Operation
        // load = 0 keeps the previous register value.
        // -----------------------------
        reset = 1'b0;
        load = 1'b0;
        data_in = 8'd99;

        @(posedge clk);
        #1;

        check_register(3, "Hold keeps previous value when load is inactive",
                       1'b0, 1'b0, 8'd99, 8'd25);

        // -----------------------------
        // Test 4: Second Load Operation
        // load = 1 stores a new data_in value.
        // -----------------------------
        reset = 1'b0;
        load = 1'b1;
        data_in = 8'd170;

        @(posedge clk);
        #1;

        check_register(4, "Load stores new value 170",
                       1'b0, 1'b1, 8'd170, 8'd170);

        // -----------------------------
        // Test 5: Hold After Second Load
        // The register should keep 170 when load is inactive.
        // -----------------------------
        reset = 1'b0;
        load = 1'b0;
        data_in = 8'd15;

        @(posedge clk);
        #1;

        check_register(5, "Hold keeps value 170 after load is inactive",
                       1'b0, 1'b0, 8'd15, 8'd170);

        // -----------------------------
        // Test 6: Reset Priority Over Load
        // When reset and load are both active, reset should clear the register.
        // -----------------------------
        reset = 1'b1;
        load = 1'b1;
        data_in = 8'd240;

        @(posedge clk);
        #1;

        check_register(6, "Reset has priority over load",
                       1'b1, 1'b1, 8'd240, 8'd0);

        // -----------------------------
        // Test 7: Load After Reset
        // After reset is cleared, the register should load normally again.
        // -----------------------------
        reset = 1'b0;
        load = 1'b1;
        data_in = 8'd64;

        @(posedge clk);
        #1;

        check_register(7, "Load works after reset is cleared",
                       1'b0, 1'b1, 8'd64, 8'd64);

        // -----------------------------
        // Test 8: Binary Pattern Load
        // Verifies that bit patterns are stored correctly.
        // -----------------------------
        reset = 1'b0;
        load = 1'b1;
        data_in = 8'b10101010;

        @(posedge clk);
        #1;

        check_register(8, "Load binary pattern 10101010",
                       1'b0, 1'b1, 8'b10101010, 8'b10101010);

        // -----------------------------
        // Test 9: All Ones Load
        // Verifies that 11111111 can be stored.
        // -----------------------------
        reset = 1'b0;
        load = 1'b1;
        data_in = 8'b11111111;

        @(posedge clk);
        #1;

        check_register(9, "Load all ones 11111111",
                       1'b0, 1'b1, 8'b11111111, 8'b11111111);

        // -----------------------------
        // Test 10: Final Reset
        // Register should return to 00000000.
        // -----------------------------
        reset = 1'b1;
        load = 1'b0;
        data_in = 8'b00001111;

        @(posedge clk);
        #1;

        check_register(10, "Final reset clears register output",
                       1'b1, 1'b0, 8'b00001111, 8'b00000000);

        print_summary;

        $fclose(log_file);
        $finish;
    end

endmodule