/*
# Team ID:          2604
# Theme:            Logic Quest
# Author List:      Anirudh, Advait, Aman
# Filename:         alu_decoder.v
# File Description: decodes ALUOp, funct3, funct7 fields to generate the ALU control signal
# Global variables: ALUControl
*/

// alu_decoder.v - logic for ALU decoder

module alu_decoder (
    input            opb5,
    input [2:0]      funct3,
    input            funct7b5,
    input [1:0]      ALUOp,
    output reg [3:0] ALUControl
);

always @(*) begin
    /*
    Purpose:
    ---
    generates the 4 bit ALU control code for load/store, branch, r-type and i-type ALU instructions
    */

    case (ALUOp)
        2'b00: ALUControl = 4'b0000;             // addition
        2'b01: ALUControl = 4'b0001;             // subtraction
        default:
            case (funct3) // r-type or i-type ALU
                3'b000: begin
                    // true for r-type subtract
                    if   (funct7b5 & opb5) ALUControl = 4'b0001; //sub
                    else ALUControl = 4'b0000; // add, addi
                end
                3'b001:  ALUControl = 4'b0100;             // sll, slli (new)
                3'b010:  ALUControl = 4'b0101;             // slt, slti
                3'b011:  ALUControl = 4'b0110;             // sltu, sltiu (new)
                3'b100:  ALUControl = 4'b0111;             // xori, xor (new)
                3'b101:  ALUControl = funct7b5 ? 4'b1001   // sra, srai (new)
                                                : 4'b1000; // srl, srli (new)
                3'b110:  ALUControl = 4'b0011;             // or, ori
                3'b111:  ALUControl = 4'b0010;             // and, andi
                default: ALUControl = 4'bxxxx;             // ???
            endcase
    endcase
end

endmodule

