// src/controlpath.v
//
// Controlpath Module
//
// Function:
//   Controls the instruction saving, loading, fetching, decoding,
//   execution, and program completion sequence of the simple CPU.
//
// Main Responsibilities:
//   - Handles FSM state transitions
//   - Controls instruction memory writing
//   - Controls instruction register loading
//   - Controls Program Counter reset and increment
//   - Controls Register A, Register B, and Register C loading
//   - Controls Zero Flag and Equal Flag loading
//   - Tracks saved instruction count
//   - Asserts program_done when the final instruction is executed
//
// FSM States:
//   IDLE    : Waits for save, load, execute, or run input
//   SAVE    : Stores the selected instruction into instruction memory
//   LOAD    : Prepares the saved program for execution
//   FETCH   : Loads the current instruction from instruction memory
//   DECODE  : Allows opcode/control decoding
//   EXECUTE : Activates datapath control signals based on opcode
//   DONE    : Indicates that the saved program has completed execution


/**
 * @file controlpath.v
 * @brief FSM-based controlpath module for the simple CPU.
 *
 * This module controls the sequence of CPU operation.
 *
 * It generates the control signals needed by:
 *  - instruction memory
 *  - instruction register
 *  - program counter
 *  - datapath registers
 *  - flag register
 *
 * The controlpath also tracks how many instructions were saved before
 * execution. This allows the CPU to know when the final stored instruction
 * has been reached.
 *
 * The CPU supports:
 *  - save mode for storing instructions
 *  - load mode for preparing execution from instruction address 0
 *  - execute mode for single-step execution
 *  - run mode for continuous execution until program_done
 */

`timescale 1ns / 1ps

module controlpath (
    input        clk,
    input        reset,

    input        save,
    input        load,
    input        execute,
    input        run,

    input  [2:0] opcode,
    input  [3:0] pc_out,

    output reg        mem_write,
    output reg        ir_load,
    output reg        pc_reset,
    output reg        pc_increment,

    output reg        reg_a_load,
    output reg        reg_b_load,
    output reg        reg_c_load,

    output reg        flag_z_load,
    output reg        flag_eq_load,

    output reg [3:0]  memory_address,
    output reg        program_done,

    output reg [2:0]  state_out,
    output reg [3:0]  save_address_out,
    output reg [4:0]  program_length_out
);

    // Opcode definitions based on the 6-instruction ISA.
    parameter LDA  = 3'b000;
    parameter LDB  = 3'b001;
    parameter ADD  = 3'b010;
    parameter SUB  = 3'b011;
    parameter AND  = 3'b100;
    parameter CMP  = 3'b101;
    parameter NOP1 = 3'b110;
    parameter NOP2 = 3'b111;

    // FSM state definitions.
    parameter IDLE    = 3'b000;
    parameter SAVE    = 3'b001;
    parameter LOAD    = 3'b010;
    parameter FETCH   = 3'b011;
    parameter DECODE  = 3'b100;
    parameter EXECUTE = 3'b101;
    parameter DONE    = 3'b110;

    reg [2:0] current_state;
    reg [2:0] next_state;

    reg [3:0] save_address;
    reg [4:0] program_length;
    reg       run_mode;

    wire      has_saved_program;
    wire      final_instruction;

    assign has_saved_program = (program_length != 5'd0);
    assign final_instruction = has_saved_program &&
                               (pc_out == (program_length[3:0] - 1'b1));

    // This block stores the current FSM state and internal control values.
    // Reset clears the state, save address, program length, run mode,
    // and program_done output.
    always @(posedge clk) begin
        if (reset) begin
            current_state  <= IDLE;
            save_address   <= 4'd0;
            program_length <= 5'd0;
            run_mode       <= 1'b0;
            program_done   <= 1'b0;
        end
        else begin
            current_state <= next_state;

            if (current_state == SAVE) begin
                if (save_address != 4'd15) begin
                    save_address <= save_address + 1'b1;
                end

                if (program_length != 5'd16) begin
                    program_length <= program_length + 1'b1;
                end

                program_done <= 1'b0;
            end

            if (current_state == LOAD) begin
                run_mode     <= 1'b0;
                program_done <= 1'b0;
            end

            // This clears program_done immediately when the user leaves
            // the DONE state by pressing load.
            //
            // Without this condition, program_done would remain high for
            // one extra clock cycle because current_state is still DONE
            // during the same clock edge that moves the FSM into LOAD.
            if (current_state == DONE && load) begin
                run_mode     <= 1'b0;
                program_done <= 1'b0;
            end

            if (current_state == IDLE) begin
                if (run && has_saved_program) begin
                    run_mode <= 1'b1;
                end
                else if (execute && has_saved_program) begin
                    run_mode <= 1'b0;
                end
            end

            if (current_state == EXECUTE && final_instruction) begin
                program_done <= 1'b1;
                run_mode     <= 1'b0;
            end
        end
    end

    // This block determines the next FSM state based on the current state
    // and user control inputs.
    always @(*) begin
        next_state = current_state;

        case (current_state)
            IDLE: begin
                if (save) begin
                    next_state = SAVE;
                end
                else if (load) begin
                    next_state = LOAD;
                end
                else if ((execute || run) && has_saved_program) begin
                    next_state = FETCH;
                end
                else begin
                    next_state = IDLE;
                end
            end

            SAVE: begin
                next_state = IDLE;
            end

            LOAD: begin
                next_state = IDLE;
            end

            FETCH: begin
                next_state = DECODE;
            end

            DECODE: begin
                next_state = EXECUTE;
            end

            EXECUTE: begin
                if (final_instruction) begin
                    next_state = DONE;
                end
                else if (run_mode || run) begin
                    next_state = FETCH;
                end
                else begin
                    next_state = IDLE;
                end
            end

            DONE: begin
                if (load) begin
                    next_state = LOAD;
                end
                else begin
                    next_state = DONE;
                end
            end

            default: begin
                next_state = IDLE;
            end
        endcase
    end

    // This block generates the control signals for the datapath,
    // memory, instruction register, and program counter.
    always @(*) begin
        // Default values prevent unwanted latch behavior.
        mem_write      = 1'b0;
        ir_load        = 1'b0;
        pc_reset       = 1'b0;
        pc_increment   = 1'b0;

        reg_a_load     = 1'b0;
        reg_b_load     = 1'b0;
        reg_c_load     = 1'b0;

        flag_z_load    = 1'b0;
        flag_eq_load   = 1'b0;

        memory_address = pc_out;

        state_out          = current_state;
        save_address_out   = save_address;
        program_length_out = program_length;

        case (current_state)
            IDLE: begin
                memory_address = pc_out;
            end

            SAVE: begin
                // Store the instruction at the current save address.
                mem_write      = 1'b1;
                memory_address = save_address;
            end

            LOAD: begin
                // Prepare program execution from the first instruction.
                pc_reset       = 1'b1;
                memory_address = 4'd0;
            end

            FETCH: begin
                // Load the current instruction from memory into the IR.
                ir_load        = 1'b1;
                memory_address = pc_out;
            end

            DECODE: begin
                // Decode state does not directly update registers.
                // It gives the controlpath a separate state before execution.
                memory_address = pc_out;
            end

            EXECUTE: begin
                memory_address = pc_out;

                case (opcode)
                    LDA: begin
                        reg_a_load = 1'b1;
                    end

                    LDB: begin
                        reg_b_load = 1'b1;
                    end

                    ADD: begin
                        reg_c_load   = 1'b1;
                        flag_z_load  = 1'b1;
                    end

                    SUB: begin
                        reg_c_load   = 1'b1;
                        flag_z_load  = 1'b1;
                    end

                    AND: begin
                        reg_c_load   = 1'b1;
                        flag_z_load  = 1'b1;
                    end

                    CMP: begin
                        reg_c_load   = 1'b1;
                        flag_z_load  = 1'b1;
                        flag_eq_load = 1'b1;
                    end

                    NOP1: begin
                        // Reserved opcode 110 is treated as no operation.
                    end

                    NOP2: begin
                        // Reserved opcode 111 is treated as no operation.
                    end

                    default: begin
                        // Undefined opcode behavior is treated as no operation.
                    end
                endcase

                // Move to the next instruction after executing the current one.
                pc_increment = 1'b1;
            end

            DONE: begin
                memory_address = pc_out;
            end

            default: begin
                memory_address = pc_out;
            end
        endcase
    end

endmodule