// src/program_counter.v
//
// Program Counter Module
//
// Function:
//   Stores the current instruction memory address.
//   The Program Counter can be reset to 0 or incremented by 1.
//
// Use:
//   This module points to the instruction currently being fetched
//   from instruction memory during CPU execution.


/**
 * @file program_counter.v
 * @brief Program Counter module for the simple CPU.
 *
 * This module stores the current instruction address used to access
 * instruction memory.
 *
 * The reset signal clears the Program Counter to 0000.
 * The increment signal advances the Program Counter to the next instruction.
 *
 * This CPU uses a 4-bit Program Counter, allowing up to 16 instruction
 * memory addresses from 0 to 15.
 */

`timescale 1ns / 1ps

module program_counter (
    input        clk,
    input        reset,
    input        pc_reset,
    input        pc_increment,

    output reg [3:0] pc_out
);

    // The Program Counter updates only on the rising edge of the clock.
    // reset has the highest priority, followed by pc_reset, then increment.
    always @(posedge clk) begin
        if (reset) begin
            pc_out <= 4'b0000;
        end
        else if (pc_reset) begin
            pc_out <= 4'b0000;
        end
        else if (pc_increment) begin
            pc_out <= pc_out + 1'b1;
        end
        else begin
            pc_out <= pc_out;
        end
    end

endmodule