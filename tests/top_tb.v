// tests/top_tb.v
//
// Testbench for the Top-Level Simple CPU Module
//
// Important:
//   This testbench writes simulation files to the out/ directory.
//   If the out/ directory does not exist, create it before compiling.
//
// To run this test on Mac/Linux:
// 1. Create output folder: mkdir -p out
// 2. Compile: iverilog -o out/top_tb.vvp src/register_8bit.v src/alu.v src/datapath.v src/instruction_memory.v src/instruction_register.v src/program_counter.v src/controlpath.v src/top.v tests/top_tb.v
// 3. Simulate: vvp out/top_tb.vvp
// 4. View Waveform: gtkwave out/top_tb.vcd
// 5. View Log File: cat out/top_tb.log
//
// To run this test on Windows Command Prompt:
// 1. Create output folder: if not exist out mkdir out
// 2. Compile: iverilog -o out/top_tb.vvp src/register_8bit.v src/alu.v src/datapath.v src/instruction_memory.v src/instruction_register.v src/program_counter.v src/controlpath.v src/top.v tests/top_tb.v
// 3. Simulate: vvp out/top_tb.vvp
// 4. View Log File: type out\top_tb.log
//
// To run this test on Windows PowerShell:
// 1. Create output folder: New-Item -ItemType Directory -Force out
// 2. Compile: iverilog -o out/top_tb.vvp src/register_8bit.v src/alu.v src/datapath.v src/instruction_memory.v src/instruction_register.v src/program_counter.v src/controlpath.v src/top.v tests/top_tb.v
// 3. Simulate: vvp out/top_tb.vvp
// 4. View Log File: Get-Content out\top_tb.log


/**
 * @file top_tb.v
 * @brief Detailed integration testbench for the top-level simple CPU module.
 *
 * This testbench verifies:
 *  - Top-level reset behavior
 *  - Instruction saving into instruction memory
 *  - Program loading and Program Counter reset
 *  - Single-step execution using execute
 *  - Continuous execution using run
 *  - Register A, Register B, and Register C integration
 *  - ADD, SUB, CMP, and NOP behavior through the full CPU path
 *  - Zero Flag and Equal Flag behavior through the full CPU path
 *  - program_done behavior after the final instruction
 *  - Multiple saved programs with reset between program runs
 *
 * The CLI output and log file both show each test in a readable format.
 */

`timescale 1ns / 1ps

module top_tb;

    reg        clk;
    reg        reset;

    reg        save;
    reg        load;
    reg        execute;
    reg        run;

    reg  [2:0] opcode;
    reg  [7:0] data_in;

    wire [7:0] reg_c_out;
    wire       zero_flag;
    wire       equal_flag;
    wire       program_done;

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

    top uut (
        .clk(clk),
        .reset(reset),

        .save(save),
        .load(load),
        .execute(execute),
        .run(run),

        .opcode(opcode),
        .data_in(data_in),

        .reg_c_out(reg_c_out),
        .zero_flag(zero_flag),
        .equal_flag(equal_flag),
        .program_done(program_done)
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
            $display("Top-Level CPU Testbench Started");
            $fdisplay(log_file, "Top-Level CPU Testbench Started");

            $display("Log File: out/top_tb.log");
            $fdisplay(log_file, "Log File: out/top_tb.log");

            $display("VCD File: out/top_tb.vcd");
            $fdisplay(log_file, "VCD File: out/top_tb.vcd");

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

    task clear_controls;
        begin
            save    = 1'b0;
            load    = 1'b0;
            execute = 1'b0;
            run     = 1'b0;
        end
    endtask

    task check_saved_instruction;
        input [5:0] test_no;
        input [120*8:1] test_name;

        input [3:0]  expected_address;
        input [10:0] expected_instruction;
        input [3:0]  expected_save_address;
        input [4:0]  expected_program_length;

        reg passed;

        begin
            test_count = test_count + 1;

            passed = (uut.imem.memory[expected_address] == expected_instruction &&
                      uut.save_address_out              == expected_save_address &&
                      uut.program_length_out            == expected_program_length);

            print_separator;
            $display("TEST %0d | %0s", test_no, test_name);
            $fdisplay(log_file, "TEST %0d | %0s", test_no, test_name);
            print_separator;

            $display("Saved Instruction Check:");
            $fdisplay(log_file, "Saved Instruction Check:");

            $display("  Address              = %0d / %b", expected_address, expected_address);
            $fdisplay(log_file, "  Address              = %0d / %b", expected_address, expected_address);

            $display("  Expected Instruction = %b", expected_instruction);
            $fdisplay(log_file, "  Expected Instruction = %b", expected_instruction);

            $display("                       = opcode %b | operand %0d / %b",
                     expected_instruction[10:8],
                     expected_instruction[7:0],
                     expected_instruction[7:0]);
            $fdisplay(log_file, "                       = opcode %b | operand %0d / %b",
                      expected_instruction[10:8],
                      expected_instruction[7:0],
                      expected_instruction[7:0]);

            print_blank;

            $display("Actual:");
            $fdisplay(log_file, "Actual:");

            $display("  Memory[%0d]           = %b",
                     expected_address,
                     uut.imem.memory[expected_address]);
            $fdisplay(log_file, "  Memory[%0d]           = %b",
                      expected_address,
                      uut.imem.memory[expected_address]);

            $display("  save_address_out     = %0d / %b", uut.save_address_out, uut.save_address_out);
            $fdisplay(log_file, "  save_address_out     = %0d / %b", uut.save_address_out, uut.save_address_out);

            $display("  program_length_out   = %0d / %b", uut.program_length_out, uut.program_length_out);
            $fdisplay(log_file, "  program_length_out   = %0d / %b", uut.program_length_out, uut.program_length_out);

            print_blank;

            $display("Expected:");
            $fdisplay(log_file, "Expected:");

            $display("  save_address_out     = %0d / %b", expected_save_address, expected_save_address);
            $fdisplay(log_file, "  save_address_out     = %0d / %b", expected_save_address, expected_save_address);

            $display("  program_length_out   = %0d / %b", expected_program_length, expected_program_length);
            $fdisplay(log_file, "  program_length_out   = %0d / %b", expected_program_length, expected_program_length);

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

    task check_cpu_state;
        input [5:0] test_no;
        input [120*8:1] test_name;

        input [7:0] expected_reg_a;
        input [7:0] expected_reg_b;
        input [7:0] expected_reg_c;
        input       expected_zero_flag;
        input       expected_equal_flag;
        input       expected_program_done;
        input [3:0] expected_pc;
        input [2:0] expected_state;

        reg passed;

        begin
            test_count = test_count + 1;

            passed = (uut.reg_a_out == expected_reg_a &&
                      uut.reg_b_out == expected_reg_b &&
                      reg_c_out     == expected_reg_c &&
                      zero_flag     == expected_zero_flag &&
                      equal_flag    == expected_equal_flag &&
                      program_done  == expected_program_done &&
                      uut.pc_out    == expected_pc &&
                      uut.state_out == expected_state);

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

            $display("  data_in = %0d / %b", data_in, data_in);
            $fdisplay(log_file, "  data_in = %0d / %b", data_in, data_in);

            print_blank;

            $display("Expected CPU State:");
            $fdisplay(log_file, "Expected CPU State:");

            $display("  Register A    = %0d / %b", expected_reg_a, expected_reg_a);
            $fdisplay(log_file, "  Register A    = %0d / %b", expected_reg_a, expected_reg_a);

            $display("  Register B    = %0d / %b", expected_reg_b, expected_reg_b);
            $fdisplay(log_file, "  Register B    = %0d / %b", expected_reg_b, expected_reg_b);

            $display("  Register C    = %0d / %b", expected_reg_c, expected_reg_c);
            $fdisplay(log_file, "  Register C    = %0d / %b", expected_reg_c, expected_reg_c);

            $display("  zero_flag     = %b", expected_zero_flag);
            $fdisplay(log_file, "  zero_flag     = %b", expected_zero_flag);

            $display("  equal_flag    = %b", expected_equal_flag);
            $fdisplay(log_file, "  equal_flag    = %b", expected_equal_flag);

            $display("  program_done  = %b", expected_program_done);
            $fdisplay(log_file, "  program_done  = %b", expected_program_done);

            $display("  PC            = %0d / %b", expected_pc, expected_pc);
            $fdisplay(log_file, "  PC            = %0d / %b", expected_pc, expected_pc);

            $display("  state_out     = %b", expected_state);
            $fdisplay(log_file, "  state_out     = %b", expected_state);

            print_blank;

            $display("Actual CPU State:");
            $fdisplay(log_file, "Actual CPU State:");

            $display("  Register A    = %0d / %b", uut.reg_a_out, uut.reg_a_out);
            $fdisplay(log_file, "  Register A    = %0d / %b", uut.reg_a_out, uut.reg_a_out);

            $display("  Register B    = %0d / %b", uut.reg_b_out, uut.reg_b_out);
            $fdisplay(log_file, "  Register B    = %0d / %b", uut.reg_b_out, uut.reg_b_out);

            $display("  Register C    = %0d / %b", reg_c_out, reg_c_out);
            $fdisplay(log_file, "  Register C    = %0d / %b", reg_c_out, reg_c_out);

            $display("  zero_flag     = %b", zero_flag);
            $fdisplay(log_file, "  zero_flag     = %b", zero_flag);

            $display("  equal_flag    = %b", equal_flag);
            $fdisplay(log_file, "  equal_flag    = %b", equal_flag);

            $display("  program_done  = %b", program_done);
            $fdisplay(log_file, "  program_done  = %b", program_done);

            $display("  PC            = %0d / %b", uut.pc_out, uut.pc_out);
            $fdisplay(log_file, "  PC            = %0d / %b", uut.pc_out, uut.pc_out);

            $display("  state_out     = %b", uut.state_out);
            $fdisplay(log_file, "  state_out     = %b", uut.state_out);

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

    task save_instruction;
        input [2:0] instruction_opcode;
        input [7:0] instruction_data;

        begin
            clear_controls;

            opcode  = instruction_opcode;
            data_in = instruction_data;
            save    = 1'b1;

            // First clock moves IDLE -> SAVE.
            apply_clock;

            // Second clock performs the memory write while in SAVE,
            // then returns the controlpath to IDLE.
            apply_clock;

            save = 1'b0;
            #1;
        end
    endtask

    task load_program;
        begin
            clear_controls;

            load = 1'b1;

            // First clock moves IDLE/DONE -> LOAD.
            apply_clock;

            // Second clock applies pc_reset while in LOAD,
            // then returns the controlpath to IDLE.
            apply_clock;

            load = 1'b0;
            #1;
        end
    endtask

    task execute_one_instruction;
        begin
            clear_controls;

            execute = 1'b1;

            // IDLE -> FETCH.
            apply_clock;

            execute = 1'b0;

            // FETCH -> DECODE, while the Instruction Register loads.
            apply_clock;

            // DECODE -> EXECUTE.
            apply_clock;

            // EXECUTE performs the datapath update and increments PC.
            apply_clock;

            #1;
        end
    endtask

    task run_until_done;
        integer i;
        begin
            clear_controls;

            run = 1'b1;

            // Enough clock cycles for the saved program to pass through
            // FETCH, DECODE, EXECUTE, and DONE.
            for (i = 0; i < 24; i = i + 1) begin
                apply_clock;
            end

            run = 1'b0;
            #1;
        end
    endtask

    task reset_cpu_for_next_program;
        begin
            clear_controls;

            reset = 1'b1;
            apply_clock;

            reset = 1'b0;
            apply_clock;

            #1;
        end
    endtask

    task print_summary;
        begin
            print_separator;
            $display("Top-Level CPU Test Summary");
            $fdisplay(log_file, "Top-Level CPU Test Summary");
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

            $display("Log Saved To: out/top_tb.log");
            $fdisplay(log_file, "Log Saved To: out/top_tb.log");

            print_separator;
        end
    endtask

    initial begin
        $dumpfile("out/top_tb.vcd");
        $dumpvars(0, top_tb);

        log_file = $fopen("out/top_tb.log", "w");

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
        data_in = 8'd0;

        test_count = 0;
        pass_count = 0;
        fail_count = 0;

        print_header;

        // -----------------------------
        // Test 1: Reset Full CPU
        // -----------------------------
        reset = 1'b1;
        apply_clock;

        check_cpu_state(1, "Reset clears top-level CPU state",
                        8'd0, 8'd0, 8'd0,
                        1'b0, 1'b0, 1'b0,
                        4'd0, IDLE);

        reset = 1'b0;
        apply_clock;

        // -----------------------------
        // Program 1:
        // 0: LDA 12
        // 1: LDB 5
        // 2: ADD
        // 3: LDB 12
        // 4: CMP
        // -----------------------------

        save_instruction(LDA, 8'd12);
        check_saved_instruction(2, "Save instruction 0: LDA 12",
                                4'd0, {LDA, 8'd12}, 4'd1, 5'd1);

        save_instruction(LDB, 8'd5);
        check_saved_instruction(3, "Save instruction 1: LDB 5",
                                4'd1, {LDB, 8'd5}, 4'd2, 5'd2);

        save_instruction(ADD, 8'd0);
        check_saved_instruction(4, "Save instruction 2: ADD",
                                4'd2, {ADD, 8'd0}, 4'd3, 5'd3);

        save_instruction(LDB, 8'd12);
        check_saved_instruction(5, "Save instruction 3: LDB 12",
                                4'd3, {LDB, 8'd12}, 4'd4, 5'd4);

        save_instruction(CMP, 8'd0);
        check_saved_instruction(6, "Save instruction 4: CMP",
                                4'd4, {CMP, 8'd0}, 4'd5, 5'd5);

        load_program;

        check_cpu_state(7, "Load program resets Program Counter",
                        8'd0, 8'd0, 8'd0,
                        1'b0, 1'b0, 1'b0,
                        4'd0, IDLE);

        execute_one_instruction;

        check_cpu_state(8, "Execute instruction 0: LDA 12 loads Register A",
                        8'd12, 8'd0, 8'd0,
                        1'b0, 1'b0, 1'b0,
                        4'd1, IDLE);

        execute_one_instruction;

        check_cpu_state(9, "Execute instruction 1: LDB 5 loads Register B",
                        8'd12, 8'd5, 8'd0,
                        1'b0, 1'b0, 1'b0,
                        4'd2, IDLE);

        execute_one_instruction;

        check_cpu_state(10, "Execute instruction 2: ADD stores 17 into Register C",
                        8'd12, 8'd5, 8'd17,
                        1'b0, 1'b0, 1'b0,
                        4'd3, IDLE);

        execute_one_instruction;

        check_cpu_state(11, "Execute instruction 3: LDB 12 prepares CMP equal",
                        8'd12, 8'd12, 8'd17,
                        1'b0, 1'b0, 1'b0,
                        4'd4, IDLE);

        execute_one_instruction;

        check_cpu_state(12, "Execute instruction 4: CMP equal completes program",
                        8'd12, 8'd12, 8'd1,
                        1'b0, 1'b1, 1'b1,
                        4'd5, DONE);

        load_program;

        check_cpu_state(13, "Load from DONE clears program_done and resets PC",
                        8'd12, 8'd12, 8'd1,
                        1'b0, 1'b1, 1'b0,
                        4'd0, IDLE);

        run_until_done;

        check_cpu_state(14, "Run mode executes saved program until DONE",
                        8'd12, 8'd12, 8'd1,
                        1'b0, 1'b1, 1'b1,
                        4'd5, DONE);

        // -----------------------------
        // Test 15: Multi-Instruction Program 2
        // Program:
        // 0: LDA 9
        // 1: LDB 9
        // 2: SUB
        //
        // Expected:
        // C = 9 - 9 = 0
        // Z = 1
        // EQ = 0
        // -----------------------------

        reset_cpu_for_next_program;

        save_instruction(LDA, 8'd9);
        save_instruction(LDB, 8'd9);
        save_instruction(SUB, 8'd0);

        load_program;
        run_until_done;

        check_cpu_state(15, "Multi-instruction program: SUB zero result",
                        8'd9, 8'd9, 8'd0,
                        1'b1, 1'b0, 1'b1,
                        4'd3, DONE);

        // -----------------------------
        // Test 16: Multi-Instruction Program 3
        // Program:
        // 0: LDA 8
        // 1: LDB 9
        // 2: CMP
        //
        // Expected:
        // A != B
        // C = 00000000
        // Z = 1
        // EQ = 0
        // -----------------------------

        reset_cpu_for_next_program;

        save_instruction(LDA, 8'd8);
        save_instruction(LDB, 8'd9);
        save_instruction(CMP, 8'd0);

        load_program;
        run_until_done;

        check_cpu_state(16, "Multi-instruction program: CMP not equal",
                        8'd8, 8'd9, 8'd0,
                        1'b1, 1'b0, 1'b1,
                        4'd3, DONE);

        // -----------------------------
        // Test 17: Multi-Instruction Program 4
        // Program:
        // 0: LDA 4
        // 1: LDB 2
        // 2: NOP
        // 3: ADD
        //
        // Expected:
        // NOP causes no register or flag change.
        // ADD gives C = 4 + 2 = 6.
        // -----------------------------

        reset_cpu_for_next_program;

        save_instruction(LDA, 8'd4);
        save_instruction(LDB, 8'd2);
        save_instruction(NOP1, 8'd0);
        save_instruction(ADD, 8'd0);

        load_program;
        run_until_done;

        check_cpu_state(17, "Multi-instruction program: NOP then ADD",
                        8'd4, 8'd2, 8'd6,
                        1'b0, 1'b0, 1'b1,
                        4'd4, DONE);

        print_summary;

        $fclose(log_file);
        $finish;
    end

endmodule