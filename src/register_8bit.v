// src/register_8bit.v
//
// 8-Bit Register Module
//
// Function:
//   Stores an 8-bit value when the load signal is asserted.
//   Clears the stored value when reset is asserted.
//
// Use:
//   This module can be reused for Register A, Register B, and Register C
//   in the simple CPU datapath.


/**
 * @file register_8bit.v
 * @brief Reusable 8-bit register module for the simple CPU.
 *
 * This module stores an 8-bit input value on the rising edge of the clock
 * when the load signal is active.
 *
 * The reset signal clears the register output to 00000000.
 *
 * In the CPU datapath, this module can be used for:
 *  - Register A
 *  - Register B
 *  - Register C
 */

`timescale 1ns / 1ps

module register_8bit (
    input        clk,
    input        reset,
    input        load,
    input  [7:0] data_in,

    output reg [7:0] data_out
);

    // The register updates only on the rising edge of the clock.
    // Reset has priority over loading new data.
    always @(posedge clk) begin
        if (reset) begin
            data_out <= 8'b00000000;
        end
        else if (load) begin
            data_out <= data_in;
        end
        else begin
            data_out <= data_out;
        end
    end

endmodule