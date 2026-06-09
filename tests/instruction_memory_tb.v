// tests/instruction_memory_tb.v
//
// Testbench for the Instruction Memory Module
//
// Important:
//   This testbench writes simulation files to the out/ directory.
//   If the out/ directory does not exist, create it before compiling.
//
// To run this test on Mac/Linux:
// 1. Create output folder: mkdir -p out
// 2. Compile: iverilog -o out/instruction_memory_tb.vvp src/instruction_memory.v tests/instruction_memory_tb.v
// 3. Simulate: vvp out/instruction_memory_tb.vvp
// 4. View Waveform: gtkwave out/instruction_memory_tb.vcd
// 5. View Log File: cat out/instruction_memory_tb.log
//
// To run this test on Windows Command Prompt:
// 1. Create output folder: if not exist out mkdir out
// 2. Compile: iverilog -o out/instruction_memory_tb.vvp src/instruction_memory.v tests/instruction_memory_tb.v
// 3. Simulate: vvp out/instruction_memory_tb.vvp
// 4. View Log File: type out\instruction_memory_tb.log
//
// To run this test on Windows PowerShell:
// 1. Create output folder: New-Item -ItemType Directory -Force out
// 2. Compile: iverilog -o out/instruction_memory_tb.vvp src/instruction_memory.v tests/instruction_memory_tb.v
// 3. Simulate: vvp out/instruction_memory_tb.vvp
// 4. View Log File: Get-Content out\instruction_memory_tb.log


/**
 * @file instruction_memory_tb.v
 * @brief Detailed testbench for the 16-location instruction memory module.
 *
 * This testbench verifies:
 *  - Reset operation
 *  - Instruction write operation
 *  - Instruction read operation
 *  - Hold behavior when write_enable is inactive
 *  - Reset priority over write_enable
 *  - Storage and reading of supported and reserved opcode instructions
 *  - Independent storage across different memory addresses
 *
 * The CLI output and log file both show each test in a readable format.
 */

`timescale 1ns / 1ps

module instruction_memory_tb;

    reg         clk;
    reg         reset;
    reg         write_enable;
    reg  [3:0]  address;
    reg  [10:0] instruction_in;

    wire [10:0] instruction_out;

    integer test_count;
    integer pass_count;
    integer fail_count;
    integer log_file;

    instruction_memory uut (
        .clk(clk),
        .reset(reset),
        .write_enable(write_enable),
        .address(address),
        .instruction_in(instruction_in),

        .instruction_out(instruction_out)
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
            $display("Instruction Memory Testbench Started");
            $fdisplay(log_file, "Instruction Memory Testbench Started");

            $display("Log File: out/instruction_memory_tb.log");
            $fdisplay(log_file, "Log File: out/instruction_memory_tb.log");

            $display("VCD File: out/instruction_memory_tb.vcd");
            $fdisplay(log_file, "VCD File: out/instruction_memory_tb.vcd");

            print_separator;
            print_blank;
        end
    endtask

    task check_instruction_memory;
        input [5:0] test_no;
        input [120*8:1] test_name;
        input expected_reset;
        input expected_write_enable;
        input [3:0] expected_address;
        input [10:0] expected_instruction_in;
        input [10:0] expected_instruction_out;

        reg passed;

        begin
            test_count = test_count + 1;

            #1;

            passed = (instruction_out == expected_instruction_out);

            print_separator;
            $display("TEST %0d | %0s", test_no, test_name);
            $fdisplay(log_file, "TEST %0d | %0s", test_no, test_name);
            print_separator;

            $display("Inputs at Check Time:");
            $fdisplay(log_file, "Inputs at Check Time:");

            $display("  reset          = %b", reset);
            $fdisplay(log_file, "  reset          = %b", reset);

            $display("  write_enable   = %b", write_enable);
            $fdisplay(log_file, "  write_enable   = %b", write_enable);

            $display("  address        = %0d / %b", address, address);
            $fdisplay(log_file, "  address        = %0d / %b", address, address);

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

            $display("  write_enable   = %b", expected_write_enable);
            $fdisplay(log_file, "  write_enable   = %b", expected_write_enable);

            $display("  address        = %0d / %b", expected_address, expected_address);
            $fdisplay(log_file, "  address        = %0d / %b", expected_address, expected_address);

            $display("  instruction_in = %b", expected_instruction_in);
            $fdisplay(log_file, "  instruction_in = %b", expected_instruction_in);

            print_blank;

            $display("Expected Output:");
            $fdisplay(log_file, "Expected Output:");

            $display("  instruction_out = %b", expected_instruction_out);
            $fdisplay(log_file, "  instruction_out = %b", expected_instruction_out);

            $display("                  = opcode %b | operand %0d / %b",
                     expected_instruction_out[10:8],
                     expected_instruction_out[7:0],
                     expected_instruction_out[7:0]);
            $fdisplay(log_file, "                  = opcode %b | operand %0d / %b",
                      expected_instruction_out[10:8],
                      expected_instruction_out[7:0],
                      expected_instruction_out[7:0]);

            print_blank;

            $display("Actual Output:");
            $fdisplay(log_file, "Actual Output:");

            $display("  instruction_out = %b", instruction_out);
            $fdisplay(log_file, "  instruction_out = %b", instruction_out);

            $display("                  = opcode %b | operand %0d / %b",
                     instruction_out[10:8],
                     instruction_out[7:0],
                     instruction_out[7:0]);
            $fdisplay(log_file, "                  = opcode %b | operand %0d / %b",
                      instruction_out[10:8],
                      instruction_out[7:0],
                      instruction_out[7:0]);

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
            $display("Instruction Memory Test Summary");
            $fdisplay(log_file, "Instruction Memory Test Summary");
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

            $display("Log Saved To: out/instruction_memory_tb.log");
            $fdisplay(log_file, "Log Saved To: out/instruction_memory_tb.log");

            print_separator;
        end
    endtask

    initial begin
        $dumpfile("out/instruction_memory_tb.vcd");
        $dumpvars(0, instruction_memory_tb);

        log_file = $fopen("out/instruction_memory_tb.log", "w");

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
        write_enable = 1'b0;
        address = 4'd0;
        instruction_in = 11'b00000000000;

        test_count = 0;
        pass_count = 0;
        fail_count = 0;

        print_header;

        // -----------------------------
        // Test 1: Reset Operation
        // reset = 1 clears all instruction memory locations.
        // -----------------------------
        reset = 1'b1;
        write_enable = 1'b0;
        address = 4'd0;
        instruction_in = {3'b010, 8'd15};

        @(posedge clk);
        #1;

        check_instruction_memory(1, "Reset clears memory location 0",
                                 1'b1, 1'b0, 4'd0, {3'b010, 8'd15},
                                 11'b00000000000);

        // -----------------------------
        // Test 2: Write LDA Instruction to Address 0
        // instruction = {000, 25}
        // -----------------------------
        reset = 1'b0;
        write_enable = 1'b1;
        address = 4'd0;
        instruction_in = {3'b000, 8'd25};

        @(posedge clk);
        #1;

        check_instruction_memory(2, "Write LDA instruction to address 0",
                                 1'b0, 1'b1, 4'd0, {3'b000, 8'd25},
                                 {3'b000, 8'd25});

        // -----------------------------
        // Test 3: Write LDB Instruction to Address 1
        // instruction = {001, 64}
        // -----------------------------
        reset = 1'b0;
        write_enable = 1'b1;
        address = 4'd1;
        instruction_in = {3'b001, 8'd64};

        @(posedge clk);
        #1;

        check_instruction_memory(3, "Write LDB instruction to address 1",
                                 1'b0, 1'b1, 4'd1, {3'b001, 8'd64},
                                 {3'b001, 8'd64});

        // -----------------------------
        // Test 4: Read Address 0
        // write_enable = 0 should only read the stored instruction.
        // -----------------------------
        reset = 1'b0;
        write_enable = 1'b0;
        address = 4'd0;
        instruction_in = {3'b111, 8'd255};

        #10;

        check_instruction_memory(4, "Read stored LDA instruction from address 0",
                                 1'b0, 1'b0, 4'd0, {3'b111, 8'd255},
                                 {3'b000, 8'd25});

        // -----------------------------
        // Test 5: Read Address 1
        // Confirms address 1 stored its own instruction.
        // -----------------------------
        reset = 1'b0;
        write_enable = 1'b0;
        address = 4'd1;
        instruction_in = {3'b111, 8'd255};

        #10;

        check_instruction_memory(5, "Read stored LDB instruction from address 1",
                                 1'b0, 1'b0, 4'd1, {3'b111, 8'd255},
                                 {3'b001, 8'd64});

        // -----------------------------
        // Test 6: Hold Behavior When Write Disabled
        // Attempt to change address 1 without write_enable.
        // Memory should still hold the previous value.
        // -----------------------------
        reset = 1'b0;
        write_enable = 1'b0;
        address = 4'd1;
        instruction_in = {3'b010, 8'd100};

        @(posedge clk);
        #1;

        check_instruction_memory(6, "Write disabled keeps address 1 unchanged",
                                 1'b0, 1'b0, 4'd1, {3'b010, 8'd100},
                                 {3'b001, 8'd64});

        // -----------------------------
        // Test 7: Write ADD Instruction to Address 2
        // instruction = {010, 0}
        // -----------------------------
        reset = 1'b0;
        write_enable = 1'b1;
        address = 4'd2;
        instruction_in = {3'b010, 8'd0};

        @(posedge clk);
        #1;

        check_instruction_memory(7, "Write ADD instruction to address 2",
                                 1'b0, 1'b1, 4'd2, {3'b010, 8'd0},
                                 {3'b010, 8'd0});

        // -----------------------------
        // Test 8: Write SUB Instruction to Address 3
        // instruction = {011, 0}
        // -----------------------------
        reset = 1'b0;
        write_enable = 1'b1;
        address = 4'd3;
        instruction_in = {3'b011, 8'd0};

        @(posedge clk);
        #1;

        check_instruction_memory(8, "Write SUB instruction to address 3",
                                 1'b0, 1'b1, 4'd3, {3'b011, 8'd0},
                                 {3'b011, 8'd0});

        // -----------------------------
        // Test 9: Write AND Instruction to Address 4
        // instruction = {100, 0}
        // -----------------------------
        reset = 1'b0;
        write_enable = 1'b1;
        address = 4'd4;
        instruction_in = {3'b100, 8'd0};

        @(posedge clk);
        #1;

        check_instruction_memory(9, "Write AND instruction to address 4",
                                 1'b0, 1'b1, 4'd4, {3'b100, 8'd0},
                                 {3'b100, 8'd0});

        // -----------------------------
        // Test 10: Write CMP Instruction to Address 5
        // instruction = {101, 0}
        // -----------------------------
        reset = 1'b0;
        write_enable = 1'b1;
        address = 4'd5;
        instruction_in = {3'b101, 8'd0};

        @(posedge clk);
        #1;

        check_instruction_memory(10, "Write CMP instruction to address 5",
                                 1'b0, 1'b1, 4'd5, {3'b101, 8'd0},
                                 {3'b101, 8'd0});

        // -----------------------------
        // Test 11: Write Reserved Opcode 110 to Address 14
        // instruction = {110, 170}
        // -----------------------------
        reset = 1'b0;
        write_enable = 1'b1;
        address = 4'd14;
        instruction_in = {3'b110, 8'd170};

        @(posedge clk);
        #1;

        check_instruction_memory(11, "Write reserved opcode 110 to address 14",
                                 1'b0, 1'b1, 4'd14, {3'b110, 8'd170},
                                 {3'b110, 8'd170});

        // -----------------------------
        // Test 12: Write Reserved Opcode 111 to Address 15
        // instruction = {111, 255}
        // -----------------------------
        reset = 1'b0;
        write_enable = 1'b1;
        address = 4'd15;
        instruction_in = {3'b111, 8'd255};

        @(posedge clk);
        #1;

        check_instruction_memory(12, "Write reserved opcode 111 to address 15",
                                 1'b0, 1'b1, 4'd15, {3'b111, 8'd255},
                                 {3'b111, 8'd255});

        // -----------------------------
        // Test 13: Read Address 14
        // Confirms address 14 retained reserved opcode 110.
        // -----------------------------
        reset = 1'b0;
        write_enable = 1'b0;
        address = 4'd14;
        instruction_in = {3'b000, 8'd0};

        #10;

        check_instruction_memory(13, "Read reserved opcode 110 from address 14",
                                 1'b0, 1'b0, 4'd14, {3'b000, 8'd0},
                                 {3'b110, 8'd170});

        // -----------------------------
        // Test 14: Read Address 15
        // Confirms address 15 retained reserved opcode 111.
        // -----------------------------
        reset = 1'b0;
        write_enable = 1'b0;
        address = 4'd15;
        instruction_in = {3'b000, 8'd0};

        #10;

        check_instruction_memory(14, "Read reserved opcode 111 from address 15",
                                 1'b0, 1'b0, 4'd15, {3'b000, 8'd0},
                                 {3'b111, 8'd255});

        // -----------------------------
        // Test 15: Reset Priority Over Write
        // reset = 1 and write_enable = 1 should clear memory.
        // -----------------------------
        reset = 1'b1;
        write_enable = 1'b1;
        address = 4'd15;
        instruction_in = {3'b010, 8'd88};

        @(posedge clk);
        #1;

        check_instruction_memory(15, "Reset has priority over memory write",
                                 1'b1, 1'b1, 4'd15, {3'b010, 8'd88},
                                 11'b00000000000);

        // -----------------------------
        // Test 16: Confirm Address 0 Also Cleared After Reset
        // The reset operation should clear all memory locations.
        // -----------------------------
        reset = 1'b0;
        write_enable = 1'b0;
        address = 4'd0;
        instruction_in = 11'b00000000000;

        #10;

        check_instruction_memory(16, "Confirm address 0 cleared after reset",
                                 1'b0, 1'b0, 4'd0, 11'b00000000000,
                                 11'b00000000000);

        print_summary;

        $fclose(log_file);
        $finish;
    end

endmodule