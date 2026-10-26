
/*
# Team ID:          2604
# Theme:            Logic Quest
# Author List:      Anirudh, Advait, Aman
# Filename:         branching_unit.v
# File Description: compares execute stage operands to determine whether a conditional branch is taken
# Global variables: funct3, SrcA, SrcB, Branch
*/

// branching_unit.v - logic for branching in execute stage

module branching_unit (
    // funct3: branch comparison type
    input [2:0] funct3,
    // SrcA: first forwarded operand used for branch comparison
    // SrcB: second forwarded operand used for branch comparison
    input [31:0] SrcA, SrcB,
    // Branch: indicates whether the selected branch condition is true
    output reg   Branch
);

always @(*) begin
    /*
    Purpose:
    ---
    compares the forwarded execute stage operands according to the branch instruction type
    */

    case (funct3)
        3'b000: Branch = (SrcA == SrcB); // beq
        3'b001: Branch = (SrcA != SrcB); // bne
        3'b100: Branch = ($signed(SrcA) < $signed(SrcB)); // blt
        3'b101: Branch = !($signed(SrcA) < $signed(SrcB)); // bge
        3'b110: Branch = (SrcA < SrcB); // bltu
        3'b111: Branch = !(SrcA < SrcB); // bgeu
        default: Branch = 1'b0;
    endcase
end

endmodule
