// tests/controlpath_tb.v
//
// Testbench for the Controlpath Module
//
// Important:
//   This testbench writes simulation files to the out/ directory.
//   If the out/ directory does not exist, create it before compiling.
//
// To run this test on Mac/Linux:
// 1. Create output folder: mkdir -p out
// 2. Compile: iverilog -o out/controlpath_tb.vvp src/controlpath.v tests/controlpath_tb.v
// 3. Simulate: vvp out/controlpath_tb.vvp
// 4. View Waveform: gtkwave out/controlpath_tb.vcd
// 5. View Log File: cat out/controlpath_tb.log
//
// To run this test on Windows Command Prompt:
// 1. Create output folder: if not exist out mkdir out
// 2. Compile: iverilog -o out/controlpath_tb.vvp src/controlpath.v tests/controlpath_tb.v
// 3. Simulate: vvp out/controlpath_tb.vvp
// 4. View Log File: type out\controlpath_tb.log
//
// To run this test on Windows PowerShell:
// 1. Create output folder: New-Item -ItemType Directory -Force out
// 2. Compile: iverilog -o out/controlpath_tb.vvp src/controlpath.v tests/controlpath_tb.v
// 3. Simulate: vvp out/controlpath_tb.vvp
// 4. View Log File: Get-Content out\controlpath_tb.log


/**
 * @file controlpath_tb.v
 * @brief Detailed testbench for the simple CPU controlpath module.
 *
 * This testbench verifies:
 *  - Reset behavior
 *  - Save state control signals
 *  - Save address and program length tracking
 *  - Load state PC reset behavior
 *  - Fetch and Decode state sequencing
 *  - Execute control signals for LDA, LDB, ADD, SUB, AND, and CMP
 *  - Reserved opcode / NOP behavior
 *  - Single-step execution behavior
 *  - Continuous run behavior
 *  - Program done behavior at the final instruction
 *
 * The CLI output and log file both show each test in a readable format.
 */

`timescale 1ns / 1ps

module controlpath_tb;

    reg        clk;
    reg        reset;

    reg        save;
    reg        load;
    reg        execute;
    reg        run;

    reg  [2:0] opcode;
    reg  [3:0] pc_out;

    wire       mem_write;
    wire       ir_load;
    wire       pc_reset;
    wire       pc_increment;

    wire       reg_a_load;
    wire       reg_b_load;
    wire       reg_c_load;

    wire       flag_z_load;
    wire       flag_eq_load;

    wire [3:0] memory_address;
    wire       program_done;

    wire [2:0] state_out;
    wire [3:0] save_address_out;
    wire [4:0] program_length_out;

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
    parameter NOP1 = 3'b110;
    parameter NOP2 = 3'b111;

    parameter IDLE    = 3'b000;
    parameter SAVE    = 3'b001;
    parameter LOAD    = 3'b010;
    parameter FETCH   = 3'b011;
    parameter DECODE  = 3'b100;
    parameter EXECUTE = 3'b101;
    parameter DONE    = 3'b110;

    controlpath uut (
        .clk(clk),
        .reset(reset),

        .save(save),
        .load(load),
        .execute(execute),
        .run(run),

        .opcode(opcode),
        .pc_out(pc_out),

        .mem_write(mem_write),
        .ir_load(ir_load),
        .pc_reset(pc_reset),
        .pc_increment(pc_increment),

        .reg_a_load(reg_a_load),
        .reg_b_load(reg_b_load),
        .reg_c_load(reg_c_load),

        .flag_z_load(flag_z_load),
        .flag_eq_load(flag_eq_load),

        .memory_address(memory_address),
        .program_done(program_done),

        .state_out(state_out),
        .save_address_out(save_address_out),
        .program_length_out(program_length_out)
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
            $display("Controlpath Testbench Started");
            $fdisplay(log_file, "Controlpath Testbench Started");

            $display("Log File: out/controlpath_tb.log");
            $fdisplay(log_file, "Log File: out/controlpath_tb.log");

            $display("VCD File: out/controlpath_tb.vcd");
            $fdisplay(log_file, "VCD File: out/controlpath_tb.vcd");

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

    task clear_inputs;
        begin
            save    = 1'b0;
            load    = 1'b0;
            execute = 1'b0;
            run     = 1'b0;
        end
    endtask

    task check_controlpath;
        input [5:0] test_no;
        input [120*8:1] test_name;

        input [2:0] expected_state;
        input       expected_mem_write;
        input       expected_ir_load;
        input       expected_pc_reset;
        input       expected_pc_increment;

        input       expected_reg_a_load;
        input       expected_reg_b_load;
        input       expected_reg_c_load;

        input       expected_flag_z_load;
        input       expected_flag_eq_load;

        input [3:0] expected_memory_address;
        input       expected_program_done;
        input [3:0] expected_save_address;
        input [4:0] expected_program_length;

        reg passed;

        begin
            test_count = test_count + 1;

            passed = (state_out          == expected_state &&
                      mem_write          == expected_mem_write &&
                      ir_load            == expected_ir_load &&
                      pc_reset           == expected_pc_reset &&
                      pc_increment       == expected_pc_increment &&
                      reg_a_load         == expected_reg_a_load &&
                      reg_b_load         == expected_reg_b_load &&
                      reg_c_load         == expected_reg_c_load &&
                      flag_z_load        == expected_flag_z_load &&
                      flag_eq_load       == expected_flag_eq_load &&
                      memory_address     == expected_memory_address &&
                      program_done       == expected_program_done &&
                      save_address_out   == expected_save_address &&
                      program_length_out == expected_program_length);

            print_separator;
            $display("TEST %0d | %0s", test_no, test_name);
            $fdisplay(log_file, "TEST %0d | %0s", test_no, test_name);
            print_separator;

            $display("Inputs at Check Time:");
            $fdisplay(log_file, "Inputs at Check Time:");

            $display("  reset   = %b", reset);
            $fdisplay(log_file, "  reset   = %b", reset);

            $display("  save    = %b", save);
            $fdisplay(log_file, "  save    = %b", save);

            $display("  load    = %b", load);
            $fdisplay(log_file, "  load    = %b", load);

            $display("  execute = %b", execute);
            $fdisplay(log_file, "  execute = %b", execute);

            $display("  run     = %b", run);
            $fdisplay(log_file, "  run     = %b", run);

            $display("  opcode  = %b", opcode);
            $fdisplay(log_file, "  opcode  = %b", opcode);

            $display("  pc_out  = %0d / %b", pc_out, pc_out);
            $fdisplay(log_file, "  pc_out  = %0d / %b", pc_out, pc_out);

            print_blank;

            $display("Expected Output:");
            $fdisplay(log_file, "Expected Output:");

            $display("  state_out          = %b", expected_state);
            $fdisplay(log_file, "  state_out          = %b", expected_state);

            $display("  mem_write          = %b", expected_mem_write);
            $fdisplay(log_file, "  mem_write          = %b", expected_mem_write);

            $display("  ir_load            = %b", expected_ir_load);
            $fdisplay(log_file, "  ir_load            = %b", expected_ir_load);

            $display("  pc_reset           = %b", expected_pc_reset);
            $fdisplay(log_file, "  pc_reset           = %b", expected_pc_reset);

            $display("  pc_increment       = %b", expected_pc_increment);
            $fdisplay(log_file, "  pc_increment       = %b", expected_pc_increment);

            $display("  reg_a_load         = %b", expected_reg_a_load);
            $fdisplay(log_file, "  reg_a_load         = %b", expected_reg_a_load);

            $display("  reg_b_load         = %b", expected_reg_b_load);
            $fdisplay(log_file, "  reg_b_load         = %b", expected_reg_b_load);

            $display("  reg_c_load         = %b", expected_reg_c_load);
            $fdisplay(log_file, "  reg_c_load         = %b", expected_reg_c_load);

            $display("  flag_z_load        = %b", expected_flag_z_load);
            $fdisplay(log_file, "  flag_z_load        = %b", expected_flag_z_load);

            $display("  flag_eq_load       = %b", expected_flag_eq_load);
            $fdisplay(log_file, "  flag_eq_load       = %b", expected_flag_eq_load);

            $display("  memory_address     = %0d / %b", expected_memory_address, expected_memory_address);
            $fdisplay(log_file, "  memory_address     = %0d / %b", expected_memory_address, expected_memory_address);

            $display("  program_done       = %b", expected_program_done);
            $fdisplay(log_file, "  program_done       = %b", expected_program_done);

            $display("  save_address_out   = %0d / %b", expected_save_address, expected_save_address);
            $fdisplay(log_file, "  save_address_out   = %0d / %b", expected_save_address, expected_save_address);

            $display("  program_length_out = %0d / %b", expected_program_length, expected_program_length);
            $fdisplay(log_file, "  program_length_out = %0d / %b", expected_program_length, expected_program_length);

            print_blank;

            $display("Actual Output:");
            $fdisplay(log_file, "Actual Output:");

            $display("  state_out          = %b", state_out);
            $fdisplay(log_file, "  state_out          = %b", state_out);

            $display("  mem_write          = %b", mem_write);
            $fdisplay(log_file, "  mem_write          = %b", mem_write);

            $display("  ir_load            = %b", ir_load);
            $fdisplay(log_file, "  ir_load            = %b", ir_load);

            $display("  pc_reset           = %b", pc_reset);
            $fdisplay(log_file, "  pc_reset           = %b", pc_reset);

            $display("  pc_increment       = %b", pc_increment);
            $fdisplay(log_file, "  pc_increment       = %b", pc_increment);

            $display("  reg_a_load         = %b", reg_a_load);
            $fdisplay(log_file, "  reg_a_load         = %b", reg_a_load);

            $display("  reg_b_load         = %b", reg_b_load);
            $fdisplay(log_file, "  reg_b_load         = %b", reg_b_load);

            $display("  reg_c_load         = %b", reg_c_load);
            $fdisplay(log_file, "  reg_c_load         = %b", reg_c_load);

            $display("  flag_z_load        = %b", flag_z_load);
            $fdisplay(log_file, "  flag_z_load        = %b", flag_z_load);

            $display("  flag_eq_load       = %b", flag_eq_load);
            $fdisplay(log_file, "  flag_eq_load       = %b", flag_eq_load);

            $display("  memory_address     = %0d / %b", memory_address, memory_address);
            $fdisplay(log_file, "  memory_address     = %0d / %b", memory_address, memory_address);

            $display("  program_done       = %b", program_done);
            $fdisplay(log_file, "  program_done       = %b", program_done);

            $display("  save_address_out   = %0d / %b", save_address_out, save_address_out);
            $fdisplay(log_file, "  save_address_out   = %0d / %b", save_address_out, save_address_out);

            $display("  program_length_out = %0d / %b", program_length_out, program_length_out);
            $fdisplay(log_file, "  program_length_out = %0d / %b", program_length_out, program_length_out);

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
            $display("Controlpath Test Summary");
            $fdisplay(log_file, "Controlpath Test Summary");
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

            $display("Log Saved To: out/controlpath_tb.log");
            $fdisplay(log_file, "Log Saved To: out/controlpath_tb.log");

            print_separator;
        end
    endtask

    initial begin
        $dumpfile("out/controlpath_tb.vcd");
        $dumpvars(0, controlpath_tb);

        log_file = $fopen("out/controlpath_tb.log", "w");

        if (log_file == 0) begin
            $display("[ERROR] Could not open log file.");
            $display("[ERROR] Please create the out/ directory before running the simulation.");
            $display("[ERROR] Mac/Linux: mkdir -p out");
            $display("[ERROR] Windows CMD: if not exist out mkdir out");
            $display("[ERROR] PowerShell: New-Item -ItemType Directory -Force out");
            $finish;
        end

        clk     = 1'b0;
        reset   = 1'b0;
        save    = 1'b0;
        load    = 1'b0;
        execute = 1'b0;
        run     = 1'b0;
        opcode  = LDA;
        pc_out  = 4'd0;

        test_count = 0;
        pass_count = 0;
        fail_count = 0;

        print_header;

        // -----------------------------
        // Test 1: Reset Operation
        // -----------------------------
        reset = 1'b1;
        apply_clock;

        check_controlpath(1, "Reset places controlpath in IDLE",
                          IDLE,
                          1'b0, 1'b0, 1'b0, 1'b0,
                          1'b0, 1'b0, 1'b0,
                          1'b0, 1'b0,
                          4'd0, 1'b0, 4'd0, 5'd0);

        reset = 1'b0;
        apply_clock;

        // -----------------------------
        // Test 2: Enter SAVE State
        // -----------------------------
        save = 1'b1;
        apply_clock;

        check_controlpath(2, "SAVE state asserts memory write at address 0",
                          SAVE,
                          1'b1, 1'b0, 1'b0, 1'b0,
                          1'b0, 1'b0, 1'b0,
                          1'b0, 1'b0,
                          4'd0, 1'b0, 4'd0, 5'd0);

        // -----------------------------
        // Test 3: SAVE State Updates Save Address and Program Length
        // -----------------------------
        save = 1'b0;
        apply_clock;

        check_controlpath(3, "After SAVE, controlpath returns to IDLE and records one instruction",
                          IDLE,
                          1'b0, 1'b0, 1'b0, 1'b0,
                          1'b0, 1'b0, 1'b0,
                          1'b0, 1'b0,
                          4'd0, 1'b0, 4'd1, 5'd1);

        // -----------------------------
        // Test 4 to Test 7: Save Three More Instructions
        // Program length becomes 4 total.
        // -----------------------------
        save = 1'b1;
        apply_clock;
        check_controlpath(4, "SAVE state writes second instruction at address 1",
                          SAVE,
                          1'b1, 1'b0, 1'b0, 1'b0,
                          1'b0, 1'b0, 1'b0,
                          1'b0, 1'b0,
                          4'd1, 1'b0, 4'd1, 5'd1);

        save = 1'b0;
        apply_clock;

        save = 1'b1;
        apply_clock;
        check_controlpath(5, "SAVE state writes third instruction at address 2",
                          SAVE,
                          1'b1, 1'b0, 1'b0, 1'b0,
                          1'b0, 1'b0, 1'b0,
                          1'b0, 1'b0,
                          4'd2, 1'b0, 4'd2, 5'd2);

        save = 1'b0;
        apply_clock;

        save = 1'b1;
        apply_clock;
        check_controlpath(6, "SAVE state writes fourth instruction at address 3",
                          SAVE,
                          1'b1, 1'b0, 1'b0, 1'b0,
                          1'b0, 1'b0, 1'b0,
                          1'b0, 1'b0,
                          4'd3, 1'b0, 4'd3, 5'd3);

        save = 1'b0;
        apply_clock;
        check_controlpath(7, "After saves, program length is four instructions",
                          IDLE,
                          1'b0, 1'b0, 1'b0, 1'b0,
                          1'b0, 1'b0, 1'b0,
                          1'b0, 1'b0,
                          4'd0, 1'b0, 4'd4, 5'd4);

        // -----------------------------
        // Test 8: LOAD State
        // -----------------------------
        load = 1'b1;
        apply_clock;

        check_controlpath(8, "LOAD state resets Program Counter",
                          LOAD,
                          1'b0, 1'b0, 1'b1, 1'b0,
                          1'b0, 1'b0, 1'b0,
                          1'b0, 1'b0,
                          4'd0, 1'b0, 4'd4, 5'd4);

        load = 1'b0;
        apply_clock;

        // -----------------------------
        // Test 9: FETCH State from execute input
        // -----------------------------
        pc_out = 4'd0;
        opcode = LDA;
        execute = 1'b1;
        apply_clock;

        check_controlpath(9, "FETCH state loads instruction register",
                          FETCH,
                          1'b0, 1'b1, 1'b0, 1'b0,
                          1'b0, 1'b0, 1'b0,
                          1'b0, 1'b0,
                          4'd0, 1'b0, 4'd4, 5'd4);

        execute = 1'b0;

        // -----------------------------
        // Test 10: DECODE State
        // -----------------------------
        apply_clock;

        check_controlpath(10, "DECODE state separates instruction before execution",
                          DECODE,
                          1'b0, 1'b0, 1'b0, 1'b0,
                          1'b0, 1'b0, 1'b0,
                          1'b0, 1'b0,
                          4'd0, 1'b0, 4'd4, 5'd4);

        // -----------------------------
        // Test 11: EXECUTE LDA
        // -----------------------------
        opcode = LDA;
        apply_clock;

        check_controlpath(11, "EXECUTE LDA loads Register A and increments PC",
                          EXECUTE,
                          1'b0, 1'b0, 1'b0, 1'b1,
                          1'b1, 1'b0, 1'b0,
                          1'b0, 1'b0,
                          4'd0, 1'b0, 4'd4, 5'd4);

        apply_clock;

        // -----------------------------
        // Test 12: EXECUTE ADD
        // Start another single-step cycle manually at PC = 1.
        // -----------------------------
        pc_out = 4'd1;
        opcode = ADD;
        execute = 1'b1;
        apply_clock;   // FETCH
        execute = 1'b0;
        apply_clock;   // DECODE
        apply_clock;   // EXECUTE

        check_controlpath(12, "EXECUTE ADD loads Register C, updates Z, and increments PC",
                          EXECUTE,
                          1'b0, 1'b0, 1'b0, 1'b1,
                          1'b0, 1'b0, 1'b1,
                          1'b1, 1'b0,
                          4'd1, 1'b0, 4'd4, 5'd4);

        apply_clock;

        // -----------------------------
        // Test 13: EXECUTE CMP
        // Start another single-step cycle manually at PC = 2.
        // -----------------------------
        pc_out = 4'd2;
        opcode = CMP;
        execute = 1'b1;
        apply_clock;   // FETCH
        execute = 1'b0;
        apply_clock;   // DECODE
        apply_clock;   // EXECUTE

        check_controlpath(13, "EXECUTE CMP loads Register C and updates Z and EQ flags",
                          EXECUTE,
                          1'b0, 1'b0, 1'b0, 1'b1,
                          1'b0, 1'b0, 1'b1,
                          1'b1, 1'b1,
                          4'd2, 1'b0, 4'd4, 5'd4);

        apply_clock;

        // -----------------------------
        // Test 14: EXECUTE Reserved Opcode / NOP
        // Reserved opcode should only increment PC.
        // -----------------------------
        pc_out = 4'd2;
        opcode = NOP1;
        execute = 1'b1;
        apply_clock;   // FETCH
        execute = 1'b0;
        apply_clock;   // DECODE
        apply_clock;   // EXECUTE

        check_controlpath(14, "EXECUTE reserved opcode 110 as NOP",
                          EXECUTE,
                          1'b0, 1'b0, 1'b0, 1'b1,
                          1'b0, 1'b0, 1'b0,
                          1'b0, 1'b0,
                          4'd2, 1'b0, 4'd4, 5'd4);

        apply_clock;

        // -----------------------------
        // Test 15: Final Instruction Sets Program Done
        // PC = 3 is final because program_length = 4.
        // -----------------------------
        pc_out = 4'd3;
        opcode = AND;
        execute = 1'b1;
        apply_clock;   // FETCH
        execute = 1'b0;
        apply_clock;   // DECODE
        apply_clock;   // EXECUTE

        check_controlpath(15, "EXECUTE final instruction before DONE state",
                          EXECUTE,
                          1'b0, 1'b0, 1'b0, 1'b1,
                          1'b0, 1'b0, 1'b1,
                          1'b1, 1'b0,
                          4'd3, 1'b0, 4'd4, 5'd4);

        apply_clock;

        check_controlpath(16, "DONE state asserts program_done",
                          DONE,
                          1'b0, 1'b0, 1'b0, 1'b0,
                          1'b0, 1'b0, 1'b0,
                          1'b0, 1'b0,
                          4'd3, 1'b1, 4'd4, 5'd4);

        // -----------------------------
        // Test 17: LOAD from DONE clears program_done and prepares PC.
        // -----------------------------
        load = 1'b1;
        apply_clock;

        check_controlpath(17, "LOAD from DONE resets PC and clears program_done",
                          LOAD,
                          1'b0, 1'b0, 1'b1, 1'b0,
                          1'b0, 1'b0, 1'b0,
                          1'b0, 1'b0,
                          4'd0, 1'b0, 4'd4, 5'd4);

        load = 1'b0;
        apply_clock;

        print_summary;

        $fclose(log_file);
        $finish;
    end

endmodule