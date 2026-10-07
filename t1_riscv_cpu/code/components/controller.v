/*
# Team ID:          2604
# Theme:            Logic Quest
# Author List:      Anirudh, Advait, Aman
# Filename:         controller.v
# File Description: connects the main decoder and ALU decoder to generate cpu control signals
# Global variables: PCSrc, ALUControl
*/

// controller.v - controller for cpu

module controller (
    input [6:0]  op,
    input [2:0]  funct3,
    input        funct7b5,
    input        Zero,
    output       [1:0] ResultSrc,
    output       MemWrite,
    output       PCSrc, ALUSrc,
    output       RegWrite, Jump, Jalr,
    output [1:0] ImmSrc,
    output [3:0] ALUControl
);

// ALUOp: main decoder output used by the ALU decoder to select instruction type
wire [1:0] ALUOp;
// Branch: enables conditional branch PC selection when the datapath condition is true
wire       Branch;

main_decoder    md (op, ResultSrc, MemWrite, Branch,
                    ALUSrc, RegWrite, Jump, Jalr, ImmSrc, ALUOp);

alu_decoder     ad (op[5], funct3, funct7b5, ALUOp, ALUControl);

// for jump and branch
assign PCSrc = (Branch & Zero) | Jump;

endmodule

