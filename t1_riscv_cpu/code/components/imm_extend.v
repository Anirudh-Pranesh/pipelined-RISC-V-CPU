/*
# Team ID:          2604
# Theme:            Logic Quest
# Author List:      Anirudh, Advait, Aman
# Filename:         imm_extend.v
# File Description: generates sign extended immediate values for i, s, b, j type instructions
# Global variables: immext
*/

// imm_extend.v - logic for sign extension
module imm_extend (
    input  [31:7]     instr,
    input  [ 1:0]     immsrc,
    output reg [31:0] immext
);

always @(*) begin
    /*
    Purpose:
    ---
    selects the instruction immediate format and sign extends it to 32 bits
    */

    case(immsrc)
        // i-type
        2'b00:   immext = {{20{instr[31]}}, instr[31:20]};
        // s-type (stores)
        2'b01:   immext = {{20{instr[31]}}, instr[31:25], instr[11:7]};
        // b-type (branches)
        2'b10:   immext = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};
        // j-type (jal)
        2'b11:   immext = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};
        default: immext = 32'bx; // undefined
    endcase
end

endmodule
