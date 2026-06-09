// src/top.v
//
// Top-Level Simple CPU Module
//
// Function:
//   Integrates the controlpath, datapath, instruction memory,
//   instruction register, and program counter into one simple CPU.
//
// CPU Features:
//   - 8-bit datapath
//   - 11-bit instruction format
//   - 3-bit opcode and 8-bit operand/data
//   - 6 supported instructions: LDA, LDB, ADD, SUB, AND, CMP
//   - Reserved/NOP support for opcodes 110 and 111
//   - Single-step execution through execute
//   - Continuous execution through run
//   - LED-friendly outputs for Register C, Zero Flag, Equal Flag,
//     and program_done


/**
 * @file top.v
 * @brief Top-level integration module for the simple 8-bit CPU.
 *
 * This module connects:
 *  - controlpath.v: FSM-based control unit
 *  - datapath.v: registers, ALU connection, result storage, and flags
 *  - instruction_memory.v: 16-location instruction storage
 *  - instruction_register.v: current instruction storage and field extraction
 *  - program_counter.v: current instruction address counter
 *
 * Input Instruction Format:
 *  - opcode[2:0] + data_in[7:0]
 *
 * Stored Instruction Format:
 *  - instruction[10:8] = opcode
 *  - instruction[7:0]  = operand/data
 *
 * Operation:
 *  - save stores the current opcode and data_in into instruction memory.
 *  - load resets the Program Counter to instruction address 0.
 *  - execute performs one instruction cycle.
 *  - run continuously executes instructions until program_done is asserted.
 */

`timescale 1ns / 1ps

module top (
    input        clk,
    input        reset,

    input        save,
    input        load,
    input        execute,
    input        run,

    input  [2:0] opcode,
    input  [7:0] data_in,

    output [7:0] reg_c_out,
    output       zero_flag,
    output       equal_flag,
    output       program_done
);

    wire        mem_write;
    wire        ir_load;
    wire        pc_reset;
    wire        pc_increment;

    wire        reg_a_load;
    wire        reg_b_load;
    wire        reg_c_load;

    wire        flag_z_load;
    wire        flag_eq_load;

    wire [3:0]  memory_address;
    wire [3:0]  pc_out;

    wire [10:0] instruction_in;
    wire [10:0] instruction_from_memory;
    wire [10:0] instruction_out;

    wire [2:0]  opcode_from_ir;
    wire [7:0]  operand_from_ir;

    wire [7:0]  reg_a_out;
    wire [7:0]  reg_b_out;
    wire [7:0]  alu_result_out;

    wire [2:0]  state_out;
    wire [3:0]  save_address_out;
    wire [4:0]  program_length_out;

    // The instruction entered by the user is formed from the opcode switches
    // and the 8-bit data input switches.
    assign instruction_in = {opcode, data_in};

    // The controlpath generates all control signals for the CPU.
    controlpath ctrl (
        .clk(clk),
        .reset(reset),

        .save(save),
        .load(load),
        .execute(execute),
        .run(run),

        .opcode(opcode_from_ir),
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

    // The instruction memory stores the saved program instructions.
    instruction_memory imem (
        .clk(clk),
        .reset(reset),
        .write_enable(mem_write),
        .address(memory_address),
        .instruction_in(instruction_in),

        .instruction_out(instruction_from_memory)
    );

    // The instruction register stores the currently fetched instruction.
    instruction_register ir (
        .clk(clk),
        .reset(reset),
        .load(ir_load),
        .instruction_in(instruction_from_memory),

        .instruction_out(instruction_out),
        .opcode_out(opcode_from_ir),
        .operand_out(operand_from_ir)
    );

    // The Program Counter points to the current instruction address.
    program_counter pc (
        .clk(clk),
        .reset(reset),
        .pc_reset(pc_reset),
        .pc_increment(pc_increment),

        .pc_out(pc_out)
    );

    // The datapath performs register loading, ALU operations, and flag updates.
    datapath dp (
        .clk(clk),
        .reset(reset),

        .opcode(opcode_from_ir),
        .data_in(operand_from_ir),

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

endmodule