// tests/instruction_register_tb.v
//
// Testbench for the Instruction Register Module
//
// Important:
//   This testbench writes simulation files to the out/ directory.
//   If the out/ directory does not exist, create it before compiling.
//
// To run this test on Mac/Linux:
// 1. Create output folder: mkdir -p out
// 2. Compile: iverilog -o out/instruction_register_tb.vvp src/instruction_register.v tests/instruction_register_tb.v
// 3. Simulate: vvp out/instruction_register_tb.vvp
// 4. View Waveform: gtkwave out/instruction_register_tb.vcd
// 5. View Log File: cat out/instruction_register_tb.log
//
// To run this test on Windows Command Prompt:
// 1. Create output folder: if not exist out mkdir out
// 2. Compile: iverilog -o out/instruction_register_tb.vvp src/instruction_register.v tests/instruction_register_tb.v
// 3. Simulate: vvp out/instruction_register_tb.vvp
// 4. View Log File: type out\instruction_register_tb.log
//
// To run this test on Windows PowerShell:
// 1. Create output folder: New-Item -ItemType Directory -Force out
// 2. Compile: iverilog -o out/instruction_register_tb.vvp src/instruction_register.v tests/instruction_register_tb.v
// 3. Simulate: vvp out/instruction_register_tb.vvp
// 4. View Log File: Get-Content out\instruction_register_tb.log


/**
 * @file instruction_register_tb.v
 * @brief Detailed testbench for the 11-bit instruction register module.
 *
 * This testbench verifies:
 *  - Reset operation
 *  - Load operation
 *  - Hold operation when load is inactive
 *  - Reset priority over load
 *  - Opcode field extraction from instruction_out[10:8]
 *  - Operand/data field extraction from instruction_out[7:0]
 *
 * The CLI output and log file both show each test in a readable format.
 */

`timescale 1ns / 1ps

module instruction_register_tb;

    reg         clk;
    reg         reset;
    reg         load;
    reg  [10:0] instruction_in;

    wire [10:0] instruction_out;
    wire [2:0]  opcode_out;
    wire [7:0]  operand_out;

    integer test_count;
    integer pass_count;
    integer fail_count;
    integer log_file;

    instruction_register uut (
        .clk(clk),
        .reset(reset),
        .load(load),
        .instruction_in(instruction_in),

        .instruction_out(instruction_out),
        .opcode_out(opcode_out),
        .operand_out(operand_out)
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
            $display("Instruction Register Testbench Started");
            $fdisplay(log_file, "Instruction Register Testbench Started");

            $display("Log File: out/instruction_register_tb.log");
            $fdisplay(log_file, "Log File: out/instruction_register_tb.log");

            $display("VCD File: out/instruction_register_tb.vcd");
            $fdisplay(log_file, "VCD File: out/instruction_register_tb.vcd");

            print_separator;
            print_blank;
        end
    endtask

    task check_instruction_register;
        input [5:0] test_no;
        input [120*8:1] test_name;
        input expected_reset;
        input expected_load;
        input [10:0] expected_instruction_in;
        input [10:0] expected_instruction_out;
        input [2:0]  expected_opcode;
        input [7:0]  expected_operand;

        reg passed;

        begin
            test_count = test_count + 1;

            passed = (instruction_out == expected_instruction_out &&
                      opcode_out      == expected_opcode &&
                      operand_out     == expected_operand);

            print_separator;
            $display("TEST %0d | %0s", test_no, test_name);
            $fdisplay(log_file, "TEST %0d | %0s", test_no, test_name);
            print_separator;

            $display("Inputs at Check Time:");
            $fdisplay(log_file, "Inputs at Check Time:");

            $display("  reset          = %b", reset);
            $fdisplay(log_file, "  reset          = %b", reset);

            $display("  load           = %b", load);
            $fdisplay(log_file, "  load           = %b", load);

            $display("  instruction_in = %b", instruction_in);
            $fdisplay(log_file, "  instruction_in = %b", instruction_in);

            $display("                 = opcode %b | operand %b",
                     instruction_in[10:8], instruction_in[7:0]);
            $fdisplay(log_file, "                 = opcode %b | operand %b",
                      instruction_in[10:8], instruction_in[7:0]);

            print_blank;

            $display("Expected Control/Input:");
            $fdisplay(log_file, "Expected Control/Input:");

            $display("  reset          = %b", expected_reset);
            $fdisplay(log_file, "  reset          = %b", expected_reset);

            $display("  load           = %b", expected_load);
            $fdisplay(log_file, "  load           = %b", expected_load);

            $display("  instruction_in = %b", expected_instruction_in);
            $fdisplay(log_file, "  instruction_in = %b", expected_instruction_in);

            print_blank;

            $display("Expected Output:");
            $fdisplay(log_file, "Expected Output:");

            $display("  instruction_out = %b", expected_instruction_out);
            $fdisplay(log_file, "  instruction_out = %b", expected_instruction_out);

            $display("  opcode_out      = %b", expected_opcode);
            $fdisplay(log_file, "  opcode_out      = %b", expected_opcode);

            $display("  operand_out     = %0d / %b", expected_operand, expected_operand);
            $fdisplay(log_file, "  operand_out     = %0d / %b", expected_operand, expected_operand);

            print_blank;

            $display("Actual Output:");
            $fdisplay(log_file, "Actual Output:");

            $display("  instruction_out = %b", instruction_out);
            $fdisplay(log_file, "  instruction_out = %b", instruction_out);

            $display("  opcode_out      = %b", opcode_out);
            $fdisplay(log_file, "  opcode_out      = %b", opcode_out);

            $display("  operand_out     = %0d / %b", operand_out, operand_out);
            $fdisplay(log_file, "  operand_out     = %0d / %b", operand_out, operand_out);

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
            $display("Instruction Register Test Summary");
            $fdisplay(log_file, "Instruction Register Test Summary");
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

            $display("Log Saved To: out/instruction_register_tb.log");
            $fdisplay(log_file, "Log Saved To: out/instruction_register_tb.log");

            print_separator;
        end
    endtask

    initial begin
        $dumpfile("out/instruction_register_tb.vcd");
        $dumpvars(0, instruction_register_tb);

        log_file = $fopen("out/instruction_register_tb.log", "w");

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
        instruction_in = 11'b00000000000;

        test_count = 0;
        pass_count = 0;
        fail_count = 0;

        print_header;

        // -----------------------------
        // Test 1: Reset Operation
        // reset = 1 clears the instruction register to 0.
        // -----------------------------
        reset = 1'b1;
        load = 1'b0;
        instruction_in = {3'b010, 8'd15};

        @(posedge clk);
        #1;

        check_instruction_register(1, "Reset clears instruction register",
                                   1'b1, 1'b0, {3'b010, 8'd15},
                                   11'b00000000000, 3'b000, 8'd0);

        // -----------------------------
        // Test 2: Load LDA Instruction
        // opcode = 000, operand = 25
        // -----------------------------
        reset = 1'b0;
        load = 1'b1;
        instruction_in = {3'b000, 8'd25};

        @(posedge clk);
        #1;

        check_instruction_register(2, "Load LDA instruction with operand 25",
                                   1'b0, 1'b1, {3'b000, 8'd25},
                                   {3'b000, 8'd25}, 3'b000, 8'd25);

        // -----------------------------
        // Test 3: Hold Operation
        // load = 0 keeps the previous instruction.
        // -----------------------------
        reset = 1'b0;
        load = 1'b0;
        instruction_in = {3'b001, 8'd99};

        @(posedge clk);
        #1;

        check_instruction_register(3, "Hold keeps previous instruction when load is inactive",
                                   1'b0, 1'b0, {3'b001, 8'd99},
                                   {3'b000, 8'd25}, 3'b000, 8'd25);

        // -----------------------------
        // Test 4: Load LDB Instruction
        // opcode = 001, operand = 64
        // -----------------------------
        reset = 1'b0;
        load = 1'b1;
        instruction_in = {3'b001, 8'd64};

        @(posedge clk);
        #1;

        check_instruction_register(4, "Load LDB instruction with operand 64",
                                   1'b0, 1'b1, {3'b001, 8'd64},
                                   {3'b001, 8'd64}, 3'b001, 8'd64);

        // -----------------------------
        // Test 5: Load ADD Instruction
        // opcode = 010, operand = 0
        // -----------------------------
        reset = 1'b0;
        load = 1'b1;
        instruction_in = {3'b010, 8'd0};

        @(posedge clk);
        #1;

        check_instruction_register(5, "Load ADD instruction",
                                   1'b0, 1'b1, {3'b010, 8'd0},
                                   {3'b010, 8'd0}, 3'b010, 8'd0);

        // -----------------------------
        // Test 6: Load SUB Instruction
        // opcode = 011, operand = 0
        // -----------------------------
        reset = 1'b0;
        load = 1'b1;
        instruction_in = {3'b011, 8'd0};

        @(posedge clk);
        #1;

        check_instruction_register(6, "Load SUB instruction",
                                   1'b0, 1'b1, {3'b011, 8'd0},
                                   {3'b011, 8'd0}, 3'b011, 8'd0);

        // -----------------------------
        // Test 7: Load AND Instruction
        // opcode = 100, operand = 0
        // -----------------------------
        reset = 1'b0;
        load = 1'b1;
        instruction_in = {3'b100, 8'd0};

        @(posedge clk);
        #1;

        check_instruction_register(7, "Load AND instruction",
                                   1'b0, 1'b1, {3'b100, 8'd0},
                                   {3'b100, 8'd0}, 3'b100, 8'd0);

        // -----------------------------
        // Test 8: Load CMP Instruction
        // opcode = 101, operand = 0
        // -----------------------------
        reset = 1'b0;
        load = 1'b1;
        instruction_in = {3'b101, 8'd0};

        @(posedge clk);
        #1;

        check_instruction_register(8, "Load CMP instruction",
                                   1'b0, 1'b1, {3'b101, 8'd0},
                                   {3'b101, 8'd0}, 3'b101, 8'd0);

        // -----------------------------
        // Test 9: Reset Priority Over Load
        // reset and load are both active, so output should clear to 0.
        // -----------------------------
        reset = 1'b1;
        load = 1'b1;
        instruction_in = {3'b101, 8'd255};

        @(posedge clk);
        #1;

        check_instruction_register(9, "Reset has priority over load",
                                   1'b1, 1'b1, {3'b101, 8'd255},
                                   11'b00000000000, 3'b000, 8'd0);

        // -----------------------------
        // Test 10: Load Reserved Opcode 110
        // Confirms that reserved opcode can still be stored.
        // -----------------------------
        reset = 1'b0;
        load = 1'b1;
        instruction_in = {3'b110, 8'd170};

        @(posedge clk);
        #1;

        check_instruction_register(10, "Load reserved opcode 110 instruction",
                                   1'b0, 1'b1, {3'b110, 8'd170},
                                   {3'b110, 8'd170}, 3'b110, 8'd170);

        // -----------------------------
        // Test 11: Load Reserved Opcode 111
        // Confirms that reserved opcode can still be stored.
        // -----------------------------
        reset = 1'b0;
        load = 1'b1;
        instruction_in = {3'b111, 8'd255};

        @(posedge clk);
        #1;

        check_instruction_register(11, "Load reserved opcode 111 instruction",
                                   1'b0, 1'b1, {3'b111, 8'd255},
                                   {3'b111, 8'd255}, 3'b111, 8'd255);

        print_summary;

        $fclose(log_file);
        $finish;
    end

endmodule