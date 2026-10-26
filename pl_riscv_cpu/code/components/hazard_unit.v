/*
# Team ID:          2604
# Theme:            Logic Quest
# Author List:      Anirudh, Advait, Aman
# Filename:         hazard_unit.v
# File Description: gives hazard control signal. decides whether forwarding, stalling or flushing is required for each stage of the pipeline
# Global variables: Rs1D, Rs2D, Rs1E, Rs2E, RdE, RdM, RdW, RegWriteM, RegWriteW, ResultSrcE, PCSrcE, ForwardAE, ForwardBE, StallF, StallD, FlushD, FlushE, loadUseStall
*/

// hazard_unit.v - forwarding, stall, and flush control

module hazard_unit (
    // Rs1D: first source register used by decode stage instruction
    // Rs2D: second source register used by decode stage instruction
    input  [4:0] Rs1D, Rs2D,
    // Rs1E: first source register used by execute stage instruction
    // Rs2E: second source register used by execute stage instruction
    // RdE: destination register of execute stage instruction
    input  [4:0] Rs1E, Rs2E, RdE,
    // RdM: destination register of memory stage instruction
    // RdW: destination register of writeback stage instruction
    input  [4:0] RdM, RdW,
    // RegWriteM: enables register writeback for memory stage instruction
    // RegWriteW: enables register writeback for writeback stage instruction
    input        RegWriteM, RegWriteW,
    // ResultSrcE: selects the result source for execute stage instruction
    input  [1:0] ResultSrcE,
    // PCSrcE: indicates that a branch or jump changes the program counter
    input        PCSrcE,
    // ForwardAE: selects the source of the first execute stage operand
    // ForwardBE: selects the source of the second execute stage operand
    output reg [1:0] ForwardAE, ForwardBE,
    // StallF: holds the fetch stage program counter during a hazard
    // StallD: holds the decode stage instruction during a hazard
    // FlushD: clears the decode stage after a branch or jump
    // FlushE: clears the execute stage after a hazard or control transfer
    output       StallF, StallD, FlushD, FlushE
);

// loadUseStall: active when a load-use dependency requires a one-cycle stall
wire loadUseStall;

always @(*) begin
    /*
    Purpose:
    ---
    generates forwarding selections and prioritises stalls or pipeline flushes when dependencies or control transfers occur
    */

    ForwardAE = 2'b00;
    ForwardBE = 2'b00;

    if (RegWriteM && (RdM != 5'd0) && (Rs1E == RdM))
        ForwardAE = 2'b10;
    else if (RegWriteW && (RdW != 5'd0) && (Rs1E == RdW))
        ForwardAE = 2'b01;

    if (RegWriteM && (RdM != 5'd0) && (Rs2E == RdM))
        ForwardBE = 2'b10;
    else if (RegWriteW && (RdW != 5'd0) && (Rs2E == RdW))
        ForwardBE = 2'b01;
end

assign loadUseStall = (ResultSrcE == 2'b01) &&
                      (RdE != 5'd0) &&
                      ((Rs1D == RdE) || (Rs2D == RdE));

assign StallF = loadUseStall;
assign StallD = loadUseStall;
assign FlushD = PCSrcE;
assign FlushE = loadUseStall | PCSrcE;

endmodule
