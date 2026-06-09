// src/instruction_memory.v
//
// Instruction Memory Module
//
// Function:
//   Stores the programmed sequence of 11-bit CPU instructions.
//   Each instruction is saved using the selected memory address.
//
// Instruction Format:
//   [10:8] = opcode
//   [7:0]  = operand/data
//
// Memory Size:
//   16 instructions
//   Address range: 0 to 15


/**
 * @file instruction_memory.v
 * @brief Instruction memory module for the simple CPU.
 *
 * This module stores 11-bit instructions before CPU execution.
 *
 * The memory uses a 4-bit address input, allowing up to 16 stored
 * instructions. Each instruction follows the format:
 *  - instruction[10:8] = opcode
 *  - instruction[7:0]  = operand/data
 *
 * The write_enable signal stores instruction_in into memory at the
 * selected address on the rising edge of the clock.
 *
 * The instruction_out output continuously shows the instruction stored
 * at the selected address.
 */

`timescale 1ns / 1ps

module instruction_memory (
    input         clk,
    input         reset,
    input         write_enable,
    input  [3:0]  address,
    input  [10:0] instruction_in,

    output [10:0] instruction_out
);

    reg [10:0] memory [15:0];

    integer i;

    // The instruction memory writes only on the rising edge of the clock.
    // Reset clears all memory locations to 00000000000.
    always @(posedge clk) begin
        if (reset) begin
            for (i = 0; i < 16; i = i + 1) begin
                memory[i] <= 11'b00000000000;
            end
        end
        else if (write_enable) begin
            memory[address] <= instruction_in;
        end
    end

    // The current instruction is read from the selected memory address.
    assign instruction_out = memory[address];

endmodule