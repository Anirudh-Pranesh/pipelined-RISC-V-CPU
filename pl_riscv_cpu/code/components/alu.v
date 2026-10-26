
/*
# Team ID:          2604
# Theme:            Logic Quest
# Author List:      Anirudh, Advait, Aman
# Filename:         alu.v
# File Description: performs arithmetic, logical, comparison and shift operations for the datapath
# Global variables: alu_out
*/

// alu.v - ALU module

module alu #(parameter WIDTH = 32) (
    // a: first ALU operand
    // b: second ALU operand
    input       [WIDTH-1:0] a, b,       // operands
    // alu_ctrl: operation selected by the controller
    input       [3:0] alu_ctrl,         // ALU control
    // alu_out: result produced by the selected operation
    output reg  [WIDTH-1:0] alu_out,    // ALU output
    // zero: high when the ALU result is zero
    output      zero                    // zero flag
);

always @(a, b, alu_ctrl) begin
    /*
    Purpose:
    ---
    performs the operation selected by alu_ctrl and produces the corresponding result
    */

    case (alu_ctrl)
        4'b0000:  alu_out <= a + b;                 // ADD
        4'b0001:  alu_out <= a + ~b + 1;            // SUB
        4'b0010:  alu_out <= a & b;                 // AND
        4'b0011:  alu_out <= a | b;                 // OR
        4'b0100:  alu_out <= a << b[4:0];           // SLL, SLLI
        4'b0110:  alu_out <= (a < b) ? 1 : 0;       // SLTU, SLTIU
        4'b0111:  alu_out <= a ^ b;                 // XOR, XORI
        4'b1000:  alu_out <= a >> b[4:0];           // SRL, SRLI
        4'b1001:  alu_out <= $signed(a) >>> b[4:0]; // SRA, SRAI
        4'b0101:  begin                             // SLT, SLTI
                     if (a[31] != b[31]) alu_out <= a[31] ? 1 : 0;
                     else alu_out <= a < b ? 1 : 0;
                 end
        default: alu_out = 0;
    endcase
end

assign zero = (alu_out == 0) ? 1'b1 : 1'b0;

endmodule

