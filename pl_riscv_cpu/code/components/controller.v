
/*
# Team ID:          2604
# Theme:            Logic Quest
# Author List:      Anirudh, Advait, Aman
# Filename:         controller.v
# File Description: connects the main decoder and ALU decoder to generate cpu control signals
# Global variables: ALUOp, ALUControl
*/

// controller.v - controller for RISC-V CPU

module controller (
    // op: instruction opcode
    input [6:0]  op,
    // funct3: instruction function field
    input [2:0]  funct3,
    // funct7b5: funct7 bit used by the ALU decoder
    input        funct7b5,
    // ResultSrc: selects the value written back to the register file
    output       [1:0] ResultSrc,
    // MemWrite: enables a memory write for store instructions
    output       MemWrite,
    // ALUSrc: selects register or immediate input for the second ALU operand
    output       ALUSrc,
    // RegWrite: enables register file writeback
    // Branch: enables conditional branch control
    // Jump: indicates JAL instruction control flow
    // Jalr: indicates JALR instruction control flow
    output       RegWrite, Branch, Jump, Jalr,
    // ImmSrc: selects the immediate format for extension
    output [1:0] ImmSrc,
    // ALUControl: encoded control signal selecting the ALU operation
    output [3:0] ALUControl
);

wire [1:0] ALUOp;

main_decoder    md (op, funct3, ResultSrc, MemWrite, Branch,
                    ALUSrc, RegWrite, Jump, Jalr, ImmSrc, ALUOp);

alu_decoder     ad (op[5], funct3, funct7b5, ALUOp, ALUControl);

endmodule
