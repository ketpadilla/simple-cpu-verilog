// src/datapath.v
//
// Datapath Module
//
// Function:
//   Handles the data storage, ALU operation, result storage, and flag updates
//   for the simple 8-bit CPU.
//
// Main Components:
//   - Register A
//   - Register B
//   - Register C
//   - ALU
//   - Zero Flag
//   - Equal Flag
//
// Datapath Behavior:
//   LDA : Load operand/data into Register A
//   LDB : Load operand/data into Register B
//   ADD : Store A + B into Register C and update Zero Flag
//   SUB : Store A - B into Register C and update Zero Flag
//   AND : Store A & B into Register C and update Zero Flag
//   CMP : Store comparison result into Register C and update Zero and Equal Flags


/**
 * @file datapath.v
 * @brief Datapath module for the simple 8-bit CPU.
 *
 * This module connects the CPU registers and ALU together.
 *
 * Register A and Register B store the operands used by the ALU.
 * Register C stores the ALU result.
 *
 * The ALU performs ADD, SUB, AND, and CMP operations based on opcode.
 *
 * The Zero Flag is updated from the ALU result when flag_z_load is active.
 * The Equal Flag is updated from the ALU comparison output when flag_eq_load
 * is active.
 *
 * For CMP:
 *  - If A == B, Register C receives 00000001 and Equal Flag becomes 1.
 *  - If A != B, Register C receives 00000000 and Equal Flag becomes 0.
 */

`timescale 1ns / 1ps

module datapath (
    input        clk,
    input        reset,

    input  [2:0] opcode,
    input  [7:0] data_in,

    input        reg_a_load,
    input        reg_b_load,
    input        reg_c_load,
    input        flag_z_load,
    input        flag_eq_load,

    output [7:0] reg_a_out,
    output [7:0] reg_b_out,
    output [7:0] reg_c_out,

    output reg   zero_flag,
    output reg   equal_flag,

    output [7:0] alu_result_out
);

    wire [7:0] alu_result;
    wire       alu_zero_flag;
    wire       alu_equal_flag;

    // Register A stores the first operand.
    register_8bit reg_a (
        .clk(clk),
        .reset(reset),
        .load(reg_a_load),
        .data_in(data_in),

        .data_out(reg_a_out)
    );

    // Register B stores the second operand.
    register_8bit reg_b (
        .clk(clk),
        .reset(reset),
        .load(reg_b_load),
        .data_in(data_in),

        .data_out(reg_b_out)
    );

    // Register C stores the selected ALU result.
    register_8bit reg_c (
        .clk(clk),
        .reset(reset),
        .load(reg_c_load),
        .data_in(alu_result),

        .data_out(reg_c_out)
    );

    // The ALU receives Register A and Register B as operands.
    alu alu_unit (
        .opcode(opcode),
        .A_in(reg_a_out),
        .B_in(reg_b_out),

        .alu_result(alu_result),
        .zero_flag(alu_zero_flag),
        .equal_flag(alu_equal_flag)
    );

    // Expose the ALU result for testing and waveform inspection.
    assign alu_result_out = alu_result;

    // The flag register stores the Zero and Equal flags.
    // reset clears both flags.
    // flag_z_load controls when the Zero Flag is updated.
    // flag_eq_load controls when the Equal Flag is updated.
    always @(posedge clk) begin
        if (reset) begin
            zero_flag  <= 1'b0;
            equal_flag <= 1'b0;
        end
        else begin
            if (flag_z_load) begin
                zero_flag <= alu_zero_flag;
            end

            if (flag_eq_load) begin
                equal_flag <= alu_equal_flag;
            end
        end
    end

endmodule