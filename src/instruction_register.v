// src/instruction_register.v
//
// Instruction Register Module
//
// Function:
//   Stores the currently fetched 11-bit instruction from instruction memory.
//   The stored instruction is separated into opcode and operand/data fields.
//
// Instruction Format:
//   [10:8] = opcode
//   [7:0]  = operand/data


/**
 * @file instruction_register.v
 * @brief Instruction register module for the simple CPU.
 *
 * This module stores the current 11-bit instruction on the rising edge
 * of the clock when the load signal is active.
 *
 * The instruction format is:
 *  - instruction_out[10:8] = opcode
 *  - instruction_out[7:0]  = operand/data
 *
 * The reset signal clears the instruction register to 00000000000.
 */

`timescale 1ns / 1ps

module instruction_register (
    input         clk,
    input         reset,
    input         load,
    input  [10:0] instruction_in,

    output reg [10:0] instruction_out,
    output     [2:0]  opcode_out,
    output     [7:0]  operand_out
);

    // The instruction register updates only on the rising edge of the clock.
    // Reset has priority over loading a new instruction.
    always @(posedge clk) begin
        if (reset) begin
            instruction_out <= 11'b00000000000;
        end
        else if (load) begin
            instruction_out <= instruction_in;
        end
        else begin
            instruction_out <= instruction_out;
        end
    end

    // These continuous assignments separate the instruction fields.
    assign opcode_out  = instruction_out[10:8];
    assign operand_out = instruction_out[7:0];

endmodule