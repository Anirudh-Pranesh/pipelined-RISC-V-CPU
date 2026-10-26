
/*
# Team ID:          2604
# Theme:            Logic Quest
# Author List:      Anirudh, Advait, Aman
# Filename:         main_decoder.v
# File Description: decodes the instruction opcode to generate the main datapath control signals
# Global variables: controls
*/

// main_decoder.v - logic for main decoder

module main_decoder (
    // op: instruction opcode
    input  [6:0] op,
    // funct3: instruction function field supplied by the controller
    input  [2:0] funct3,
    // ResultSrc: selects the value written back to the register file
    output [1:0] ResultSrc,
    // MemWrite: enables a memory write for store instructions
    // Branch: enables conditional branch control
    // ALUSrc: selects register or immediate input for the second ALU operand
    output       MemWrite, Branch, ALUSrc,
    // RegWrite: enables register file writeback
    // Jump: indicates JAL instruction control flow
    // Jalr: indicates JALR instruction control flow
    output       RegWrite, Jump, Jalr,
    // ImmSrc: selects the immediate format for extension
    output [1:0] ImmSrc,
    // ALUOp: identifies the instruction type for the ALU decoder
    output [1:0] ALUOp
);

// controls: packed control word used to drive the main datapath control signals
reg [11:0] controls;

always @(*) begin
    /*
    Purpose:
    ---
    selects the control signal values required for the decoded instruction opcode
    */

    casez (op)
        // RegWrite_ImmSrc_ALUSrc_MemWrite_ResultSrc_ALUOp_Jump_Jalr_Branch
        7'b0000011: controls = 12'b1_00_1_0_01_00_0_0_0; // lw
        7'b0100011: controls = 12'b0_01_1_1_00_00_0_0_0; // sw
        7'b0110011: controls = 12'b1_xx_0_0_00_10_0_0_0; // R–type
        7'b1100011: begin // branch
            controls = 12'b0_10_0_0_00_01_0_0_1;
        end
        7'b0010011: controls = 12'b1_00_1_0_00_10_0_0_0; // I–type ALU
        7'b1101111: controls = 12'b1_11_0_0_10_00_1_0_0; // jal
        7'b1100111: controls = 12'b1_00_1_0_10_00_0_1_0; // jalr
        7'b0?10111: controls = 12'b1_xx_x_0_11_xx_0_0_0; // lui or auipc
        default:    controls = 12'b0_00_0_0_00_00_0_0_0; // ???
    endcase
end

assign {RegWrite, ImmSrc, ALUSrc, MemWrite, ResultSrc, ALUOp, Jump, Jalr, Branch} = controls;

endmodule
