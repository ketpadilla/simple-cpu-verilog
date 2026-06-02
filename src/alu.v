// src/alu.v
//
// Arithmetic Logic Unit Module
//
// Function:
//   Performs the arithmetic, logical, and comparison operations
//   for the simple 8-bit CPU.
//
// Supported ALU Operations:
//   ADD : C = A + B
//   SUB : C = A - B
//   AND : C = A & B
//   CMP : If A == B, result = 00000001; else result = 00000000
//
// Flags:
//   Z  : Set to 1 when the ALU result is zero.
//   EQ : Set to 1 when A and B are equal during CMP.


/**
 * @file alu.v
 * @brief Arithmetic Logic Unit for the simple 8-bit CPU.
 *
 * This module receives Register A, Register B, and the decoded opcode.
 * It performs the selected ALU operation and produces an 8-bit result.
 *
 * The ALU supports:
 *  - ADD for addition
 *  - SUB for subtraction
 *  - AND for bitwise AND
 *  - CMP for comparison
 *
 * The zero flag is set when the result is zero.
 * The equal flag is set only during CMP when Register A equals Register B.
 */

`timescale 1ns / 1ps

module alu (
    input  [2:0] opcode,
    input  [7:0] A_in,
    input  [7:0] B_in,

    output reg [7:0] alu_result,
    output reg       zero_flag,
    output reg       equal_flag
);

    // Opcode definitions based on the 6-instruction ISA.
    parameter LDA = 3'b000;
    parameter LDB = 3'b001;
    parameter ADD = 3'b010;
    parameter SUB = 3'b011;
    parameter AND = 3'b100;
    parameter CMP = 3'b101;

    // The reserved opcodes are treated as no operation.
    parameter NOP1 = 3'b110;
    parameter NOP2 = 3'b111;

    always @(*) begin
        // Default values prevent unwanted latch behavior.
        alu_result = 8'b00000000;
        zero_flag  = 1'b0;
        equal_flag = 1'b0;

        case (opcode)
            ADD: begin
                alu_result = A_in + B_in;
            end

            SUB: begin
                alu_result = A_in - B_in;
            end

            AND: begin
                alu_result = A_in & B_in;
            end

            CMP: begin
                if (A_in == B_in) begin
                    alu_result = 8'b00000001;
                    equal_flag = 1'b1;
                end
                else begin
                    alu_result = 8'b00000000;
                    equal_flag = 1'b0;
                end
            end

            LDA: begin
                alu_result = 8'b00000000;
            end

            LDB: begin
                alu_result = 8'b00000000;
            end

            NOP1: begin
                alu_result = 8'b00000000;
            end

            NOP2: begin
                alu_result = 8'b00000000;
            end

            default: begin
                alu_result = 8'b00000000;
            end
        endcase

        // The zero flag checks the final ALU result.
        if (alu_result == 8'b00000000)
            zero_flag = 1'b1;
        else
            zero_flag = 1'b0;
    end

endmodule